#!/bin/bash

# created(bruin, 2017-03-03)

# this script is exectued on the host (centos7.x) to provide an environment
# for setup kvm/libvirt guests, which connects to two bridges (br0/br1) on the
# host

# arguments:
# 1. host's external ip@
# 2. host's mgmt ip@
# 3. host's netmask
# 4. host's gw
# 5. host's dns server
# 6. host's nic1 name
# 7. host's nic2 name
host_setup() {

  local host1=${1}
  local host2=${2}
  local netmask=${3}
  local gw=${4}
  local dns=${5}
  local nic1=${6}
  local nic2=${7}

  local script="/tmp/host.sh"
  local br0="/etc/sysconfig/network-scripts/ifcfg-br0"  # external bridge
  local br1="/etc/sysconfig/network-scripts/ifcfg-br1"  # mgmt bridge

  ssh ${host1} -- cat <<-EOF \>${script}
	#!/bin/bash
	yum -y update
	yum -y install kvm qemu-kvm qemu-img virt-manager libvirt libvirt-python python-virtinst libvirt-client virt-install virt-viewer
	yum -y install tmux htop wget lynx NetworkManager-tui nmon lsof tcpdump nmap-ncat socat psmisc inxi rsync sudo ipmitool smartmontools gsmartcontrol MariaDB-client expect
	# this is to enable SSH X11 forwarding
	yum -y groupinstall "X Window System"
	# this is to install basic x11 fonts
	yum -y install xorg-x11-fonts*

	# add user 'bruin' into group 'libvirt'
	usermod -a -G libvirt bruin

	# disable NetworkManager, firewalld, selinux
	systemctl disable NetworkManager
	systemctl disable firewalld
	systemctl disable iptables
	systemctl stop NetworkManager
	systemctl stop firewalld
	systemctl stop iptables

	setenforce 0
	sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config

	# disable IPv6 for all interface:
	echo net.ipv6.conf.all.disable_ipv6 = 1  >> /etc/sysctl.conf
	echo net.ipv6.conf.default.disable_ipv6 = 1 >> /etc/sysctl.conf
	sysctl -p

	# Enable ssh login without password
	sed -i.bak '{
	  /^#RSAAuthentication/cRSAAuthentication yes
	  /^#PubkeyAuthentication/cPubkeyAuthentication yes
	}' /etc/ssh/sshd_config
	mkdir -p ~/.ssh
	chmod 700 ~/.ssh
	touch ~/.ssh/authorized_keys
	chmod 600 ~/.ssh/authorized_keys
	systemctl restart sshd

	# FIXME: enable x11-forwarding
	#X11Forwarding yes
	#X11UseLocalhost no
	#X11DisplayOffset 10

	# Enable passwordless sudo
	usermod -a -G wheel bruin  # add bruin into wheel group
	sed -i.bak -e '/^#.*wheel.*NOPASSWD/s/^# //' /etc/sudoers

	# enable ip forwarding
	#echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
	#echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.conf
	#sysctl -p

	# disable default virtual network
	systemctl start libvirtd
	virsh net-destroy default
	virsh net-undefine default
	EOF
  ssh ${host1} -- chmod +x ${script} \; ${script}

  echo "setting up br0..."
  ssh ${host1} -- mkdir -p /etc/sysconfig/network-scripts/backup
  ssh ${host1} -- mv -f /etc/sysconfig/network-scripts/\{ifcfg-${nic1},backup\}
  ssh ${host1} -- cat <<-EOF \> /etc/sysconfig/network-scripts/ifcfg-${nic1}
	DEVICE=${nic1}
	ONBOOT=yes
	TYPE=Ethernet
	IPV6INIT=no
	USERCTL=no
	BRIDGE=br0
	EOF
  ssh ${host1} -- cat <<-EOF \> ${br0}
	DEVICE=br0
	TYPE=Bridge
	BOOTPROTO=static
	IPADDR=${host1}
	NETMASK=${netmask}
	GATEWAY=${gw}
	DNS1=${dns}
	ONBOOT=yes
	EOF

  echo "setting up br1..."
  ssh ${host1} -- mkdir -p /etc/sysconfig/network-scripts/backup
  ssh ${host1} -- mv -f /etc/sysconfig/network-scripts/\{ifcfg-${nic2},backup\}
  ssh ${host1} -- cat <<-EOF \> /etc/sysconfig/network-scripts/ifcfg-${nic2}
	DEVICE=${nic2}
	ONBOOT=yes
	TYPE=Ethernet
	IPV6INIT=no
	USERCTL=no
	BRIDGE=br1
	EOF
  ssh ${host1} -- cat <<-EOF \> ${br1}
	DEVICE=br1
	TYPE=Bridge
	BOOTPROTO=static
	IPADDR=${host2}
	NETMASK=${netmask}
	GATEWAY=${gw}
	DNS1=${dns}
	ONBOOT=yes
	EOF

  ssh ${host1} -- systemctl restart network
}
