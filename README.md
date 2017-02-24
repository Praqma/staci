# STACI - Simple CI:
## History:
Originally STACI was written  by Henrik . The idea was to setup Atlassian suite using Docker containers. So he came up with STACI - Support Tracking and Continuous Integration. Although it worked well, and in fact is being used in production in few places, it did not have a reverse proxy. In original STACI all Atlassian products map their ports on the host and the clients access these products using the (docker) server IP and the port number of the particular product. In certain situations the customer wanted to access each product through a DNS name - without using any custom port numbers ; essentially behind a reverse proxy. Also original STACI had only Atlassian products in it, whereas at some places (customers), Jenkins and Artifactory was also required. 

To have it all bundled together was initially conceived to be a trivial task, but it actually turned out that having a reverse proxy would mean a redesign of STACI. So we thought of creating a separate branch **simple_ci** , where the configurations are not so dynamically generated as original STACI, and a tool-stack comes up immediately, comprising: Jenkins, Artifactory, Jira, BitBucket and Crucible, all behind a reverse proxy. So this is still STACI, but a simplified version.

In short, this is s water-downed version of STACI which gives you a devops tool stack made of Jira, Confluence, Crucible, Jenkins, Artifactory, MySQL. They are placed behind a loadbalancer (HAProxy) so that they can be accessed with a comon domain suffic over HTTPS.

One core goal of this project is to simplify the installation of these tools albeit for a limited context. Here the time it takes to transition from one infrastructure state to a new version is negligible as the tar balls - Jira, Bitbucket, Crucible, MySQL connector -  which ordinarily would be downloaded for every new build job would be fetched for the first job and kept locally for subsequent jobs.


# Setup:
You need to run `setup.sh` as root (or sudo).

# Post Installation hacks:

## Link Bitbucket and Jira:

- Copy the content of jira_tc_connector
- Run docker exec -it jira.example.com bash
- Open /opt/atlassian/jira/conf/server.xml
- Locate the configuration block delineated by server=catalina
- Delete the uncommented connector in that section
- Copy in the contents of jira_tc_connector
- save your change and exit the container

Do the same for bitbucket using the contents of bitbucket_tc_connector.

Run,
- Docker-compose stop jira bitbucket haproxy
- Docker-compose up -d

Go ahead and configure the database and admin user for both Bitbucket and Jira. 

When you are done with the initial configuration and have been presented with a web gui, create mutually directed links. i.e, on Jira create a link to bitbucket using its docker IP address and the port number of the extra tomcat connector you added to that container. e.g, `http://192.19.0.5:8081/bitbucket`. On bitbucket do the same. If you encounter any errors click on the edit icon beside the link entry and check that OAUTH (impersonation) is enabled.

Do not panic if errors occur on your first try: a successful connection requires that there be reciprocal links present. My suggestion is to start from the bitbucket side.


(This is very much work in progress. The code and documentation will be augmented in due time. Feel free to make contributions)
