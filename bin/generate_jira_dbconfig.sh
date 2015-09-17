#! /bin/bash
source $STACI_HOME/functions/tools.f 

# Set version of images
mysql_port=$(getProperty "mysql_port")
mysql_driver_class=$(getProperty "mysql_driver_class")
jira_username=$(getProperty "jira_username")
jira_password=$(getProperty "jira_password")
jira_database_name=$(getProperty "jira_database_name")
docker_host_ip=$(echo $DOCKER_HOST | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+[.][0-9]\+')

cat << EOF
<?xml version="1.0" encoding="UTF-8"?>

<jira-database-config>
  <name>defaultDS</name>
  <delegator-name>default</delegator-name>
  <database-type>mysql</database-type>
  <jdbc-datasource>
    <url>jdbc:mysql://$docker_host_ip:$mysql_port/$jira_database_name?useUnicode=true&amp;characterEncoding=UTF8&amp;sessionVariables=storage_engine=InnoDB</url>
    <driver-class>$mysql_driver_class</driver-class>
    <username>$jira_username</username>
    <password>$jira_password</password>
    <pool-min-size>20</pool-min-size>
    <pool-max-size>20</pool-max-size>
    <pool-max-wait>30000</pool-max-wait>
    <validation-query>select 1</validation-query>
    <min-evictable-idle-time-millis>60000</min-evictable-idle-time-millis>
    <time-between-eviction-runs-millis>300000</time-between-eviction-runs-millis>
    <pool-max-idle>20</pool-max-idle>
    <pool-remove-abandoned>true</pool-remove-abandoned>
    <pool-remove-abandoned-timeout>300</pool-remove-abandoned-timeout>
    <pool-test-while-idle>true</pool-test-while-idle>
    <validation-query-timeout>3</validation-query-timeout>
  </jdbc-datasource>
</jira-database-config>
EOF
