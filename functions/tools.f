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

# Extracts a property from a VMware vSphere property file
#
# 1: name of property to retrieve
function getVmwareVsphereProperty(){
    local property=$1
    echo $(cat $STACI_HOME/conf/vmwarevsphere.properties | grep "$property" | cut -d ":" -f 2-)
}

function getContainerIP(){
    containerName=$1
    docker inspect --format '{{ .NetworkSettings.IPAddress }}' $containerName
}

do_version_check() {
# http://stackoverflow.com/questions/4023830/bash-how-compare-two-strings-in-version-format
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 0
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

#
# command_exists checks if a host program exists or not
#
command_exists () {
    type "$1" &> /dev/null ;
}

