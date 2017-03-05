FROM postgres:9.3.16

# Notes: 
# * Jira does not support postgres versions higher than 9.3 
# ** Ref: https://confluence.atlassian.com/adminjiraserver071/supported-platforms-802592168.html
# * Bitbucket does not support postgres DBs 9.3.0-9.3.5 . But it does support from 9.4 - 9.6.      
# ** Ref: https://confluence.atlassian.com/bitbucketserver/supported-platforms-776640981.html


# Reference: https://hub.docker.com/_/postgres/
# Pass an env variable POSTGRES_PASSWORD with postgres password.
# Need to mount host volume into /var/lib/postgresql/data
