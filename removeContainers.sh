#! /bin/bash
# Sourcing env setup
source setEnv.sh
source $STACI_HOME/functions/tools.f

# Find out, if we are using a cluster or not
cluster=$(getProperty "createCluster")

if [ "$cluster" == 1 ]; then
   eval $(docker-machine env --swarm praqma-mysql)
fi

# we stop all containers
docker-compose -f compose/docker-compose.yml rm 
