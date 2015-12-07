#! /bin/bash

##
#
# This script will initialize the MySql database for 
# Jira, Confluence and Bamboo
#
##

source $STACI_HOME/functions/tools.f
docker_host_ip=$(echo $DOCKER_HOST | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+[.][0-9]\+')
version=$(getProperty "imageVersion")

function exec_sql(){
   local pw=$1
   local sqlcmd=$2
   mysql_ip=$(docker inspect --format '{{ .NetworkSettings.IPAddress }}' atlassiandb)
   docker run -it staci/atlassiandb:$version mysql --host="$mysql_ip" --port="3306" --user=root --password=$pw -e "$sqlcmd" > $STACI_HOME/logs/mysqlInit.log 2>&1 >> $STACI_HOME/logs/mysql.log
}

# Find out what to init
start_jira=$(getProperty "start_jira")
start_confluence=$(getProperty "start_confluence")
start_bamboo=$(getProperty "start_bamboo")
start_crowd=$(getProperty "start_crowd")
start_bitbucket=$(getProperty "start_bitbucket")
start_crucible=$(getProperty "start_crucible")
mysql_root_pass=$(getProperty "mysql_root_pass")


# Clear old logfile
rm -f $STACI_HOME/logs/mysql.log

if [ "$start_jira" == "1" ]; then
   echo " - Setting up MySQL for Jira"
   jira_username=$(getProperty "jira_username")
   jira_password=$(getProperty "jira_password")
   jira_database=$(getProperty "jira_database_name")

   exec_sql $mysql_root_pass "CREATE USER '$jira_username'@'%' IDENTIFIED BY '$jira_password';"
   exec_sql $mysql_root_pass "CREATE DATABASE $jira_database CHARACTER SET utf8 COLLATE utf8_bin;"
   exec_sql $mysql_root_pass "GRANT SELECT,INSERT,UPDATE,DELETE,CREATE,DROP,ALTER,INDEX on $jira_database.* TO '$jira_username'@'%';"
   exec_sql $mysql_root_pass "FLUSH PRIVILEGES;"

   echo "*** Use the following to setup Jira db connection ***
 - Database Type : MySQL
 - Hostname : $mysql_ip
 - Port : 3306
 - Database : $jira_database
 - Username : $jira_username
 - Password : $jira_password
   "
fi

if [ "$start_confluence" == "1" ]; then
   echo " - Setting up MySQL for Confluence"
   confluence_username=$(getProperty "confluence_username")
   confluence_password=$(getProperty "confluence_password")
   confluence_database=$(getProperty "confluence_database_name")

   exec_sql $mysql_root_pass "CREATE DATABASE $confluence_database CHARACTER SET utf8 COLLATE utf8_bin;"
   exec_sql $mysql_root_pass "GRANT ALL PRIVILEGES ON $confluence_database.* TO '$confluence_username'@'%' IDENTIFIED BY '$confluence_password';"
   exec_sql $mysql_root_pass "FLUSH PRIVILEGES;"

   echo "*** Use the following to setup Bamboo db connection ***
 - Install type : Production install
 - Database Type : MySQL
 - Connection : Direct JDBC
 - Driver Class Name : com.mysql.jdbc.Driver
 - Database URL : jdbc:mysql://$mysql_ip/$confluence_database?sessionVariables=storage_engine%3DInnoDB&useUnicode=true&characterEncoding=utf8
 - User Name : $confluence_username
 - Password : $confluence_password
   "
fi

if [ "$start_bamboo" == "1" ]; then
   echo " - Setting up MySQL for Bamboo"
   bamboo_username=$(getProperty "bamboo_username")
   bamboo_password=$(getProperty "bamboo_password")
   bamboo_database=$(getProperty "bamboo_database_name")

   exec_sql $mysql_root_pass "CREATE DATABASE $bamboo_database CHARACTER SET utf8 COLLATE utf8_bin;"
   exec_sql $mysql_root_pass "GRANT ALL PRIVILEGES ON $bamboo_database.* TO '$bamboo_username'@'%' IDENTIFIED BY '$bamboo_password';"
   exec_sql $mysql_root_pass "FLUSH PRIVILEGES;"

   echo " *** Use the following to setup Bamboo db connection ***
 - Install type : Production install
 - Select database : External MySQL
 - Connection : Direct JDBC
 - Database URL : jdbc:mysql://$mysql_ip/$bamboo_database?autoReconnect=true
 - User name : $bamboo_username
 - Password : $bamboo_password
 - Overwrite Existing data : Yes, if you want
   "
fi

if [ "$start_crowd" == "1" ]; then
   echo " - Setting up MySQL for Crowd"
   crowd_username=$(getProperty "crowd_username")
   crowd_password=$(getProperty "crowd_password")
   crowd_database=$(getProperty "crowd_database_name")

   exec_sql $mysql_root_pass "create database $crowd_database character set utf8 collate utf8_bin;"
   exec_sql $mysql_root_pass "GRANT ALL PRIVILEGES ON $crowd_database.* TO '$crowd_username'@'%' IDENTIFIED BY '$crowd_password';"
   exec_sql $mysql_root_pass "FLUSH PRIVILEGES;"

   echo " *** Use the following to setup Crowd db connection ***
 - Install type : New installation
 - Database type : JDBC connection
 - Database : MySQL
 - Database URL : jdbc:mysql://$mysql_ip/$crowd_database?autoReconnect=true&characterEncoding=utf8&useUnicode=true
 - User name : $crowd_username
 - Password : $crowd_password
 - Overwrite Existing data : Yes, if you want
   "
fi

if [ "$start_bitbucket" == "1" ]; then
   echo " - Setting up MySQL for Bitbucket"
   bitbucket_username=$(getProperty "bitbucket_username")
   bitbucket_password=$(getProperty "bitbucket_password")
   bitbucket_database=$(getProperty "bitbucket_database_name")

   exec_sql $mysql_root_pass "CREATE DATABASE $bitbucket_database CHARACTER SET utf8 COLLATE utf8_bin;"
   exec_sql $mysql_root_pass "GRANT ALL PRIVILEGES ON $bitbucket_database.* TO '$bitbucket_username'@'%' IDENTIFIED BY '$bitbucket_password';"
   exec_sql $mysql_root_pass "FLUSH PRIVILEGES;"

   echo " *** Use the following to setup Bitbucket db connection ***
 - Database : External
 - Database type : MySQL
 - Hostname : $mysql_ip
 - Port : 3306
 - Database name : $bitbucket_database
 - Database username : $bitbucket_username
 - Database password : $bitbucket_password
   "
fi

if [ "$start_crucible" == "1" ]; then
   echo " - Setting up MySQL for Crucible"
   crucible_username=$(getProperty "crucible_username")
   crucible_password=$(getProperty "crucible_password")
   crucible_database=$(getProperty "crucible_database_name")

   exec_sql $mysql_root_pass "CREATE DATABASE $crucible_database CHARACTER SET utf8 COLLATE utf8_bin;"
   exec_sql $mysql_root_pass "GRANT ALL PRIVILEGES ON $crucible_database.* TO '$crucible_username'@'%' IDENTIFIED BY '$crucible_password';"
   exec_sql $mysql_root_pass "FLUSH PRIVILEGES;"

   echo " *** Use the following to setup Bitbucket db connection ***
 - Database : External
 - Database type : MySQL
 - Hostname : $mysql_ip
 - Port : 3306
 - Database name : $crucible_database
 - Database username : $crucible_username
 - Database password : $crucible_password
   "
fi
