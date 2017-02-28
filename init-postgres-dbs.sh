#! /bin/bash

##
#
# This script will initialize the Atlassian database - depending on the choice made between mysql or postgres in setup.conf
# Jira, BitBucket and Crucible
#
##

# Note: setup.conf is already sourced in the main program, so those variabls should be available as global variable.


SETUP_DIR=$(pwd)

DB_HOST="atlassiandb"

function exec_mysql(){
   local PASSWORD=$1
   local SQL_COMMAND=$2

   docker exec atlassiandb mysql --user=root --password=$PASSWORD -e "$SQL_COMMAND" >> $SETUP_DIR/logs/mysqlInit.log 2>&1 
}


# MYSQL_ROOT_PASSWORD is defined in setup.conf and should be a global variable. 

# Jira DB:
exec_mysql $MYSQL_ROOT_PASSWORD "CREATE DATABASE IF NOT EXISTS ${JIRA_DB_NAME} CHARACTER SET utf8 COLLATE utf8_bin;"
exec_mysql $MYSQL_ROOT_PASSWORD "GRANT ALL PRIVILEGES ON $JIRA_DB_NAME.* TO '$JIRA_DB_USER'@'%' IDENTIFIED BY '$JIRA_DB_PASS';"
exec_mysql $MYSQL_ROOT_PASSWORD "FLUSH PRIVILEGES;"

# BitBucket DB:
exec_mysql $MYSQL_ROOT_PASSWORD "CREATE DATABASE IF NOT EXISTS $BITBUCKET_DB_NAME CHARACTER SET utf8 COLLATE utf8_bin;"
exec_mysql $MYSQL_ROOT_PASSWORD "GRANT ALL PRIVILEGES ON $BITBUCKET_DB_NAME.* TO '$BITBUCKET_DB_USER'@'%' IDENTIFIED BY '$BITBUCKET_DB_PASS';"
exec_mysql $MYSQL_ROOT_PASSWORD "FLUSH PRIVILEGES;"

# Crucible/FishEye DB
exec_mysql $MYSQL_ROOT_PASSWORD "CREATE DATABASE IF NOT EXISTS $CRUCIBLE_DB_NAME CHARACTER SET utf8 COLLATE utf8_bin;"
exec_mysql $MYSQL_ROOT_PASSWORD "GRANT ALL PRIVILEGES ON $CRUCIBLE_DB_NAME.* TO '$CRUCIBLE_DB_USER'@'%' IDENTIFIED BY '$CRUCIBLE_DB_PASS';"
exec_mysql $MYSQL_ROOT_PASSWORD "FLUSH PRIVILEGES;"



