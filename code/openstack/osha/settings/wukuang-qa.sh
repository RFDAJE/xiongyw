#!/bin/bash

# created(bruin, 2017-03-10)

# this file contains settings for wukuang qa environment.
settings_wukuang_qa() {
	SETTINGS_INFO="settings for wukuang test-deployment"

    # sleep for a while after install one component, otherwise
    # the system may be choked by the pacemaker resources' activities
	BREATH_TIME_IN_SECONDS=15

    NODES=( ctl1 ctl2 ctl3 )
    MGMT_SUFFIX="m"
    STOR_SUFFIX="s"
    IPMI_SUFFIX="i"

    NODES_IP_ADDRS=( "192.168.120.155 10.0.1.155 192.168.10.211" \
                     "192.168.120.156 10.0.1.156 192.168.10.212" \
                     "192.168.120.157 10.0.1.157 192.168.10.213" )

    # this is used for grant user access rights for mariadb
    NODES_SUBNET_FOR_MARIADB=( "192.168.120.%" "10.0.1.%" )
    # CIDR format mask
    NODES_IP_MASKS=( "23" "24" )
    # gateway for each subnet
    NODES_GW_ADDRS=( "192.168.120.1" "10.0.1.1" )
    NODES_DNS_ADDR="192.168.120.1"
    # the cluster has two VIPs: external (1st) and management (2nd)
    NODES_VIP_NAMES=( "ctlvip" "ctlvipm" )  # these are also the pckm resource names
    NODES_VIP_ADDRS=( "192.168.120.154" "10.0.1.154" )
    NODES_VIP_MASKS=( "23" "24" )

    # for ceilometer to poll snmp info from all hosts/switches applicable
    SNMP_IP_LIST=( "192.168.120.155" \
                   "192.168.120.156" \
                   "192.168.120.157" )
    # for ceilometer to poll ipmi info from all applicable hosts
    IPMI_IP_LIST=( "TODO" )
}
