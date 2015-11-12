#! /bin/bash
source $STACI_HOME/functions/tools.f 

# Set version of images
version=$(getProperty "imageVersion")

# Find out what to start
start_mysql=$(getProperty "start_mysql")
start_jira=$(getProperty "start_jira")
start_confluence=$(getProperty "start_confluence")
start_bamboo=$(getProperty "start_bamboo")
start_crowd=$(getProperty "start_crowd")
start_bitbucket=$(getProperty "start_bitbucket")
start_crucible=$(getProperty "start_crucible")

# Get context path for each application
jiraContextPath=$(getProperty "jira_contextpath")
confluenceContextPath=$(getProperty "confluence_contextpath")
bambooContextPath=$(getProperty "bamboo_contextpath")
bitbucketContextPath=$(getProperty "bitbucket_contextpath")

# Build our base image
  echo " --- Base image"
docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.build.log 2>&1 

# Set context path and build Jira
if [ ! -z "$jiraContextPath" ] && [ "$start_jira" == "1" ]; then
  echo " ----- Jira"
  jiraContextPath='\'$jiraContextPath
  echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$jiraContextPath\"/g' /opt/atlassian/jira/conf/server.xml" > $STACI_HOME/images/jira/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/jira/context/setContextPath.sh
  docker build -t staci/jira:$version $STACI_HOME/images/jira/context/ > $STACI_HOME/logs/jira.build.log 2>&1 &
fi

# Set context path and build Confluence
if [ ! -z "$confluenceContextPath" ] && [ "$start_confluence" == "1" ]; then
  echo " ----- Confluence"
  confluenceContextPath='\'$confluenceContextPath
  echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$confluenceContextPath\"/g' /opt/atlassian/confluence/conf/server.xml" > $STACI_HOME/images/confluence/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/confluence/context/setContextPath.sh
  docker build -t staci/confluence:$version $STACI_HOME/images/confluence/context/ > $STACI_HOME/logs/confluence.build.log 2>&1 &
fi

# Set context path and build Bamboo
if [ ! -z "$bambooContextPath" ] && [ "$start_bamboo" == "1" ]; then
  echo " ----- Bamboo"
  bambooContextPath='\'$bambooContextPath
  echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$bambooContextPath\"/g' /opt/atlassian/bamboo/conf/server.xml" > $STACI_HOME/images/bamboo/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/bamboo/context/setContextPath.sh
  docker build -t staci/bamboo:$version $STACI_HOME/images/bamboo/context/ > $STACI_HOME/logs/bamboo.build.log 2>&1 &
fi

# Set context path and build Bitbucket
if [ ! -z "$bitbucketContextPath" ] && [ "$start_bitbucket" == "1" ]; then
  echo " ----- Bitbucket"
  bitbucketContextPath='\'$bitbucketContextPath
  echo "sed -i -e 's/path=\"\"/path=\"$bitbucketContextPath\"/g' /opt/atlassian/bitbucket/conf/server.xml" > $STACI_HOME/images/bitbucket/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/bitbucket/context/setContextPath.sh
  docker build -t staci/bitbucket:$version $STACI_HOME/images/bitbucket/context/ > $STACI_HOME/logs/bitbucket.build.log 2>&1 &
fi

# Build mysql database as atlassiandb
if [ "$start_mysql" == "1" ]; then
  echo " ----- Mysql"
  docker build -t staci/atlassiandb:$version $STACI_HOME/images/mysql/context/ > $STACI_HOME/logs/atlassiandb.build.log 2>&1 &
fi

# Build Crowd
if [ "$start_crowd" == "1" ]; then
  echo " ----- Crowd"
  docker build -t staci/crowd:$version $STACI_HOME/images/crowd/context/ > $STACI_HOME/logs/crowd.build.log 2>&1 &
fi

# Build Crucible
if [ "$start_crucible" == "1" ]; then
  echo " ----- Crucible"
  docker build -t staci/crucible:$version $STACI_HOME/images/crucible/context/ > $STACI_HOME/logs/crucible.build.log 2>&1 &
fi

wait

# clean up
if [ "$start_jira" == "1" ]; then
  rm $STACI_HOME/images/jira/context/setContextPath.sh
fi
if [ "$start_confluence" == "1" ]; then
  rm $STACI_HOME/images/confluence/context/setContextPath.sh
fi
if [ "$start_bamboo" == "1" ]; then
  rm $STACI_HOME/images/bamboo/context/setContextPath.sh
fi
if [ "$start_bitbucket" == "1" ]; then
  rm $STACI_HOME/images/bitbucket/context/setContextPath.sh
fi

