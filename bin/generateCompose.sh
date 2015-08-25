#!/bin/sh
source $STACI_HOME/functions/tools.f

# Set version of images
version=$(getProperty "imageVersion")

cat << EOF
jira:
  image: staci/jira:$version
  expose:
    - "8080"
  ports:
    - "8080:8080"
  links:
    - atlassiandb
confluence:
  image: staci/confluence:$version
  expose:
    - "8090"
  ports:
    - "8090:8090"
  links:
    - atlassiandb
bamboo:
  image: staci/bamboo:$version
  expose:
    - "8085"
  ports:
    - "8085:8085"
  links:
    - atlassiandb

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
