#!/bin/bash
#
#
# Please create a security group called DockerAPI in openstack.

#  It should have the following rules:
#
#  DIRECTION    ETHER TYPE    IP PROTOCOL     PORT RANGE        REMOTE
#  Ingress      IPv4          TCP             50000 - 50999     0.0.0.0/0 (CIDR)
#  Egress       IPv4          Any             -                 0.0.0.0/0 (CIDR)
#  Ingress      IPv4          TCP             2376              0.0.0.0/0 (CIDR)
#  Ingress      IPv4          TCP             3376              0.0.0.0/0 (CIDR)
#  Egress       IPv6          Any             -                 ::/0      (CIDR)


# Please create a security group called Atlassian in openstack
# It should have the following rules:

#  DIRECTION    ETHER TYPE    IP PROTOCOL     PORT RANGE        REMOTE
#  Ingress      IPv4          TCP             7999              0.0.0.0/0 (CIDR)
#  Egress       IPv4          ICMP            -                 0.0.0.0/0 (CIDR)
#  Ingress      IPv4          TCP             443 (HTTPS)       0.0.0.0/0 (CIDR)
#  Ingress      IPv4          TCP             8090              0.0.0.0/0 (CIDR)
#  Ingress      IPv4          TCP             22 (SSH)          0.0.0.0/0 (CIDR)
#  Ingress      IPv4          ICMP            -                 0.0.0.0/0 (CIDR)
#  Egress       IPv6          Any             -                 ::/0 (CIDR)     
#  Ingress      IPv4          TCP             8060              0.0.0.0/0 (CIDR)
#  Ingress      IPv4          TCP             8080              0.0.0.0/0 (CIDR)
#  Egress       IPv4          Any             -                 0.0.0.0/0 (CIDR)
#  Ingress      IPv4          TCP             7990              0.0.0.0/0 (CIDR)
#  Ingress	IPv4	      TCP	      8085	        0.0.0.0/0 (CIDR)
#  Ingress	IPv4	      TCP	      54663 	        0.0.0.0/0 (CIDR)
source $STACI_HOME/functions/tools.f

export OS_AUTH_URL=$(getOpenStackProperty "openstack_OS_AUTH_URL")
#export OS_AUTH_URL=https://identity.api.zetta.io/v3
export OS_REGION_NAME=$(getOpenStackProperty "openstack_OS_REGION_NAME")
export OS_PROJECT_ID=$(getOpenStackProperty "openstack_OS_PROJECT_ID")
export OS_PROJECT_NAME=$(getOpenStackProperty "openstack_OS_PROJECT_NAME")
export OS_PROJECT_DOMAIN_ID=$(getOpenStackProperty "openstack_OS_PROJECT_DOMAIN_ID")
export OS_USER_DOMAIN_ID=$(getOpenStackProperty "openstack_OS_USER_DOMAIN_ID")
export OS_IDENTITY_API_VERSION=$(getOpenStackProperty "openstack_OS_IDENTITY_API_VERSION")
export OS_USERNAME=$(getOpenStackProperty "openstack_OS_USERNAME")
export OS_PASSWORD=$(getOpenStackProperty "openstack_OS_PASSWORD")
export OS_TENANT_NAME=$(getOpenStackProperty "openstack_OS_TENANT_NAME")
export OS_DOMAIN_NAME=$(getOpenStackProperty "openstack_OS_DOMAIN_NAME")

staci_debug=$(getProperty "staci_debug")

if [ $staci_debug == "on" ]; then
  echo  $OS_AUTH_URL
  echo  $OS_REGION_NAME
  echo  $OS_PROJECT_ID
  echo  $OS_PROJECT_NAME
  echo  $OS_PROJECT_DOMAIN_ID
  echo  $OS_USER_DOMAIN_ID
  echo  $OS_IDENTITY_API_VERSION
  echo  $OS_USERNAME
  echo  $OS_PASSWORD
  echo  $OS_TENANT_NAME
  echo  $OS_DOMAIN_NAME
  debug="--debug"
fi

sec_groups=$(getOpenStackProperty "openstack_sec_groups")
ssh_user=$(getOpenStackProperty "openstack_ssh_user")
floating_ip_pool=$(getOpenStackProperty "openstack_floating_ip_pool")
flavor_id=$(getOpenStackProperty "openstack_flavor_id")
net_id=$(getOpenStackProperty "openstack_net_id")
image_id=$(getOpenStackProperty "openstack_image_id")
instance_name=$(getOpenStackProperty "openstack_instance_name")

#openstack image list
#openstack flavor list
#openstack network list

echo " - Creating OpenStack instance $instance_name, please wait."
echo " - This could take some time..."

docker-machine --debug create \
        --driver openstack \
        --openstack-net-id $net_id \
        --openstack-flavor-id $flavor_id \
        --openstack-image-id $image_id  \
        --openstack-floatingip-pool $floating_ip_pool  \
        --openstack-ssh-user $ssh_user  \
        --openstack-sec-groups $sec_groups  \
        $instance_name > $STACI_HOME/logs/openstack.$instance_name.log 2>&1 

echo " - Setting up docker client to point at new instance..."
eval "$(docker-machine env $instance_name)"
export staci_docker_host_ip=$(docker-machine ip $instance_name)
echo " - Ip of OpenStack instance $instance_name: $staci_docker_host_ip"

#docker info

# To ssh into the machine, use the following for inspiration:
# /usr/bin/ssh -o PasswordAuthentication=no -o IdentitiesOnly=yes -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null -o LogLevel=quiet -o ConnectionAttempts=3 -o ConnectTimeout=10 -i /home/hoeghh/.docker/machine/machines/Atlassian-test/id_rsa -p 22 ubuntu@185.56.186.156
