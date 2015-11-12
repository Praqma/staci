docker_host_ip=$(echo $DOCKER_HOST | grep -o '[0-9]\+[.][0-9]\+[.][0-9]\+[.][0-9]\+')

cat << EOF2
#!/bin/bash

configfile=\$(cat << EOF
<config control-bind="127.0.0.1:8059" version="1.0">
    <web-server site-url="http://$docker_host_ip:8060">
        <http bind=":8060"/>
    </web-server>
    <security allow-anon="true" allow-cru-anon="true"/>
    <repository-defaults>
        <linker/>
        <allow/>
        <tarball enabled="false" maxFileCount="0"/>
        <security allow-anon="true"/>
    </repository-defaults>
</config>
EOF
)

echo "Copying config.xml to /opt/atlassian/crucible/config.xml"
echo \$configfile > /opt/atlassian/crucible/config.xml
EOF2
