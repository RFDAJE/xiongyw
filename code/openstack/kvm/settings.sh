#!/bin/bash

# created(bruin, 2017-03-03)

# this file contains settings for ehualu mini-deployment, i.e., each
# cluster is formed on several guests running a host.

settings_ehualu() {

    # an array of pairs of "cluster_name host_ext_ip host_mgmt_ip node_nr mac_prefix_for_guests guest_ip_start root_pass"
    CLUSTERS=( "ctl  192.168.8.120  192.168.9.120  3  52:54:00:00:a1:  211 qwerty" \
               "ptl  192.168.8.115  192.168.9.115  3  52:54:00:00:a2:  221 qwerty" \
               "gw   192.168.8.123  192.168.9.123  7  52:54:00:00:a3:  231 qwerty" \
               "hot  192.168.8.118  192.168.9.118  3  52:54:00:00:a4:  241 ssx" \
               "warm 192.168.8.116  192.168.9.116  3  52:54:00:00:a5:  251 qwerty" )

    SUBNET_PREFIX=( "192.168.8." "192.168.9." )

    # host nic info. the 1st nic put into br0, and 2nd put into br1 (thus all in promisc mode)
    HOST_NIC_NAMES=( "enp4s0f0" "enp4s0f1" )
    HOST_IP_MASK="255.255.0.0"
    HOST_GW_ADDR="192.168.8.1"
    HOST_DNS_ADDR="219.141.136.10"

    # the abstract path for the folder contains VM xml & images
    GUESTS_ROOT="/kvm"
    GUESTS_IMAGE_SIZE="100G"

    MGMT_SUFFIX="m"

    # each guest has 4 nic/mac, the first 2 for external network, and rest for
    # mgmt network
    # the i/f name recognized by kernel
    NODES_NIC_NAMES=( eth0 eth1 eth2 eth3 )
    # the team i/f names
    NODES_TEAM_NAMES=( team0 team1 )

    NODES_IP_MASKS=( "16" "16" )
    NODES_GW_ADDRS=( "192.168.8.1" "192.168.8.1" )
    NODES_DNS_ADDR="219.141.136.10"

    # ip:port of the web server
    TOOLS_IP_ADDR="10.2.162.153"
    TOOLS_HTTP_PORT="80"
    TOOLS_TFTP_ROOT="/tftproot"
    # Note that we put "kickstart" under tftproot, and symbolic link to /mirrors

    NODES_KS_CFG_DIR="${TOOLS_TFTP_ROOT}/kickstart/"
    #NODES_KS_CFG_FILES=( $(echo ${NODES[*]}|sed "s/\([^ ]\+\b\)/ks-\1.cfg/g") )

    NODES_KS_URL_PREFIX="http://${TOOLS_IP_ADDR}:${TOOLS_HTTP_PORT}/kickstart/"
    NODES_PXE_CFG_DIR="${TOOLS_TFTP_ROOT}/pxelinux.cfg/"
    NETWORK_INSTALL_URL="http://${TOOLS_IP_ADDR}:${TOOLS_HTTP_PORT}/centos/7/os/x86_64/"
    KERNEL_TFTP_PATH="images/centos/7.3/x86_64/vmlinuz"
    INITRD_TFTP_PATH="images/centos/7.3/x86_64/initrd.img"
}
