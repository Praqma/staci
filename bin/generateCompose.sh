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

volume_dir=$(getProperty "volume_dir")
timezone=$(getProperty "time_zone")

# Printing Bitbucket specific yml
if [ "$start_bitbucket" == "1" ]; then
cat << EOF
bitbucket:
  image: staci/bitbucket:$version
  container_name: bitbucket
  hostname: bitbucket
  expose:
    - "7990"
    - "7999"
  ports:
    - "7990:7990"
    - "7999:7999"
#  volumes:
#    - $volume_dir/bitbucket:/var/atlassian/bitbucket
EOF
fi

# Printing Crowd specific yml
if [ "$start_crowd" == "1" ]; then
cat << EOF
crowd:
  image: staci/crowd:$version
  container_name: crowd
  hostname: crowd
  expose:
    - "8095"
  ports:
    - "8095:8095"
#  volumes:
#    - $volume_dir/crowd:/var/atlassian/crowd
EOF
fi

# Printing Crucible specific yml
if [ "$start_crucible" == "1" ]; then
cat << EOF
crucible:
  image: staci/crucible:$version
  container_name: crucible
  hostname: crowd
  expose:
    - "8060"
  ports:
    - "8060:8060"
#  volumes:
#    - $volume_dir/crucible:/var/atlassian/crucible
EOF
fi

# Printing Jira specific yml
if [ "$start_jira" == "1" ]; then
jira_xms=$(getProperty "jira_xms")
jira_xmx=$(getProperty "jira_xmx")
jira_session_cookie_name=$(getProperty "jira_session_cookie_name")
jira_plugin_wait=$(getProperty "jira_plugin_wait")

cat << EOF
jira:
  image: staci/jira:$version
  container_name: jira
  hostname: jira
  expose:
    - "8080"
  ports:
    - "8080:8080"
#  volumes:
#    - $volume_dir/jira:/var/atlassian/jira
  environment:
    - CATALINA_OPTS="-Datlassian.plugins.enable.wait=$jira_plugin_wait" "-Xmx$jira_xmx" "-Xms$jira_xms" "-Dorg.apache.catalina.SESSION_COOKIE_NAME=$jira_session_cookie_name" "-Duser.timezone=$timezone"
EOF
fi

# Printing Confluence specific yml
if [ "$start_confluence" == "1" ]; then
cat << EOF
confluence:
  image: staci/confluence:$version
  container_name: confluence
  hostname: confluence
  expose:
    - "8090"
  ports:
    - "8090:8090"
#  volumes:
#    - $volume_dir/confluence:/var/atlassian/confluence
EOF
fi

# Printing Bamboo specific yml
if [ "$start_bamboo" == "1" ]; then
cat << EOF
bamboo:
  image: staci/bamboo:$version
  container_name: bamboo
  hostname: bamboo
  expose:
    - "8085"
    - "54663"
  ports:
    - "8085:8085"
    - "54663:54663"
#  volumes:
#    - $volume_dir/bamboo:/var/lib/bamboo
EOF
fi

# Printing database specific yml
if [ "$start_mysql" == "1" ]; then
cat << EOF
atlassiandb:
  image: staci/atlassiandb:$version
  container_name: atlassiandb
  hostname: atlassiandb
  expose:
    - "3306"
  ports:
    - "3306:3306"
#  volumes:
#    - $volume_dir/atlassiandb:/var/lib/mysql
  environment:
    - MYSQL_ROOT_PASSWORD=pass_word
EOF
fi
