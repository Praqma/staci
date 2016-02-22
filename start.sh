#! /bin/bash
# Sourcing env setup
source setEnv.sh
source $STACI_HOME/functions/tools.f

# Find out, if we are using a cluster or not
cluster=$(getProperty "createCluster")

if [ "$cluster" == 1 ]; then
  node_prefix=$(getProperty "clusterNodePrefix")
  eval $(docker-machine env --swarm $node_prefix-mysql)
fi

# we start all containers
docker-compose -f ./compose/docker-compose.yml start
