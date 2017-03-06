#!/bin/bash

# created(bruin, 2017-03-03): scripts to install kvm guests on hosts, including:
# - setup hosts (pkgs, bridges, etc)
# - define/delete guests (storage, xml, etc)
# - generate pxe/kickstart for guests
# - boot/reboot guests
# - postinstall setup of guests
# - install pacemaker on guests


#
# assumptions
# 1. host/guest os is centos 7.3
# 2. guests on each host form a pacemaker cluster
#
# prerequisites:
# 1. execute as root (or sudo) on a box
# 2. the box can ssh to all hosts without providing passwd (i.e. ssh-copy-id to all nodes)

#####################################################
# initilialize
#####################################################
SCRIPT=$(readlink -f $0)
SCRIPTPATH=$(dirname $SCRIPT)

########################################################
# settings goes first                                  #
# settings to be customized for each depolyment        #
#
. $SCRIPTPATH/settings.sh

settings_ehualu
#                                                      #
#                                                      #
########################################################

. $SCRIPTPATH/common.sh
. $SCRIPTPATH/host-setup.sh
. $SCRIPTPATH/libvirt.sh
. $SCRIPTPATH/guest-setup.sh
. $SCRIPTPATH/pxe-ks.sh
. $SCRIPTPATH/dnsmasq.sh
. $SCRIPTPATH/postinstall.sh
. $SCRIPTPATH/pacemaker.sh


usage() {
  cat <<-EOF
	usage: # $(basename $0) (ssh-copy-id|host|guests[-d]|pxeks|boot|reboot|reboot-vm|poweroff|pacemaker)

	  - list-hosts: list ip@ and hostname of all hosts (cluster)
	  - list-guests: list ip@ and hostname of all guests (node)
	  - ssh-copy-id-hosts: allows root-ssh to each host without providing passwd

	  - host: setup all hosts
	  - guests[-d]: define all guests on all hosts
	  - pxeks: generate pxe/ks config file for all guests on all host
	  - boot: boot all guests on all hosts
	  - reboot: reboot all guests via ssh
	  - reboot-vm: reboot all guests via virsh
	  - poweroff: poweroff all guests via ssh
	  - ssh-copy-id-guests: allows root-ssh to each guest without providing passwd
	  - post: post install tasks
	  - etc-hosts: update /etc/hosts on all nodes, as well as hosts and the box on which this script runs

	  - pacemaker: install pacemaker on all guests and configure each cluster
	  - chronyd:
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
      list-hosts)
        for idx in "${!CLUSTERS[@]}"; do
          local entry=( ${CLUSTERS[${idx}]} )
          local name=${entry[0]}
          local ip=${entry[1]}
          local ip2=${entry[2]}
          echo ${ip}, ${ip2}: ${name}
        done
      ;;
      list-guests)
        for idx in "${!CLUSTERS[@]}"; do
          local entry=( ${CLUSTERS[${idx}]} )
          local name=${entry[0]}
          local node_nr=${entry[3]}
          local ip_start=${entry[5]}
          for idx2 in $(seq 1 ${node_nr}); do
            local guest_name=${name}${idx2}
            let ip_last=ip_start+idx2-1
            local ip=${SUBNET_PREFIX[0]}${ip_last}
            local ip2=${SUBNET_PREFIX[1]}${ip_last}
            local pass="qwerty"
            echo ${ip}, ${ip2}: ${guest_name}
          done
        done
      ;;
      ssh-copy-id-hosts)
        for idx in "${!CLUSTERS[@]}"; do
          local entry=( ${CLUSTERS[${idx}]} )
          local name=${entry[0]}
          local ip=${entry[1]}
          local pass=${entry[6]}
          ssh_copy_id ${name} ${ip} ${pass}
        done
        ;;
      ssh-copy-id-guests)
        for idx in "${!CLUSTERS[@]}"; do
          local entry=( ${CLUSTERS[${idx}]} )
          local name=${entry[0]}
          local node_nr=${entry[3]}
          local ip_start=${entry[5]}
          for idx2 in $(seq 1 ${node_nr}); do
            local guest_name=${name}${idx2}
            let ip_last=ip_start+idx2-1
            local ip=${SUBNET_PREFIX[0]}${ip_last}
            local pass="qwerty"
            ssh_copy_id ${guest_name} ${ip} ${pass}
          done
        done
        ;;
      host)
        for idx in "${!CLUSTERS[@]}"; do
          local entry=( ${CLUSTERS[${idx}]} )
          local cluster=${entry[0]}
          local ip1=${entry[1]}
          local ip2=${entry[2]}
          local node_nr=${entry[3]}
          local mac_prefix=${entry[4]}
          local ip_start=${entry[5]}
          host_setup ${ip1} ${ip2} ${HOST_IP_MASK} ${HOST_GW_ADDR} ${HOST_DNS_ADDR} ${HOST_NIC_NAMES[@]}
        done
        ;;
      guests)
        guests_create ;;
      guests-d)
        guests_delete ;;
      pxeks)
        pxeks
        ;;
      pxeks-d)
        pxeks-d
        ;;
      dnsmasq)
        dnsmasq ;;
      dnsmasq-d)
        dnsmasq-d ;;
      boot)
        for idx in "${!CLUSTERS[@]}"; do
          local entry=( ${CLUSTERS[${idx}]} )
          local name=${entry[0]}
          local ip=${entry[1]}
          local node_nr=${entry[3]}
          for idx2 in `seq 1 $node_nr`; do
            local guest_name=${name}${idx2}
            vm_start ${ip} ${guest_name}
          done
        done
        ;;
      reboot)
        for node in "${NODES[@]}"; do
          ssh ${node} -- reboot
        done
        ;;
      reboot-vm)
        for idx in "${!CLUSTERS[@]}"; do
          local entry=( ${CLUSTERS[${idx}]} )
          local name=${entry[0]}
          local ip=${entry[1]}
          local node_nr=${entry[3]}
          for idx2 in `seq 1 $node_nr`; do
            local guest_name=${name}${idx2}
            vm_reboot ${ip} ${guest_name}
          done
        done
        ;;
      destroy-vm)
        for idx in "${!CLUSTERS[@]}"; do
          local entry=( ${CLUSTERS[${idx}]} )
          local name=${entry[0]}
          local ip=${entry[1]}
          local node_nr=${entry[3]}
          for idx2 in `seq 1 $node_nr`; do
            local guest_name=${name}${idx2}
            vm_destroy ${ip} ${guest_name}
          done
        done
        ;;
      poweroff)
        :
        ;;
      post)
        for idx in "${!CLUSTERS[@]}"; do
          local entry=( ${CLUSTERS[${idx}]} )
          local name=${entry[0]}
          local node_nr=${entry[3]}
          local ip_start=${entry[5]}
          for idx2 in $(seq 1 ${node_nr}); do
			  #    update hostname: hostname represent which i/f, mgmt or external?
			  #    it seems that rabbitmq cluster requires rabbit node names are the
			  #    same as the pacemaker node name. as all those infrastructure services
			  #    (pacemaker/rabbitmq/mariadb/...) should be only accessable from
			  #    internal mgmt network, it's better set the hostnames to mgmt ip@.
            local guest_name=${name}${idx2}${MGMT_SUFFIX}
            let ip_last=ip_start+idx2-1
            local ext_ip=${SUBNET_PREFIX[0]}${ip_last}
            local mgmt_ip=${SUBNET_PREFIX[1]}${ip_last}
            postinstall ${guest_name} ${ext_ip} ${mgmt_ip} ${NODES_IP_MASKS[*]} ${NODES_GW_ADDRS[0]} \
                        ${NODES_NIC_NAMES[*]} \
                        ${NODES_TEAM_NAMES[*]} \
                        ${NODES_DNS_ADDR}
          done
        done
        ;;
      etc-hosts)
        update_etc_hosts
        ;;
      etc-hosts-d)
        update_etc_hosts cleanup
        ;;
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
      *)
        echo "error: unsupported service '$1'"
        usage
        ;;
    esac
}

main $*
