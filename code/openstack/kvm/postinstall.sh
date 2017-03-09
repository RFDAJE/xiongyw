#!/bin/bash

# created(bruin, 2017-03-06)

# args:
# 1: hostname
# 2: ext ip (team0), which should be currently accessible
# 3: mgmt ip (team1)
# 4: ext mask
# 5: mgmt mask
# 6: ext gw
# 7: nic0 name
# 8: nic1 name
# 9: nic2 name
# 10: nic3 name
# 11: ext team name
# 12: mgmt team name
# 13: dns
postinstall() {

  ssh ${2} -- hostnamectl set-hostname ${1}

  _config_yum_repo ${TOOLS_IP_ADDR}:${TOOLS_HTTP_PORT} ${2}

  _install_pkgs ${2}

  # timedatectl
  ssh ${2} -- timedatectl set-ntp 1
  ssh ${2} -- timedatectl set-local-rtc 0

  _setup_teaming $*

  # ssh-key-gen?
}

# args:
# 1: ip
postinstall-t() {
    local node=${1}

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
}


# args:
# 1: hostname
# 2: ext ip (team0), which should be currently accessible
# 3: mgmt ip (team1)
# 4: ext mask
# 5: mgmt mask
# 6: ext gw
# 7: nic0 name
# 8: nic1 name
# 9: nic2 name
# 10: nic3 name
# 11: ext team name
# 12: mgmt team name
# 13: dns
_setup_teaming() {

  local script="/tmp/team.sh"
  local name=${1}
  local ip=(${2} ${3})
  local mask=(${4} ${5})
  local gw=${6}
  local nics=(${7} ${8} ${9} ${10})
  local team=(${11} ${12})
  local dns=${13}

  ssh ${ip[0]} -- cat <<-EOF \>${script}
	#!/bin/bash
	echo "setting up network teaming for ${name}..."

	yum -y install NetworkManager-team

	mkdir -p /etc/sysconfig/network-scripts/backup
	mv -f /etc/sysconfig/network-scripts/ifcfg-eth* /etc/sysconfig/network-scripts/backup
	mv -f /etc/sysconfig/network-scripts/ifcfg-team* /etc/sysconfig/network-scripts/backup

	systemctl enable NetworkManager
	systemctl start NetworkManager; sleep 5

	nmcli con add type team con-name ${team[0]} ifname ${team[0]} ip4 ${ip[0]}/${mask[0]} gw4 ${gw}
	nmcli con add type team-slave con-name ${nics[0]} ifname ${nics[0]} master ${team[0]}
	nmcli con add type team-slave con-name ${nics[1]} ifname ${nics[1]} master ${team[0]}
	nmcli con modify ${team[0]} +ipv4.dns ${dns}

	# don't set gw4 for the second team, if the gw does not allow outgoing traffic
	nmcli con add type team con-name ${team[1]} ifname ${team[1]} ip4 ${ip[1]}/${mask[1]}
	nmcli con add type team-slave con-name ${nics[2]} ifname ${nics[2]} master ${team[1]}
	nmcli con add type team-slave con-name ${nics[3]} ifname ${nics[3]} master ${team[1]}

	systemctl restart network

	echo "testing network..."
	ping -c 3 www.sohu.com
	if [[ $? = 0 ]]; then
	  echo "success!"
	else
	  echo "error!"
	fi
	EOF
  ssh ${ip[0]} -- chmod +x ${script} \; ${script}
}

# update /etc/hosts on all nodes, as well as hosts and the box on which this script runs
# note that VIPs should also be added into /etc/hosts
# TODO: if $1=="cleanup", remove the entries
update_etc_hosts() {
  local ip=""
  local name=""
  local ip_name=()   # ( "ip" "name" )
  local ip_names=()  # ( "ip name" "ip name" ... )
  local nodes=()
  local script="/tmp/hosts.sed"

  info "updating /etc/hosts..."

  #
  # 0. gather all nodes whose /etc/hosts is going to be updated
  #
  for idx in "${!CLUSTERS[@]}"; do
    local entry=( ${CLUSTERS[${idx}]} )
    name=${entry[0]}
    ip=${entry[1]}
    local node_nr=${entry[3]}
    local ip_start=${entry[5]}
    nodes+=(${ip})  # host
    for idx2 in $(seq 1 ${node_nr}); do
      let ip_last=ip_start+idx2-1
      local ext_ip=${SUBNET_PREFIX[0]}${ip_last}
      nodes+=("${ext_ip}")
    done
  done

  #echo "totally ${#nodes[@]} nodes to update: ${nodes[@]}"

  #
  # 1. gather all ip/host pairs in local array
  #
  for idx in "${!CLUSTERS[@]}"; do
    local entry=( ${CLUSTERS[${idx}]} )
    name=${entry[0]}
    local node_nr=${entry[3]}
    local ip_start=${entry[5]}

    for idx2 in $(seq 1 ${node_nr}); do
      local ext_name=${name}${idx2}
      local mgm_name=${name}${idx2}${MGMT_SUFFIX}
      let ip_last=ip_start+idx2-1
      local ext_ip=${SUBNET_PREFIX[0]}${ip_last}
      local mgm_ip=${SUBNET_PREFIX[1]}${ip_last}
      ip_names+=("${ext_ip} ${ext_name}")
      ip_names+=("${mgm_ip} ${mgm_name}")
    done

    let vip=ip_start-1
    local ext_vip=${SUBNET_PREFIX[0]}${vip}
    local mgm_vip=${SUBNET_PREFIX[1]}${vip}
    local ext_vipname=${name}vip
    local mgm_vipname=${name}vipm
    ip_names+=("${ext_vip} ${ext_vipname}")
    ip_names+=("${mgm_vip} ${mgm_vipname}")
  done

  #echo "totally ${#ip_names[@]} entries to add: ${ip_names[@]}"

  # test
  #for elm in "${ip_names[@]}"; do
  #  ip_name=( ${elm} )
  #  echo "${ip_name[@]}, ${#ip_name[@]}"
  #done

  :>${script}

  for elm in "${ip_names[@]}"; do
    ip_name=( ${elm} )
    ip=${ip_name[0]}
    name=${ip_name[1]}
    cat<<-EOF >>${script}
	/${name}\s*$/d
	EOF
    if [[ ${1} != "cleanup" ]]; then
      cat<<-EOF >>${script}
		$ a ${ip} ${name}
		EOF
	fi
  done

  #cat ${script}

  #
  # 2. update /etc/hosts of localhost
  #
  sed -i -f ${script} /etc/hosts

  #
  # 3. update /etc/hosts of each node
  #

  for node in "${nodes[@]}"; do
    info "updating ${node}:/etc/hosts..."
    scp ${script} ${node}:${script}
    ssh ${node} -- sed -i -f ${script} /etc/hosts
    ssh ${node} -- cat /etc/hosts
  done

}


# the 1st argument is the ip[:port] for the HTTP mirror server
# the 2nd argument is the node name or ip
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

# the 1st argument is the node name or ip
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
