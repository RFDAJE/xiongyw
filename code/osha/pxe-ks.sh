#!/bin/bash

# created(bruin, 2017-01-27)

# this script contains utilities to generate PXE and Kickstart config files.

KS_URL_PLACE_HOLDER="URL_PLACE_HOLDER"


# the 1st argument is the TOOLS's ip addr
pxeks() {

  local tools=${1}

  echo "${FUNCNAME[0]}() entering..."
  for idx in "${!NODES[@]}"; do
    local ks_cfg_file=${NODES_KS_CFG_DIR}/${NODES_KS_CFG_FILES[$idx]}
    local install_url=${NETWORK_INSTALL_URL}
    local pxe_cfg_dir=${NODES_PXE_CFG_DIR}
    local ks_cfg_url=${NODES_KS_URL_PREFIX}${NODES_KS_CFG_FILES[$idx]}
    # take the first mac@ which is 17 characters long
    local pxe_mac=${NODES_MAC_ADDR[$idx]:0:17}
    local kernel=${KERNEL_TFTP_PATH}
    local initrd=${INITRD_TFTP_PATH}
    local guest_name=${NODES[$idx]}

    pxe_ks_generate_cfg ${tools} \
                        ${ks_cfg_file} \
                        ${install_url} \
                        ${pxe_cfg_dir} \
                        ${ks_cfg_url} \
                        ${pxe_mac} \
                        ${kernel} \
                        ${initrd} \
                        ${guest_name}

  done
}


# this function prepare ks and pxe config file for the guests, and boot them
# the first time.
# it's assumed that the vm has been defined, and it will boot from NIC (either
# NIC is the 1st boot, or NIC is the 2nd boot while the 1st boot (disk) is not
# initialized yet.
# the function takes the following parameters
# 1. TOOLS's ip@
# 2. path of kickstart cfg file to be created
# 3. network installation url, e.g., "http://x.x.x.x/centos/7/os/x86_64/"
# 4. full path of "./pxelinux.cfg/" directory
# 5. url of the kickstart cfg created, e.g., http://x.x.x.x/ks.cfg
# 6. pxe mac@ for the vm ("aa:bb:cc:dd:ee:ff")
# 7. kernel's tftp path
# 8. initrd's tftp path
# 9. guest vm name
pxe_ks_generate_cfg() {

  local tools=${1}
  local ks_cfg_file=${2}
  local install_url=${3}
  local pxe_cfg_dir=${4}
  local ks_cfg_url=${5}
  local pxe_mac=${6}
  local kernel=${7}
  local initrd=${8}
  local guest_name=${9}

  # generate kickstart cfg file
  _ks_generate_cfg ${tools} ${ks_cfg_file} ${install_url}

  # generate pxe cfg file
  _pxe_generate_cfg ${tools} ${pxe_cfg_dir} ${pxe_mac} ${kernel} ${initrd} ${ks_cfg_url} ${guest_name}
}


################################################################
# takes parameters:
# 1. TOOLS' ip@
# 2. full path of the ks cfg file to be created
# 3. the network installation url
# 4. network configs (could be multi-line string)
_ks_generate_cfg() {
  local tools=${1}
  local cfg=${2}
  local url=${3}
  echo "generating kickstart config file ${2}..."
  _ks_generate_template_cfg ${tools} ${cfg}

  echo "updating kickstart config file ${2}..."
  ssh ${tools} -- sed -i "s@${KS_URL_PLACE_HOLDER}@${url}@" ${cfg}
}


################################################################
# takes the following parameters
# 1. TOOLS' ip@
# 2. full path "./pxelinux.cfg/" directory
# 3. pxe mac@ for the box ("aa:bb:cc:dd:ee:ff")
# 4. kernel's tftp path
# 5. initrd's tftp path
# 6. kickstart cfg url
# 7. guest name
_pxe_generate_cfg() {

  local tools=${1}
  local pxe_dir=${2}
  local mac=${3}
  local kernel=${4}
  local initrd=${5}
  local ks=${6}
  local guest_name=${7}

  echo "generating pxelinux config file for mac@ ${mac}..."
  # pxe config file full path: "...pxelinux.cfg/01-aa-bb-cc-dd-ee-ff"
  local pxe_cfg="${pxe_dir}/01-${mac//:/-}"
  ssh ${tools} -- cat <<-EOF \>${pxe_cfg}
	default menu.c32
	prompt 0
	timeout 50
	ONTIMEOUT CentOS

	MENU TITLE PXE Menu

	LABEL CentOS
	    MENU LABEL CentOS 7.3 x86_64 Kickstart for ${guest_name} (${mac})
	    KERNEL ${kernel}
	    APPEND initrd=${initrd} ramdisk_size=200000 ip=dhcp ks=${ks}
	EOF
}

################################################################
# the 1st argument is the TOOLS's ip@
# the 2nd is the cfg file's full path
_ks_generate_template_cfg() {
  echo "generating ks template config file ${2}..."
  ssh ${1} -- cat <<'EOF' \>${2}
#platform=, AMD64, or Intel EM64T

#version=DEVEL
# System authorization information
auth --useshadow  --passalgo=sha512
# Install OS instead of upgrade
install
# Use network installation
url --url="URL_PLACE_HOLDER"
# Use text mode install
text
# Firewall configuration
firewall --disabled
firstboot --disable
ignoredisk --only-use=vda
# Keyboard layouts
#keyboard --vckeymap=us --xlayouts=''
# System language
lang en_US.UTF-8

# Network information
network  --bootproto=dhcp --device=eth0 --ipv6=no --activate
# Halt after installation
#halt
# reboot after installation
reboot
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
# System bootloader configuration
bootloader --append=" crashkernel=auto" --location=mbr --boot-drive=vda
autopart --type=plain
# Partition clearing information
clearpart --linux --initlabel --drives=vda

%post
%end


%packages
@core
@x11
NetworkManager-tui
chrony
ipmitool
kexec-tools
kexec-tools
lsof
lynx
nmap-ncat
psmisc
rsync
smartmontools
socat
sudo
tcpdump
tmux
wget
xorg-x11-fonts*

%end

%addon com_redhat_kdump --enable --reserve-mb='auto'

%end

EOF
}
