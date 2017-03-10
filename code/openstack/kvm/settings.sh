#!/bin/bash

# created(bruin, 2017-03-03)

# this file contains settings for ehualu mini-deployment, i.e., each
# cluster is formed by several guests running on a host.

settings_ehualu() {

    # an array of "cluster_name host_ext_ip host_mgmt_ip node_nr mac_prefix_for_guests guest_ip_start root_pass guests_root"
    CLUSTERS=( "ctl  192.168.8.120  192.168.9.120  3  52:54:00:00:a1:  211 qwerty /data/kvm" \
               "ptl  192.168.8.115  192.168.9.115  3  52:54:00:00:a2:  221 qwerty /data/kvm" \
               "gw   192.168.8.123  192.168.9.123  7  52:54:00:00:a3:  231 qwerty /data/kvm" \
               "hot  192.168.8.118  192.168.9.118  3  52:54:00:00:a4:  241 ssx    /home/data/kvm" \
               "warm 192.168.8.116  192.168.9.116  3  52:54:00:00:a5:  251 qwerty /home/data/kvm" )

    # note that the VIPs of each cluster is the guest_ip_start - 1
    # e.g., if ctl cluster nodes' ip start from .211, then the VIPs are .210
    SUBNET_PREFIX=( "192.168.8." "192.168.9." )

    # host nic info. the 1st nic put into br0, and 2nd put into br1 (thus all in promisc mode)
    HOST_NIC_NAMES=( "enp4s0f0" "enp4s0f1" )
    HOST_IP_MASK="255.255.0.0"
    HOST_GW_ADDR="192.168.8.1"
    HOST_DNS_ADDR="219.141.136.10"

    # the abstract path for the folder contains VM xml & images
    #GUESTS_ROOT="/data/kvm"
    GUESTS_IMAGE_SIZE="100G"
    # unit in Kib: 12(GiB)=12*1024*1024(KiB)
    GUESTS_RAM_SIZE=12582912
    GUESTS_CPU_NR=8
    # each guests has 4 nics (mac@)
    GUESTS_NIC_NR=4

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

    KS_CFG_DIR="${TOOLS_TFTP_ROOT}/kickstart"
    #NODES_KS_CFG_FILES=( $(echo ${NODES[*]}|sed "s/\([^ ]\+\b\)/ks-\1.cfg/g") )

    KS_URL_PREFIX="http://${TOOLS_IP_ADDR}:${TOOLS_HTTP_PORT}/kickstart"
    PXE_CFG_DIR="${TOOLS_TFTP_ROOT}/pxelinux.cfg"
    NETWORK_INSTALL_URL="http://${TOOLS_IP_ADDR}:${TOOLS_HTTP_PORT}/centos/7/os/x86_64/"
    KERNEL_TFTP_PATH="images/centos/7.3/x86_64/vmlinuz"
    INITRD_TFTP_PATH="images/centos/7.3/x86_64/initrd.img"

    # also on TOOLS, for leasing static IP@ to vms
    DNSMASQ_HOSTSFILE_PATH="/etc/dnsmasq.d/kvm-hostsfile.conf"
}

settings_wukuang_qa() {

    # an array of "cluster_name host_ext_ip host_mgmt_ip node_nr mac_prefix_for_guests guest_ip_start root_pass guests_root"
    CLUSTERS=( "ctl  192.168.120.232  10.0.1.232 3  52:54:00:00:a1:  155 qwerty /data/kvm")

    # note that the VIPs of each cluster is the guest_ip_start - 1
    # e.g., if ctl cluster nodes' ip start from .211, then the VIPs are .210
    SUBNET_PREFIX=( "192.168.120." "10.0.1." )

    # host nic info. the 1st nic put into br0, and 2nd put into br1 (thus all in promisc mode)
    HOST_NIC_NAMES=( "ens20f0" "ens20f1" )
    HOST_IP_MASK="255.255.254.0"
    HOST_GW_ADDR="192.168.120.1"
    HOST_DNS_ADDR="192.168.120.1"

    # the abstract path for the folder contains VM xml & images
    #GUESTS_ROOT="/data/kvm"
    GUESTS_IMAGE_SIZE="100G"
    # unit in Kib: 12(GiB)=12*1024*1024(KiB)
    GUESTS_RAM_SIZE=12582912
    GUESTS_CPU_NR=8
    # each guests has 4 nics (mac@)
    GUESTS_NIC_NR=4

    MGMT_SUFFIX="m"

    # each guest has 4 nic/mac, the first 2 for external network, and rest for
    # mgmt network
    # the i/f name recognized by kernel
    NODES_NIC_NAMES=( eth0 eth1 eth2 eth3 )
    # the team i/f names
    NODES_TEAM_NAMES=( team0 team1 )

    NODES_IP_MASKS=( "23" "24" )
    NODES_GW_ADDRS=( "192.168.120.1" "10.0.1.1" )
    NODES_DNS_ADDR="192.168.120.1"

    # ip:port of the web server
    TOOLS_IP_ADDR="192.168.120.80"
    TOOLS_HTTP_PORT="8080"
    TOOLS_TFTP_ROOT="/tftproot"
    # Note that we put "kickstart" under tftproot, and symbolic link to /mirrors

    KS_CFG_DIR="${TOOLS_TFTP_ROOT}/kickstart"
    #NODES_KS_CFG_FILES=( $(echo ${NODES[*]}|sed "s/\([^ ]\+\b\)/ks-\1.cfg/g") )

    KS_URL_PREFIX="http://${TOOLS_IP_ADDR}:${TOOLS_HTTP_PORT}/kickstart"
    PXE_CFG_DIR="${TOOLS_TFTP_ROOT}/pxelinux.cfg"
    NETWORK_INSTALL_URL="http://${TOOLS_IP_ADDR}:${TOOLS_HTTP_PORT}/centos/7/os/x86_64/"
    KERNEL_TFTP_PATH="images/centos/7.3/x86_64/vmlinuz"
    INITRD_TFTP_PATH="images/centos/7.3/x86_64/initrd.img"

    # also on TOOLS, for leasing static IP@ to vms
    DNSMASQ_HOSTSFILE_PATH="/etc/dnsmasq.d/kvm-hostsfile.conf"
}

