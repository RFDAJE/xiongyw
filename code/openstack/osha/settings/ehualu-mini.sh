#!/bin/bash

# created(bruin, 2017-03-09)

# this file contains settings for ehualu mini-deployment.
settings_ehualu_mini() {
	SETTINGS_INFO="settings for ehualu mini-deployment"

    # sleep for a while after install one component, otherwise
    # the system may be choked by the pacemaker resources' activities
	BREATH_TIME_IN_SECONDS=15

    NODES=( ctl1 ctl2 ctl3 )
    MGMT_SUFFIX="m"
    STOR_SUFFIX="s"
    IPMI_SUFFIX="i"

    NODES_IP_ADDRS=( "192.168.8.211 192.168.9.211 192.168.10.211" \
                     "192.168.8.212 192.168.9.212 192.168.10.212" \
                     "192.168.8.213 192.168.9.213 192.168.10.213" )

    # this is used for grant user access rights for mariadb
    NODES_SUBNET_FOR_MARIADB=( "192.168.8.%" "192.168.9.%" )
    # CIDR format mask
    NODES_IP_MASKS=( "24" "24" )
    # gateway for each subnet
    NODES_GW_ADDRS=( "192.168.8.1" "192.168.8.1" )
    NODES_DNS_ADDR="219.141.136.10"
    # the cluster has two VIPs: external (1st) and management (2nd)
    NODES_VIP_NAMES=( "ctlvip" "ctlvipm" )  # these are also the pckm resource names
    NODES_VIP_ADDRS=( "192.168.8.210" "192.168.9.210" )
    NODES_VIP_MASKS=( "24" "24" )

    # for ceilometer to poll snmp info from all hosts/switches applicable
    SNMP_IP_LIST=( "192.168.9.211" \
                   "192.168.9.212" \
                   "192.168.9.213" )
    # for ceilometer to poll ipmi info from all applicable hosts
    IPMI_IP_LIST=( "TODO" )
}
