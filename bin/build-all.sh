#! /bin/bash
source $STACI_HOME/functions/tools.f 
source $STACI_HOME/functions/dockermachine.f

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

cluster=$(getProperty "createCluster")
node_prefix=$(getProperty "clusterNodePrefix")

# Build our base image
if [ "$cluster" == "0" ]; then
  echo " --- Base image"
docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.build.log 2>&1 
fi

# Set context path and build Jira
if [ ! -z "$jiraContextPath" ] && [ "$start_jira" == "1" ]; then
  if [ "$cluster" == "1" ]; then
    eval $(docker-machine env "$node_prefix-jira")
    docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.build.log 2>&1
  fi
  echo " ----- Jira"
  jiraContextPath='\'$jiraContextPath
  echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$jiraContextPath\"/g' /opt/atlassian/jira/conf/server.xml" > $STACI_HOME/images/jira/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/jira/context/setContextPath.sh
  docker build -t staci/jira:$version $STACI_HOME/images/jira/context/ > $STACI_HOME/logs/jira.build.log 2>&1 &
fi

# Set context path and build Confluence
if [ ! -z "$confluenceContextPath" ] && [ "$start_confluence" == "1" ]; then
  if [ "$cluster" = "1" ]; then
    eval $(docker-machine env "$node_prefix-confluence")
    docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.build.log 2>&1
  fi
  echo " ----- Confluence"
  confluenceContextPath='\'$confluenceContextPath
  echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$confluenceContextPath\"/g' /opt/atlassian/confluence/conf/server.xml" > $STACI_HOME/images/confluence/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/confluence/context/setContextPath.sh
  docker build -t staci/confluence:$version $STACI_HOME/images/confluence/context/ > $STACI_HOME/logs/confluence.build.log 2>&1 &
fi

# Set context path and build Bamboo
if [ ! -z "$bambooContextPath" ] && [ "$start_bamboo" == "1" ]; then
  if [ "$cluster" = "1" ]; then
    eval $(docker-machine env "$node_prefix-bamboo")
    docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.build.log 2>&1
  fi
  echo " ----- Bamboo"
  bambooContextPath='\'$bambooContextPath
  echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$bambooContextPath\"/g' /opt/atlassian/bamboo/conf/server.xml" > $STACI_HOME/images/bamboo/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/bamboo/context/setContextPath.sh
  docker build -t staci/bamboo:$version $STACI_HOME/images/bamboo/context/ > $STACI_HOME/logs/bamboo.build.log 2>&1 &
fi

# Set context path and build Bitbucket
if [ ! -z "$bitbucketContextPath" ] && [ "$start_bitbucket" == "1" ]; then
  if [ "$cluster" = "1" ]; then
    eval $(docker-machine env "$node_prefix-bitbucket")
    docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.build.log 2>&1
  fi
  echo " ----- Bitbucket"
  bitbucketContextPath='\'$bitbucketContextPath
  echo "sed -i -e 's/path=\"\"/path=\"$bitbucketContextPath\"/g' /opt/atlassian/bitbucket/conf/server.xml" > $STACI_HOME/images/bitbucket/context/setContextPath.sh
  chmod u+x $STACI_HOME/images/bitbucket/context/setContextPath.sh
  docker build -t staci/bitbucket:$version $STACI_HOME/images/bitbucket/context/ > $STACI_HOME/logs/bitbucket.build.log 2>&1 &
fi

# Build mysql database as atlassiandb
if [ "$start_mysql" == "1" ]; then
  if [ "$cluster" = "1" ]; then
    eval $(docker-machine env "$node_prefix-mysql")
    docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.build.log 2>&1
  fi
  echo " ----- Mysql"
  docker build -t staci/atlassiandb:$version $STACI_HOME/images/mysql/context/ > $STACI_HOME/logs/atlassiandb.build.log 2>&1 &
fi

# Build Crowd
if [ "$start_crowd" == "1" ]; then
  if [ "$cluster" = "1" ]; then
    eval $(docker-machine env "$node_prefix-crowd")
    docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.build.log 2>&1
  fi
  echo " ----- Crowd"
  docker build -t staci/crowd:$version $STACI_HOME/images/crowd/context/ > $STACI_HOME/logs/crowd.build.log 2>&1 &
fi

# Build Crucible
if [ "$start_crucible" == "1" ]; then
  if [ "$cluster" = "1" ]; then
    eval $(docker-machine env "$node_prefix-crucible")
    docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.build.log 2>&1
  fi
  echo " ----- Crucible"
  $STACI_HOME/bin/generate_crucible_config.sh > $STACI_HOME/images/crucible/context/configure.sh
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

if [ "$cluster" = "1" ]; then
  eval $(docker-machine env --swarm "$node_prefix-mysql")
fi

