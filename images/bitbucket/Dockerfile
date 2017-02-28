FROM praqma/java_8

# Add staci user and set password
RUN useradd -u 1000 -m -s /bin/bash atlassian
RUN echo "atlassian:praqma" | chpasswd

# Configuration variables.
ENV BITBUCKET_HOME     /var/atlassian/bitbucket
ENV BITBUCKET_INSTALL  /opt/atlassian/bitbucket
ENV BITBUCKET_VERSION  4.10.1

# Define memory usage for tomcat
ENV Xms           512m
ENV Xmx           1512m

# Install Atlassian Bitbucket, tools and setup initial home directory structure.
COPY atlassian-bitbucket-4.10.1.tar.gz "${BITBUCKET_INSTALL}/atlassian-bitbucket-4.10.1.tar.gz"

# Copy our custom (superior) server.xml file in the correct location: :)
COPY server.xml /tmp

RUN set -x \
    && apt-get install git perl -y \
    && mkdir -p               "${BITBUCKET_HOME}/lib" \
    && chmod -R 700           "${BITBUCKET_HOME}" \
    && chown -R atlassian:atlassian "${BITBUCKET_HOME}" \
    && mkdir -p               "${BITBUCKET_INSTALL}" \
    && tar -xzf "${BITBUCKET_INSTALL}/atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz" --directory  "${BITBUCKET_INSTALL}" --strip-components=1 --no-same-owner \
    && rm -f "${BITBUCKET_INSTALL}/atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz" \
    && cp /tmp/server.xml /opt/atlassian/bitbucket/conf/server.xml \
    && chmod -R 700           "${BITBUCKET_INSTALL}/conf" \
    && chmod -R 700           "${BITBUCKET_INSTALL}/logs" \
    && chmod -R 700           "${BITBUCKET_INSTALL}/temp" \
    && chmod -R 700           "${BITBUCKET_INSTALL}/work" \
    && chown -R atlassian:atlassian "${BITBUCKET_INSTALL}/conf" \
    && chown -R atlassian:atlassian "${BITBUCKET_INSTALL}/logs" \
    && chown -R atlassian:atlassian "${BITBUCKET_INSTALL}/temp" \
    && chown -R atlassian:atlassian "${BITBUCKET_INSTALL}/work" \
    && ln --symbolic          "/usr/lib/x86_64-linux-gnu/libtcnative-1.so" "${BITBUCKET_INSTALL}/lib/native/libtcnative-1.so" \
    && sed --in-place         's/^# umask 0027$/umask 0027/g' "${BITBUCKET_INSTALL}/bin/setenv.sh" \
    && xmlstarlet             ed --inplace \
        --delete              "Server/Service/Engine/Host/@xmlValidation" \
        --delete              "Server/Service/Engine/Host/@xmlNamespaceAware" \
                              "${BITBUCKET_INSTALL}/conf/server.xml" \
    && sed -ri 's/JVM_MINIMUM_MEMORY="512m"/JVM_MINIMUM_MEMORY="'"${Xms}"'"/' $BITBUCKET_INSTALL/bin/setenv.sh \
    && sed -ri 's/JVM_MAXIMUM_MEMORY="768m"/JVM_MAXIMUM_MEMORY="'"${Xmx}"'"/' $BITBUCKET_INSTALL/bin/setenv.sh

# Getting the MySQL driver
COPY mysql-connector-java-5.1.36.tar.gz "${BITBUCKET_INSTALL}/mysql-connector-java-5.1.36.tar.gz"
RUN tar -xzf "${BITBUCKET_INSTALL}/mysql-connector-java-5.1.36.tar.gz" --directory "${BITBUCKET_INSTALL}/lib/" --strip-components=1 --no-same-owner
RUN rm -f "${BITBUCKET_INSTALL}/mysql-connector-java-5.1.36.tar.gz"

# Add /bitbucket Context Path
# COPY setContextPath.sh /tmp/setContextPath.sh
# RUN /tmp/setContextPath.sh

# Use the user atlassian to run Jira.
USER atlassian:atlassian

# Expose default HTTP connector port.
EXPOSE 7990 7999

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/atlassian/bitbucket"]

# Set the default working directory as the installation directory.
WORKDIR ${BITBUCKET_HOME}

# Run Atlassian Bitbucket as a foreground process by default.
CMD ["/opt/atlassian/bitbucket/bin/start-bitbucket.sh", "-fg"]
