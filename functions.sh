#! /bin/bash


function generateSSLCertificate(){
    # Certificate specific variables:
    COUNTRY="NO"
    STATE="Oslo"
    LOCATION="Oslo"
    ORGANIZATION="Praqma" 
    ORG_UNIT="IT"

    # COMMON_NAME="server1.example.com"
    # COMMON_NAME="jenkins.example.com"
    # COMMON_NAME="example.com"
    # COMMON_NAME="*.example.com"

    COMMON_NAME="*.${DOMAIN_NAME}"

    # http://crohr.me/journal/2014/generate-self-signed-ssl-certificate-without-prompt-noninteractive-mode.html

    openssl genrsa -des3 -passout pass:x -out /tmp/server.pass.key 2048

    openssl rsa -passin pass:x -in /tmp/server.pass.key -out /tmp/server.key

    rm /tmp/server.pass.key 

    openssl req -new -key /tmp/server.key -out /tmp/server.csr \
        -subj "/C=${COUNTRY}/ST=${STATE}/L=${LOCATION}/O=${ORGANIZATION}/OU=${ORG_UNIT}/CN=${COMMON_NAME}"

    openssl x509 -req -days 365 -in /tmp/server.csr -signkey /tmp/server.key -out /tmp/server.crt

    # Combine /tmp/server.key and /tmp/server.crt into a single server.pem file. 
    cat /tmp/server.crt /tmp/server.key > ${CODE_TOP_DIR}/haproxy/haproxy.pem
    echo "- Created SSL certificate for ${COMMON_NAME} as: ${CODE_TOP_DIR}/hapropxy/haproxy.pem"
}



function testDBReadiness-mysql() {
ATTEMPT=0
RETURN_CODE=9

DB_CONTAINER="atlassiandb.${DOMAIN_NAME}"

while [ $ATTEMPT -le 59 ]; do
  ATTEMPT=$(( $ATTEMPT + 1 ))
  STATUS=$(docker exec  ${DB_CONTAINER} mysqladmin --user=root --password=${MYSQL_ROOT_PASSWORD} ping 2> /dev/null | grep 'alive')
  if [ "${STATUS}" == "mysqld is alive"  ]; then
    echo " Done."
    echo "- MySQL DB is up! (and accepting connections!)"
    RETURN_CODE=0
    break
  else
    echo -n "."
    sleep 1
  fi
done

if [ $RETURN_CODE -ne 0 ] ; then
  echo " attempt # ${ATTEMPT} - TIMEOUT !"
fi

return $RETURN_CODE
}


function testDBReadiness-postgres() {

# Postgres has a strange way of coming up. It comes up, then shutsdown again, then inits DB, then comes up again.
# So  testing only for pg_ready was not enough. As the system was incorrectly thinking that the DB is ready,
# whereas it used to go through a shutdown again and then come up later.
# That was the reason some of my init-databases.sh commands were failing. 
# In light of above, I have to first check for a string in postgres container logs.
# i.e. "PostgreSQL init process complete; ready for start up."

DB_CONTAINER="atlassiandb.${DOMAIN_NAME}"

INIT_STATUS=""

## SEARCH_STRING="PostgreSQL init process complete; ready for start up."
SEARCH_STRING="is ready to accept connections"

# echo "Waiting for Postges to complete it's init process ..."

while [ "${READY_STATUS}" == "" ]; do
   READY_STATUS=$(docker logs ${DB_CONTAINER} 2>&1 | grep  "$SEARCH_STRING")
   echo -n "."
   sleep 1
done
# echo  " Done"

ATTEMPT=0
RETURN_CODE=9

while [ $ATTEMPT -le 59 ]; do
  ATTEMPT=$(( $ATTEMPT + 1 ))
  STATUS=$(docker exec  ${DB_CONTAINER}  pg_isready   2> /dev/null)
  if [ "${STATUS}" == "/var/run/postgresql:5432 - accepting connections"  ]; then
    # echo " Done."
    # echo "- Postgres DB is up! (and accepting connections!)"
    RETURN_CODE=0
    break
  else
    echo -n "."
    sleep 1
  fi
done

# if [ $RETURN_CODE -ne 0 ] ; then
#   echo " attempt # ${ATTEMPT} - TIMEOUT !"
# fi

return $RETURN_CODE
}


