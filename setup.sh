#!/bin/bash

CI_HOME=$(pwd)
source haproxy_ssl_setup.f

# Set ownership of directories and files
user_id=1000
group_id=1000

#Download tar balls for Atlassian products

if [ ! -f images/jira/atlassian-jira-software-7.3.1.tar.gz ]; then
	echo "####### Downloading jira ########"
	echo
	wget -q "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-7.3.1.tar.gz" -O images/jira/atlassian-jira-software-7.3.1.tar.gz
fi
echo -e "Skipping Jira download\; tarball is available locally\n"

if [ ! -f images/jira/mysql-connector-java-5.1.36.tar.gz ]; then 
	 echo "####### Downloading mysql connector  ########"
	wget -q "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.36.tar.gz" -O images/jira/mysql-connector-java-5.1.36.tar.gz
fi
echo -e "Skipping mysql connector  download\; tarball is available in jira image dir\n"

if [ ! -f images/crucible/crucible-4.2.0.zip ]; then
	echo "####### Downloading Crucible ########"
	echo
	wget -q "https://www.atlassian.com/software/crucible/downloads/binary/crucible-4.2.0.zip" -O images/crucible/crucible-4.2.0.zip
fi
echo -e "Skipping crucible  download\; tarball is available locally\n"

if [ ! -f images/crucible/mysql-connector-java-5.1.36.tar.gz ]; then
	cp images/jira/mysql-connector-java-5.1.36.tar.gz images/crucible/mysql-connector-java-5.1.36.tar.gz
fi
if [ ! -f images/bitbucket/atlassian-bitbucket-4.10.1.tar.gz ]; then
	wget -q "https://www.atlassian.com/software/stash/downloads/binary/atlassian-bitbucket-4.10.1.tar.gz" -O images/bitbucket/atlassian-bitbucket-4.10.1.tar.gz
fi
if [ ! -f images/bitbucket/mysql-connector-java-5.1.36.tar.gz ]; then
        cp images/jira/mysql-connector-java-5.1.36.tar.gz images/bitbucket/mysql-connector-java-5.1.36.tar.gz
fi

#Create volume directories for persistent data storage
if [ !  -d "$CI_HOME/logs" ]; then
        sudo mkdir $CI_HOME/logs
	chown -R 1000:1000 $CI_HOME/logs
fi

if [ !  -d "/opt/simple_ci/" ]; then
	sudo mkdir /opt/simple_ci
fi

for service in haproxy jira crucible bitbucket artifactory jenkins; do
	if [  ! -d "/opt/simple_ci/$service" ]; then
		sudo mkdir /opt/simple_ci/$service
		if [ $service == "artifactory" ]; then
			sudo mkdir /opt/simple_ci/$service/backup /opt/simple_ci/$service/data /opt/simple_ci/$service/logs
			
		fi
	fi
done
chown -R 1000:1000 /opt/simple_ci

# Generate SSL certificates for haproxy

setupHaproxySSLcrt  > /dev/null 2>&1

# build java base image for jira, crucible, bitbucket
image_check=$(docker images | grep praqma/java)
if [ -z "$image_check" ]; then
	echo "###### building the base image ########"
	echo
	docker build -t "praqma/java_8"  $CI_HOME/images/base/. >> $CI_HOME/logs/base.log 2>&1  
fi


wait

echo "####### Spinning up the stack database ########"
echo


docker-compose up -d atlassiandb > $CI_HOME/logs/docker-compose.atlassiandb.log 2>&1

  
 # Wait for MySql to start up
echo
echo "####### waiting for MySQL to start ########"
echo 
status=$(docker inspect -f {{.State.Running}} atlassiandb 2>&1)

if [ "$status" == "true" ];then
   echo "  # Container mysql is active, waiting to be ready"
   attempt=0
   while [ $attempt -le 59 ]; do
      attempt=$(( $attempt + 1 ))
      result=$(docker logs atlassiandb 2>&1)
      if grep -q 'MySQL init process done. Ready for start up.' <<< $result ; then
         echo "   # MySQL is starting up!"
         echo
         break
         fi
         sleep .5
   done

   attempt=0
   while [ $attempt -le 59 ]; do
      attempt=$(( $attempt + 1 ))
      result=$(docker logs --tail=10 atlassiandb 2>&1)
      if grep -q 'ready for connections' <<< $result ; then
         echo "   # MySQL is up!"
         break
      fi
      sleep .5
   done
   else
      echo "Container mysql is not running..."
      exit 0
fi

# Setup database
echo
echo "######## setting up database #######"
sleep 1
./init-mysql.sh

echo
echo "######## spinning up the rest of the stack ########"
echo
docker-compose up -d >> $CI_HOME/logs/docker-compose.log 2>&1

echo " >>>>>>>>>>>>>>>> Installation Complete! <<<<<<<<<<<<<<<<<"






