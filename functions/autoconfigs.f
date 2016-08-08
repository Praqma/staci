function waitForJiraLogin(){
        local isRunning=false
        # Is jira loginscreen ready ?
        attempt=0
        while [ $attempt -le 3600 ]; do
          attempt=$(( $attempt + 1 ))
          result=$(curl -Is 'http://localhost:8080/jira/'| grep "HTTP/1.1 200 OK")
          if [ ! -z "$result" ] ; then
            echo " - Jira Loginscreen is ready"
            isRunning=true
            break
          fi
        sleep 2
        done

        if [ $isRunning = "false" ]; then
          echo " - Jira loginscreen did not start within timeelimit"
          exit 0
        fi
}


function waitForJiraWebSetup(){
      # Is Jira started ?
      status=$(docker inspect -f {{.State.Running}} jira 2>&1)

      # Is Jira ready ? 
      if [ "$status" == "true" ];then
        echo " - Container jira is active, waiting to be ready"
        attempt=0
        while [ $attempt -le 120 ]; do
          attempt=$(( $attempt + 1 ))
          result=$(docker logs jira 2>&1)
          if grep -q 'You can now access JIRA through your web browser' <<< $result ; then
            echo " - Jira is Running!"
            break
          fi
          sleep 1
        done

        # Is jira websetup ready ?
        attempt=0
        while [ $attempt -le 240 ]; do
          attempt=$(( $attempt + 1 ))
          result=$(curl -Is 'http://localhost:8080/jira/' | grep 'Location')
          if grep -q '/jira/secure/SetupMode!default.jspa' <<< $result ; then
            echo " - Jira Websetup is ready"
            break
          fi
        sleep 2
        done
      else
        echo "Container jira is not running..."
        exit 0
      fi
      sleep 1

}

function setupJira(){

  if [ ! -z $start_jira ];then
    local importJiraBackup=$(getProperty "jira_import_backup")
    local importJiraData=$(getProperty "jira_import_datafolder")
    local importJiraLicens=$(getProperty "jira_import_license")
    local JiraBaseUrl=$(getProperty "jira_baseurl")
    local JiraDbName=$(getProperty "jira_database_name")

    if [ ! -z "$importJiraBackup" ]; then

      waitForJiraWebSetup

      # Import Jira backup
      local importJiraBackup=$(getProperty "jira_import_backup")
      local importJiraHome=$(getProperty "jira_import_datafolder")

      local backupfilename=$(echo $importJiraBackup| rev | cut -d"/" -f1 | rev)
      local homefilename=$(echo $importJiraHome| rev | cut -d"/" -f1 | rev)
      if [ ! -z "$importJiraBackup" ]; then
        copyFileToContainer jira $importJiraBackup "/var/atlassian/jira/import/"
      fi

       echo " - Calling Jira import"
       curl -F filename="jirabackup.zip" -F license="$importJiraLicens" -F outgoingEmail="false" -F downgradeAnyway="False" "http://localhost:8080/jira/secure/SetupImport.jspa"

      waitForJiraLogin

      if [ ! -z "$importJiraBackup" ]; then
        copyFileToContainer jira $importJiraHome "/tmp/"
        docker exec jira /bin/bash -c "unzip -qq -o /tmp/$homefilename -d /var/atlassian" 2>&1
        docker exec -u root jira /bin/bash -c "rm -f /tmp/$homefilename" 2>&1


        if [ ! -z "$JiraBaseUrl" ]; then
          echo " - Updating Jira Base URL to $JiraBaseUrl"
          local update_jira_baseurl="update propertystring, propertyentry  set propertyvalue='$JiraBaseUrl'  where propertyentry.id=propertystring.id and propertyentry.property_key = 'jira.baseurl';"
          exec_mysql_sql "$update_jira_baseurl" "$JiraDbName"
        fi
        echo " - Restarting Jira for import to take effect"
        docker-compose -f compose/docker-compose.yml restart jira &> /dev/null

      elif [ -z "$importJiraBackup" ]; then
        setupJiraInstance
      fi
    else
      echo " - Skipping Jira backup import"
    fi
    echo " - Waiting for Jira to be ready"
    waitForJiraLogin
  fi
}

function copyFileToContainer(){
    local application=$1
    local source=$2
    local destination=$3
    docker cp $source $application:$destination
}


function setupJiraInstance(){
  echo "Setting up Jira"
}

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

