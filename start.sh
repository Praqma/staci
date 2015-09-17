#! /bin/bash

# Set env
source setEnv.sh

# Build containers
./bin/build-all.sh

# Generate compose file
./bin/generateCompose.sh > ./compose/docker-compose.yml

# we start all containers
docker-compose -f ./compose/docker-compose.yml start
