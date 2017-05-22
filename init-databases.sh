#! /bin/bash


# Load setup.conf and setup.conf.local
if [ "$1" == "debug" ] ; then
  source ./setup.conf
fi

if [ -r ./setup.conf.local ]; then
  source ./setup.conf.local
fi


###########################################################
#
# This script will initialize the Atlassian (mysql)database.
# Jira, BitBucket and Crucible
#
#############################################################

# Notes: 
#   - setup.conf is already sourced in the main program, so those variabls should be available as global variable.
#   - DO NOT change the name of the functions. In case you do, they need to have 'mysql' and 'postgres' in function name,
#   -- as that is the value of DB_PROVIDER variable from the conf file.
    
SETUP_DIR=$(pwd)

DB_CONTAINER="atlassiandb"

function setup_mysql_db(){
  local USER_NAME=$1
  local USER_PASS=$2
  local DB_NAME=$3

  # Note: MYSQL_ROOT_PASSWORD is sourced and is a global variable.

  CREATE_DB_COMMAND="CREATE DATABASE IF NOT EXISTS ${DB_NAME} CHARACTER SET utf8 COLLATE utf8_bin;"

  docker exec $DB_CONTAINER mysql --user=root --password=$MYSQL_ROOT_PASSWORD \
    -e "$CREATE_DB_COMMAND"  >> $LOG_DIR/mysql-init.log 2>&1 

  CREATE_USER_COMMAND="GRANT ALL PRIVILEGES ON ${DB_NAME}.* TO '${USER_NAME}'@'%' IDENTIFIED BY '${USER_PASS}';"

  docker exec $DB_CONTAINER mysql --user=root --password=$MYSQL_ROOT_PASSWORD \
    -e "${CREATE_USER_COMMAND}" >> $LOG_DIR/mysqlInit.log 2>&1 

  docker exec $DB_CONTAINER mysql --user=root --password=$MYSQL_ROOT_PASSWORD \
    -e "FLUSH PRIVILEGES;"

}


function setup_postgres_db() {
  local USER_NAME=$1
  local USER_PASS=$2
  local DB_NAME=$3
  # Notes:
  # - createuser script does not provide facility to assign password through CLI. So a SQL command is used. 
  # - createdb is a OS command (wrapper to create database)
  # - We do not need postgres root password when running commands on container as 'localhost'
  # - There must be NO SPACE between the closing quote marks of the password and the ; in the command below;
  #   which is a polite way to say that this is really silly of postgres.

  CREATE_USER_SQL="create user ${USER_NAME} with password '${USER_PASS}';"

  #docker exec ${DB_CONTAINER} \
  #  psql -h localhost -U postgres -c "${CREATE_USER_SQL}"  >> $LOG_DIR/postgres-init.log 2>&1 

  docker exec ${DB_CONTAINER} \
    psql -h localhost -U postgres -c "${CREATE_USER_SQL}"

  sleep 1

  # https://confluence.atlassian.com/jira064/connecting-jira-to-postgresql-720411771.html
  CREATE_DB_SQL="create database ${DB_NAME} with owner=${USER_NAME} encoding='UNICODE' LC_COLLATE='C' LC_CTYPE='C' TEMPLATE=template0;"

  # docker exec ${DB_CONTAINER} \
  #  psql -h localhost -U postgres -c "${CREATE_DB_SQL}"  >> $LOG_DIR/postgres-init.log 2>&1 
  
  docker exec ${DB_CONTAINER} \
    psql -h localhost -U postgres -c "${CREATE_DB_SQL}"

  sleep 1  
}

echo "Executing setup_${DB_PROVIDER} ... " 

setup_${DB_PROVIDER}_db $JIRA_DB_USER      $JIRA_DB_PASS      $JIRA_DB_NAME
setup_${DB_PROVIDER}_db $BITBUCKET_DB_USER $BITBUCKET_DB_PASS $BITBUCKET_DB_NAME
setup_${DB_PROVIDER}_db $CRUCIBLE_DB_USER  $CRUCIBLE_DB_PASS  $CRUCIBLE_DB_NAME


