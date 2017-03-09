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
CONFIG_FILE=setup.conf

#
#
########### END - USER DEFINED VARIABLES - ################################



# Load some config variables from the setup.conf file.
if [ ! -r ${CONFIG_FILE} ] ; then
  echo "${CONFIG_FILE} is not found. Need to know the URLs for various software. Exiting ... "
  exit 1
else
  echo "Loading values for JIRA_URL , CRUCIBLE_URL, BITBUCKET_URL , MYSQL_CONNECTOR_URL and a lot more ..."
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
POSTGRES_CONNECTOR_TARBALL=$(basename $POSTGRES_CONNECTOR_URL)

# Define the UID and GID for the directories and files ...
USER_ID=1000
GROUP_ID=1000

LOG_DIR=/tmp/staci_logs

# Various options used with curl command. Note "do not" use -z . It does not work. (Kamran) . Also don't use -s.
# CURL_OPTIONS="-# -L"
CURL_OPTIONS="-# -L"

# Set domain name to example.com if it is not specified in setup.conf.
if [ -z "${DOMAIN_NAME}" ]; then
  DOMAIN_NAME='example.com'
fi

# If there is no DB_PROVIDER, then use mysql as default DB_PROVIDER.
if [ -z "${DB_PROVIDER}"  ] ; then
  DB_PROVIDER='mysql'
fi

# If DB_PROVIDER is none of either mysql or postgres, set mysql as the default one.
if [ "${DB_PROVIDER}" != "mysql" ] ; then  
  if [ "${DB_PROVIDER}" != "postgres" ] ; then
    echo "Unidentified DB_PROVIDER in config file. You must use either 'mysql' or 'postgres'."
    echo "Setting mysql as default DB_PROVIDER ."
    DB_PROVIDER='mysql'
  fi
fi

echo
echo "Using the "${DB_PROVIDER}" as DB provider for atlassiandb container."
echo

# Assign the password in DB_ROOT_PASSWORD to both MYSQL and POSTGRES env variables. 
MYSQL_ROOT_PASSWORD="${DB_ROOT_PASSWORD}"
POSTGRES_PASSWORD="${DB_ROOT_PASSWORD}"

#
#
########### END - SYTEM DEFINED VARIABLES - ##############################


########### START - Main Program - #######################################
#
#

source ./functions.sh


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

echo
echo "- PostgreSQL JDBC Connector - (${POSTGRES_CONNECTOR_URL}) ..."
if [ ! -r images/jira/${POSTGRES_CONNECTOR_TARBALL} ] ; then
  curl ${CURL_OPTIONS} -o images/jira/${POSTGRES_CONNECTOR_TARBALL} ${POSTGRES_CONNECTOR_URL}
else
  echo "-- File images/jira/${POSTGRES_CONNECTOR_TARBALL} exists. Skipping download."
fi

# Notice that Postgres connector is downloaded directly in Jira's image location.


##########################################################################################

echo 
echo "Copying MySQL connector tarball inside each atlassian product ..."
# Copy from Jira to other two atlassian products.

if [ ! -r images/bitbucket/${MYSQL_CONNECTOR_TARBALL} ]; then
  cp images/jira/${MYSQL_CONNECTOR_TARBALL}  images/bitbucket/${MYSQL_CONNECTOR_TARBALL}
fi

if [ ! -r images/crucible/${MYSQL_CONNECTOR_TARBALL} ]; then
  cp images/jira/${MYSQL_CONNECTOR_TARBALL}  images/crucible/${MYSQL_CONNECTOR_TARBALL}
fi

echo
echo "Copying PostgreSQL JDBC connector inside each atlassian product ..."
# Copy from Jira to other two atlassian products.

if [ ! -r images/bitbucket/${POSTGRES_CONNECTOR_TARBALL} ]; then
  cp images/jira/${POSTGRES_CONNECTOR_TARBALL}  images/bitbucket/${POSTGRES_CONNECTOR_TARBALL}
fi

if [ ! -r images/crucible/${POSTGRES_CONNECTOR_TARBALL} ]; then
  cp images/jira/${POSTGRES_CONNECTOR_TARBALL}  images/crucible/${POSTGRES_CONNECTOR_TARBALL}
fi

####################################################################################

echo
echo "Creating logs directory in ${LOG_DIR} ..."

if [ !  -d $LOG_DIR ]; then
  mkdir $LOG_DIR
  chmod 0700 $LOG_DIR
  chown root:root $LOG_DIR
fi

echo
echo "Creating volume directories for persistent data storage in ${STORAGE_DIR}..."
if [ !  -d ${STORAGE_DIR} ]; then
  mkdir -p ${STORAGE_DIR}
fi

for SERVICE in haproxy jira crucible bitbucket artifactory jenkins atlassiandb; do
  if [  ! -d "${STORAGE_DIR}/${SERVICE}" ]; then
    mkdir ${STORAGE_DIR}/${SERVICE}
    if [ "${SERVICE}" == "artifactory" ]; then
      mkdir -p ${STORAGE_DIR}/${SERVICE}/backup ${STORAGE_DIR}/${SERVICE}/data ${STORAGE_DIR}/${SERVICE}/logs
    fi

    # atlassiandb can have mysql or postgres backend. Need to keep them separated.
    if [ "${SERVICE}" == "atlassiandb" ]; then
      mkdir -p ${STORAGE_DIR}/${SERVICE}/mysql ${STORAGE_DIR}/${SERVICE}/postgres
    fi
  fi
done

chown -R 1000:1000 ${STORAGE_DIR}

# postgres and mysql are special. They both need the uid:gid of 999:999.
chown -R 999:999 ${STORAGE_DIR}/atlassiandb 

echo

echo "Generating self-signed SSL certificates for haproxy ..."
echo "Logs in: $LOG_DIR/SSL-certs.log"

generateSSLCertificate >> $LOG_DIR/SSL-certs.log  2>&1

# build java base image for jira, crucible and bitbucket
image_check=$(docker images | grep praqma/java)

if [ -z "$image_check" ]; then
  echo
  echo "Building the base image: praqma/java_8 ... Logs in: $LOG_DIR/base.log"
  echo
  docker build -t "praqma/java_8"  $SETUP_DIR/images/base/. >> $LOG_DIR/base-image.log 2>&1  
fi



# here we have to select based on DB_PROVIDER.
cat docker-compose-minus-db.yml docker-compose-db-${DB_PROVIDER}.yml > docker-compose.yml

# Then do some sed magic:
sed -i -e s#STORAGEDIR#${STORAGE_DIR}#g \
       -e s#MYSQLPASS#${MYSQL_ROOT_PASSWORD}#g \
       -e s#POSTGRESPASS#${POSTGRES_PASSWORD}#g \
    docker-compose.yml  


# NO need - debug
# Setup correct Dockerfile for atlassiandb image
# cp images/atlassiandb/Dockerfile.${DB_PROVIDER} images/atlassiandb/Dockerfile


echo 
echo "Spinning up database atlassiandb with '${DB_PROVIDER}' as DB provider for initial configuration ..."
echo "This will take a while. It includes building atlassiandb docker image when run for the first time."
echo "Logs in: $LOG_DIR/docker-compose.atlassiandb.log"
echo


docker-compose up -d atlassiandb >> $LOG_DIR/docker-compose.atlassiandb.log 2>&1


echo
echo -n "Waiting for atlassiandb container to start ..."
# Needs to be a loop here, which exits when the status becomes true. 
while [ "$status" != "true" ] ; do
  status=$(docker inspect -f {{.State.Running}} atlassiandb 2>&1)
  sleep 1
  echo -n "."
done
echo " Done."

echo
echo "The atlassiandb container is now running. "
echo
echo -n "Waiting for '${DB_PROVIDER}' DB container to start accepting connections ..."

# Test if DB is ready for accepting connections. Call a function depending on DB_PROVIDER and check it's exit code.
testDBReadiness-${DB_PROVIDER}
if [ $? -eq 0 ] ; then
  echo " Done."
  echo "The container 'atlassiandb' (with provider '${DB_PROVIDER}') is now ready and accepting connections."
else
  echo " TIMEOUT!"
  echo "Something went wrong in bringing up DB container 'atlassiandb' with the provider '${DB_PROVIDER}' ."
  echo "Please investigate. Exiting ..."
  exit 9
fi


# Initialize / setup Databases for usage, based on DB_Provider.
# The init-databases.sh has intelligence built into it to select the right DB_PROVIDER, 
#   and execute the necessary commands on that.
echo
source ./init-databases.sh



echo " >>>>>>>>>>>>>>>> Installation/Configuration Complete! <<<<<<<<<<<<<<<<<"

echo

echo
echo "Proceeding to bringing up the rest of the stack..."
echo "This will take a while. It includes building several images when run for the first time."
echo "Logs in: $LOG_DIR/docker-compose.log "
echo

docker-compose up -d >> $LOG_DIR/docker-compose.log 2>&1
if [ $? -eq 0 ] ; then 
  echo "docker-compose was able to bring up entire application suite." 
  echo "Though it may take few minutes for the complete application suite to be usable."
  echo "Please refer to README.md for next steps."
  exit 0
else
  echo "Something went wrong in bringing up application suite. Please investigate and fix." 
  echo "You do not need to run setup again though. "
  echo "From this point onwards, you can just manage your application using docker-compose "
  echo "Exiting ..."
  exit 9
fi
echo
