#!/bin/sh -e

bamboo_init() {
    if [ -d /srv/bamboo-$1.d ]; then
        for f in $(find /srv/bamboo-$1.d -type f | sort); do
            case "$f" in
                *.sh)   echo "$0: sourcing $f"; . "$f" ;;
                *)      echo "$0: ignoring $f" ;;
            esac
        done
    fi
}

case "$1" in
    agent)
        bamboo_init $1

        if [ -x ${BAMBOO_HOME}/bin/bamboo-agent.sh ]; then
            exec ${BAMBOO_HOME}/bin/bamboo-agent.sh console
        else
            exec java -Dbamboo.home=${BAMBOO_HOME} -jar \
                ${BAMBOO_INSTALL}/atlassian-bamboo/admin/agent/atlassian-bamboo-agent-installer-${BAMBOO_VERSION}.jar \
                http://${BAMBOO_SERVER:-bamboo}:8085/agentServer/
        fi
    ;;

    server)
        bamboo_init $1

        exec ${BAMBOO_INSTALL}/bin/start-bamboo.sh -fg
    ;;

    *)
        exec "$@"
    ;;
esac

