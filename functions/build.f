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
    
    if [ "$start_jenkins" == "1" ]; then
      echo "   - Building base image on Jenkins instance."
      eval $(docker-machine env "$node_prefix-jenkins")
      docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.jenkins.build.log 2>&1 &
    fi
    if [ "$start_artifactory" == "1" ]; then
      echo "   - Building base image on aritfactory instance."
      eval $(docker-machine env "$node_prefix-artifactory")
      docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.artifactory.build.log 2>&1 &
    fi
    
    if [ "$start_haproxy" == "1" ]; then
      echo "   - Building base image on haproxy instance."
      eval $(docker-machine env "$node_prefix-haproxy")
      docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.haproxy.build.log 2>&1 &
    fi

  else
    if [ ! "$provider_type" == "none" ];then
      node_prefix=$(getProperty "clusterNodePrefix")
      eval $(docker-machine env $node_prefix-Atlassian)
    fi

    echo "    - Building base image."
    docker build -t staci/base:$version $STACI_HOME/images/base/context/ > $STACI_HOME/logs/base.local.build.log 2>&1
  fi

  wait
}

function buildJira(){
  if [ "$start_jira" == "1"  ];then
    if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-jira")
    else
      if [ ! "$provider_type" == "none" ];then
        node_prefix=$(getProperty "clusterNodePrefix")
        eval $(docker-machine env $node_prefix-Atlassian)
      fi
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
    else
      if [ ! "$provider_type" == "none" ];then
        node_prefix=$(getProperty "clusterNodePrefix")
        eval $(docker-machine env $node_prefix-Atlassian)
      fi
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
    else
      if [ ! "$provider_type" == "none" ];then
        node_prefix=$(getProperty "clusterNodePrefix")
        eval $(docker-machine env $node_prefix-Atlassian)
      fi
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
    else
      if [ ! "$provider_type" == "none" ];then
        node_prefix=$(getProperty "clusterNodePrefix")
        eval $(docker-machine env $node_prefix-Atlassian)
      fi
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
    else
      if [ ! "$provider_type" == "none" ];then
        node_prefix=$(getProperty "clusterNodePrefix")
        eval $(docker-machine env $node_prefix-Atlassian)
      fi
    fi
    echo "   - Building MySQL image"
    docker build -t staci/atlassiandb:$version $STACI_HOME/images/mysql/context/ > $STACI_HOME/logs/atlassiandb.build.log 2>&1 &
  fi
}

function buildCrowd(){
  if [ "$start_crowd" == "1" ]; then
    if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-crowd")
    else
      if [ ! "$provider_type" == "none" ];then
        node_prefix=$(getProperty "clusterNodePrefix")
        eval $(docker-machine env $node_prefix-Atlassian)
      fi
    fi
    echo "   - Building Crowd image"
    docker build -t staci/crowd:$version $STACI_HOME/images/crowd/context/ > $STACI_HOME/logs/crowd.build.log 2>&1 &
  fi
}

function buildCrucible(){
  if [ "$start_crucible" == "1" ]; then
    if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-crucible")
    else
      if [ ! "$provider_type" == "none" ];then
        node_prefix=$(getProperty "clusterNodePrefix")
        eval $(docker-machine env $node_prefix-Atlassian)
      fi
    fi
    $STACI_HOME/bin/generate_crucible_config.sh > $STACI_HOME/images/crucible/context/configure.sh
    echo "   - Building Crucible image"
    docker build -t staci/crucible:$version $STACI_HOME/images/crucible/context/ > $STACI_HOME/logs/crucible.build.log 2>&1 &
  fi
}

function buildJenkins(){
  if [ "$start_jenkins" == "1" ]; then
    if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-jenkins")
    else
      if [ ! "$provider_type" == "none" ];then
        node_prefix=$(getProperty "clusterNodePrefix")
        eval $(docker-machine env $node_prefix-Atlassian)
      fi
    fi
    jenkinsContextPath=$(getProperty "jenkins_contextpath")
    jenkinsContextPath='\'$jenkinsContextPath
    echo "sed -i -e 's/path=\"\"/path=\"$jenkinsContextPath\"/g' /opt/atlassian/jenkins/conf/server.xml" > $STACI_HOME/images/jenkins/context/setContextPath.sh
    chmod u+x $STACI_HOME/images/jenkins/context/setContextPath.sh
    echo "   - Building jenkins image"
    docker build -t staci/jenkins:$version $STACI_HOME/images/jenkins/context/ > $STACI_HOME/logs/jenkins.build.log 2>&1 &
  fi
}

function buildArtifactory(){
  if [ "$start_artifactory" == "1" ]; then
    if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-artifactory")
    else
      if [ ! "$provider_type" == "none" ];then
        node_prefix=$(getProperty "clusterNodePrefix")
        eval $(docker-machine env $node_prefix-Atlassian)
      fi
    fi
    artifactoryContextPath=$(getProperty "artifactory_contextpath")
    artifactoryContextPath='\'$artifactoryContextPath
    echo "sed -i -e 's/path=\"\"/path=\"$artifactoryContextPath\"/g' /opt/atlassian/artifactory/conf/server.xml" > $STACI_HOME/images/artifactory/context/setContextPath.sh
    chmod u+x $STACI_HOME/images/artifactory/context/setContextPath.sh
    echo "   - Building artifactory image"
    docker build -t staci/artifactory:$version $STACI_HOME/images/artifactory/context/ > $STACI_HOME/logs/artifactory.build.log 2>&1 &
  fi
}

function buildHaproxy(){
  if [ "$start_haproxy" == "1" ]; then
    if [ "$cluster" == "1" ]; then
      eval $(docker-machine env "$node_prefix-haproxy")
    else
      if [ ! "$provider_type" == "none" ];then
        node_prefix=$(getProperty "clusterNodePrefix")
        eval $(docker-machine env $node_prefix-Atlassian)
      fi
    fi
    haproxyContextPath=$(getProperty "haproxy_contextpath")
    haproxyContextPath='\'$haproxyContextPath
    echo "sed -i -e 's/path=\"\"/path=\"haproxyContextPath\"/g' /opt/atlassian/haproxy/conf/server.xml" > $STACI_HOME/images/haproxy/context/setContextPath.sh
    chmod u+x $STACI_HOME/images/haproxy/context/setContextPath.sh
    echo "   - Building artifactory image"
    docker build -t staci/haproxy:$version $STACI_HOME/images/haproxy/context/ > $STACI_HOME/logs/haproxy.build.log 2>&1 &
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
    buildJenkins
    buildArtifactory
    buildHaproxy

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
  start_jenkins=$(getProperty "start_jenkins")
  start_artifactory=$(getProperty "start_artifactory")
  start_haproxy=$(getProperty "start_haproxy")
  cluster=$(getProperty "createCluster")
  node_prefix=$(getProperty "clusterNodePrefix")

  buildBaseImage 
  buildAtlassian
}
