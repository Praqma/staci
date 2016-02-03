#! /bin/bash

# Extracts a property from a STACI property file
#
# 1: name of property to retrieve
function getProperty(){
    local property=$1
    echo $(cat $STACI_HOME/conf/staci.properties|grep "$property"|cut -d":" -f 2-)
}

# Extracts a property from an OpenStack property file
#
# 1: name of property to retrieve
function getOpenStackProperty(){
    local property=$1
    echo $(cat $STACI_HOME/conf/openstack.properties|grep "$property"|cut -d":" -f 2-)
}

# Extracts a property from a VirtualBox property file
#
# 1: name of property to retrieve
function getVirtualBoxProperty(){
    local property=$1
    echo $(cat $STACI_HOME/conf/virtualbox.properties | grep "$property" | cut -d ":" -f 2-)
}

function getContainerIP(){
    containerName=$1
    docker inspect --format '{{ .NetworkSettings.IPAddress }}' $containerName
}
