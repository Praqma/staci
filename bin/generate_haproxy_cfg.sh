#!/bin/bash

#fetch helper tools
source $STACI_HOME/functions/tools.f

# Find out what to include
start_mysql=$(getProperty "start_mysql")
start_jira=$(getProperty "start_jira")
start_confluence=$(getProperty "start_confluence")
start_bamboo=$(getProperty "start_bamboo")
start_crowd=$(getProperty "start_crowd")
start_bitbucket=$(getProperty "start_bitbucket")
start_crucible=$(getProperty "start_crucible")
start_jenkins=$(getProperty "start_jenkins")
start_artifactory=$(getProperty "start_artifactory")
start_haproxy=$(getProperty "start_haproxy")

# Here we can use some function to get the actual domain name from the staci.properties file,
# and use it to build our haprpoxy.cfg

# DOMAIN_NAME='example.com'. If required, change the domain name in conf/staci.properties
DOMAIN_NAME=$(getProperty "org_domain_name")

# Creating global, default, and frontend settings.
# Some settings, such as user and group, are not so necessary relative to use context.

cat << EOF
global
        log 127.0.0.1 local0
        user root
        group root
        daemon
        ssl-default-bind-options no-sslv3 no-tls-tickets
defaults
        log global
        mode http
        # we are using docker-compose "depend_on", so there is no need to use libc hack.
        # default-server init-addr libc,none
        option httplog
        option dontlognull
        option httpclose
	option forwardfor
        timeout connect 5000
        timeout client 10000
        timeout server 10000

frontend http-in
        mode http
        bind *:80

        #define samples and matches in ACLs 
        acl jenkins hdr(host) -i jenkins.${DOMAIN_NAME}
        acl artifactory hdr(host) -i artifactory.${DOMAIN_NAME}
        acl jira hdr(host) -i jira.${DOMAIN_NAME}
        acl confluence hdr(host) -i confluence.${DOMAIN_NAME}
        acl bamboo hdr(host) -i bamboo.${DOMAIN_NAME}
        acl crowd hdr(host) -i crowd.${DOMAIN_NAME}
        acl bitbucket hdr(host) -i bitbucket.${DOMAIN_NAME}
        acl crucible hdr(host) -i crucible.${DOMAIN_NAME}
EOF

# conditional selection of backends in association with the above ACLs

for service in start_jenkins start_artifactory start_jira start_confluence start_bamboo start_crowd start_bitbucket start_crucible ; do
  # echo "Processing $service"
  if [ ! -z "${!service+x}" ] ; then
    if [ ${!service} -eq 1 ] ; then
      BACKEND_STRING=$(echo -e "\t use_backend ${service} if ${service}"| sed 's/start_//g')
      # echo -e $BACKEND_STRING
      # since output of this script is being appended to a conf file, even the output of echo will  appear in the target file
      # So no need of cat EOF here
      echo -e "\t use_backend ${service} if ${service}"| sed 's/start_//g'
    fi
  fi
done


# References:
# - http://stackoverflow.com/questions/2634590/bash-script-variable-inside-variable
# - http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash


cat << EOF
frontend https-in
        bind *:443 ssl crt /var/atlassian/haproxy/haproxy.pem
        reqadd X-Forwarded-Proto:\ https

        # Define hosts
        acl jenkins hdr(host) -i jenkins.${DOMAIN_NAME}
        acl artifactory hdr(host) -i artifactory.${DOMAIN_NAME}
        acl jira hdr(host) -i jira.${DOMAIN_NAME}
        acl confluence hdr(host) -i confluence.${DOMAIN_NAME}
        acl bamboo hdr(host) -i bamboo.${DOMAIN_NAME}
        acl crowd hdr(host) -i crowd.${DOMAIN_NAME}
        acl bitbucket hdr(host) -i bitbucket.${DOMAIN_NAME}
        acl crucible hdr(host) -i crucible.${DOMAIN_NAME}
EOF

#conditional selection of backends
for service in start_jenkins start_artifactory start_jira start_confluence start_bamboo start_crowd start_bitbucket start_crucible ; do
  if [ ! -z ${!service+x} ]; then
    if [ ${!service} -eq 1 ] ; then
      BACKEND_STRING=$(echo -e "\t use_backend ${service} if ${service}"| sed 's/start_//g')
      # echo -e $BACKEND_STRING
      # since output of this script is being appended to a conf file, even the output of echo will  appear in the target file
      # So no need of cat EOF here
      echo -e "\t use_backend ${service} if ${service}"| sed 's/start_//g'
    fi
  fi
done

# References:
# - http://stackoverflow.com/questions/2634590/bash-script-variable-inside-variable
# - http://stackoverflow.com/questions/3601515/how-to-check-if-a-variable-is-set-in-bash


if [ "$start_bitbucket" == "1" ]; then
cat << EOF
backend bitbucket
        redirect scheme https if !{ ssl_fc }
        server bitbucket bitbucket:7990 check
EOF
fi

if [ "$start_crowd" == "1" ]; then
cat << EOF
backend crowd
        redirect scheme https if !{ ssl_fc }
        server crowd crowd:8095 check
EOF
fi

if [ "$start_crucible" == "1" ]; then
cat << EOF
backend crucible
        redirect scheme https if !{ ssl_fc }
        server crucible crucible:8060 check
EOF
fi

if [ "$start_jira" == "1" ]; then
cat << EOF
backend jira
        redirect scheme https if !{ ssl_fc }
        server jira jira:8080 check
EOF
fi

if [ "$start_confluence" == "1" ]; then
cat << EOF
backend confluence
        redirect scheme https if !{ ssl_fc }
        server confluence confluence:8090 check
EOF
fi

if [ "$start_bamboo" == "1" ]; then
cat << EOF
backend bamboo
        redirect scheme https if !{ ssl_fc }
        server bamboo bamboo:8085 check
EOF
fi

if [ "$start_jenkins" == "1" ]; then
cat << EOF
backend jenkins
        redirect scheme https if !{ ssl_fc }
        server jenkins jenkins:8080 check
EOF
fi

if [ "$start_artifactory" == "1" ]; then
cat << EOF
backend artifactory
        redirect scheme https if !{ ssl_fc }
        server artifactory artifactory:8080
EOF
fi
