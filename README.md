# Support Tracking And Continuous Integration
This repository is maintained by www.praqma.com 

## STACI consists of
- Jira
- Confluence
- Bamboo
- BitBucket server
- Crowd
- Crucible
- MySQL

## Requirements
- Docker version 1.10
- Docker-compose version: 1.6.0
- ~~MySQL client installed~~
- Docker-machine 0.6.0 if cluster is used

## Important information
- Remember to turn off SE-LINUX and Apparmor.
- Setting up MySQL is now done with the script ./bin/init-mysql.sh and run automatically by install.sh

## TO-DO's
- Create a guideline for how to use Atlassian tools in Docker. Never use localhost, always use the dockerhost ip
- Testing, testing and testing
- Backup for cluster setup 

## Preparation for backup (works only when used locally)
- Create a folder structure in /data/atlassian where a user with uid 1000 has full read-write access. 
- Create a jira, atlassiandb, confluence, bamboo, crowd, crucible, bitbucket and backup folder inside /data/atlassian with same rights. 
- You can specify another folder in ./conf/staci.properties instead of /data/atlassian (look for volume_dir=/data)

## Getting started
```
Turn off SELinux or AppAmour.
Create data directory (See Preparation section)
pull the repository (git clone https://github.com/Praqma/staci.git)
cd staci
cp conf/staci.properties.template staci.properties
vim conf/staci.properties
export DOCKER_HOST=YOUR-IP:2375  (only if not using a provider)
./install.sh
```

If you want to change the behaviour of STACI, edit the file ./conf/staci.properties

## Taking backup of local containers (not working with external providers yet)
The containers have consistent data in /data/atlassian/ (default, edit staci.properties). You can take a backup by executing the script ./bin/backup.sh. This will tar-gz the volumes to /data/atlassian/backup/[date]. 
