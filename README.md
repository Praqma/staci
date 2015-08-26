STACI - Support Ticketing and Continous Integration

Remember to turn off SE-LINUX and APPAMOR.

Create a folder structure in /data where a user with uid has full read-write access. Also, create a jira, atlassiandb, confluence and bamboo inside this folder with same rights. You can specify another folder in ./bin/staci.properties instead of /data (look for volume_dir=/data)

```
pull the repository
cd staci
export DOCKER_HOST=YOUR-IP:2375
./run.sh
```

If you want to change the behavour of STACI, edit the file ./bin/staci.properties
