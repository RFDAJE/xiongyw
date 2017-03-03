#!/bin/bash

# created(bruin, 2017-01-26)

# this script is exectued on the host (centos7.x) to provide an environment
# for setup kvm/libvirt guests, which can connect to two networks (bridges)

# the 1st argument is the HOST's hostname or ip@
host_setup() {

  local host=${1}
  local script="/tmp/host.sh"
  local br1="/etc/rc.d/rc.br1"  # mgmt bridge network
  ssh ${host} -- cat <<-EOF \>${script}
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
	echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf
	echo "net.ipv4.conf.all.forwarding=1" >> /etc/sysctl.conf
	sysctl -p

	# disable default virtual network
	systemctl start libvirtd
	virsh net-destroy default
	virsh net-undefine default
	EOF
  ssh ${host} -- chmod +x ${script} \; ${script}

  echo "setting up br0 for bridged networking..."
  ssh ${host} -- mkdir -p /etc/sysconfig/network-scripts/backup
  ssh ${host} -- mv -f /etc/sysconfig/network-scripts/\{ifcfg-${HOST_NIC_NAME},backup\}
  ssh ${host} -- cat <<-EOF \> /etc/sysconfig/network-scripts/ifcfg-${HOST_NIC_NAME}
	DEVICE=${HOST_NIC_NAME}
	ONBOOT=yes
	TYPE=Ethernet
	IPV6INIT=no
	USERCTL=no
	BRIDGE=br0
	EOF
  ssh ${host} -- cat <<-EOF \> /etc/sysconfig/network-scripts/ifcfg-br0
	DEVICE=br0
	TYPE=Bridge
	BOOTPROTO=static
	IPADDR=${HOST_IP_ADDR}
	NETMASK=${HOST_IP_MASK}
	GATEWAY=${HOST_GW_ADDR}
	DNS1=${HOST_DNS_ADDR}
	ONBOOT=yes
	EOF
  ssh ${host} -- systemctl restart network

  # create a virtual network br1 for mgmt subnet: 10.0.1.*/24
  ssh ${host} -- cat<<-EOF \> ${br1}
	#!/bin/bash
	echo "setting up br1 ${BR1_IP_ADDR}..."
	ip link del d1
	ip link del br1

	ip link add d1 addr ${BR1_MAC_ADDR} type dummy
	ip link add br1 type bridge
	ip link set d1 master br1
	ip address add ${BR1_IP_ADDR} dev br1 broadcast ${BR1_BROADCAST}

	ip link set d1 up
	ip link set br1 up
	EOF
  ssh ${host} -- chmod +x ${br1}

  ssh ${host} -- sed -i -e '/rc.br1/d' /etc/rc.d/rc.local
  ssh ${host} -- sed -i -e '\$a/etc/rc.d/rc.br1' /etc/rc.d/rc.local
  ssh ${host} -- chmod +x /etc/rc.d/rc.local
  ssh ${host} -- /etc/rc.d/rc.local

  # the host's haproxy acts as a reverse proxy for access WebUIs & services provided from the cluster
  #_haproxy
}


# if we let the guest to bridge on the host's network, then the haproxy on host is not needed.
_haproxy() {

  local script="/tmp/haproxy.sh"
  echo "installing/configuring haproxy..."

  # install & config haproxy
  cat<<-EOF >${script}
	#!/bin/bash
	echo "installing haproxy..."
	yum -y install haproxy
	# save the original /etc/haproxy/haproxy.cfg
	cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig
	systemctl enable haproxy
	systemctl start haproxy
	EOF
    chmod +x ${script}
    ${script}

    echo "configuring haproxy..."
    cat<<-EOF > /etc/haproxy/haproxy.cfg
	#---------------------------------------------------------------------
	# Global settings
	#---------------------------------------------------------------------
	global
	    # to have these messages end up in /var/log/haproxy.log you will
	    # need to:
	    #
	    # 1) configure syslog to accept network log events.  This is done
	    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
	    #    /etc/sysconfig/syslog
	    #
	    # 2) configure local2 events to go to the /var/log/haproxy.log
	    #   file. A line like the following can be added to
	    #   /etc/sysconfig/syslog
	    #
	    #    local2.*                       /var/log/haproxy.log
	    #
	    log         127.0.0.1 local2

	    chroot      /var/lib/haproxy
	    pidfile     /var/run/haproxy.pid
	    maxconn     4000
	    user        haproxy
	    group       haproxy
	    daemon

	    # turn on stats unix socket
	    stats socket /var/lib/haproxy/stats

	#---------------------------------------------------------------------
	# common defaults that all the 'listen' and 'backend' sections will
	# use if not designated in their block
	#---------------------------------------------------------------------
	defaults
	    mode                    http
	    log                     global
	    option                  httplog
	    option                  dontlognull
	    option http-server-close
	    option forwardfor       except 127.0.0.0/8
	    option                  redispatch
	    retries                 3
	    timeout http-request    10s
	    timeout queue           1m
	    timeout connect         10s
	    timeout client          1m
	    timeout server          1m
	    timeout http-keep-alive 10s
	    timeout check           10s
	    maxconn                 3000

	listen host-haproxy-stats
	    bind *:8080
	    mode http
	    stats enable
	    stats uri /
	    stats realm Strictly\ Private
	    stats auth haproxy:password
	EOF

    cat<<-EOF >> /etc/haproxy/haproxy.cfg
    listen host-haproxy-stats
	    bind *:8081
	    mode http
        server ${NODES_VIP_NAMES[0]} ${NODES_VIP_NAMES[0]}:8080 check inter 2000 rise 2 fall 5

	listen mariadb-server
	  bind *:3306
	  mode tcp
	  balance source
	  option tcplog
	  server ${NODES_VIP_NAMES[1]} ${NODES_VIP_ADDRS[1]}:3306 check

	# pacemaker webui is https, so use tcp mode.
	listen pacemaker
	  bind *:2224
	  mode tcp
	  balance source
	  option tcpka
	  option tcplog
	  # fixme
	  server ctl1m 10.0.1.51:2224 check inter 2000 rise 2 fall 5
	  server ctl2m 10.0.1.52:2224 check inter 2000 rise 2 fall 5
	  server ctl3m 10.0.1.53:2224 check inter 2000 rise 2 fall 5

	 # rabbitmq
	 # rabbitmq webui
	 # mongod
	 # keystone
	 # ceilometer
	 # aodh
	 # horizon
	 # puppet?
	EOF
  systemctl restart haproxy
}
