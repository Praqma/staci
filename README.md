# STACI - Simple CI:
## History:
Originally STACI was written  by Henrik . The idea was to setup Atlassian suite using Docker containers. So he came up with STACI - Support Tracking and Continuous Integration. Although it worked well, and in fact is being used in production in few places, it did not have a reverse proxy. In original STACI all Atlassian products map their ports on the host and the clients access these products using the (docker) server IP and the port number of the particular product. In certain situations the customer wanted to access each product through a DNS name - without using any custom port numbers ; essentially behind a reverse proxy. Also original STACI had only Atlassian products in it, whereas at some places (customers), Jenkins and Artifactory was also required. 

To have it all bundled together was initially conceived to be a trivial task, but it actually turned out that having a reverse proxy would mean a redesign of STACI. So we thought of creating a separate branch **simple_ci** , where the configurations are not so dynamically generated as original STACI, and a tool-stack comes up immediately, comprising: Jenkins, Artifactory, Jira, BitBucket and Crucible, all behind a reverse proxy. So this is still STACI, but a simplified version.


The tar balls - Jira, Bitbucket, Crucible, MySQL connector -  which are usually downloaded for every new build are now fetched for the first docker image build process, and kept locally for later use.


# Configuration:
Edit and adjust `setup.conf`

# Setup:
You need to run `setup.sh` as root (or sudo).

# Post Installation steps:

## Link Jira , BitBucket and Jira together:

When you are done with the initial configuration and have been presented with a web gui, create mutually directed links. i.e, on Jira create a link to bitbucket using its docker IP address (service name - jira) and the port number of the extra tomcat connector we have already setup in server.xml for Jira and BitBucket. e.g, `http://jira:8888` and `http://bitbucket:8888`. On bitbucket do the same. 
Crucible is special. You just use it's default port for application links, such as: `http://crucible:8060`. Also you need to manually setup MySQL as db backend for Crucible through it's GUI.

If you encounter any errors click on the edit icon beside each application link entry and check that OAUTH (impersonation) is enabled.

Do not panic if errors occur on your first try: a successful connection requires that there be reciprocal links present. We suggest to start from the jira and bitbucket.


(This is very much work in progress. The code and documentation will be augmented in due time. Feel free to make contributions)
