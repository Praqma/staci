This is s water-downed version of STACI which gives you a devops tool stack made of Jira, Confluence, Crucible, Jenkins, Artifactory, MySQL. They are placed behind a loadbalancer (HAProxy) so that they can be accessed with a comon domain suffic over HTTPS.

One core goal of this project is to simplify the installation of these tools albeit for a limited context. Here the time it takes to transition from one infrastructure state to a new version is negligible as the tar balls - Jira, Bitbucket, Crucible, MySQL connector -  which ordinarily would be downloaded for every new build job would be fetched for the first job and kept locally for subsequent jobs.



Runnig `bash setup.sh` will install the tool stack for you.

Post Installation hacks:

Link Bitbucket and Jira:

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

When you are done with the initial configuration and have been presented with a web gui, create mutually directed links. I.e, on Jira create a link to bitbucket using its docker IP address and the port number of the extra tomcat connector you added to that container. E.g, http://192.19.0.5:8081/bitbucket. On bitbucket do the same. If youencounter any errors click on the edit icon beside the link entry and check that OAUTH (impersonation) is enabled.

Do not panic if errors occur on your first try: a successful connection requires that there be reciprocal links present. My suggestion is to start from the bitbucket side.


(This is very much work in progress. The code and documentation will be augmented in due time. Feel free to make contributions)
