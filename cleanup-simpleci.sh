#!/bin/bash
echo "Removing stopped containers and removing images forcefully having 'none/simpleci' in their name ..."
docker stop $(docker ps -q)
docker rm $(docker ps -aq)
docker rmi -f $(docker images | egrep "none|^simpleci|^staci" | awk '{print $3}' )
