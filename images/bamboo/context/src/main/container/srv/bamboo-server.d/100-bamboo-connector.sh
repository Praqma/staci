#!/bin/sh

BAMBOO_SERVER_XML="/opt/atlassian/bamboo/conf/server.xml"
BAMBOO_CONNECTOR_SECURE_ATTR="secure"
BAMBOO_CONNECTOR_SCHEME_ATTR="scheme"
BAMBOO_CONNECTOR_PROXY_PORT_ATTR="proxyPort"
BAMBOO_CONNECTOR_PROXY_NAME_ATTR="proxyName"

if [ ! -z "${BAMBOO_CONNECTOR_PROXY_NAME}" ] && [ -z "$(xmlstarlet sel -t -c '//Connector[@proxyName]' ${BAMBOO_SERVER_XML})" ]; then
    BAMBOO_CONNECTOR_SECURE=${BAMBOO_CONNECTOR_SECURE:-true}
    BAMBOO_CONNECTOR_SCHEME=${BAMBOO_CONNECTOR_SCHEME:-https}
    BAMBOO_CONNECTOR_PROXY_PORT=${BAMBOO_CONNECTOR_PROXY_PORT:-443}

    echo "+${BAMBOO_SERVER_XML}://Connector[@port=8085] ${BAMBOO_CONNECTOR_SECURE_ATTR}=\"${BAMBOO_CONNECTOR_SECURE}\""
    echo "+${BAMBOO_SERVER_XML}://Connector[@port=8085] ${BAMBOO_CONNECTOR_SCHEME_ATTR}=\"${BAMBOO_CONNECTOR_SCHEME}\""
    echo "+${BAMBOO_SERVER_XML}://Connector[@port=8085] ${BAMBOO_CONNECTOR_PROXY_PORT_ATTR}=\"${BAMBOO_CONNECTOR_PROXY_PORT}\""
    echo "+${BAMBOO_SERVER_XML}://Connector[@port=8085] ${BAMBOO_CONNECTOR_PROXY_NAME_ATTR}=\"${BAMBOO_CONNECTOR_PROXY_NAME}\""

    xmlstarlet ed --inplace \
            --insert '//Connector[@port=8085]' -t attr -n ${BAMBOO_CONNECTOR_SECURE_ATTR} -v ${BAMBOO_CONNECTOR_SECURE} \
            --insert '//Connector[@port=8085]' -t attr -n ${BAMBOO_CONNECTOR_SCHEME_ATTR} -v ${BAMBOO_CONNECTOR_SCHEME} \
            --insert '//Connector[@port=8085]' -t attr -n ${BAMBOO_CONNECTOR_PROXY_PORT_ATTR} -v ${BAMBOO_CONNECTOR_PROXY_PORT} \
            --insert '//Connector[@port=8085]' -t attr -n ${BAMBOO_CONNECTOR_PROXY_NAME_ATTR} -v ${BAMBOO_CONNECTOR_PROXY_NAME} \
        ${BAMBOO_SERVER_XML}
fi

echo "=${BAMBOO_SERVER_XML}:"
xmlstarlet sel -t -c '//Connector[@port=8085]' ${BAMBOO_SERVER_XML} | fold -s | sed -e '2,$s/^/    /g' -e 's/^/    /g'
echo

