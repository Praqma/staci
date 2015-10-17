# Create a VirtualBox host with specified specs.
docker-machine create -d virtualbox --virtualbox-boot2docker-url https://github.com/boot2docker/boot2docker/releases/download/v1.8.1/boot2docker.iso --virtualbox-memory 3515 --virtualbox-cpu-count "1" atlassian

# Set env, DOCKER_HOST
eval $(docker-machine env atlassian)

# Create folders on the system for data
docker-machine ssh atlassian "sudo mkdir -p /data/atlassian/jira"
docker-machine ssh atlassian "sudo chown -R docker /data"
docker-machine ssh atlassian "sudo chmod -R g+rwx /data"
docker-machine ssh atlassian "mkdir -p /data/atlassian/confluence"
docker-machine ssh atlassian "mkdir -p /data/atlassian/bamboo"
docker-machine ssh atlassian "mkdir -p /data/atlassian/backup"
docker-machine ssh atlassian "mkdir -p /data/atlassian/atlassiandb"
