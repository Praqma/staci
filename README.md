# Support Ticketing and Continous Integration

## Important information
- Remember to turn off SE-LINUX and APPAMOR.
- Application linking does now yet work. Confluence looses its users, when administrated from Jira.

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

## Setting up MySQL for JIRA
This is now done with the script ./bin/init-mysql.sh

## Setting up MySQL for Confluence
This is now done with the script ./bin/init-mysql.sh

## Setting up MySQL for Bamboo
This is now done with the script ./bin/init-mysql.sh
