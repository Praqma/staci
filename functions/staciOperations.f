function setMachineEnv(){
  # This function cannot be used by installStaci as it takes arguments, 
  # not properties.
  # Find out, if we are using a cluster or not

  local create_cluster=$(getProperty "createCluster")
  local node_prefix=$(getProperty "clusterNodePrefix")
  local provider_type=$(getProperty "provider_type")

  if [ "$create_cluster" == 1 ]; then
    eval $(docker-machine env --swarm $node_prefix-mysql)
  elif [ ! "$provider_type" == "none" ];then
    eval $(docker-machine env $node_prefix-Atlassian)
  fi
}

function deleteStaci(){
  # Set docker-machine to point to the active host
  setMachineEnv

  # we delete all containers
  docker-compose -f compose/docker-compose.yml rm -f
}

function stopStaci(){
  # Set docker-machine to point to the active host
  setMachineEnv

  # We write docker-compose log to file logs/compose.log
  echo "Writting log output to logs/compose.log"
  docker-compose -f ./compose/docker-compose.yml logs > logs/compose.log &

  # we stop all containers
  docker-compose -f ./compose/docker-compose.yml stop
}

function startStaci(){
  # Set docker-machine to point to the active host
  setMachineEnv

  # we start all containers
  docker-compose -f ./compose/docker-compose.yml start
}

function installStaciInteractive() {
  create_cluster=0 # Not an option
  if [ $(uname) == "Darwin" ]; then
    echo OS looks like Mac OS X. Using VirtualBox provider
    provider_type="virtualbox"
  else
    echo OS looks like Linux. Running locally
    provider_type="none"
  fi
  installStaci $create_cluster $provider_type
}

function installStaciUsingProperties() {
  create_cluster=$(getProperty "createCluster")
  provider_type=$(getProperty "provider_type")
  installStaci $create_cluster $provider_type
}

function installStaci() {
  create_cluster=$1
  provider_type=$2

  if [ "$provider_type" == "none" ]; then
    # Show directory for data
    volume_dir=$(getProperty "volume_dir")
    echo " - Using $volume_dir for persistence"

    # Show backup folder
    backup_folder=$(getProperty "backup_folder")
    echo " - Using $backup_folder for backup"
  fi

  # Create needed directories
  if [ ! -d "compose" ]; then
    mkdir -p compose
  fi

  if [ ! -d "$DIRECTORY" ]; then
    mkdir -p logs
  fi


  # WE force use UID and GID to be 1000, as all the containers expect that.
  USERID=1000
  GROUPID=1000

  # Create folders for persistent container data, if not existing
  # But only if run locally
  # if [ ! -d "$volume_dir" ] && [ "$provider_type" == "none" ]; then
  if [ "$provider_type" == "none" ]; then
   # Assuming that provider type is none, run a loop:  

    if [ ! -d "$volume_dir" ] ; then
      sudo mkdir -p $volume_dir
      sudo chown $USERID:$GROUPID $volume_dir 
    fi

    # Add more directories to the list below, if needed
    for dir in jira confluence bamboo atlassiandb bitbucket crowd crucible jenkins artifactory haproxy; do 
      echo "Checking directory ${volume_dir}/${dir} ..."
      if [ ! -d ${volume_dir}/${dir} ] ; then
        sudo mkdir -p ${volume_dir}/${dir}
        sudo chown $USERID:$GROUPID  ${volume_dir}/${dir}

        # Jenkins and artifactory have a requirement to have other subdirectories too
        if [ "${dir}" == "jenkins" ] ; then
          sudo mkdir -p ${volume_dir}/${dir}/jenkins_home
          sudo chown $USERID:$GROUPID  ${volume_dir}/${dir} -R 
        fi

        if [ "${dir}" == "artifactory" ] ; then
          sudo mkdir -p ${volume_dir}/${dir}/{backup,data,logs}
          sudo chown $USERID:$GROUPID  ${volume_dir}/${dir} -R
        fi
      fi
     
    done 
  fi

  if [ "$create_cluster" == 1 ]; then
     source functions/dockermachine.f
     createSwarm
  else
    if [ ! "$provider_type" == "none" ];then
      source functions/dockermachine.f
      createSingleHost
    fi
  fi

  echo " - Autosetup preparing"
   setJiraDatabaseConnection > $STACI_HOME/images/jira/context/dbconfig.xml

  
  #Prepare HAProxy settings and files
  source functions/haproxy_ssl_setup.f
  setupHaproxySSLcrt
  
  ./bin/generate_haproxy_cfg.sh > ./images/haproxy/context/haproxy.cfg 

  echo " - Building images"
  buildAll

  # Generate a new compose yml, and put it in the compose folder
  echo -n " - Generating docker-compose.yml - "
  ./bin/generateCompose.sh > ./compose/docker-compose.yml
  if [ $? -ne 0 ]; then
     echo "ERROR"
  else
     echo "OK"
  fi


  echo " - Starting Database, using docker-compose"

  if [ "$create_cluster" == 1 ]; then
    node_prefix=$(getProperty "clusterNodePrefix")
    eval $(docker-machine env --swarm $node_prefix-mysql)
  else
    if [ ! "$provider_type" == "none" ];then
      node_prefix=$(getProperty "clusterNodePrefix")
      eval $(docker-machine env $node_prefix-Atlassian)
    fi
  fi

  # Starting docker containers
  docker-compose -f compose/docker-compose.yml up -d atlassiandb > $STACI_HOME/logs/docker-compose.atlassiandb.log 2>&1 

  start_mysql=$(getProperty "start_mysql")
  if [ ! -z $start_mysql ];then
    # Wait for MySql to start up
    status=$(docker inspect -f {{.State.Running}} atlassiandb 2>&1)

    if [ "$status" == "true" ];then
      echo "  # Container mysql is active, waiting to be ready"
      attempt=0
      while [ $attempt -le 59 ]; do
        attempt=$(( $attempt + 1 ))
        result=$(docker logs atlassiandb 2>&1)
        if grep -q 'MySQL init process done. Ready for start up.' <<< $result ; then
          echo "   # MySQL is starting up!"
          break
        fi
        sleep .5
      done

      attempt=0
      while [ $attempt -le 59 ]; do
        attempt=$(( $attempt + 1 ))
        result=$(docker logs --tail=10 atlassiandb 2>&1)
        if grep -q 'ready for connections' <<< $result ; then
          echo "   # MySQL is up!"
          break
        fi
        sleep .5
      done
    else
      echo "Container mysql is not running..."
      exit 0
    fi

    # Setup database
    sleep 1
    ./bin/init-mysql.sh
  fi

  echo " - Starting Atlassian stack, using docker-compose"
  docker-compose -f compose/docker-compose.yml up -d > $STACI_HOME/logs/docker-compose.log 2>&1

  sleep 10

  # Setupjira from backup or blanc.
  setupJira 

  echo "Generating system info page ..."
  sleep 2
  # Generate System Information html
  source  ./bin/generateSystemInfo.sh > $STACI_HOME/SystemInfo.html

  echo "Install complete"
  echo "Open ${STACI_HOME}/SystemInfo.html in a browser to continue using the tool stack"

  # Open tools and System Information websites
  use_browser=$(getProperty "use_browser")
  if [ "$use_browser" == "1" ]; then
    browser_cmd=$(getProperty "browser_cmd")
    $browser_cmd "$STACI_HOME/SystemInfo.html" &>/dev/null &
  fi

}
