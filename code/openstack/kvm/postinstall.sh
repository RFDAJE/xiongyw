#!/bin/bash

# created(bruin, 2017-03-03)

postinstall() {

  _ssh_copy_id
  _setup_teaming
  #_update_sshd_listenaddress
  _update_hostname_n_hosts

  for node in "${NODES[@]}"; do
    _config_yum_repo ${TOOLS_IP_ADDR}:${TOOLS_HTTP_PORT} ${node}
    _install_pkgs ${node}
  done

  # timedatectl
  for node in "${NODES[@]}"; do
    ssh ${node} -- timedatectl set-ntp 1
    ssh ${node} -- timedatectl set-local-rtc 0
  done

  # ssh-key-gen?
}

postinstall-t() {
  for node in "${NODES[@]}"; do
    # connectivity check
    ssh ${node} -- ping -c 3 www.sohu.com
    if [[ $? = 0 ]]; then
      echo "ping success!"
    else
      error "ERROR: ping fail!"
      exit 1
    fi

    # firewalld
    echo "checking firewalld..."
    ssh ${node} -- systemctl status firewalld \| grep inactive
    if [[ $? != 0 ]]; then
      error "firealld is not disabled on ${node}!"
      exit 1
    fi

    # selinux
    echo "checking selinux..."
    ssh ${node} -- getenforce \| grep Disabled
    if [[ $? != 0 ]]; then
      error "selinux is not disabled on ${node}!"
      exit 1
    fi

    # iptables
    echo "checking iptables..."
    ssh ${node} -- systemctl status iptables
    if [[ $? == 0 ]]; then
      # iptables is installed, check further
      ssh ${node} -- systemctl status iptables \| grep inactive
      if [[ $? != 0 ]]; then
        error "iptables is not disabled on ${node}!"
        exit 1
      fi
    fi

    # timedatectl
    cat <<-'EOF' | ssh -T ${node} --
	timedatectl | grep "NTP enabled: yes"
	EOF
    if [[ $? != 0 ]]; then
      error "NTP is not enabled on ${node}! correct this by: timedatectl set-ntp 1"
      exit 1
    fi

    cat <<-'EOF' | ssh -T ${node} --
	timedatectl | grep "RTC in local TZ: no"
	EOF
    if [[ $? != 0 ]]; then
      error "RTC setting is not good on ${node}! correct this by: timedatectl set-local-rtc 0"
      exit 1
    fi
  done
}

_ssh_copy_id() {
  echo "adding all guests into host's /etc/hosts, and removing history in .ssh/* ..."
  for idx in "${!NODES[@]}"; do
    local name=${NODES[$idx]}
    local ip=( ${NODES_IP_ADDRS[$idx]} )

    sed -i "/\s${name}\s*$/d" /etc/hosts
    sed -i "$ a ${ip[0]} ${name}" /etc/hosts

    ssh-keygen -f "/root/.ssh/known_hosts" -R ${name}
    ssh-keygen -f "/root/.ssh/known_hosts" -R ${ip[0]}
  done

  echo "ssh-copy-id for all guests..."
  script="/tmp/ssh-copy-id.exp";
  for node in "${NODES[@]}"; do
    echo "ssh-copy-id..."
    cat <<-EOF >${script}
	#!/usr/bin/expect

	set password "qwerty"
	set timeout -1

	spawn ssh-copy-id ${node}
	expect {
	    "(yes/no)?" {
	        send "yes\r"
	        exp_continue
	    }
	    "password:" {
	        send \$password
	        send "\r"
	        exp_continue
	    }
	}
	EOF
	chmod +x ${script}
	${script}
  done
}

_setup_teaming() {
  # setup network teaming for all nodes
  local script="/tmp/team.sh"
  local name=""
  local ip=""
  for idx in "${!NODES[@]}"; do
    name=${NODES[$idx]}
    ip=( ${NODES_IP_ADDRS[$idx]} )
    ssh ${name} -- cat <<-EOF \>${script}
	#!/bin/bash
	echo "setting up network teaming for ${name}..."

	yum -y install NetworkManager-team

	mkdir -p /etc/sysconfig/network-scripts/backup
	mv -f /etc/sysconfig/network-scripts/ifcfg-eth* /etc/sysconfig/network-scripts/backup
	mv -f /etc/sysconfig/network-scripts/ifcfg-team* /etc/sysconfig/network-scripts/backup

	systemctl enable NetworkManager
	systemctl start NetworkManager; sleep 5

	nmcli con add type team con-name ${NODES_TEAM_NAMES[0]} ifname ${NODES_TEAM_NAMES[0]} ip4 ${ip[0]}/${NODES_IP_MASKS[0]} gw4 ${NODES_GW_ADDRS[0]}
	nmcli con add type team-slave con-name ${NODES_NIC_NAMES[0]} ifname ${NODES_NIC_NAMES[0]} master ${NODES_TEAM_NAMES[0]}
	nmcli con add type team-slave con-name ${NODES_NIC_NAMES[1]} ifname ${NODES_NIC_NAMES[1]} master ${NODES_TEAM_NAMES[0]}
	nmcli con modify ${NODES_TEAM_NAMES[0]} +ipv4.dns ${NODES_DNS_ADDR}

	# don't set gw4 for the second team, if the gw does not allow outgoing traffic
	nmcli con add type team con-name ${NODES_TEAM_NAMES[1]} ifname ${NODES_TEAM_NAMES[1]} ip4 ${ip[1]}/${NODES_IP_MASKS[1]}
	nmcli con add type team-slave con-name ${NODES_NIC_NAMES[2]} ifname ${NODES_NIC_NAMES[2]} master ${NODES_TEAM_NAMES[1]}
	nmcli con add type team-slave con-name ${NODES_NIC_NAMES[3]} ifname ${NODES_NIC_NAMES[3]} master ${NODES_TEAM_NAMES[1]}

	systemctl restart network

	echo "testing network..."
	ping -c 3 www.sohu.com
	if [[ $? = 0 ]]; then
	  echo "success!"
	else
	  echo "error!"
	fi
	EOF
	ssh ${name} -- chmod +x ${script} \; ${script}
  done
}

# instead of listen on all i/f, specify the i/f to listen
_update_sshd_listenaddress () {
  local conf="/etc/ssh/sshd_config"
  local ips=""
  for idx in "${!NODES[@]}"; do
    echo "updating sshd_config ${NODES[$idx]}..."
    ips=( ${NODES_IP_ADDRS[${idx}]} )
    cat <<-EOF | ssh -T ${NODES[$idx]} --
		sed -i.bak -e "/#ListenAddress ::/a ListenAddress ${ips[0]}\nListenAddress ${ips[1]}" ${conf}
	EOF
    echo "restarting sshd..."
    ssh ${NODES[$idx]} -- systemctl restart sshd
  done
}

# update hostname and /etc/hosts for each node
_update_hostname_n_hosts() {
  local ip=""
  local name=""
  local ip_name=()   # ( "ip" "name" )
  local ip_names=()  # ( "ip name" "ip name" ... )

  #
  # 0. update hostname: hostname represent which i/f, mgmt or external?
  #    it seems that rabbitmq cluster requires rabbit node names are the
  #    same as the pacemaker node name. as all those infrastructure services
  #    (pacemaker/rabbitmq/mariadb/...) should be only accessable from
  #    internal mgmt network, it's better set the hostnames to mgmt ip@.
  #
  echo "updating hostname..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- hostnamectl set-hostname ${node}${MGMT_SUFFIX}
  done

  echo "updating /etc/hosts..."

  #
  # 1. gather all ip/host paris in local array
  #
  # external/mgmt/ipmi
  for idx in "${!NODES[@]}"; do
    name=${NODES[$idx]}
    ip=( ${NODES_IP_ADDRS[$idx]} )
    ip_names+=( "${ip[0]} ${name}" )
    ip_names+=( "${ip[1]} ${name}m" )   # mgmt
    ip_names+=( "${ip[2]} ${name}i" )   # ipmi
  done

  # vips
  for idx in "${!NODES_VIP_NAMES[@]}"; do
    name=${NODES_VIP_NAMES[$idx]}
    ip=${NODES_VIP_ADDRS[$idx]}
    ip_names+=( "${ip} ${name}" )
  done
  # test
  #for elm in "${ip_names[@]}"; do
  #  ip_name=( ${elm} )
  #  echo "${ip_name[@]}, ${#ip_name[@]}"
  #done

  #
  # 2. update /etc/hosts of each node
  #
  for node in "${NODES[@]}"; do
    for elm in "${ip_names[@]}"; do
      ip_name=( ${elm} )
      ip=${ip_name[0]}
      name=${ip_name[1]}
      ssh ${node} -- sed -i \'"/\s${name}\s*$/d"\' /etc/hosts
      ssh ${node} -- sed -i \'"$ a ${ip} ${name}"\' /etc/hosts
    done
    ssh ${node} -- cat /etc/hosts
  done

  #
  # 3. update /etc/hosts of localhost
  #
  echo "updating /etc/host of localhost..."
  for elm in "${ip_names[@]}"; do
    ip_name=( ${elm} )
    ip=${ip_name[0]}
    name=${ip_name[1]}
    sed -i "/\s${name}\s*$/d" /etc/hosts
    sed -i "$ a ${ip} ${name}" /etc/hosts
  done
  cat /etc/hosts
}

# the 1st argument is the ip[:port] for the HTTP mirror server
# the 2nd argument is the node name
# eg.: config_yum_repo 192.168.120.80:8080 g2
_config_yum_repo() {

  local mirrors=$1
  local node=$2
  local releasever=7
  local basearch=x86_64

  echo "configuring yum repos for ${node}..."
  # disable fastest mirror plugin
  ssh $node -- sed -i.bak -e '/enabled/cenabled=0' /etc/yum/pluginconf.d/fastestmirror.conf

  # backup existing repo files
  ssh $node -- mkdir -p /etc/yum.repos.d/backup
  ssh $node -- mv -f /etc/yum.repos.d/*.repo /etc/yum.repos.d/backup

  # create the local repo file
  ssh $node -- cat<<-EOF \> /etc/yum.repos.d/$mirrors.repo
	###############################################
	# centos
	###############################################
	[base]
	name=CentOS-$releasever - Base
	baseurl=http://$mirrors/centos/$releasever/os/$basearch/
	gpgcheck=0
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

	#released updates
	[updates]
	name=CentOS-$releasever - Updates
	baseurl=http://$mirrors/centos/$releasever/updates/$basearch/
	gpgcheck=0
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

	#additional packages that may be useful
	[extras]
	name=CentOS-$releasever - Extras
	baseurl=http://$mirrors/centos/$releasever/extras/$basearch/
	gpgcheck=0
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

	#additional packages that extend functionality of existing packages
	[centosplus]
	name=CentOS-$releasever - Plus
	baseurl=http://$mirrors/centos/$releasever/centosplus/$basearch/
	gpgcheck=0
	enabled=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-7

	###############################################
	# CentOS-OpenStack-newton.repo
	###############################################
	# Please see http://wiki.centos.org/SpecialInterestGroup/Cloud for more information
	[centos-openstack-newton]
	name=CentOS-7 - OpenStack newton
	baseurl=http://$mirrors/centos/7/cloud/$basearch/openstack-newton/
	gpgcheck=0
	enabled=1
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-CentOS-SIG-Cloud

	###########################################
	# epel
	###########################################
	# note: first do: yum install yum install epel-release
	[epel]
	name=Extra Packages for Enterprise Linux 7 - $basearch
	baseurl=http://$mirrors/epel/7/$basearch
	failovermethod=priority
	enabled=1
	gpgcheck=0
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7

	###########################################
	# elrepo
	###########################################
	# note: first do: rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org

	[elrepo]
	name=ELRepo.org Community Enterprise Linux Repository - el7
	baseurl=http://$mirrors/elrepo/el7/$basearch/
	enabled=0

	###########################################
	# mariadb 10.1.19
	###########################################

	[mariadb]
	name = MariaDB 10.1.19
	baseurl=http://$mirrors/mariadb/mariadb-10.1.19/yum/centos7-amd64/
	gpgkey=http://$mirrors/mariadb/RPM-GPG-KEY-MariaDB
	gpgcheck=0

	###########################################
	# mongodb 3.4
	###########################################
	[mongodb-org-3.4]
	name=MongoDB Repository
	baseurl=http://$mirrors/mongodb/el7-3.4/
	gpgcheck=0
	enabled=1
	gpgkey=https://www.mongodb.org/static/pgp/server-3.4.asc

	###########################################
	# puppet pc1
	###########################################

	[puppetlabs-pc1]
	name=Puppet Labs PC1 Repository el 7 - $basearch
	baseurl=http://$mirrors/yum.puppetlabs.com/packages/yum/el/7/PC1/$basearch
	gpgkey=file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppetlabs-PC1
	       file:///etc/pki/rpm-gpg/RPM-GPG-KEY-puppet-PC1
	enabled=1
	gpgcheck=0

	###########################################
	# ha-clustering
	###########################################

	[ha-clustering]
	name=Stable High Availability/Clustering packages (CentOS_CentOS-7)
	type=rpm-md
	baseurl=http://$mirrors/opensuse-repositories/network:/ha-clustering:/Stable/CentOS_CentOS-7/
	gpgcheck=0
	gpgkey=file:///$mirrors/opensuse-repositories/network:/ha-clustering:/Stable/CentOS_CentOS-7/repodata/repomd.xml.key
	enabled=0

	###########################################
	# docker
	###########################################
	[docker]
	name=Docker Repository
	baseurl=http://$mirrors/docker/yum/repo/centos7/
	enabled=1
	gpgcheck=0
	gpgkey=file:///$mirrors/docker/gpg
	EOF
}

# the 1st argument is the node name
_install_pkgs() {
  local node=$1
  local script="/tmp/pkg.sh"
  ssh ${node} -- cat<<-EOF \>${script}
	#!/bin/bash

	echo "yum clean all and update..."
	yum clean all
	rpm --import https://www.elrepo.org/RPM-GPG-KEY-elrepo.org
	yum -y update

	echo "installing misc packages..."
	yum -y install NetworkManager-tui NetworkManager-team chrony ipmitool \
	kexec-tools kexec-tools lsof lynx nmap-ncat psmisc rsync smartmontools \
	socat sudo tcpdump tmux wget htop inxi gsmartcontrol

	echo "installing vim-enhanced..."
	yum -y install vim-enhanced
	yum -y remove vim-minimal
	ln -s /usr/bin/vim /usr/bin/vi

	echo "disabling firewalld/iptables/selinux"
	systemctl disable firewalld
	systemctl disable iptables
	systemctl stop firewalld
	systemctl stop iptables

	setenforce 0
	sed -i.bak '/^SELINUX=/cSELINUX=disabled' /etc/selinux/config

	echo "disabling IPv6 for all interface..."
	echo net.ipv6.conf.all.disable_ipv6 = 1  >> /etc/sysctl.conf
	echo net.ipv6.conf.default.disable_ipv6 = 1 >> /etc/sysctl.conf
	sysctl -p

	echo "enabling ssh login without password..."
	sed -i.bak '{
	  /^#RSAAuthentication/cRSAAuthentication yes
	  /^#PubkeyAuthentication/cPubkeyAuthentication yes
	}' /etc/ssh/sshd_config
	mkdir -p ~/.ssh
	chmod 700 ~/.ssh
	touch ~/.ssh/authorized_keys
	chmod 600 ~/.ssh/authorized_keys

	echo "enabling passwordless sudo..."
	usermod -a -G wheel bruin  # add bruin into wheel group
	sed -i.bak '{
	  /^# \%wheel/c\%wheel ALL=(ALL) NOPASSWD: ALL
	}' /etc/sudoers
	EOF
  ssh ${node} -- chmod +x ${script} \; ${script}
}
