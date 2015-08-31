#! /bin/bash

# we stop all containers
docker-compose -f ./compose/docker-compose.yml logs > logs/compose.log &
docker-compose -f ./compose/docker-compose.yml stop
