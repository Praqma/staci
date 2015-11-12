#FROM java:8
FROM staci/base:0.1

# Add staci user and set password
RUN useradd -u 1000 -ms /bin/bash atlassian
RUN echo "atlassian:praqma" | chpasswd

# Configuration variables.
ENV LANG C.UTF-8
ENV FECRU_VERSION 3.10.1
ENV FISHEYE_HOME /opt/atlassian/crucible
ENV FISHEYE_INST /var/atlassian/crucible

WORKDIR /opt/atlassian/

# download and install fisheye to /opt/atlassian/fisheye
RUN wget "http://www.atlassian.com/software/crucible/downloads/binary/crucible-${FECRU_VERSION}.zip" -O crucible-${FECRU_VERSION}.zip \
&& unzip crucible-${FECRU_VERSION}.zip \
&& mv fecru-${FECRU_VERSION} crucible \
&& mkdir -p ${FISHEYE_INST}/crucible

ADD start.sh ${FISHEYE_HOME}/
RUN chmod +x ${FISHEYE_HOME}/start.sh
ADD configure.sh ${FISHEYE_HOME}/
RUN chmod +x ${FISHEYE_HOME}/configure.sh

RUN chmod -R 700                 "${FISHEYE_INST}" \
&&  chmod -R 700                 "${FISHEYE_HOME}" \
&&  chown -R atlassian:atlassian "${FISHEYE_INST}" \
&&  chown -R atlassian:atlassian "${FISHEYE_HOME}" 

# Use the user atlassian to run Jira.
USER atlassian:atlassian

VOLUME ${FISHEYE_INST} 

EXPOSE 8060

WORKDIR ${FISHEYE_HOME}/
RUN ./configure.sh

CMD ["./bin/run.sh"]
