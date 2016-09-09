echo $(docker inspect --format '{{ .NetworkSettings.Networks.compose_default.IPAddress }}' jira) jira
echo $(docker inspect --format '{{ .NetworkSettings.Networks.compose_default.IPAddress }}' bitbucket) bitbucket
echo $(docker inspect --format '{{ .NetworkSettings.Networks.compose_default.IPAddress }}' confluence) confluence
echo $(docker inspect --format '{{ .NetworkSettings.Networks.compose_default.IPAddress }}' atlassiandb) atlassiandb
