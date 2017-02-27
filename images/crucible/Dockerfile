#FROM java:8
FROM praqma/java_8

# Add staci user and set password
RUN useradd -u 1000 -ms /bin/bash atlassian
RUN echo "atlassian:praqma" | chpasswd

# Install tools
RUN apt-get update && \
  apt-get install -y git mercurial subversion && \
  wget -q -P /usr/bin http://www.perforce.com/downloads/perforce/r15.1/bin.linux26x86_64/p4 && \
  chmod +x /usr/bin/p4

# Configuration variables.
ENV LANG C.UTF-8
ENV FECRU_VERSION 4.2.0
ENV FISHEYE_HOME /var/atlassian/crucible
ENV FISHEYE_INST /opt/atlassian/crucible

# Set Fisheye memory usage
# ENV FISHEYE_OPTS -Xmx3072m -XX:MaxPermSize=256m

WORKDIR /opt/atlassian/

# download and install fisheye to /opt/atlassian/fisheye
COPY crucible-4.2.0.zip crucible-4.2.0.zip
RUN unzip -q crucible-${FECRU_VERSION}.zip \
  && mv fecru-${FECRU_VERSION} crucible \
  && mkdir -p ${FISHEYE_HOME}/crucible \
  && rm -f crucible-4.2.0.zip

# Getting the MySQL driver
COPY mysql-connector-java-5.1.36.tar.gz mysql-connector-java-5.1.36.tar.gz 

# There is nothing dynamic in config.xml, so it is better to just copy the file as it is. - or so I understand. (Kamran)
COPY config.xml /opt/atlassian/crucible/config.xml

RUN tar -zxf "mysql-connector-java-5.1.36.tar.gz" --directory "${FISHEYE_INST}/lib/" --strip-components=1 --no-same-owner
RUN rm -f mysql-connector-java-5.1.36.tar.gz
ADD start.sh ${FISHEYE_INST}/
RUN chmod +x ${FISHEYE_INST}/start.sh
ADD configure.sh ${FISHEYE_INST}/
RUN chmod +x ${FISHEYE_INST}/configure.sh

RUN   chmod -R 700                 "${FISHEYE_INST}" \
  &&  chmod -R 700                 "${FISHEYE_HOME}" \
  &&  chown -R atlassian:atlassian "${FISHEYE_INST}" \
  &&  chown -R atlassian:atlassian "${FISHEYE_HOME}" 

# Use the user atlassian to run Jira.
USER atlassian:atlassian

VOLUME ${FISHEYE_HOME} 

EXPOSE 8060

WORKDIR ${FISHEYE_INST}/
# RUN ./configure.sh

CMD ["./bin/run.sh"]
