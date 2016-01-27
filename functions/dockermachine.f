#! /bin/bash

function getVirtualboxFlags(){
  echo "virtualbox"
}

function getOpenStackFlags(){
  # Get informations from propertyfile
  local username=$(getOpenStackProperty "openstack_OS_USERNAME")
  local password=$(getOpenStackProperty "openstack_OS_PASSWORD")
  local domain_name=$(getOpenStackProperty "openstack_OS_DOMAIN_NAME")
  local auth_url=$(getOpenStackProperty "openstack_OS_AUTH_URL")
  local tenant_name=$(getOpenStackProperty "openstack_OS_TENANT_NAME")
  local sec_groups=$(getOpenStackProperty "openstack_sec_groups")
  local ssh_user=$(getOpenStackProperty "openstack_ssh_user")
  local floating_ip_pool=$(getOpenStackProperty "openstack_floating_ip_pool")
  local flavor_id=$(getOpenStackProperty "openstack_flavor_id")
  local net_id=$(getOpenStackProperty "openstack_net_id")
  local image_id=$(getOpenStackProperty "openstack_image_id")

  local dmflags=" \
        --openstack-username $username \
        --openstack-password $password \
        --openstack-domain-name $domain_name \
        --openstack-tenant-name $tenant_name \
        --openstack-auth-url $auth_url \
        --openstack-flavor-id $flavor_id \
        --openstack-image-id $image_id  \
        --openstack-net-id $net_id \
        --openstack-floatingip-pool $floating_ip_pool \
        --openstack-ssh-user $ssh_user \
        --openstack-sec-groups $sec_groups \
  "
  echo $dmflags
}

function getDMFlags(){

    local provider=$1
    if [ $provider == "local" ];then
        echo "local"
    elif [ $provider == "openstack" ];then
        getOpenStackFlags
    elif [ $provider == "virtualbox" ];then
        getVirtualboxFlags
    fi
}

function createSwarm(){
    local provider=$1
    echo "Creating swarm. Please wait."

    # Find out what to start
    local start_mysql=$(getProperty "start_mysql")
    local start_jira=$(getProperty "start_jira")
    local start_confluence=$(getProperty "start_confluence")
    local start_bamboo=$(getProperty "start_bamboo")
    local start_crowd=$(getProperty "start_crowd")
    local start_bitbucket=$(getProperty "start_bitbucket")
    local start_crucible=$(getProperty "start_crucible")

    if [ "$start_jira" == "1" ];then
        createDMInstans "$provider" "$dmflags" "jira"
    fi

}

function createDMInstans(){
    local dmprovider=$1
    local dmflags=$2
    local dmname=$3
    echo "Creating instans $dmname via $provider"
    eval docker-machine create -d "$dmprovider" "$dmflags" "$dmname" > $STACI_HOME/logs/dockermachine.$provider.$dmname.log 2>&1

}
