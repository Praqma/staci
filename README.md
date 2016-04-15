# Support Tracking And Continuous Integration

STACI lets you run Atlassian products with easy command line scripts.

STACI uses Docker to create the environment and adds provides features for integrating
the services.

STACI consists of:
- Jira
- Confluence
- Bamboo
- Bitbucket server
- Crowd
- Crucible
- MySQL

This repository is maintained by www.praqma.com

## Quick Start

STACI uses properties files to configure the stack. You need to follow these overall
steps to get started:

- Create configuration files
  - Copy the `.template` files in the `conf` folder to files with just a `.properties`
    extension
  - Edit your `.properties` files
- Start `docker`
- Run `./staci.sh install` to install and start the stack

You can take down the stack by following these steps:

- Run `./staci.sh stop` to stop the `docker` containers.
- Run `./staci.sh delete` to delete the containers.


## Requirements
- Docker version 1.10
- Docker-compose version: 1.6.0
- Docker-machine 0.6.0 if cluster is used

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
Turn off SELinux or AppAmour, if applicable
Create data directory (See Preparation section)
pull the repository (git clone https://github.com/Praqma/staci.git)
cd staci
cp conf/staci.properties.template staci.properties
vim conf/staci.properties
./staci.sh install
```

If you want to change the behaviour of STACI, edit the file ./conf/staci.properties

## Taking backup of local containers (not working with external providers yet)
The containers have consistent data in /data/atlassian/ (default, edit staci.properties). You can take a backup by executing the script ./bin/backup.sh. This will tar-gz the volumes to /data/atlassian/backup/[date].
