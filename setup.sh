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
  source ${CONFIG_FILE}
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

# Various options used with curl command. Note "do not" use -z . It does not work. (Kamran) . Also don't use -s.
CURL_OPTIONS="-# -L"

#
#
########### END - SYTEM DEFINED VARIABLES - ##############################


########### START - Main Program - #######################################
#
#

source haproxy_ssl_setup.f


echo "Downloading Atlassian software products ..."

echo
echo "- Jira - (${JIRA_URL}) ..."
if [ ! -r images/jira/${JIRA_TARBALL} ] ; then
  curl ${CURL_OPTIONS} -o images/jira/${JIRA_TARBALL} ${JIRA_URL}
else
  echo "-- File images/jira/${JIRA_TARBALL} exists. Skipping download."
fi 

echo
echo "- Crucible - (${CRUCIBLE_URL}) ..."
if [ ! -r images/crucible/${CRUCIBLE_TARBALL} ] ; then
  curl ${CURL_OPTIONS} -o images/crucible/${CRUCIBLE_TARBALL} ${CRUCIBLE_URL}
else
  echo "-- File images/crucible/${CRUCIBLE_TARBALL} exists. Skipping download."
fi

echo
echo "- Bit Bicket - (${BITBUCKET_URL}) ..."
if [ ! -r images/bitbucket/${BITBUCKET_TARBALL} ] ; then
  curl ${CURL_OPTIONS} -o images/bitbucket/${BITBUCKET_TARBALL} ${BITBUCKET_URL}
else
  echo "-- File images/bitbucket/${BITBUCKET_TARBALL} exists. Skipping download."
fi

echo
echo "- MYQL Connector - (${MYSQL_CONNECTOR_URL}) ..."
if [ ! -r images/jira/${MYSQL_CONNECTOR_TARBALL} ] ; then
  curl ${CURL_OPTIONS} -o images/jira/${MYSQL_CONNECTOR_TARBALL} ${MYSQL_CONNECTOR_URL}
else
  echo "-- File images/jira/${MYSQL_CONNECTOR_TARBALL} exists. Skipping download."
fi

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

echo
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
echo
echo "Generating self-signed SSL certificates for haproxy ..."
echo "Logs in: $SETUP_DIR/logs/SSL-certs.log"

setupHaproxySSLcrt >> $SETUP_DIR/logs/SSL-certs.log  2>&1

# build java base image for jira, crucible and bitbucket
image_check=$(docker images | grep praqma/java)

if [ -z "$image_check" ]; then
  echo
  echo "Building the base image: praqma/java_8 ... Logs in: $SETUP_DIR/logs/base.log"
  echo
  docker build -t "praqma/java_8"  $SETUP_DIR/images/base/. >> $SETUP_DIR/logs/base.log 2>&1  
fi


wait

echo 
echo "Spinning up database for initial configuration ..."
echo "This will take a while. It includes building atlassiandb docker image when run for the first time."
echo "Logs in: $SETUP_DIR/logs/docker-compose.atlassiandb.log"
echo


docker-compose up -d atlassiandb > $SETUP_DIR/logs/docker-compose.atlassiandb.log 2>&1

  
echo
echo -n "Waiting for atlassiandb container to start ..."
# Needs to be a loop here, which exits when the status becomes true. 
while [ "$status" != "true" ] ; do
  status=$(docker inspect -f {{.State.Running}} atlassiandb 2>&1)
  sleep 1
  echo -n "."
done

echo 
if [ "$status" == "true" ];then
   echo -n "Container atlassiandb is now active; waiting for DB init process to complete ..."
   attempt=0
   while [ $attempt -le 59 ]; do
      attempt=$(( $attempt + 1 ))
      result=$(docker logs atlassiandb 2>&1)
      if grep -q 'MySQL init process done. Ready for start up.' <<< $result ; then
         # echo
         # echo "MySQL init process complete."
         # echo
         break
      else
         echo -n "."
         sleep 1
      fi
   done

   echo 
   echo -n "DB init process complete. Waiting for it to be ready for connections ..."
   attempt=0
   while [ $attempt -le 59 ]; do
      attempt=$(( $attempt + 1 ))
      STATUS=$(docker exec  atlassiandb mysqladmin --user=root --password=${MYSQL_ROOT_PASSWORD} ping 2> /dev/null | grep 'alive')
      if [ "${STATUS}" == "mysqld is alive"  ]; then
         echo "Done."
         echo "- MySQL DB is up!"
         break
      else
        echo -n "."
        sleep 1
      fi
   done
   else
      echo "Container atlassiandb did not start. Please investigate. Logs in: $SETUP_DIR/logs/docker-compose.atlassiandb.log"
      echo "Exiting ..."    
      exit 9
fi

# Setup database
echo
echo "Setting up databases for Atlassian products in the DB container ..."
source ./init-atlassiandb.sh

echo
echo "Bringing up the rest of the stack..."
echo "This will take a while. It includes building several images when run for the first time."
echo "Logs in: $SETUP_DIR/logs/docker-compose.log "
echo
docker-compose up -d >> $SETUP_DIR/logs/docker-compose.log 2>&1

echo
echo " >>>>>>>>>>>>>>>> Installation Complete! <<<<<<<<<<<<<<<<<"
echo

echo "Please refer to README.md for next steps."
echo

exit 0




