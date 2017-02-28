#!/bin/bash
set -e
set -x
if [ "${1}x" == "x" ]; then
#  echo "Parameter 1 is empty - please specify '$USER' as a parameter" 
  exit 1
fi
export para_user=$1

sudo apt-get update || exit 1 
sudo apt-get install -y apt-transport-https ca-certificates || exit 2 
sudo apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 58118E89F3A912897C070ADBF76221572C52609D || exit 3

sudo echo "deb https://apt.dockerproject.org/repo ubuntu-xenial main" > /etc/apt/sources.list.d/docker.list || exit 4 
sudo apt-get update || exit 5 
sudo apt-get purge -y lxc-docker || exit 6 
apt-cache policy docker-engine
sudo apt-get update
sudo apt-get install -y linux-image-extra-$(uname -r) linux-image-extra-virtual
sudo apt-get install -y docker-engine
sudo service docker start

sudo groupadd --force docker
sudo usermod -aG docker $para_user 

sudo apt-get install -y curl
sudo curl -L https://github.com/docker/compose/releases/download/1.8.0/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose 
sudo chmod +x /usr/local/bin/docker-compose
docker-compose --version

sudo curl -L https://github.com/docker/machine/releases/download/v0.8.0/docker-machine-`uname -s`-`uname -m` > /usr/local/bin/docker-machine
sudo chmod +x /usr/local/bin/docker-machine
docker-machine --version

mkdir -p /data/atlassian
chmod -R 777 /data
chown -R $para_user /data
chgrp -R $para_user /data
ls -la /data
