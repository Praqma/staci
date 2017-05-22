#FROM java:8
FROM praqma/java_8

# Add atlassian user and set password
RUN useradd -u 1000 -m -s /bin/bash atlassian
RUN echo "atlassian:praqma" | chpasswd

# Install tools
RUN apt-get update && \
  apt-get install -y git mercurial subversion && \
  wget -q -P /usr/bin http://www.perforce.com/downloads/perforce/r15.1/bin.linux26x86_64/p4 && \
  chmod +x /usr/bin/p4


# Some configuration variables.
ENV LANG C.UTF-8
ENV FECRU_VERSION 4.4.1

# Set Fisheye memory usage
# ENV FISHEYE_OPTS -Xmx3072m -XX:MaxPermSize=256m


# VERY IMPORTANT: Refer to https://confluence.atlassian.com/crucible/installing-crucible-on-linux-and-mac-298977373.html

# From the above reference URL:

# Crucible Home:
# -------------
# Download Crucible from the Atlassian download site.
# Extract the downloaded file to an install location.
# The path to the extracted directory is referred to as the <Crucible home directory> in these instructions. 
# If you use FishEye and Crucible together, they run as one instance, and use the same home directory – see Crucible and FishEye.

# Based on above explanation, set CRUCIBLE_HOME as /opt/atlassian/crucible
ENV CRUCIBLE_HOME   /opt/atlassian/crucible


# (Notes about Crucible instance directory / storage for your data are furhter below.)


# Copy crucible.zip from host computer to /opt/atlassian/ in the container,
#   and then unzip it over there. Then rename the resultant directory to crucible.
# COPY crucible-4.2.0.zip /opt/atlassian/
COPY crucible-4.4.1.zip /opt/atlassian/

WORKDIR /opt/atlassian/

RUN unzip -q crucible-${FECRU_VERSION}.zip \
  && mv fecru-${FECRU_VERSION} crucible \
  && rm -f crucible-4.2.0.zip


# PGSQL and MySQL java driver
COPY postgresql-42.0.0.jar  ${CRUCIBLE_HOME}/lib/ 
COPY mysql-connector-java-5.1.36.tar.gz /opt/atlassian/ 
RUN tar -zxf mysql-connector-java-5.1.36.tar.gz \
      --directory ${CRUCIBLE_HOME}/lib/ --strip-components=1 --no-same-owner \
 && rm -f mysql-connector-java-5.1.36.tar.gz



# Crucible instance directory / storage for your data:
# ---------------------------------------------------
# Tell Crucible where to store your data
# The Crucible instance directory is where your Crucible data is stored.
# Create your Crucible instance directory.
# Tell Crucible where you created the instance directory by adding a FISHEYE_INST environment variable as follows:
# Open the  /etc/environment  file in a text editor and insert :
# FISHEYE_INST="path/to/<Crucible instance directory>"
# Now copy the newly extracted <Crucible home directory>\config.xml file to the root of your new Crucible instance directory.

# NOTE: You should not locate your Crucible instance directory inside the <Crucible home directory> -
#       they should be entirely separate locations. If you do put the  instance directory in
#       the <Crucible home directory> it will be overwritten, and lost, when Crucible gets upgraded.
#       And by the way, you'll need separate Crucible instance directories if you want to run multiple copies of Crucible.


# Set FISHEYE_INST based on above explanation:

ENV FISHEYE_INST  /var/atlassian/crucible
RUN mkdir -p /var/atlassiab/crucible

# Note: We have our own config.xml (in the repo) which we would like to use.
# So based on above explanation, I will copy that config.xml to instance directory,
#    i.e. /var/atlassian/crucible/
COPY config.xml ${FISHEYE_INST}/


# Now fix ownership and permissions, etc.
RUN   chmod -R 700                 "${FISHEYE_INST}" \
  &&  chmod -R 700                 "${CRUCIBLE_HOME}" \
  &&  chown -R atlassian:atlassian "${FISHEYE_INST}" \
  &&  chown -R atlassian:atlassian "${CRUCIBLE_HOME}" 


# Use the user atlassian to run crucible.
USER atlassian:atlassian

# Expose the Crucible instance directory as a volume.
VOLUME ${FISHEYE_INST} 

EXPOSE 8060

# WORKDIR ${FISHEYE_HOME}
WORKDIR ${FISHEYE_INST}

CMD ["/opt/atlassian/crucible/bin/run.sh"]

