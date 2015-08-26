#!/bin/sh
source $STACI_HOME/functions/tools.f

# Set version of images
version=$(getProperty "imageVersion")

# Find out what to start
start_mysql=$(getProperty "start_mysql")
start_jira=$(getProperty "start_jira")
start_confluence=$(getProperty "start_confluence")
start_bamboo=$(getProperty "start_bamboo")

if [ "$start_mysql" == "1" ]; then
   dblink="links:
    - atlassiandb
"
else
   dblink=""
fi

if [ "$start_jira" == "1" ]; then
cat << EOF
jira:
  image: staci/jira:$version
  expose:
    - "8080"
  ports:
    - "8080:8080"
  $dblink
EOF

fi
if [ "$start_confluence" == "1" ]; then
cat << EOF
confluence:
  image: staci/confluence:$version
  expose:
    - "8090"
  ports:
    - "8090:8090"
  $dblink
EOF
fi

if [ "$start_bamboo" == "1" ]; then
cat << EOF
bamboo:
  image: staci/bamboo:$version
  expose:
    - "8085"
  ports:
    - "8085:8085"
  $dblink
EOF
fi

if [ "$start_mysql" == "1" ]; then
cat << EOF
atlassiandb:
  image: staci/atlassiandb:$version
  expose:
    - "3306"
  volumes:
    - "/data/jira/db/:/var/lib/mysql/"
  environment:
    - MYSQL_ROOT_PASSWORD="pw"
    - MYSQL_PASSWORD="nlpw"
    - MYSQL_USER="jira"
EOF
fi
