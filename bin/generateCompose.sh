#!/bin/sh
source $STACI_HOME/functions/tools.f

# Set version of images
version=$(getProperty "imageVersion")

# Find out what to start
start_mysql=$(getProperty "start_mysql")
start_jira=$(getProperty "start_jira")
start_confluence=$(getProperty "start_confluence")
start_bamboo=$(getProperty "start_bamboo")
volume_dir=$(getProperty "volume_dir")

# Check if a database will be needed
if [ "$start_mysql" == "1" ]; then
   dblink="links:
    - atlassiandb
"
else
   dblink=""
fi

# Printing Jira specific yml
if [ "$start_jira" == "1" ]; then
cat << EOF
jira:
  image: staci/jira:$version
  expose:
    - "8080"
  ports:
    - "8080:8080"
  volumes:
    - $volume_dir/jira:/var/atlassian/jira
  $dblink
EOF
fi

# Printing Confluence specific yml
if [ "$start_confluence" == "1" ]; then
cat << EOF
confluence:
  image: staci/confluence:$version
  expose:
    - "8090"
  ports:
    - "8090:8090"
  volumes:
    - $volume_dir/confluence:/var/atlassian/confluence
  $dblink
EOF
fi

# Printing Bamboo specific yml
if [ "$start_bamboo" == "1" ]; then
cat << EOF
bamboo:
  image: staci/bamboo:$version
  expose:
    - "8085"
    - "54663"
  ports:
    - "8085:8085"
    - "54663:54663"
  volumes:
    - $volume_dir/bamboo:/var/lib/bamboo
  $dblink
EOF
fi

# Printing database specific yml
if [ "$start_mysql" == "1" ]; then
cat << EOF
atlassiandb:
  image: staci/atlassiandb:$version
  expose:
    - "3306"
  volumes:
    - "/data/jira/atlassiandb:/var/lib/mysql"
  environment:
    - MYSQL_ROOT_PASSWORD="pw"
    - MYSQL_PASSWORD="nlpw"
    - MYSQL_USER="jira"
EOF
fi
