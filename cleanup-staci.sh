#!/bin/bash
echo "Removing stopped containers and removing images forcefully having 'none/staci' in their name ..."
docker rm $(docker ps -aq)
docker rmi $(docker images | egrep "none|^staci/" | awk '{print $3}' )
