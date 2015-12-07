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
#  Ingress	IPv4	      TCP	      8080	        0.0.0.0/0 (CIDR)
	
source $STACI_HOME/functions/tools.f

export OS_AUTH_URL=$(getOpenStackProperty "openstack_OS_AUTH_URL")
export OS_REGION_NAME=$(getOpenStackProperty "openstack_OS_REGION_NAME")
export OS_PROJECT_ID=$(getOpenStackProperty "openstack_OS_PROJECT_ID")
export OS_PROJECT_NAME=$(getOpenStackProperty "openstack_OS_PROJECT_NAME")
export OS_PROJECT_DOMAIN_ID=$(getOpenStackProperty "openstack_OS_PROJECT_DOMAIN_ID")
export OS_USER_DOMAIN_ID=$(getOpenStackProperty "openstack_OS_USER_DOMAIN_ID")
export OS_IDENTITY_API_VERSION=$(getOpenStackProperty "openstack_OS_IDENTITY_API_VERSION")
export OS_USERNAME=$(getOpenStackProperty "openstack_OS_USERNAME")
export OS_PASSWORD=$(getOpenStackProperty "openstack_OS_PASSWORD")
#export OS_TENANT_NAME=$(getOpenStackProperty "openstack_OS_TENANT_NAME")
#export OS_DOMAIN_NAME=$(getOpenStackProperty "openstack_OS_DOMAIN_NAME")

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

openstack image list
openstack flavor list
openstack network list

