function deleteStaci(){
  # Find out, if we are using a cluster or not
  cluster=$(getProperty "createCluster")

  # Todo : does not do none cluster on provider
  if [ "$cluster" == 1 ]; then
    node_prefix=$(getProperty "clusterNodePrefix")
    eval $(docker-machine env --swarm $node_prefix-mysql)
  fi

  # we stop all containers
  docker-compose -f compose/docker-compose.yml rm
}

function stopStaci(){
  # Find out, if we are using a cluster or not
  local cluster=$(getProperty "createCluster")

  # Todo : does not do none cluster on provider
  if [ "$cluster" == 1 ]; then
    node_prefix=$(getProperty "clusterNodePrefix")
    eval $(docker-machine env --swarm $node_prefix-mysql)
  fi

  # We write docker-compose log to file logs/compose.log
  echo "Writting log output to logs/compose.log"
  docker-compose -f ./compose/docker-compose.yml logs > logs/compose.log &

  # we stop all containers
  docker-compose -f ./compose/docker-compose.yml stop

}

function startStaci(){

  # Find out, if we are using a cluster or not
  local cluster=$(getProperty "createCluster")

  # Todo : does not do none cluster on provider
  if [ "$cluster" == 1 ]; then
    node_prefix=$(getProperty "clusterNodePrefix")
    eval $(docker-machine env --swarm $node_prefix-mysql)
  fi

  # we start all containers
  docker-compose -f ./compose/docker-compose.yml start

}

function installStaciInteractive() {
  create_cluster=0 # Not an option
  installStaci $create_cluster
}

function installStaci() {
  create_cluster=$1

  provider_type=$(getProperty "provider_type")

  if [ "$provider_type" == "none" ]; then
    # Show directory for data
    volume_dir=$(getProperty "volume_dir")
    echo " - Using $volume_dir for persistance"

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

  # Create folders for persistent container data, if not existing
  # But only if run locally
  if [ ! -d "$volume_dir" ] && [ "$provider_type" == "none" ]; then
    mkdir -p "$volume_dir"
    mkdir -p "$volume_dir/jira"
    mkdir -p "$volume_dir/confluence"
    mkdir -p "$volume_dir/bamboo"
    mkdir -p "$volume_dir/atlassiandb"
    mkdir -p "$volume_dir/bitbucket"
    mkdir -p "$volume_dir/crowd"
    mkdir -p "$volume_dir/crucible"
    echo " - Created $volume_dir folder."
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

  echo "
 - Building images"
  buildAll

  # Generate a new compose yml, and put it in the compose folder
  echo -n " - Generating docker-compose.yml - "
  ./bin/generateCompose.sh > ./compose/docker-compose.yml
  if [ $? -ne 0 ]; then
     echo "ERROR"
  else
     echo "OK"
  fi


  echo " - Starting containers, using docker-compose"

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
  docker-compose -f compose/docker-compose.yml up -d > $STACI_HOME/logs/docker-compose.log 2>&1 &

  start_mysql=$(getProperty "start_mysql")
  if [ ! -z $start_mysql ];then
    # TODO: Need to wait for MySQL to start, before continuing, instead of sleep
    sleep 20

    # Setup database
    ./bin/init-mysql.sh
  fi

  # Generate System Information html
  ./bin/generateSystemInfo.sh > $STACI_HOME/SystemInfo.html

  # Open tools and System Information websites
  use_browser=$(getProperty "use_browser")
  if [ "$use_browser" == "1" ]; then
    browser_cmd=$(getProperty "browser_cmd")
    $browser_cmd "$STACI_HOME/SystemInfo.html" &>/dev/null &
  fi

}
