#! /bin/bash
source $STACI_HOME/functions/tools.f
source $STACI_HOME/functions/dockermachine.f


# Set version of images
version=$(getProperty "imageVersion")


function buildBaseImage(){
  echo "  # Building base image, please wait..."

  if [ "$cluster" == "1" ]; then
    if [ "$start_jira" == "1"  ];then
      echo "   - Building base image on Jira instance."
      eval $(docker-machine env "$node_prefix-jira")
      docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.jira.build.log 2>&1 &
    fi

    if [ "$start_confluence" == "1" ]; then
      echo "   - Building base image on Confluence instance."
      eval $(docker-machine env "$node_prefix-confluence")
      docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.confluence.build.log 2>&1 &
    fi 

    if [ "$start_bamboo" == "1" ]; then
      echo "   - Building base image on Bamboo instance."
      eval $(docker-machine env "$node_prefix-bamboo")
      docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.bamboo.build.log 2>&1 &
    fi

    if [ "$start_bitbucket" == "1" ]; then
      echo "   - Building base image on Bitbucket instance."
      eval $(docker-machine env "$node_prefix-bitbucket")
      docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.bitbucket.build.log 2>&1 &
    fi

    if [ "$start_crowd" == "1" ]; then
      echo "   - Building base image on Crowd instance."
      eval $(docker-machine env "$node_prefix-crowd")
      docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.crowd.build.log 2>&1 &
    fi

    if [ "$start_crucible" == "1" ]; then
      echo "   - Building base image on Crucible instance."
      eval $(docker-machine env "$node_prefix-crucible")
      docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.crucible.build.log 2>&1 &
    fi

  else
    echo "    - Building base image locally."
    docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.local.build.log 2>&1
  fi

  wait
}

function buildJira(){
  if [ "$start_jira" == "1"  ];then
    if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-jira")
    fi
    jiraContextPath=$(getProperty "jira_contextpath")
    jiraContextPath='\'$jiraContextPath

    echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$jiraContextPath\"/g' /opt/atlassian/jira/conf/server.xml" > $STACI_HOME/images/jira/context/setContextPath.sh
    chmod u+x $STACI_HOME/images/jira/context/setContextPath.sh
    echo "   - Building Jira image"
    docker build -t staci/jira:$version $STACI_HOME/images/jira/context/ > $STACI_HOME/logs/jira.build.log 2>&1 &
  fi
}

function buildConfluence(){
  if [ "$start_confluence" == "1" ]; then
    if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-confluence")
    fi
    confluenceContextPath=$(getProperty "confluence_contextpath")
    confluenceContextPath='\'$confluenceContextPath
    echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$confluenceContextPath\"/g' /opt/atlassian/confluence/conf/server.xml" > $STACI_HOME/images/confluence/context/setContextPath.sh
    chmod u+x $STACI_HOME/images/confluence/context/setContextPath.sh
    echo "   - Building Confluence image"
    docker build -t staci/confluence:$version $STACI_HOME/images/confluence/context/ > $STACI_HOME/logs/confluence.build.log 2>&1 &
  fi
}

function buildBamboo(){
  if [ "$start_bamboo" == "1" ]; then
    if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-bamboo")
    fi
    bambooContextPath=$(getProperty "bamboo_contextpath")
    bambooContextPath='\'$bambooContextPath
    echo "sed -i -e 's/<Context path=\"\"/<Context path=\"$bambooContextPath\"/g' /opt/atlassian/bamboo/conf/server.xml" > $STACI_HOME/images/bamboo/context/setContextPath.sh
    chmod u+x $STACI_HOME/images/bamboo/context/setContextPath.sh
    echo "   - Building Bamboo image"
    docker build -t staci/bamboo:$version $STACI_HOME/images/bamboo/context/ > $STACI_HOME/logs/bamboo.build.log 2>&1 &
  fi
}

function buildBitbucket(){
  if [ "$start_bitbucket" == "1" ]; then
    if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-bitbucket")
    fi
    bitbucketContextPath=$(getProperty "bitbucket_contextpath")
    bitbucketContextPath='\'$bitbucketContextPath
    echo "sed -i -e 's/path=\"\"/path=\"$bitbucketContextPath\"/g' /opt/atlassian/bitbucket/conf/server.xml" > $STACI_HOME/images/bitbucket/context/setContextPath.sh
    chmod u+x $STACI_HOME/images/bitbucket/context/setContextPath.sh
    echo "   - Building Bitbucket image"
    docker build -t staci/bitbucket:$version $STACI_HOME/images/bitbucket/context/ > $STACI_HOME/logs/bitbucket.build.log 2>&1 &
  fi
}

function buildMySQL(){
  if [ "$start_mysql" == "1" ]; then
    if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-mysql")
    fi
    echo "   - Building MySQL image"
    docker build -t staci/atlassiandb:$version $STACI_HOME/images/mysql/context/ > $STACI_HOME/logs/atlassiandb.build.log 2>&1 &
  fi
}

function buildCrowd(){
  if [ "$start_crowd" == "1" ]; then
    if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-crowd")
    fi
    echo "   - Building Crowd image"
    docker build -t staci/crowd:$version $STACI_HOME/images/crowd/context/ > $STACI_HOME/logs/crowd.build.log 2>&1 &
  fi
}

function buildCrucible(){
  if [ "$start_crucible" == "1" ]; then
    if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-crucible")
    fi
    $STACI_HOME/bin/generate_crucible_config.sh > $STACI_HOME/images/crucible/context/configure.sh
    echo "   - Building Crucible image"
    docker build -t staci/crucible:$version $STACI_HOME/images/crucible/context/ > $STACI_HOME/logs/crucible.build.log 2>&1 &
  fi
}

function buildAtlassian(){
  echo "  # Building Atlassian, please wait..."
    buildJira 
    buildConfluence 
    buildBamboo 
    buildBitbucket 
    buildMySQL 
    buildCrowd 
    buildCrucible    

  wait

}

function buildAll(){
  start_jira=$(getProperty "start_jira")
  start_confluence=$(getProperty "start_confluence")
  start_bamboo=$(getProperty "start_bamboo")
  start_crowd=$(getProperty "start_crowd")
  start_bitbucket=$(getProperty "start_bitbucket")
  start_crucible=$(getProperty "start_crucible")
  start_mysql=$(getProperty "start_mysql")
  cluster=$(getProperty "createCluster")
  node_prefix=$(getProperty "clusterNodePrefix")

  buildBaseImage 
  buildAtlassian
}
