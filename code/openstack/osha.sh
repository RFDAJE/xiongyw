#!/bin/bash

# created(bruin, 2017-01-17): OpenStack High Availability (osha) scripts

#
# assumptions
# 1. openstack-newton release, use only keystone/ceilometer/aodh components
# 2. on centos 7.3 (as of 2017-01)
# 2. a 3 nodes active/active cluster managed by pacemaker
#
# prerequisites:
# 1. execute as root (or sudo) on a box
# 2. the box can ssh to all nodes without providing passwd (i.e. ssh-copy-id to all nodes)
# 3. /etc/hosts of the box should contains ip for all nodes

# style guide: https://google.github.io/styleguide/shell.xml

#####################################################
# initilialize
#####################################################
SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)

######################################################## 
# settings goes first                                  #
# settings to be customized for each depolyment        #
#
. $SCRIPTPATH/settings/home.sh
. $SCRIPTPATH/settings/wukuang.sh
. $SCRIPTPATH/settings/ehualu.sh
. $SCRIPTPATH/settings/xiamen.sh

#settings_home
#settings_wukuang
#settings_xiamen
settings_ehualu
#                                                      #
#                                                      #
########################################################

# common utilities
. $SCRIPTPATH/common.sh
# create yum mirror, install dnsmasq, httpd...
. $SCRIPTPATH/tools.sh
# install kvm/libvirt pkgs and bridge/iptabls setup
. $SCRIPTPATH/kvm/host-setup.sh
# qemu-img/virsh wrapper
. $SCRIPTPATH/kvm/libvirt.sh
# create/define & delete guests
. $SCRIPTPATH/kvm/guest-setup.sh
# generate pxe/ks cfgs
. $SCRIPTPATH/pxe-ks.sh
# post install for nodes
. $SCRIPTPATH/postinstall.sh
# ha resources
. $SCRIPTPATH/ha/pacemaker.sh
. $SCRIPTPATH/ha/chronyd.sh
. $SCRIPTPATH/ha/memcached.sh
. $SCRIPTPATH/ha/mariadb.sh
. $SCRIPTPATH/ha/rabbitmq.sh
. $SCRIPTPATH/ha/mongod.sh
. $SCRIPTPATH/ha/vip.sh
. $SCRIPTPATH/ha/haproxy.sh
. $SCRIPTPATH/ha/keystone.sh
. $SCRIPTPATH/ha/snmpd.sh
. $SCRIPTPATH/ha/ceilometer.sh
. $SCRIPTPATH/ha/horizon.sh
# dependency & constraint
. $SCRIPTPATH/ha/dependency.sh
. $SCRIPTPATH/ha/constraint.sh


usage() {
  cat <<-EOF
	usage: # $(basename $0) (tools|host|guests[-d]|pxeks|boot|reboot|reboot-vm|poweroff
	                  |post[-t]|pacemaker[-d]|cluster-status|cluster-stop|cluster-start
	                  |vip|haproxy|chronyd|memcached|rabbitmq|mongod|mariadb|keystone|snmpd|ceilometer|aodh)

	  - tools: prepare yum local mirrors and install/config httpd/dnsmasq services on the TOOLS box
	  - host: kvm only. prepare a HOST box as a kvm host (install pkgs and config bridges/iptables)
	  - guests|guests-d: kvm only: create/delete on HOST box the kvm guests which are nodes of the ha cluster
	  - pxeks: generate pxe & ks cfg files for all cluster nodes
	  - boot: kvm only. just "virsh start" the guest nodes, if it's the 1st time, it will pxe boot for ks install
	  - post: postinstall on all nodes, for further configurations
	  - post-t: check connectivity of all nodes
	  - reboot: just reboot all nodes, using "ssh <node> -- reboot"
	  - reboot-vm: reboot all nodes, using "virsh reboot <domain>"
	  - pacemaker: install pacemaker and setup/start cluster
	  - cluster-status: pcs status
	  - cluster-stop: stop cluster
	  - cluster-start: start cluster (required manual start after reboot all nodes)

	  the following are openstack related ha services, most of them support delete and test, by suffix
	  with '-d' and '-t' respectively; some also support reinstall, by suffixing a '-r'.
	  - vip:
	  - haproxy:
	  - chronyd:
	  - memcached:
	  - rabbitmq:
	  - mongod:
	  - mariadb:
	  - keystone:
	  - snmpd:
	  - ceilometer:
	  - aodh:
	EOF
}




#####################################################
# do the work...
#####################################################
main () {
  if [[ $(id -u) != 0 ]]; then
      echo "This script must be run by root, please try it with sudo."
      exit 1;
    fi

    if [[ $# != 1 ]]; then
       usage
       exit 1;
    fi

    case $1 in
    ###############################################
      tools)
        build_yum_mirrors ${TOOLS_IP_ADDR}
        config_dnsmasq ${TOOLS_IP_ADDR}
        populate_tftp ${TOOLS_IP_ADDR}
        ;;
      host)
        host_setup ${HOST_IP_ADDR}
        ;;
      guests)
        guests_create ${HOST_IP_ADDR}
        ;;
      guests-d)
        guests_delete ${HOST_IP_ADDR}
        ;;
      pxeks)
        pxeks ${TOOLS_IP_ADDR}
        ;;
      boot)
        for node in "${NODES[@]}"; do
          vm_start ${HOST_IP_ADDR} ${node}
        done
        ;;
      reboot)
        for node in "${NODES[@]}"; do
          ssh ${node} -- reboot
        done
        ;;
      reboot-vm)
        for node in "${NODES[@]}"; do
          vm_reboot ${HOST_IP_ADDR} ${node}
        done
        ;;
      poweroff)
        ssh ${NODES[0]} -- pcs cluster stop --all
        for node in "${NODES[@]}"; do
          ssh ${node} -- poweroff
        done
        ;;
      post)
        postinstall ;;
      post-t)
        postinstall-t ;;
      pacemaker | pacemaker-[d])
        $1 ;;
      cluster-status)
        ssh ${NODES[0]} -- pcs status ;;
      cluster-stop)
        ssh ${NODES[0]} -- pcs cluster stop --all ;;
      cluster-start)
        ssh ${NODES[0]} -- pcs cluster start --all ;;
    ###############################################
      chronyd | chronyd-[dt])
        $1 ;;
      memcached | memcached-[dt])
        $1 ;;
      mariadb | mariadb-[drt])
        $1 ;;
      rabbitmq | rabbitmq-[dtr])
        $1 ;;
      mongod | mongod-[dtr])
        $1 ;;
      vip | vip-[dt])
        $1 ;;
      haproxy | haproxy-[dtr])
        $1 ;;
      keystone | keystone-[dtr])
        $1 ;;
      snmpd | snmpd-[dtr])
        $1 ;;
      ceil | ceil-[dtr])
        $1 ;;
      aodh | aodh-[dt])
        $1 ;;
      *)
        echo "error: unsupported service '$1'"
        usage
        ;;
    esac
}

main $1
