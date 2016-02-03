##
#
# This script will generate a docker-compose yml file
# to ensure correct version being used, and then starts
# the containers.
#
##

# Printing welcome msg
echo "
##                                                                            ##
#                                                                              #
#  Starting STACI - Support Tracking and Continous Integration.                #
#                                                                              #
#  - If you need to build images, use ./bin/build-all.sh                       #
#  - If you need to push images to docker hub, use ./bin/push-to-dockerhub.sh  #
#      (You might want to implement it first)                                  #
##                                                                            ##
"

# Sourcing env setup
source setEnv.sh
source $STACI_HOME/functions/tools.f

# Find out, if we should create a cluster or not
cluster=$(getProperty "createCluster")
provider_type=$(getProperty "provider_type")

# Show directory for data
volume_dir=$(getProperty "volume_dir")
echo " - Using $volume_dir for persistance"

# Show backup folder
backup_folder=$(getProperty "backup_folder")
echo " - Using $backup_folder for backup"

# Create folders for persistant container data, if not existing
if [ ! -d "$volume_dir" ]; then
  mkdir "$volume_dir"
  mkdir "$volume_dir/jira"
  mkdir "$volume_dir/confluence"
  mkdir "$volume_dir/bamboo"
  mkdir "$volume_dir/atlassiandb"
  echo " - Created $volume_dir folder."
fi

# Check if we have a DOCKER_HOST variable
if [ -z "$DOCKER_HOST" ] && [ "$cluster" == 0 ]; then
   echo " - Can't find a valid DOCKER_HOST variable, and cluster is OFF."
   echo " - Exiting....
"
   exit
fi

if [ ! -z "$DOCKER_HOST" ] && [ "$cluster" == 1 ]; then
   echo " - Make up your mind ! unset DOCKER_HOST or turn cluster off."
   echo " - Exiting....
"
   exit
fi

if [ ! -z "$DOCKER_HOST" ]; then
   echo " - Deploying on $DOCKER_HOST"
fi

read -p "
 - Press [Enter] key to continue..."

if [ "$cluster" == 1 ]; then
   echo " - Deploying on cluster $provider_type"
   if [ "$provider_type" == "virtualbox" ];then
     source ./bin/createSwarm.sh
   fi
   if [ "$provider_type" == "openstack" ];then
     source ./bin/openstack.sh
   fi
fi

# Generate database configuration for Jira
# Only works with JDK 1.8+
#./bin/generate_jira_dbconfig.sh > $volume_dir/jira/dbconfig.xml

start_crucible=$(getProperty "start_crucible")
if [ "$start_crucible" == 1 ]; then
  ./bin/generate_crucible_config.sh > images/crucible/context/configure.sh
fi

echo "
 - Building images"
./bin/build-all.sh

# Generate a new compose yml, and put it in the compose folder
echo -n " - Generating docker-compose.yml - "
./bin/generateCompose.sh > ./compose/docker-compose.yml
if [ $? -ne 0 ]; then
   echo "ERROR"
else
   echo "OK"
fi

# Start the containers with docker-compose
echo -n " - Starting containers, using docker-compose :
"
docker-compose -f ./compose/docker-compose.yml up -d

# Generate System Information html
./bin/generateSystemInfo.sh > $STACI_HOME/SystemInfo.html

# Open tools and System Information websites
use_browser=$(getProperty "use_browser")
if [ "$use_browser" == "1" ]; then
  browser_cmd=$(getProperty "browser_cmd")
  $browser_cmd "$STACI_HOME/SystemInfo.html" &>/dev/null &
fi

start_mysql=$(getProperty "start_mysql")
if [ ! -z $start_mysql ];then
  # TODO: Need to wait for MySQL to start, before continuing, instead of sleep
  sleep 20

  # Setup database
  ./bin/init-mysql.sh
fi

echo '
 - To view log, exec "docker-compose log"
 - To stop, exec "./stop.sh"
 - To start again later, exec "./start.sh"

'
