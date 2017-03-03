#!/bin/bash

# created(bruin, 2017-01-28)

# this script provides functions for:
# - build_yum_mirrors()
# - config_dnsmasq()
# - populate_tftp()
#
# the scripts is to be root-executed on existing CentOS 7 host which serves as a tool node.
# in case of kvm deployment, the tool node can be the same as the host node.


# this is to build a local yum repository for openstack newton on centos 7.x
# the 1st argument is the host name or ip@
build_yum_mirrors() {
  local tools=${1}

  # rsync options
  local options="-avz --exclude SRPMS --exclude sources --delete"
  local script="~/mirrors.sh"

  echo "starting rsync yum repositories..."
  ssh ${tools} -- yum -y install rsync
  ssh ${tools} -- cat<<-EOF \>${script}
	#!/bin/bash
	mkdir -p ${TOOLS_MIRRORS_ROOT}/centos/7/
	mkdir -p ${TOOLS_MIRRORS_ROOT}/epel/7/x86_64/
	mkdir -p ${TOOLS_MIRRORS_ROOT}/elrepo/el7/x86_64/
	mkdir -p ${TOOLS_MIRRORS_ROOT}/mariadb/mariadb-10.1.21/yum/centos7-amd64/
	mkdir -p ${TOOLS_MIRRORS_ROOT}/docker/yum/repo/centos7/
	mkdir -p ${TOOLS_MIRRORS_ROOT}/yum.puppetlabs.com/packages/yum/el/7/PC1/x86_64/

	rsync ${options} ${TOOLS_MIRRORS_SITE}::centos/7/                    ${TOOLS_MIRRORS_ROOT}/centos/7/
	rsync ${options} ${TOOLS_MIRRORS_SITE}::epel/7/x86_64/               ${TOOLS_MIRRORS_ROOT}/epel/7/x86_64/
	rsync ${options} ${TOOLS_MIRRORS_SITE}::elrepo/elrepo/el7/x86_64/    ${TOOLS_MIRRORS_ROOT}/elrepo/el7/x86_64/
	rsync ${options} ${TOOLS_MIRRORS_SITE}::mariadb/mariadb-10.1.21/yum/centos7-amd64/ ${TOOLS_MIRRORS_ROOT}/mariadb/mariadb-10.1.21/yum/centos7-amd64/
	rsync ${options} ${TOOLS_MIRRORS_SITE}::docker/yum/repo/centos7/     ${TOOLS_MIRRORS_ROOT}/docker/yum/repo/centos7/
	rsync ${options} yum.puppetlabs.com::packages/yum/el/7/PC1/x86_64/   ${TOOLS_MIRRORS_ROOT}/yum.puppetlabs.com/packages/yum/el/7/PC1/x86_64/
	EOF
  # rsync repo mirrors is a long process, better copy it manually
  #ssh ${tools} -- chmod +x ${script} \; ${script} 2\>\&1 \>/dev/null \&

  echo "adding rsync activity into crontab..."
  ssh ${tools} -- sed -i.bak '/mirrors.sh/d' /var/spool/cron/root
  ssh ${tools} -- cat<<-EOF \>\>/var/spool/cron/root
	1 1 * * * ${script}
	EOF
  : <<-SKIP

  echo "setting up a web server serving the mirrors..."
  ssh ${tools} -- yum -y remove nginx
  ssh ${tools} -- yum -y install nginx
  ssh ${tools} -- sed -i.bak \'/server {/,+20d\' /etc/nginx/nginx.conf
  ssh ${tools} -- cat<<-EOF \>/etc/nginx/conf.d/mirrors.conf
	server
	{
	        listen ${TOOLS_HTTP_PORT};
	        server_name mirrors;
	        root  ${TOOLS_MIRRORS_ROOT};
	        location / {
	                #index index.html;
	                autoindex on;
	        }
	}
	EOF
  ssh ${tools} -- systemctl enable nginx
  ssh ${tools} -- systemctl start nginx
	SKIP
}

# install dnsmasq & config DHCP(67)/tftp(69) service
# the first argument is the tools hostname or ip@
config_dnsmasq() {
  local tools=${1}

  echo "installing dnsmasq on ${tools}..."
  ssh ${tools} -- yum -y install dnsmasq

  echo "configuring dnsmasq on ${tools}..."
  ssh ${tools} -- cat<<-EOF \> /etc/dnsmasq.d/dnsmasq.conf
	# Sample configuration for dnsmasq to function as a proxyDHCP server, enabling PXE clients
	# to boot when an external, unmodifiable/un-cooperative DHCP server is present.

	# The main dnsmasq configuration is in /etc/dnsmasq.conf;
	# the contents of this script are added to the main configuration.
	# You may modify the file to suit your needs.

	# listen on a specified address/interface
	listen-address=${TOOLS_DHCP_BIND_IP}

	# Don't function as a DNS server, leaving only DHCP/TFTP
	port=0

	# Dnsmasq can also function as a TFTP server, just uncomment the next line:
	enable-tftp

	# Set the root directory for files available via FTP.
	tftp-root=${TOOLS_TFTP_ROOT}

	#######################################################
	# DHCP
	#######################################################

	# Log lots of extra information about DHCP transactions.
	log-dhcp

	# This range(s) is for the private network on 2-NIC servers,
	# where dnsmasq functions as a normal DHCP server, providing IP leases.
	#dhcp-range=10.0.0.200,10.0.0.210,24h

	# This range(s) is for the public interface, where dnsmasq functions
	# as a proxy DHCP server providing boot information but no IP leases.
	# Any ip in the subnet will do, so you may just put your server NIC ip here.
	#dhcp-range=10.0.0.1,proxy

	# For static client IPs, and only for the private subnets,
	# you may put entries like this:
	# put those into a separate config file: hostsfile.conf
	#dhcp-host=70:10:6f:b9:35:1a,10.2.162.170,cyphy-11,infinite
	#dhcp-host=52:54:00:20:a4:51,10.0.0.254,2nic-test,infinite

	# The NBP filename.
	dhcp-boot=pxelinux.0

	# rootpath option, for NFS
	#dhcp-option=17,/opt/ltsp/i386

	# kill multicast
	#dhcp-option=vendor:PXEClient,6,2b

	# Disable re-use of the DHCP servername and filename fields as extra
	# option space. That's to avoid confusing some old or broken DHCP clients.
	dhcp-no-override

	# PXE menu
	pxe-prompt="Press F8 for boot menu", 3

	# The known types are x86PC, PC98, IA64_EFI, Alpha, Arc_x86,
	# Intel_Lean_Client, IA32_EFI, BC_EFI, Xscale_EFI and X86-64_EFI
	pxe-service=X86PC, "Boot from network", ${TOOLS_TFTP_ROOT}/pxelinux

	# A boot service type of 0 is special, and will abort the
	# net boot procedure and continue booting from local media.
	pxe-service=X86PC, "Boot from local hard disk", 0

	# If an integer boot service type, rather than a basename is given, then the
	# PXE client will search for a suitable boot service for that type on the
	# network. This search may be done by multicast or broadcast, or direct to a
	# server if its IP address is provided.
	#pxe-service=x86PC, "Install windows from RIS server", 1
	EOF
  ssh ${tools} -- cat<<-EOF \> /etc/dnsmasq.d/hostsfile.conf
	# # gateway (router)
	dhcp-option=3,${TOOLS_DHCP_GATEWAY}
	# dns
	dhcp-option=6,${TOOLS_DHCP_DNS}
	
	# For static client IPs
	dhcp-range=10.2.162.170,static,255.255.255.0,infinite
	dhcp-host=70:10:6f:b9:35:1a,10.2.162.170,cyphy-11,infinite
	
	dhcp-range=10.2.162.173,static,255.255.255.0,infinite
	dhcp-host=70:10:6f:b9:33:5e,10.2.162.173,cyphy-03,infinite
	
	dhcp-range=10.2.162.152,static,255.255.255.0,infinite
	dhcp-host=1c:39:47:de:11:fa,10.2.162.152,lenovo,infinite
	EOF

  ssh ${tools} -- systemctl enable dnsmasq
  ssh ${tools} -- systemctl start dnsmasq
}

# populate tftp root directory
# the 1st argument is tools hostname or ip@
populate_tftp() {

  local tools=${1}

  echo "creating tftp directories ${TOOLS_TFTP_ROOT}/..."
  ssh ${tools} -- mkdir -p ${TOOLS_TFTP_ROOT}/\{pxelinux.cfg,kickstart,images/centos/7.3/x86_64\}/

  # make a symbolic link to httpd root, thus serving ks cfg via http
  ssh ${tools} -- ln -s ${TOOLS_TFTP_ROOT}/kickstart/ ${TOOLS_MIRRORS_ROOT}/kickstart

  echo "preparing kernel and initrd image..."
  # vmlinuz & initrd.img
  ssh ${tools} -- cp -a /mirrors/centos/7/os/x86_64/images/pxeboot/* ${TOOLS_TFTP_ROOT}/images/centos/7.3/x86_64/

  echo "preparing pxelinux.0 & menu.c32..."
  ssh ${tools} -- yum -y install syslinux
  ssh ${tools} -- cp /usr/share/syslinux/pxelinux.0 ${TOOLS_TFTP_ROOT}
  ssh ${tools} -- cp /usr/share/syslinux/menu.c32 ${TOOLS_TFTP_ROOT}

  echo "preparing default PXE config file ..."
  ssh ${tools} -- cat<<-EOF \> ${TOOLS_TFTP_ROOT}/pxelinux.cfg/default
	default menu.c32
	prompt 0
	timeout 300
	ONTIMEOUT local

	MENU TITLE PXE Menu

	LABEL CentOS 7.3 x86_64 NO KS
	        MENU LABEL CentOS 6.8 x86_64 Manual
	        KERNEL images/centos/7.3/x86_64/vmlinuz
	        APPEND initrd=images/centos/7.3/x86_64/initrd.img ramdisk_size=200000

	LABEL CentOS 7.3 x86_64 with KS
	        MENU LABEL CentOS 7.3 x86_64 Kickstart
	        KERNEL images/centos/7.3/x86_64/vmlinuz
	        APPEND initrd=images/centos/7.3/x86_64/initrd.img ramdisk_size=200000 ksdevice=eth0 ip=dhcp ks=http://${TOOLS_IP_ADDR}:${TOOLS_HTTP_PORT}/kickstart/ks-7.3.cfg
	EOF

  echo "preparing default kickstart config file..."
  ssh ${tools} -- cat<<-'EOF' \>${TOOLS_TFTP_ROOT}/kickstart/ks-7.3.cfg
	#platform=86, AMD64, or Intel EM64T

	#version=DEVEL
	# System authorization information
	auth --useshadow  --passalgo=sha512
	# Install OS instead of upgrade
	install
	# Use network installation
	url --url="http://IP_PORT/centos/7/os/x86_64/"
	# Use text mode install
	text
	# Firewall configuration
	firewall --disabled
	firstboot --disable
	# Keyboard layouts
	# old format: keyboard us
	# new format:
	keyboard --vckeymap=us --xlayouts=''
	# System language
	lang en_US.UTF-8

	# Halt after installation
	halt
	# Root password
	rootpw --plaintext qwerty
	# SELinux configuration
	selinux --enforcing
	# System services
	services --enabled="chronyd"
	# Do not configure the X Window System
	skipx
	# System timezone
	timezone Asia/Shanghai --isUtc
	user --groups=wheel --name=bruin --password=$6$Yn/eguLC2HonSozi$a7BUHBLSH8HAiDa.HOKypXBsZ7DzuVFPcgm.t9QFH.KfX/xr41Q7yIFjir57SVC4g1CE05Dgrah/CT4wfCdb6/ --iscrypted --gecos="bruin"

	%packages
	@core
	chrony
	kexec-tools
	%end

	%addon com_redhat_kdump --enable --reserve-mb='auto'
	%end
	EOF
  ssh ${tools} -- sed -i "s/IP_PORT/${TOOLS_IP_ADDR}:${TOOLS_HTTP_PORT}/" ${TOOLS_TFTP_ROOT}/kickstart/ks-7.3.cfg
}
