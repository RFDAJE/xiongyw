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
. $SCRIPTPATH/settings/ehualu-dev.sh
. $SCRIPTPATH/settings/ehualu-mini.sh
. $SCRIPTPATH/settings/xiamen.sh

#settings_home
#settings_wukuang
#settings_xiamen
#settings_ehualu_dev
settings_ehualu_mini
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
. $SCRIPTPATH/ha/aodh.sh
. $SCRIPTPATH/ha/summary.sh
. $SCRIPTPATH/ha/horizon.sh

# dependency & constraint
. $SCRIPTPATH/ha/dependency.sh
. $SCRIPTPATH/ha/constraint.sh


usage() {
  cat <<-EOF
	usage: # $(basename $0) (tools|host|guests[-d]|pxeks|boot|reboot|reboot-vm|poweroff
	                  |post[-t]|pacemaker[-d]|pcs
	                  |vip|haproxy|chronyd|memcached|rabbitmq|mongod|mariadb|keystone|snmpd|ceil|aodh)

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
	  - pcs: all pcs commands, including cluster-start, cluster-stop, status, etc
	  - openstack: all openstack commands
	  - ceilomter: all ceilometer commands

	  the following are openstack related ha services, most of them support delete and test, by suffix
	  with '-d' and '-t' respectively; some also support reinstall, by suffixing a '-r'.
	  - chronyd:
	  - vip:
	  - haproxy:
	  - memcached:
	  - rabbitmq:
	  - mongod:
	  - mariadb:
	  - keystone:
	  - snmpd:
	  - ceil:
	  - aodh:

	  - ALL: install all components at once.
	  - summary: output summary info for all services provided by the cluster.
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

    if [[ $# < 1 ]]; then
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
      pcs)
        ssh ${NODES[0]} -- $* ;;
      ${NODES[0]} | ${NODES[1]} | ${NODES[2]})
        node=$1
        shift
        ssh ${node} -- $*
        ;;
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
      settings)
        echo ${SETTINGS_INFO}
		  local EXT_IPS=()
		  local MGMT_IPS=()
		  local IPMI_IPS=()
		  for idx in "${!NODES[@]}"; do
			local ips=( ${NODES_IP_ADDRS[$idx]} )
			EXT_IPS+=(${ips[0]})
			MGMT_IPS+=(${ips[1]})
			IPMI_IPS+=(${ips[2]})
		  done

		  echo "+ nodes info (hostname, ext_ip, mgmt_ip, ipmi_ip):"
		  for idx in "${!NODES[@]}"; do
			echo "  - ${NODES[${idx}]}${MGMT_SUFFIXE} ${EXT_IPS[${idx}]} ${MGMT_IPS[${idx}]} ${IPMI_IPS[${idx}]}"
		  done
        ;;
      ALL)
        pacemaker; sleep ${BREATH_TIME_IN_SECONDS}
        chronyd; sleep ${BREATH_TIME_IN_SECONDS}
        vip; sleep ${BREATH_TIME_IN_SECONDS}
        haproxy; sleep ${BREATH_TIME_IN_SECONDS}
        memcached; sleep ${BREATH_TIME_IN_SECONDS}
        rabbitmq; sleep ${BREATH_TIME_IN_SECONDS}
        mariadb; sleep ${BREATH_TIME_IN_SECONDS}
        mongod; sleep ${BREATH_TIME_IN_SECONDS}
        keystone; sleep ${BREATH_TIME_IN_SECONDS}
        snmpd; sleep ${BREATH_TIME_IN_SECONDS}
        ceil; sleep ${BREATH_TIME_IN_SECONDS}
        aodh; sleep ${BREATH_TIME_IN_SECONDS}
        ;;
      ALL-d)
        aodh-d; sleep ${BREATH_TIME_IN_SECONDS}
        ceil-d; sleep ${BREATH_TIME_IN_SECONDS}
        snmpd-d; sleep ${BREATH_TIME_IN_SECONDS}
        keystone-d; sleep ${BREATH_TIME_IN_SECONDS}
        mongod-d; sleep ${BREATH_TIME_IN_SECONDS}
        mariadb-d; sleep ${BREATH_TIME_IN_SECONDS}
        rabbitmq-d; sleep ${BREATH_TIME_IN_SECONDS}
        memcached-d; sleep ${BREATH_TIME_IN_SECONDS}
        haproxy-d; sleep ${BREATH_TIME_IN_SECONDS}
        vip-d; sleep ${BREATH_TIME_IN_SECONDS}
        chronyd-d; sleep ${BREATH_TIME_IN_SECONDS}
        pacemaker-d; sleep ${BREATH_TIME_IN_SECONDS}
        ;;
      summary)
        $1 ;;
    ###############################################
      openstack)
        ssh ${NODES[0]} -- . admin_openrc \; $*;;
      ceilometer)
        ssh ${NODES[0]} -- . admin_openrc \; $*;;
    ###############################################
      *)
        echo "error: unsupported service '$1'"
        usage
        ;;
    esac
}

main $*
