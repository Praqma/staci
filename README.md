# Support Tracking and Continous Integration

## Important information
- Remember to turn off SE-LINUX and APPAMOR.
- Setting up MySQL is now done with the script ./bin/init-mysql.sh and ran automaticly by install.sh
- You need to install mysql client. I'm working on using a doker image instead.

## TO-DO's
- Create a guideline for how to use Atlassian tools in Docker. Never use localhost, always use the dockerhost ip
- Testing, testing and testing
- Cluster / Swarm / Mesos support. 

## Preperation
- Create a folder structure in /data where a user with uid has full read-write access. 
- Create a jira, atlassiandb, confluence and bamboo folder inside this folder with same rights. 
- You can specify another folder in ./bin/staci.properties instead of /data (look for volume_dir=/data)

## Getting started
```
pull the repository (git clone https://github.com/Praqma/staci.git)
cd staci
export DOCKER_HOST=YOUR-IP:2375
./install.sh
```

If you want to change the behavour of STACI, edit the file ./bin/staci.properties

## Taking backup of containers
The containers has consistant data in /data/atlassian/ (default, edit staci.properties). You can take a backup by executing the script ./bin/backup.sh. This will tar-gz the volumes to /data/atlassian/backup/[date]. 
