#!/bin/bash

# created(bruin, 2017-01-28)

# this file contains various settings for test environment at home.

settings_home() {


    # this is for test environment at home using kvm VMs for nodes.
    #
    # it's assumed that:
    # 1. the guests connect to two networks:
    #   - external:   192.168.100.*/24
    #   - management: 10.0.1.*/24
    # 2. each guest has 4 NICs configures, eth0~3:
    #   - eth0/eth1 connect to external network, teaming as an interface "team0"
    #   - eth2/eth3 connect to management network, teaming as an interface "team1"
    #   - mac@ for 3 guests are:  52:54:00:00:aa:01/02/03/04
    #                             52:54:00:00:bb:01/02/03/04
    #                             52:54:00:00:cc:01/02/03/04
    #   - ip@ for 3 guests are: 192.168.100.51/52/53 (team0)
    #                           10.0.1.51/52/53 (team1)
    # 3. the cluster has two VIPs, one for external, the other for mgmt
    #   - vip@ are: 192.168.100.50 (external)
    #               10.0.1.50 (mgmt)

    # the host (centos7.x) provides an environment
    # for setup kvm/libvirt guests, which can connect to two networks (bridges):
    # - br0: bridge on eth0 of host
    # - br1: for guests to communicate directly (no gateway needed)

    # node names. this is also the libvirt domain name and node's hostname.
    # this name corresponding to the 1st ip@ of the node, where the 1st ip@
    # is located on the external subnet.
    # for the 2nd ip@, which is the on internal mgmt subnet, it also has a
    # name, just suffixed with character 'm'.
    # if there is a 3rd ip@ for storage network, suffix with 's'.
    # the IPMI ip@ suffix is 'i'
    SETTINGS_INFO="settings for home environment"

    # sleep for a while after install one component, otherwise
    # the system may be choked by the pacemaker resources' activities
	BREATH_TIME_IN_SECONDS=30


    NODES=( ctl1 ctl2 ctl3 )
    MGMT_SUFFIX="m"
    STOR_SUFFIX="s"
    IPMI_SUFFIX="i"

    # the abstract path for the folder contains VM xml & images
    GUESTS_ROOT="/home/bruin/work/kvm/ha"
    # both guests' virsh domain name and guests' hostname
    # VM images (qcow2 format) size & file name
    GUESTS_IMAGE_SIZE="100G"
    GUESTS_IMAGES=( ctl1.qcow2 ctl2.qcow2 ctl3.qcow2 )
    GUESTS_CONFIG_FILES=( ctl1.xml ctl2.xml ctl3.xml )

    # host eth0 info. need these to put it into bridge br0 (thus promisc mode)
    HOST_NIC_NAME="eth0"
    HOST_IP_ADDR="192.168.100.19"
    HOST_IP_MASK="255.255.255.0"
    HOST_GW_ADDR="192.168.100.1"
    HOST_DNS_ADDR="192.168.100.1"
    #BR0_MAC_ADDR="52:54:00:7e:27:ae"
    #BR0_IP_ADDR="10.0.0.1/24"
    #BR0_BROADCAST="10.0.0.255"

    BR1_MAC_ADDR="52:54:00:7e:27:af"
    BR1_IP_ADDR="10.0.1.1/24"
    BR1_BROADCAST="10.0.1.255"


    # nodes' mac@: each node has 4 mac@
    NODES_MAC_ADDR=( "52:54:00:00:aa:00 52:54:00:00:aa:01 52:54:00:00:aa:02 52:54:00:00:aa:03" \
                     "52:54:00:00:bb:00 52:54:00:00:bb:01 52:54:00:00:bb:02 52:54:00:00:bb:03" \
                     "52:54:00:00:cc:00 52:54:00:00:cc:01 52:54:00:00:cc:02 52:54:00:00:cc:03" )
    # the i/f name recognized by kernel
    NODES_NIC_NAMES=( eth0 eth1 eth2 eth3 )
    # the team i/f names
    NODES_TEAM_NAMES=( team0 team1 )
    # nodes' ip@: each node has 2 ip@ on 2 subnets, the 3rd one is IPMI
    #NODES_IP_ADDRS=( "10.0.0.51 10.0.1.51 10.0.2.51" \
    #                 "10.0.0.52 10.0.1.52 10.0.2.52" \
    #                 "10.0.0.53 10.0.1.53 10.0.2.53" )
    NODES_IP_ADDRS=( "192.168.100.51 10.0.1.51 10.0.2.51" \
                     "192.168.100.52 10.0.1.52 10.0.2.52" \
                     "192.168.100.53 10.0.1.53 10.0.2.53" )
    # this is used for grant user access rights for mariadb
    #NODES_SUBNET_FOR_MARIADB=( "10.0.0.%" "10.0.1.%" )
    NODES_SUBNET_FOR_MARIADB=( "192.168.100.%" "10.0.1.%" )
    # CIDR format mask
    NODES_IP_MASKS=( "24" "24" )
    # gateway for each subnet
    #NODES_GW_ADDRS=( "10.0.0.1" "10.0.1.1" )
    NODES_GW_ADDRS=( "192.168.100.1" "10.0.1.1" )
    NODES_DNS_ADDR="192.168.100.1"
    # the cluster has two VIPs: external and management
    NODES_VIP_NAMES=( "vip0" "vip1" )  # these are also the pckm resource names
    #NODES_VIP_ADDRS=( "10.0.0.50" "10.0.1.50" )
    NODES_VIP_ADDRS=( "192.168.100.50" "10.0.1.50" )
    NODES_VIP_MASKS=( "24" "24" )

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
    TOOLS_IP_ADDR="192.168.100.19"
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
