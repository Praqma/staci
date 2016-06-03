# Support Tracking And Continuous Integration

STACI lets you run Atlassian products with easy command line scripts. It uses Docker to
create the environment and adds features for integrating the services.

STACI consists of:
- Jira
- Confluence
- Bamboo
- Bitbucket Server
- Crowd
- Crucible
- MySQL

This repository is maintained by www.praqma.com

## Quick Start

STACI uses properties files to configure the stack. You get started by following these
steps:

- Create configuration files
  - Copy the `.template` files in the `conf` folder to files with just a `.properties`
    extension
  - Edit your `.properties` files
  - If you are not using Linux, you probably want to set `provider_type:virtualbox` in
    `staci.properties`
- Start `docker`
- Run `./staci.sh install` to install and start the stack


## Commands

- `./staci.sh install` : Create Docker host and images, and start Docker containers for
   the chosen Atlassian tools
- `./staci.sh stop` : Stop the Docker containers
- `./staci.sh start` : Start existing Docker containers
- `./staci.sh delete` : Delete the containers

There are currently no STACI commands to manage the Docker host.


## Access Services

The `install` command creates a `SystemInfo.html` in the root directory. It contains
links to all the services started.


## Requirements
- Docker
  - Docker version 1.10
  - Docker-compose version 1.6.0
  - Docker-machine 0.6.0
- Bash
  - The STACI scripts are written in `bash` and have been tested on Linux and Mac
- VirtualBox (optional)
  - On a Mac, an easy way to get started is to use Docker with VirtualBox


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


## Continuous delivery pipeline

The `pipeline` folder contains an implementation of [the pragmatic workflow](http://www.praqma.com/stories/a-pragmatic-workflow/)
for this project: A Jenkins setup which uses the Pretested Integration plugin to merge
changes from `ready` branches into `master`.

It is run like this:

* Start Jenkins in Docker using the scripts in `pipeline/docker`
* Manually add GitHub credentials in Jenkins, with the ID `github`
* Run the `seed` job

Notice that the generated job has no trigger. You need to manually build it to pick up
changes on a `ready` branch.


## A pragmatic workflow

Praqma has a workflow that encourages feature branching and a continuous delivery
pipeline. It is described in this blog post:
http://www.praqma.com/stories/a-pragmatic-workflow/

Once you have it set up with `ghi` and the `git` aliases, here is how you can work on an
issue:

* `ghi open` - Create an issue
* `ghi list` - List open issues to see the issue number you will fix, say 48
* `git work-on 48` - Creates a feature branch for you, assigns the issue to you
* Hack hack hack - fix the issue
* `git wrapup` - Commits changes and closes the issue
* `git deliver` - Pushes to a `ready` branch, adds `delivered` prefix to your local
  feature branch
* Trigger the pipeline - it should pick up the `ready` branch and integrate it to `master`
* `git purge-all-delivered` - To delete your local feature branch that you no longer need
