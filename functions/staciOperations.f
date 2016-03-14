function stopContainers(){
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

function startContainers(){

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
