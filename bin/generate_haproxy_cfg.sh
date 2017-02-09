#!/bin/bash

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

# DOMAIN_NAME='example.com'
DOMAIN_NAME=$(getProperty "org_domain_name")

# Printing version and header

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
        default-server init-addr libc,none
        option httplog
        option dontlognull
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

        option httplog
EOF

#conditional selection of backends

if [ "$start_jenkins" == "1" ]; then
cat << EOF
        use_backend jenkins if jenkins
EOF
fi
if [ "$start_artifactory" == "1" ]; then
cat << EOF
        use_backend artifactory if artifactory
EOF
fi
if [ "$start_jira" == "1" ]; then
cat << EOF
        use_backend jira if jira
EOF
fi
if [ "$start_confluence" == "1" ]; then
cat << EOF
        use_backend confluence if confluence
EOF
fi
if [ "$start_bamboo" == "1" ]; then
cat << EOF
        use_backend bamboo if bamboo
EOF
fi
if [ "$start_crowd" == "1" ]; then
cat << EOF
        use_backend crowd if crowd
EOF
fi
if [ "$start_bitbucket" == "1" ]; then
cat << EOF
        use_backend bitbucket if bitbucket
EOF
fi
if [ "$start_crucible" == "1" ]; then
cat << EOF
        use_backend crucible if crucible
EOF
fi

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

## figure out which one to use
if [ "$start_jenkins" == "1" ]; then
cat << EOF
        use_backend jenkins if jenkins
EOF
fi

if [ "$start_artifactory" == "1" ]; then
cat << EOF
        use_backend artifactory if artifactory
EOF
fi

if [ "$start_jira" == "1" ]; then
cat << EOF
        use_backend jira if jira
EOF
fi

if [ "$start_confluence" == "1" ]; then
cat << EOF
        use_backend confluence if confluence
EOF
fi

if [ "$start_bamboo" == "1" ]; then
cat << EOF
        use_backend bamboo if bamboo
EOF
fi

if [ "$start_crowd" == "1" ]; then
cat << EOF
        use_backend crowd if crowd
EOF
fi

if [ "$start_bitbucket" == "1" ]; then
cat << EOF
        use_backend bitbucket if bitbucket
EOF
fi

if [ "$start_crucible" == "1" ]; then
cat << EOF
        use_backend crucible if crucible
EOF
fi

if [ "$start_bitbucket" == "1" ]; then
cat << EOF
backend bitbucket
 	mode http
        redirect scheme https if !{ ssl_fc }
        option httpclose
        option forwardfor
        server bitbucket bitbucket:7990 check
EOF
fi

if [ "$start_crowd" == "1" ]; then
cat << EOF
backend crowd
        mode http
        redirect scheme https if !{ ssl_fc }
        option httpclose
        option forwardfor
        server crowd crowd:8095 check
EOF
fi

if [ "$start_crucible" == "1" ]; then
cat << EOF
backend crucible
        mode http
        redirect scheme https if !{ ssl_fc }
        option httpclose
        option forwardfor
        server crucible crucible:8060 check
EOF
fi
if [ "$start_jira" == "1" ]; then
cat << EOF
backend jira
        mode http
        redirect scheme https if !{ ssl_fc }
        option httpclose
        option forwardfor
        server jira jira:8080 check
EOF
fi
if [ "$start_confluence" == "1" ]; then
cat << EOF
backend confluence
        mode http
        redirect scheme https if !{ ssl_fc }
        option httpclose
        option forwardfor
        server confluence confluence:8090 check
EOF
fi
if [ "$start_bamboo" == "1" ]; then
cat << EOF
backend bamboo
        mode http
        redirect scheme https if !{ ssl_fc }
        option httpclose
        option forwardfor
        server bamboo bamboo:8085 check
EOF
fi

if [ "$start_jenkins" == "1" ]; then
cat << EOF
backend jenkins
        mode http
        redirect scheme https if !{ ssl_fc }
        option httpclose
        option forwardfor
        server jenkins jenkins:8080 check
EOF
fi
if [ "$start_artifactory" == "1" ]; then
cat << EOF
backend artifactory
        mode http
        redirect scheme https if !{ ssl_fc }
        option httpclose
        option forwardfor
        server artifactory artifactory:8080
EOF
fi
