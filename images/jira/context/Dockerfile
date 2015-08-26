#FROM java:8
FROM airdock/oracle-jdk:1.8

# Configuration variables.
ENV JIRA_HOME     /var/atlassian/jira
ENV JIRA_INSTALL  /opt/atlassian/jira
ENV JIRA_VERSION  6.4.10

# Add luci user and set password
RUN useradd -u 1000 -ms /bin/bash atlassian
RUN echo "atlassian:praqma" | chpasswd

# Install Atlassian JIRA and helper tools and setup initial home
# directory structure.
RUN set -x \
    && apt-get update --quiet \
    && apt-get install --quiet --yes --no-install-recommends libtcnative-1 xmlstarlet \
    && apt-get clean \
    && mkdir -p                     "${JIRA_HOME}" \
    && chmod -R 700                 "${JIRA_HOME}" \
    && chown -R atlassian:atlassian "${JIRA_HOME}" \
    && mkdir -p                     "${JIRA_INSTALL}/conf/Catalina" \
    && curl -Ls                     "http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-${JIRA_VERSION}.tar.gz" | tar -xz --directory "${JIRA_INSTALL}" --strip-components=1 --no-same-owner \
    && chmod -R 700                 "${JIRA_INSTALL}/conf" \
    && chmod -R 700                 "${JIRA_INSTALL}/logs" \
    && chmod -R 700                 "${JIRA_INSTALL}/temp" \
    && chmod -R 700                 "${JIRA_INSTALL}/work" \
    && chown -R atlassian:atlassian "${JIRA_INSTALL}/conf" \
    && chown -R atlassian:atlassian "${JIRA_INSTALL}/logs" \
    && chown -R atlassian:atlassian "${JIRA_INSTALL}/temp" \
    && chown -R atlassian:atlassian "${JIRA_INSTALL}/work" \
    && echo -e                      "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties"

# Use the default unprivileged account. This could be considered bad practice
# on systems where multiple processes end up being executed by 'daemon' but
# here we only ever run one process anyway.
USER atlassian:atlassian

# Expose default HTTP connector port.
EXPOSE 8080

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/atlassian/jira"]

# Set the default working directory as the installation directory.
WORKDIR ${JIRA_HOME}

# Run Atlassian JIRA as a foreground process by default.
CMD ["/opt/atlassian/jira/bin/start-jira.sh", "-fg"]
