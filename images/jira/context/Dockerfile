#
# Hack :
#  To use Jira Software : http://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-software-7.0.0-jira-7.0.0.tar.gz
#  To use Jira Service Desk : http://www.atlassian.com/software/jira/downloads/binary/atlassian-servicedesk-3.0.0-jira-7.0.0.tar.gz

#FROM java:8
FROM staci/base:0.1

# Add staci user and set password
RUN useradd -u 1000 -ms /bin/bash atlassian
RUN echo "atlassian:praqma" | chpasswd

# Configuration variables.
ENV JIRA_HOME     /var/atlassian/jira
ENV JIRA_INSTALL  /opt/atlassian/jira

# Install Atlassian JIRA and helper tools and setup initial home
# directory structure.
RUN set -x \
    && mkdir -p                     "${JIRA_HOME}" \
    && chmod -R 700                 "${JIRA_HOME}" \
    && chown -R atlassian:atlassian "${JIRA_HOME}" \
    && mkdir -p                     "${JIRA_INSTALL}/conf/Catalina" \
    && curl -Ls                     "https://www.atlassian.com/software/jira/downloads/binary/atlassian-jira-core-7.1.4.tar.gz" | tar -xz --directory "${JIRA_INSTALL}" --strip-components=1 --no-same-owner \
    && chmod -R 700                 "${JIRA_INSTALL}/logs" \
    && chmod -R 700                 "${JIRA_INSTALL}/temp" \
    && chmod -R 700                 "${JIRA_INSTALL}/work" \
    && chown -R atlassian:atlassian "${JIRA_INSTALL}" \
    && echo -e                      "\njira.home=$JIRA_HOME" >> "${JIRA_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties" 
# Getting the MySQL driver
RUN curl -Ls "http://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-5.1.36.tar.gz" | tar -xz --directory "${JIRA_INSTALL}/lib/" --strip-components=1 --no-same-owner

# Fix Issue #2  -- https://github.com/Praqma/staci/issues/2
COPY setContextPath.sh /tmp/setContextPath.sh
RUN /tmp/setContextPath.sh

# Use the user atlassian to run Jira.
USER atlassian:atlassian

# Expose default HTTP connector port.
EXPOSE 8080

# Set volume mount points for installation and home directory. Changes to the
# home directory needs to be persisted as well as parts of the installation
# directory due to eg. logs.
VOLUME ["/var/atlassian/jira"]

# Fix Issue #1  -- https://github.com/Praqma/staci/issues/1
#RUN sed -i -e 's/<Context>/<Context sessionCookieName="JIRASESSIONID">/g' /opt/atlassian/jira/conf/context.xml

# Set the default working directory as the installation directory.
WORKDIR ${JIRA_HOME}

# Run Atlassian JIRA as a foreground process by default.
CMD ["/opt/atlassian/jira/bin/start-jira.sh", "-fg"]
