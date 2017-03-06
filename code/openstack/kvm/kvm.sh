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
. $SCRIPTPATH/postinstall.sh
. $SCRIPTPATH/pacemaker.sh


usage() {
  cat <<-EOF
	usage: # $(basename $0) (ssh-copy-id|host|guests[-d]|pxeks|boot|reboot|reboot-vm|poweroff|pacemaker)

	  - ssh-copy-id: allows root-ssh to each host without providing passwd
	  - host: setup all hosts
	  - guests[-d]: define all guests on all hosts
	  - pxeks: generate pxe/ks config file for all guests on all host
	  - boot: boot all guests on all hosts
	  - reboot: reboot all guests via ssh
	  - reboot-vm: reboot all guests via virsh
	  - poweroff: poweroff all guests via ssh
	  - pacemaker: install pacemaker on all guests and configure each cluster
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
      ssh-copy-id)
        for idx in "${!CLUSTERS[@]}"; do
          local entry=( ${CLUSTERS[${idx}]} )
          local name=${entry[0]}
          local ip=${entry[1]}
          local pass=${entry[6]}
          ssh_copy_id ${name} ${ip} ${pass}
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
      *)
        echo "error: unsupported service '$1'"
        usage
        ;;
    esac
}

main $*
