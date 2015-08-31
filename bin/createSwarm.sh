# This script creates a Swarm on a local VirtualBox
# Still in Beta...

swarmId=$(docker run swarm create)

echo "swarmId = $swarmId"

docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-master \
    --swarm-discovery token://$swarmId \
    --virtualbox-memory 2000 \
    staci-jira &

docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-discovery token://$swarmId \
    --virtualbox-memory 3000 \
    staci-confluence &

docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-discovery token://$swarmId \
    --virtualbox-memory 1500 \
    staci-bamboo &

docker-machine create \
    -d virtualbox \
    --swarm \
    --swarm-discovery token://$swarmId \
    --virtualbox-memory 512 \
    staci-atlassiandb &

wait

sleep 15

eval $(docker-machine env --swarm staci-jira)
docker info
