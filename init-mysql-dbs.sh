#! /bin/bash

##
#
# This script will initialize the MySql database for 
# Jira, Confluence and Bamboo
#
##

SETUP_DIR=$(pwd)
MYSQL_HOST="atlassiandb"

function exec_sql(){
   local PASSWORD=$1
   local SQL_COMMAND=$2
   
   docker exec atlassiandb mysql --user=root --password=$PASSWORD -e "$SQL_COMMAND" > $SETUP_DIR/logs/mysqlInit.log 2>&1 >> $SETUP_DIR/logs/mysql.log
}


# Clear old logfile
rm -f $SETUP_DIR/logs/mysql.log

echo " - Setting up MySQL for Jira"
jira_username="jiradbuser"
jira_password="jirapass"
jira_database="jiradb"

# MYSQL_ROOT_PASSWORD is defined in setup.conf and should be a global variable. 
mysql_root_pass=$MYSQL_ROOT_PASSWORD

#   exec_sql $mysql_root_pass "CREATE USER '$jira_username'@'%' IDENTIFIED BY '$jira_password';"
exec_sql $mysql_root_pass "CREATE DATABASE IF NOT EXISTS $jira_database CHARACTER SET utf8 COLLATE utf8_bin;"
exec_sql $mysql_root_pass "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX on $jira_database.* TO '$jira_username'@'%' IDENTIFIED BY '$jira_password';"
exec_sql $mysql_root_pass "FLUSH PRIVILEGES;"

echo "  # Database Type : MySQL
  # Hostname : $MYSQL_HOST
  # Port : 3306
  # Database : $jira_database
  # Username : $jira_username
  # Password : $jira_password
   "

echo " - Setting up MySQL for Bitbucket"
bitbucket_username="bitbucketdbuser"
bitbucket_password="bitbucketpass"
bitbucket_database="bitbucketdb"

exec_sql $mysql_root_pass "CREATE DATABASE IF NOT EXISTS $bitbucket_database CHARACTER SET utf8 COLLATE utf8_bin;"
exec_sql $mysql_root_pass "GRANT ALL PRIVILEGES ON $bitbucket_database.* TO '$bitbucket_username'@'%' IDENTIFIED BY '$bitbucket_password';"
exec_sql $mysql_root_pass "FLUSH PRIVILEGES;"

echo "  # Database : External
  # Database type : MySQL
  # Hostname : $MYSQL_HOST
  # Port : 3306
  # Database name : $bitbucket_database
  # Database username : $bitbucket_username
  # Database password : $bitbucket_password
  "

echo " - Setting up MySQL for Crucible"
crucible_username="crucibledbuser"
crucible_password="cruciblepass"
crucible_database="crucibledb"

exec_sql $mysql_root_pass "CREATE DATABASE IF NOT EXISTS $crucible_database CHARACTER SET utf8 COLLATE utf8_bin;"
exec_sql $mysql_root_pass "GRANT ALL PRIVILEGES ON $crucible_database.* TO '$crucible_username'@'%' IDENTIFIED BY '$crucible_password';"
exec_sql $mysql_root_pass "FLUSH PRIVILEGES;"

echo "  # Database : External
  # Database type : MySQL
  # Hostname : $MYSQL_HOST
  # Port : 3306
  # Database name : $crucible_database
  # Database username : $crucible_username
  # Database password : $crucible_password
   "
