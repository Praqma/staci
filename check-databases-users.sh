#!/bin/bash

source ./setup.conf

DB_CONTAINER="atlassiandb"

function check_mysql_db() {
  echo "List of databases:"
  echo "------------------"


  echo "List of users:"
  echo "--------------"
}

function check_postgres_db() {

  echo "List of databases:"
  echo "------------------"
  docker exec ${DB_CONTAINER} psql -U postgres -c "\l"

  echo "List of users:"
  echo "--------------"
  docker exec ${DB_CONTAINER} psql -U postgres -c "\du"
}

echo
echo "Using DB provider: '${DB_PROVIDER}'"
echo "============================="
echo
# run the function depending on DB_PROVIDER
check_${DB_PROVIDER}_db 
