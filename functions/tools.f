#! /bin/bash

# This function extract a property from a STACI property file
#
# 1: name of property to retrieve
function getProperty(){
    local property=$1
    echo $(cat $STACI_HOME/bin/staci.properties|grep "$property"|cut -d":" -f2)
}
