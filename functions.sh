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
    cat /tmp/server.crt /tmp/server.key > ${STORAGE_DIR}/haproxy/haproxy.pem
    echo "- Created SSL certificate for ${COMMON_NAME} as: ${STORAGE_DIR}/hapropxy/haproxy.pem"
}



function testDBReadiness-mysql() {

while [ $ATTEMPT -le 59 ]; do
  ATTEMPT=$(( $ATTEMPT + 1 ))
  STATUS=$(docker exec  atlassiandb mysqladmin --user=root --password=${MYSQL_ROOT_PASSWORD} ping 2> /dev/null | grep 'alive')
  if [ "${STATUS}" == "mysqld is alive"  ]; then
    echo "Done."
    echo "- MySQL DB is up! (and accepting connections!)"
    break
  else
    echo -n "."
    sleep 1
  fi
done

}


function testDBReadiness-postgres() {

while [ $ATTEMPT -le 59 ]; do
  ATTEMPT=$(( $ATTEMPT + 1 ))
  STATUS=$(docker exec  atlassiandb pg_isready   2> /dev/null  )
  if [ "${STATUS}" == "/var/run/postgresql:5432 - accepting connections"  ]; then
    echo "Done."
    echo "- Postgres DB is up! (and accepting connections!)"
    break
  else
    echo -n "."
    sleep 1
  fi
done

}






