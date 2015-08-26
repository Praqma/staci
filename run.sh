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
#  Starting STACI - Support, Ticketing and Continous Integration.              #
#                                                                              #
#  - If you need to build images, use ./bin/build-all.sh                       #
#  - If you need to push images to docker hub, use ./bin/push-to-dockerhub.sh  #
#                                                                              #
##                                                                            ##
"

# Sourcing env setup
source setEnv.sh
source $STACI_HOME/functions/tools.f

# Find location for persistant container data
volume_dir=$(getProperty "volume_dir")
echo " - Using $volume_dir for persistance"

# Create folders for persistant container data, if not existing
if [ ! -d "$volume_dir" ]; then
  mkdir "$volume_dir"
  mkdir "$volume_dir/jira"
  mkdir "$volume_dir/confluence"
  mkdir "$volume_dir/bamboo"
  mkdir "$volume_dir/atlassiandb"
  echo " - Created $volume_dir folder."
fi

# Find out, if we should create a cluster or not
cluster=$(getProperty "createCluster")

echo "Building images"
./bin/build-all.sh

# Check if we have a DOCKER_HOST variable
if [ -z "$DOCKER_HOST" ] && [ "$cluster" == 0 ]; then
   echo " - Cant find a valid DOCKER_HOST variable, and cluster is OFF."
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

if [ "$cluster" == 1 ]; then
   echo " - Deploying on cluster"
fi 


# Generate a new compose yml, and put it in the compose folder
echo -n " - Generating docker-compose.yml - "
./bin/generateCompose.sh > ./compose/docker-compose.yml
if [ $? -ne 0 ]; then
   echo "ERROR"
else
   echo "OK"
fi


# Create a cluster, if needed
if [ "$cluster" == "1" ]; then
   echo -n " - Creating cluster to run STACI - "
   echo "Not implemented yet"
fi

# Start the containers with docker-compose
echo -n " - Starting containers, using docker-compose : "
docker-compose -f ./compose/docker-compose.yml up 
