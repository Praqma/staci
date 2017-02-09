#!/bin/bash
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
start_jenkins=$(getProperty "start_jenkins")
start_artifactory=$(getProperty "start_artifactory")
start_haproxy=$(getProperty "start_haproxy")

volume_dir=$(getProperty "volume_dir")
timezone=$(getProperty "time_zone")

node_prefix=$(getProperty "clusterNodePrefix")
cluster=$(getProperty "createCluster")
provider_type=$(getProperty "provider_type")

# Printing version and header

cat << EOF
version: '2'

services:
EOF


# Printing Bitbucket specific yml
if [ "$start_bitbucket" == "1" ]; then
if [ "$cluster" == 1 ]; then
  cluster_opts='    environment:
      - "constraint:node=='$node_prefix'-bitbucket"
    networks:
      - back'
else
  if [ ! "$provider_type" == "none" ];then
    cluster_opts=''
  else
    cluster_opts='    volumes:
      - '$volume_dir'/bitbucket:/var/atlassian/bitbucket'
  fi
fi

cat << EOF
  bitbucket:
    image: staci/bitbucket:$version
    container_name: bitbucket
    hostname: bitbucket
    ports:
      - "7999:7999"
$cluster_opts
EOF
fi

# Printing Crowd specific yml
if [ "$start_crowd" == "1" ]; then
if [ "$cluster" == 1 ]; then
  cluster_opts='    environment:
      - "constraint:node=='$node_prefix'-crowd"
    networks:
      - back'
else
  if [ ! "$provider_type" == "none" ];then
    cluster_opts=''
  else
    cluster_opts='    volumes:
    - '$volume_dir'/crowd:/var/atlassian/crowd'
  fi
fi

cat << EOF
  crowd:
    image: staci/crowd:$version
    container_name: crowd
    hostname: crowd
$cluster_opts
EOF
fi

# Printing Crucible specific yml
if [ "$start_crucible" == "1" ]; then
if [ "$cluster" == 1 ]; then
  cluster_opts='    environment:
      - "constraint:node=='$node_prefix'-crucible"
    networks:
      - back'
else
  if [ ! "$provider_type" == "none" ];then
    cluster_opts=''
  else
    cluster_opts='    volumes:
    - '$volume_dir'/crucible:/var/atlassian/crucible'
  fi
fi

cat << EOF
  crucible:
    image: staci/crucible:$version
    container_name: crucible
    hostname: crucible
$cluster_opts
EOF
fi

# Printing Jira specific yml
if [ "$start_jira" == "1" ]; then
jira_xms=$(getProperty "jira_xms")
jira_xmx=$(getProperty "jira_xmx")
jira_session_cookie_name=$(getProperty "jira_session_cookie_name")
jira_plugin_wait=$(getProperty "jira_plugin_wait")


if [ "$cluster" == 1 ]; then
  cluster_opts='    environment:
      - "constraint:node=='$node_prefix'-jira"
      - CATALINA_OPTS="-Datlassian.plugins.enable.wait='$jira_plugin_wait'" "-Xmx'$jira_xmx'" "-Xms'$jira_xms'" "-Dorg.apache.catalina.SESSION_COOKIE_NAME='$jira_session_cookie_name'" "-Duser.timezone='$timezone'"
    networks:
      - back'
else
  if [ ! "$provider_type" == "none" ];then
    cluster_opts='    environment:
      - CATALINA_OPTS="-Datlassian.plugins.enable.wait='$jira_plugin_wait'" "-Xmx'$jira_xmx'" "-Xms'$jira_xms'" "-Dorg.apache.catalina.SESSION_COOKIE_NAME='$jira_session_cookie_name'" "-Duser.timezone='$timezone'"'
  else
    cluster_opts='    environment:
      - CATALINA_OPTS="-Datlassian.plugins.enable.wait='$jira_plugin_wait'" "-Xmx'$jira_xmx'" "-Xms'$jira_xms'" "-Dorg.apache.catalina.SESSION_COOKIE_NAME='$jira_session_cookie_name'" "-Duser.timezone='$timezone'"
    volumes:
      - '$volume_dir'/jira:/var/atlassian/jira'
  fi
fi

cat << EOF
  jira:
    image: staci/jira:$version
    container_name: jira
    hostname: jira
$cluster_opts
EOF
fi

# Printing Confluence specific yml
if [ "$start_confluence" == "1" ]; then
confluence_xms=$(getProperty "confluence_xms")
confluence_xmx=$(getProperty "confluence_xmx")
confluence_session_cookie_name=$(getProperty "confluence_session_cookie_name")

if [ "$cluster" == 1 ]; then
  cluster_opts='    environment:
      - "constraint:node=='$node_prefix'-confluence"
      - CATALINA_OPTS="-Xmx'$confluence_xmx'" "-Xms'$confluence_xms'" "-Dorg.apache.catalina.SESSION_COOKIE_NAME='$confluence_session_cookie_name'" "-Duser.timezone='$timezone'"
    networks:
      - back'
else
  if [ ! "$provider_type" == "none" ];then
    cluster_opts='    environment:
      - CATALINA_OPTS="-Xmx'$confluence_xmx'" "-Xms'$confluence_xms'" "-Dorg.apache.catalina.SESSION_COOKIE_NAME='$confluence_session_cookie_name'" "-Duser.timezone='$timezone'"'
  else
    cluster_opts='    environment:
      - CATALINA_OPTS="-Xmx'$confluence_xmx'" "-Xms'$confluence_xms'" "-Dorg.apache.catalina.SESSION_COOKIE_NAME='$confluence_session_cookie_name'" "-Duser.timezone='$timezone'"
    volumes:
      - '$volume_dir'/confluence:/var/atlassian/confluence'
  fi
fi

cat << EOF
  confluence:
    image: staci/confluence:$version
    container_name: confluence
    hostname: confluence
$cluster_opts
EOF
fi

# Printing Bamboo specific yml
if [ "$start_bamboo" == "1" ]; then

if [ "$cluster" == 1 ]; then
  cluster_opts='    environment:
      - "constraint:node=='$node_prefix'-bamboo"
    networks:
      - back'
else
  if [ ! "$provider_type" == "none" ];then
    cluster_opts=''
  else
    cluster_opts='    volumes:
      - '$volume_dir'/bamboo:/var/lib/bamboo'
  fi
fi

cat << EOF
  bamboo:
    image: staci/bamboo:$version
    container_name: bamboo
    hostname: bamboo
    expose:
      - "54663"
    ports:
      - "54663:54663"
$cluster_opts
EOF
fi

# Printing database specific yml
if [ "$start_mysql" == "1" ]; then
mysql_root_pass=$(getProperty "mysql_root_pass")

if [ "$cluster" == 1 ]; then
  cluster_opts='    environment:
      - MYSQL_ROOT_PASSWORD='$mysql_root_pass'
      - "constraint:node=='$node_prefix'-mysql"
    networks:
      - back'
else
  if [ ! "$provider_type" == "none" ];then
    cluster_opts='    environment:
      - MYSQL_ROOT_PASSWORD='$mysql_root_pass
  else
    cluster_opts='    environment:
      - MYSQL_ROOT_PASSWORD='$mysql_root_pass'
    volumes:
      - '$volume_dir'/atlassiandb:/var/lib/mysql'
  fi
fi

cat << EOF
  atlassiandb:
    image: staci/atlassiandb:$version
    container_name: atlassiandb
    hostname: atlassiandb
    expose:
      - "3306"
    ports:
      - "3306:3306"
$cluster_opts
EOF
fi

# Create network
if [ "$cluster" == "1" ]; then
cat << EOF
networks:
  back:
    driver: overlay

EOF
fi

#Printing jenkins specific yml
if [ "$start_jenkins" == "1" ]; then
if [ "$cluster" == 1 ]; then
  cluster_opts='    environment:
      - "constraint:node=='$node_prefix'-jenkins"
    networks:
      - back'
else
  if [ ! "$provider_type" == "none" ];then
    cluster_opts=''
  else
    cluster_opts='    volumes:
      - '$volume_dir'/jenkins:/var/atlassian/jenkins'
  fi
fi

cat << EOF
  jenkins:
    image: staci/jenkins:$version
    container_name: jenkins
    hostname: jenkins
    ports:
      - "50000:50000"
$cluster_opts
EOF
fi

#Printing artifactory specific yml
if [ "$start_artifactory" == "1" ]; then
if [ "$cluster" == 1 ]; then
  cluster_opts='    environment:
      - "constraint:node=='$node_prefix'-artifactory"
    networks:
      - back'
else
  if [ ! "$provider_type" == "none" ];then
    cluster_opts=''
  else
    cluster_opts='    volumes:
      - '$volume_dir'/artifactory:/var/atlassian/artifactory'
  fi
fi

cat << EOF
  artifactory:
    image: staci/artifactory:$version
    container_name: artifactory
    hostname: artifactory
$cluster_opts
EOF
fi

#Printing haproxy specific yml

if [ "$start_haproxy" == "1" ]; then
if [ "$cluster" == 1 ]; then
  cluster_opts='    environment:
      - "constraint:node=='$node_prefix'-haproxy"
    networks:
      - back'
else
  if [ ! "$provider_type" == "none" ];then
    cluster_opts=''
  else
    cluster_opts='    volumes:
      - '$volume_dir'/haproxy:/var/atlassian/haproxy'
  fi
fi

cat << EOF
  haproxy:
    image: staci/haproxy:$version
    container_name: haproxy
    hostname: haproxy
    depends_on:
      - atlassiandb
EOF
if [ "$start_jenkins" == "1" ]; then
cat << EOF
      - jenkins        
EOF
fi
if [ "$start_artifactory" == "1" ]; then
cat << EOF
      - artifactory
EOF
fi
if [ "$start_jira" == "1" ]; then
cat << EOF
      - jira
EOF
fi
if [ "$start_confluence" == "1" ]; then
cat << EOF
      - confluence
EOF
fi
if [ "$start_bamboo" == "1" ]; then
cat << EOF
      - bamboo
EOF
fi
if [ "$start_crowd" == "1" ]; then
cat << EOF
      - crowd
EOF
fi
if [ "$start_bitbucket" == "1" ]; then
cat << EOF
      - bitbucket
EOF
fi
if [ "$start_crucible" == "1" ]; then
cat << EOF
      - crucible
EOF
fi
cat << EOF
    ports:
      - "443:443"
      - "80:80"
$cluster_opts
EOF
fi
