#!/bin/bash

# created(bruin, 2017-02-21)

# this file contains settings for physical test environment at xiamen lab.

settings_xiamen() {

    NODES=( operation1 operation2 operation3 )
    MGMT_SUFFIX="m"
    STOR_SUFFIX="s"
    IMPI_SUFFIX="i"

    # the i/f name recognized by kernel
    NODES_NIC_NAMES=( enp3s0f1 eno1 )
    # the team i/f names
    #NODES_TEAM_NAMES=( team0 team1 )
    # nodes' ip@: each node has 2 ip@ on 2 subnets, the 3rd one is IPMI
    NODES_IP_ADDRS=( "192.168.100.171 10.0.0.1 10.0.1.1" \
                     "192.168.100.172 10.0.0.2 10.0.1.2" \
                     "192.168.100.173 10.0.0.3 10.0.1.3" )
    # this is used for grant user access rights for mariadb
    NODES_SUBNET_FOR_MARIADB=( "192.168.100.%" "10.0.0.%" )
    # CIDR format mask
    NODES_IP_MASKS=( "22" "24" )
    # gateway for each subnet
    NODES_GW_ADDRS=( "192.168.100.252" "10.0.0.252" )
    NODES_DNS_ADDR="218.85.152.99"
    # the cluster has two VIPs: external and management
    NODES_VIP_NAMES=( "vip0" "vip1" )  # these are also the pckm resource names
    NODES_VIP_ADDRS=( "192.168.100.50" "10.0.1.50" )
    NODES_VIP_MASKS=( "22" "24" )

    # for ceilometer to poll snmp info from all hosts/switches applicable
    SNMP_IP_LIST=( "10.0.1.51" \
                   "10.0.1.52" \
                   "10.0.1.53" )
    # for ceilometer to poll ipmi info from all applicable hosts
    IPMI_IP_LIST=( "TODO" )

    # the local directory for storing repos
    TOOLS_MIRRORS_ROOT="/mirrors"
    # the source site from where to rsync
    TOOLS_MIRRORS_SITE="mirrors.tuna.tsinghua.edu.cn"
    # ip:port of the web server
    TOOLS_IP_ADDR="192.168.101.11"
    TOOLS_HTTP_PORT="80"
    
    # dhcp server bind address
    TOOLS_DHCP_BIND_IP="10.0.0.1"
    # dhcp option 3, providing default gateway to clients
    TOOLS_DHCP_GATEWAY="192.168.100.1"
    # dhcp option 6, providing dns list to clients
    TOOLS_DHCP_DNS="192.168.100.1"
    # tftp root directory
    TOOLS_TFTP_ROOT="/tftp"
    # Note that we put "kickstart" under tftproot, and symbolic link to /mirrors

    NODES_KS_CFG_DIR="${TOOLS_TFTP_ROOT}/kickstart/"
    #NODES_KS_CFG_FILES=( "ks-ctl1.cfg" "ks-ctl2.cfg" "ks-ctl3.cfg" )
    #tmp=( ${NODES[@]/#/ks-} )
    #NODES_KS_CFG_FILES=( ${tmp[@]/%/.cfg} )
    # use sed's "word boundary" match & grouping subsitution, both will do. note that \+ should be escaped.
    #NODES_KS_CFG_FILES=( $(echo ${NODES[*]}|sed "s/\(\b[^ ]\+\)/ks-\1.cfg/g") )
    NODES_KS_CFG_FILES=( $(echo ${NODES[*]}|sed "s/\([^ ]\+\b\)/ks-\1.cfg/g") )

    NODES_KS_URL_PREFIX="http://${TOOLS_IP_ADDR}:${TOOLS_HTTP_PORT}/kickstart/"
    NODES_PXE_CFG_DIR="${TOOLS_TFTP_ROOT}/pxelinux.cfg/"
    NETWORK_INSTALL_URL="http://${TOOLS_IP_ADDR}:${TOOLS_HTTP_PORT}/centos/7/os/x86_64/"
    KERNEL_TFTP_PATH="images/centos/7.3/x86_64/vmlinuz"
    INITRD_TFTP_PATH="images/centos/7.3/x86_64/initrd.img"
}
