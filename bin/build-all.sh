#! /bin/bash
source $STACI_HOME/functions/tools.f 

# Set version of images
version=$(getProperty "imageVersion")

# Find out what to start
start_mysql=$(getProperty "start_mysql")
start_jira=$(getProperty "start_jira")
start_confluence=$(getProperty "start_confluence")
start_bamboo=$(getProperty "start_bamboo")

# Get context path for each application
jiraContextPath=$(getProperty "jira_contextpath")
confluenceContextPath=$(getProperty "confluence_contextpath")
bambooContextPath=$(getProperty "bamboo_contextpath")

# Set context path and build Jira
if [ ! -z "$jiraContextPath" ] && [ "$start_jira" == "1" ]; then
  jiraContextPath='\'$jiraContextPath
  echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$jiraContextPath\"/g' /opt/atlassian/jira/conf/server.xml" > $STACI_HOME/images/jira/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/jira/context/setContextPath.sh
  docker build -t staci/jira:$version $STACI_HOME/images/jira/context/ > $STACI_HOME/logs/jira.build.log 2>&1 &

  # clean up
  rm $STACI_HOME/images/jira/context/setContextPath.sh
fi

# Set context path and build Confluence
if [ ! -z "$confluenceContextPath" ] && [ "$start_confluence" == "1" ]; then
  confluenceContextPath='\'$confluenceContextPath
  echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$confluenceContextPath\"/g' /opt/atlassian/confluence/conf/server.xml" > $STACI_HOME/images/confluence/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/confluence/context/setContextPath.sh
  docker build -t staci/confluence:$version $STACI_HOME/images/confluence/context/ > $STACI_HOME/logs/confluence.build.log 2>&1 &

  # clean up
  rm $STACI_HOME/images/confluence/context/setContextPath.sh
fi

# Set context path and build Bamboo
if [ ! -z "$bambooContextPath" ] && [ "$start_bamboo" == "1" ]; then
  bambooContextPath='\'$bambooContextPath
  echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$bambooContextPath\"/g' /opt/atlassian/bamboo/conf/server.xml" > $STACI_HOME/images/bamboo/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/bamboo/context/setContextPath.sh
  docker build -t staci/bamboo:$version $STACI_HOME/images/bamboo/context/ > $STACI_HOME/logs/bamboo.build.log 2>&1 &

  # clean up
  rm $STACI_HOME/images/bamboo/context/setContextPath.sh
fi

# Build mysql database as atlassiandb
if [ "$start_mysql" == "1" ]; then
  docker build -t staci/atlassiandb:$version $STACI_HOME/images/atlassiandb/context/ > $STACI_HOME/logs/atlassiandb.build.log 2>&1 &
fi

wait
