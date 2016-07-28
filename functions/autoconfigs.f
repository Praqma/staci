function setJiraDatabaseConnection(){

local jirausername=$(getProperty "jira_username")
local jirapassword=$(getProperty "jira_password")
local jiradatabasename=$(getProperty "jira_database_name")
local startmysql=$(getProperty "start_mysql")

if [ "$startmysql" == "1" ]; then
  local mysqldriver=$(getProperty "mysql_driver_class")
  local mysqlport=$(getProperty "mysql_port")

cat << EOF
<?xml version="1.0" encoding="UTF-8"?>
<jira-database-config>
  <name>defaultDS</name>
  <delegator-name>default</delegator-name>
  <database-type>mysql</database-type>
  <jdbc-datasource>
    <url>jdbc:mysql://atlassiandb:$mysqlport/$jiradatabasename?useUnicode=true&amp;characterEncoding=UTF8&amp;sessionVariables=storage_engine=InnoDB</url>
    <driver-class>$mysqldriver</driver-class>
    <username>$jirausername</username>
    <password>$jirapassword</password>
    <pool-min-size>20</pool-min-size>
    <pool-max-size>20</pool-max-size>
    <pool-max-wait>30000</pool-max-wait>
    <validation-query>select 1</validation-query>
    <min-evictable-idle-time-millis>60000</min-evictable-idle-time-millis>
    <time-between-eviction-runs-millis>300000</time-between-eviction-runs-millis>
    <pool-max-idle>20</pool-max-idle>
    <pool-remove-abandoned>true</pool-remove-abandoned>
    <pool-remove-abandoned-timeout>300</pool-remove-abandoned-timeout>
    <pool-test-on-borrow>false</pool-test-on-borrow>
    <pool-test-while-idle>true</pool-test-while-idle>
    <validation-query-timeout>3</validation-query-timeout>
  </jdbc-datasource>
</jira-database-config>
EOF
fi
}

