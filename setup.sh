#!/bin/bash

# Note: this script needs to run as root or as sudo.

ME=$(whoami)

if [ "${ME}" != "root" ] ; then
  echo "This script needs to run as root or using sudo. Exiting ..."
  exit 1
fi

########### START - USER DEFINED VARIABLES - ###############################
#
#

SETUP_DIR=$(pwd)
SETUP_DIR=${SETUP_DIR}
CONFIG_FILE=setup.conf

#
#
########### END - USER DEFINED VARIABLES - ################################

# Load some config variables from the setup.conf file.
if [ ! -r ${CONFIG_FILE} ] ; then
  echo "${CONFIG_FILE} is not found. Need to know the URLs for various software. Exiting ... "
  exit 1
else
  echo "Loading values for JIRA_URL , CRUCIBLE_URL, BITBUCKET_URL and MYSQL_CONNECTOR_URL ..."
  source {CONFIG_FILE}
fi

########### START - SYTEM DEFINED VARIABLES - #############################
#
#
# The command basename only returns the last (filename) portion of any long path / URL.  

JIRA_TARBALL=$(basename $JIRA_URL)
CRUCIBLE_TARBALL=$(basename $CRUCIBLE_URL)
BITBUCKET_TARBALL=$(basename $BITBUCKET_URL)
MYSQL_CONNECTOR_TARBALL=$(basename $MYSQL_CONNECTOR_URL)

# Define the UID and GID for the directories and files ...
USER_ID=1000
GROUP_ID=1000

#
#
########### END - SYTEM DEFINED VARIABLES - ##############################


########### START - Main Program - #######################################
#
#

source haproxy_ssl_setup.f


echo "Downloading Atlassian software products ..."
echo "- Jira ..."
curl -s -# -z -o images/jira/${JIRA_TARBALL} ${JIRA_URL}

echo "- Crucible ..."
curl -s -# -z -o images/jira/${CRUCIBLE_TARBALL} ${CRUCIBLE_URL}

echo "- Bit Bicket ..."
curl -s -# -z -o images/jira/${BITBUCKET_TARBALL} ${BITBUCKET_URL}

echo "- MYQL Connector ..."
curl -s -# -z -o images/jira/${MYSQL_CONNECTOR_TARBALL} ${MYSQL_CONNECTOR_URL}

# Notice that MySQL connector is downloaded directly in Jira's image location.


echo "Copying MySQL connector tarball inside each atlassian product ..."
# Copy from Jira to other two atlassian products.

if [ ! -r images/crucible/${MYSQL_CONNECTOR_TARBALL} ]; then
	cp images/jira/${MYSQL_CONNECTOR_TARBALL}  images/crucible/${MYSQL_CONNECTOR_TARBALL}
fi

if [ ! -r images/bitbucket/${MYSQL_CONNECTOR_TARBALL} ]; then
        cp images/jira/${MYSQL_CONNECTOR_TARBALL}  images/bitbucket/${MYSQL_CONNECTOR_TARBALL}
fi

echo "Creating logs directory in the root of setup directory - ${SETUP_DIR} ..."

if [ !  -d $SETUP_DIR/logs ]; then
        mkdir $SETUP_DIR/logs
	chown -R 1000:1000 $SETUP_DIR/logs
fi


echo "Creating volume directories for persistent data storage in:  ${STORAGE_DIR}..."
if [ !  -d ${STORAGE_DIR} ]; then
	mkdir -p ${STORAGE_DIR}
fi

for service in haproxy jira crucible bitbucket artifactory jenkins; do
	if [  ! -d "${STORAGE_DIR}/$service" ]; then
		mkdir ${STORAGE_DIR}/$service
		if [ $service == "artifactory" ]; then
			mkdir -p ${STORAGE_DIR}/$service/backup ${STORAGE_DIR}/$service/data ${STORAGE_DIR}/$service/logs
			
		fi
	fi
done

chown -R 1000:1000 ${STORAGE_DIR}

echo "Generating self-signed SSL certificates for haproxy"

setupHaproxySSLcrt  > /dev/null 2>&1

# build java base image for jira, crucible and bitbucket
image_check=$(docker images | grep praqma/java)

if [ -z "$image_check" ]; then
	echo "###### Building the base image: praqma/java_8 ########"
	echo
	docker build -t "praqma/java_8"  $SETUP_DIR/images/base/. >> $SETUP_DIR/logs/base.log 2>&1  
fi


wait

echo "####### Spinning up  database for initial configuration ########"
echo


docker-compose up -d atlassiandb > $SETUP_DIR/logs/docker-compose.atlassiandb.log 2>&1

  
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
docker-compose up -d >> $SETUP_DIR/logs/docker-compose.log 2>&1

echo " >>>>>>>>>>>>>>>> Installation Complete! <<<<<<<<<<<<<<<<<"






