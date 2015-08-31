# Support Ticketing and Continous Integration

## Important information
Remember to turn off SE-LINUX and APPAMOR.

## Preperation
- Create a folder structure in /data where a user with uid has full read-write access. 
- Create a jira, atlassiandb, confluence and bamboo folder inside this folder with same rights. 
- You can specify another folder in ./bin/staci.properties instead of /data (look for volume_dir=/data)

## Getting started
```
pull the repository (git clone https://github.com/Praqma/staci.git)
cd staci
export DOCKER_HOST=YOUR-IP:2375
./run.sh
```

If you want to change the behavour of STACI, edit the file ./bin/staci.properties
