FROM ubuntu:vivid

ENV BAMBOO_HOME=/var/lib/bamboo \
    BAMBOO_INSTALL=/opt/atlassian/bamboo \
    BAMBOO_UID=1000 \
    BAMBOO_USER=atlassian \
    BAMBOO_GID=1000 \
    BAMBOO_GROUP=atlassian \
    BAMBOO_VERSION=5.9.4 \
#
    DOCKER_GID=999 \
    DOCKER_GROUP=docker \
    DOCKER_VERSION=1.8.1 \
#
    JAVA_HOME=/usr/lib/jvm/java-8-oracle \
    JAVA_VERSION=8 \
    JAVA_UPDATE=60

RUN set -x \
 && export DEBIAN_FRONTEND=noninteractive \
### Install ca-certificates so that wget won't complain about the cert for the Oracle downloads site
 && apt-get --assume-yes --no-install-recommends install \
        ca-certificates \
### Add the Oracle JDK repo and pre-acknowledge the licenses
 && apt-key adv --keyserver hkp://p80.pool.sks-keyservers.net:80 --recv-keys 7B2C3B0889BF5709A105D03AC2518248EEA14886 \
 && echo deb http://ppa.launchpad.net/webupd8team/java/ubuntu vivid main > /etc/apt/sources.list.d/webupd8team-ubuntu-java-vivid.list \
 && echo oracle-java${JAVA_VERSION}-installer shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
 && echo oracle-java${JAVA_VERSION}-unlimited-jce-policy shared/accepted-oracle-license-v1-1 select true | debconf-set-selections \
### Get an updated list of packages that can be installed/upgraded which will now include the Oracle JDKs
 && apt-get update \
### Install Oracle JDK, making it the default JVM
 && apt-get --assume-yes --no-install-recommends install \
        oracle-java${JAVA_VERSION}-installer=${JAVA_VERSION}u${JAVA_UPDATE}* \
        oracle-java${JAVA_VERSION}-unlimited-jce-policy=${JAVA_VERSION}u${JAVA_UPDATE}* \
        oracle-java${JAVA_VERSION}-set-default=${JAVA_VERSION}u${JAVA_UPDATE}* \
### Install the Tomcat Native and APR shared objects
        libapr1 \
        libaprutil1 \
        libtcnative-1 \
### Install curl, git, ssh, wget, and xmlstarlet along with ca-certificates-java
        ca-certificates-java \
        curl \
        git \
        openssh-client \
        wget \
        xmlstarlet \
### Patch the ca-certificates-java script to use our Java
 && sed -i -e 's/java-6-sun/java-${JAVA_VERSION}-oracle/g' /etc/ca-certificates/update.d/jks-keystore \
 && update-ca-certificates \
### Modify the JDK installation to use our local cacerts
 && mv -v ${JAVA_HOME}/jre/lib/security/cacerts ${JAVA_HOME}/jre/lib/security/cacerts.original \
 && ln -vs /etc/ssl/certs/java/cacerts ${JAVA_HOME}/jre/lib/security/ \
### Let the JVM find the Tomcat Native and APR shared objects
 && ln -sv /usr/lib/x86_64-linux-gnu /usr/lib64 \
### Install Docker
 && mkdir -p /tmp \
 && wget --progress=dot:mega -P /tmp https://get.docker.com/builds/$(uname -s)/$(uname -i)/docker-${DOCKER_VERSION} \
 && mv -v /tmp/docker-${DOCKER_VERSION} /usr/bin/docker \
 && groupadd -rg ${DOCKER_GID} ${DOCKER_GROUP} \
 && chown -v root:${DOCKER_GROUP} /usr/bin/docker \
 && chmod -v +xs /usr/bin/docker \
### Install Bamboo
 && mkdir -p ${BAMBOO_INSTALL} ${BAMBOO_HOME} \
 && groupadd -g ${BAMBOO_GID} ${BAMBOO_GROUP} \
 && useradd -d ${BAMBOO_INSTALL} -u ${BAMBOO_UID} -g ${BAMBOO_GID} -G ${DOCKER_GROUP} -c "Atlassian Bamboo" ${BAMBOO_USER} \
 && wget --progress=dot:mega -O- "https://www.atlassian.com/software/bamboo/downloads/binary/atlassian-bamboo-${BAMBOO_VERSION}.tar.gz" | tar -xz --strip=1 -C "${BAMBOO_INSTALL}" \
 && echo "bamboo.home=${BAMBOO_HOME}" > ${BAMBOO_INSTALL}/atlassian-bamboo/WEB-INF/classes/bamboo-init.properties \
 && chmod -R 700 ${BAMBOO_INSTALL} ${BAMBOO_HOME} \
 && chown -R ${BAMBOO_USER}:${BAMBOO_GROUP} \
        ${BAMBOO_HOME} \
        ${BAMBOO_INSTALL} \
        /etc/default/cacerts \
        /etc/java-${JAVA_VERSION}-oracle \
        /etc/ssl \
 && find ${BAMBOO_INSTALL} -name "*.sh" | xargs chmod -v +x \
### Cleanup
 && apt-get clean \
 && rm -rf \
        /etc/java-6-sun \
        /tmp/* \
        /var/tmp/* \
        /var/cache/oracle-* \
        /var/lib/apt/lists/*

COPY src/main/container/srv/ /srv/
### Not a fan of the extra layer but I am very much a fan of docker build caching many megabytes of lower layers
RUN set -x \
 && find /srv/ -name "*.sh" | xargs chmod -v +x

# Getting the MySQL driver
RUN curl -Ls "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.36.tar.gz" | tar -xz --directory "${BAMBOO_INSTALL}/lib/" --strip-components=1 --no-same-owner

USER ${BAMBOO_USER}:${BAMBOO_GROUP}

VOLUME ["${BAMBOO_HOME}"]

#      HTTP MASTER
EXPOSE 8085 54663

WORKDIR ${BAMBOO_INSTALL}

ENTRYPOINT ["/srv/bamboo.sh"]
CMD ["server"]
