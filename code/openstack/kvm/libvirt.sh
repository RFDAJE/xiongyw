#!/bin/bash

# created(bruin, 2017-01-27)

#
# this script contains utilities using virsh to ... a VM:
# - define/undefine
# - start/stop
# - destroy
# - delete (deleting xml and image)
#
# it'a ssumed that the VM has 1 HDD (VDA) and 4 MAC@ (eth0~3).
#

# place holder in xml config file for VM
VM_MAC_PLACE_HOLDER=( 'PLACE-HOLDER-0' 'PLACE-HOLDER-1' 'PLACE-HOLDER-2' 'PLACE-HOLDER-3' )
VM_RAM_SIZE_PLACE_HOLDER=RAM_PLACE_HOLDER
VM_CPU_NR_PLACE_HOLDER=CPU_NR_PLACE_HOLDER
#########################################
# define one libvirt VM
# the parameters are:
# 1: the HOST's hostname or ip@
# 2: full path of vm xml file to be created
# 3: vm name (known to libvirt)
# 4: full path of the vm image to be created
# 5: vm image size, e.g. "100G"
# 6/7/8/9: mac@, totally 4
vm_define() {
  local host=$1
  local xml=$2
  local name=$3
  local img=$4
  local img_size=$5
  local mac=( $6 $7 $8 $9 )

  # make sure the directories exist
  ssh ${host} -- mkdir -p $(dirname $xml)
  ssh ${host} -- mkdir -p $(dirname $img)

  echo -n "on ${host}: ${FUNCNAME[0]}(): creating VM image ($img)..."
  if [[ -f ${img} ]]; then
    ssh ${host} -- rm -f ${img};
  fi
  ssh ${host} -- qemu-img create -f qcow2 -o size=${img_size} ${img}
  echo "done!"


  echo -n "on ${host}: ${FUNCNAME[0]}(): creating VM config file ($xml)..."
  _vm_generate_template_xml ${host} ${xml}
  # update the VM name
  ssh ${host} -- sed -i "s/template_name/${name}/" ${xml}
  # update the image file path
  ssh ${host} -- sed -i "s@template.qcow2@${img}@" ${xml}
  # update ram size
  ssh ${host} -- sed -i "s/${VM_RAM_SIZE_PLACE_HOLDER}/${GUESTS_RAM_SIZE}/" ${xml}
  # update cpu nr
  ssh ${host} -- sed -i "s/${VM_CPU_NR_PLACE_HOLDER}/${GUESTS_CPU_NR}/" ${xml}
  # update 4 mac@
  for idx in "${!mac[@]}"; do
    ssh ${host} -- sed -i "s/${VM_MAC_PLACE_HOLDER[$idx]}/${mac[idx]}/" ${xml}
  done
  echo "done!"

  echo "on ${host}: ${FUNCNAME[0]}(): defining VM ${name}..."
  ssh ${host} -- virsh define ${xml}
  echo "done!"
}

# the 1st argument is the HOST's hostname or ip@
# the 2nd is the vm name
vm_start() {
  echo "on ${1}: starting vm ${2} ..."
  ssh ${1} -- virsh start ${2}
}

# the 1st argument is the HOST's hostname or ip@
# the 2nd is the vm name
vm_reboot() {
  echo "on ${1}: rebooting vm ${2} ..."
  ssh ${1} -- virsh reboot ${2}
}

# the 1st argument is the HOST's hostname or ip@
# the 2nd is the vm name
vm_stop() {
  echo "on ${1}: stopping vm ${2} ..."
  ssh ${1} -- virsh stop ${2}
}

# the 1st argument is the HOST's hostname or ip@
# the 2nd is the vm name
vm_destroy() {
  echo "on ${1}: destroying vm ${2} ..."
  ssh ${1} -- virsh destroy ${2}
}

# takes 3 parameters:
# 1. the HOST's hostname or ip@
# 2. full path to the image file
# 3. full path to the xml file
vm_delete() {
  echo -n "on ${1}: ${FUNCNAME[0]}(): "
  echo -n "removing VM image ${2}..."
  ssh ${1} -- rm -f ${2}
  echo "done!"

  echo -n "on ${1}: ${FUNCNAME[0]}(): "
  echo -n "removing VM config file ${3}..."
  ssh ${1} -- rm -f ${3}
  echo "done!"
}

# the 1st argument is the HOST's hostname or ip@
# the 2nd is the vm name
vm_undefine() {
  echo "on ${1}: undefining vm ${1} ..."
  ssh ${1} -- virsh undefine ${2}
}

# the 1st argument is the HOST's hostname or ip@
# the 2nd is the xml's full path
_vm_generate_template_xml() {
  echo "on ${1}: generating a template xml for VMs..."
  ssh ${1} -- cat <<'EOF' \>${2}
<domain type='kvm'>
  <name>template_name</name>
  <memory unit='KiB'>RAM_PLACE_HOLDER</memory>
  <currentMemory unit='KiB'>RAM_PLACE_HOLDER</currentMemory>
  <vcpu placement='static'>CPU_NR_PLACE_HOLDER</vcpu>
  <os>
    <type arch='x86_64' machine='pc-i440fx-rhel7.0.0'>hvm</type>
    <bootmenu enable='yes'/>
  </os>
  <features>
    <acpi/>
    <apic/>
    <pae/>
  </features>
  <cpu mode='custom' match='exact'>
    <model fallback='allow'>SandyBridge</model>
  </cpu>
  <clock offset='utc'>
    <timer name='rtc' tickpolicy='catchup'/>
    <timer name='pit' tickpolicy='delay'/>
    <timer name='hpet' present='no'/>
  </clock>
  <on_poweroff>destroy</on_poweroff>
  <on_reboot>restart</on_reboot>
  <on_crash>restart</on_crash>
  <pm>
    <suspend-to-mem enabled='no'/>
    <suspend-to-disk enabled='no'/>
  </pm>
  <devices>
    <emulator>/usr/libexec/qemu-kvm</emulator>
    <disk type='file' device='disk'>
      <driver name='qemu' type='qcow2'/>
      <source file='template.qcow2'/>
      <target dev='vda' bus='virtio'/>
      <boot order='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x0b' function='0x0'/>
    </disk>
    <controller type='usb' index='0' model='ich9-ehci1'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x7'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci1'>
      <master startport='0'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x0' multifunction='on'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci2'>
      <master startport='2'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x1'/>
    </controller>
    <controller type='usb' index='0' model='ich9-uhci3'>
      <master startport='4'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x05' function='0x2'/>
    </controller>
    <controller type='pci' index='0' model='pci-root'/>
    <controller type='virtio-serial' index='0'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x06' function='0x0'/>
    </controller>
    <interface type='bridge'>
      <mac address='PLACE-HOLDER-0'/>
      <source bridge='br0'/>
      <model type='virtio'/>
      <boot order='2'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x03' function='0x0'/>
    </interface>
    <interface type='bridge'>
      <mac address='PLACE-HOLDER-1'/>
      <source bridge='br0'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x04' function='0x0'/>
    </interface>
    <interface type='bridge'>
      <mac address='PLACE-HOLDER-2'/>
      <source bridge='br1'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x09' function='0x0'/>
    </interface>
    <interface type='bridge'>
      <mac address='PLACE-HOLDER-3'/>
      <source bridge='br1'/>
      <model type='virtio'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x0a' function='0x0'/>
    </interface>
    <serial type='pty'>
      <target port='0'/>
    </serial>
    <console type='pty'>
      <target type='serial' port='0'/>
    </console>
    <channel type='spicevmc'>
      <target type='virtio' name='com.redhat.spice.0'/>
      <address type='virtio-serial' controller='0' bus='0' port='1'/>
    </channel>
    <input type='mouse' bus='ps2'/>
    <input type='keyboard' bus='ps2'/>
    <graphics type='spice' autoport='yes'/>
    <video>
      <model type='qxl' ram='65536' vram='65536' heads='1'/>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x02' function='0x0'/>
    </video>
    <redirdev bus='usb' type='spicevmc'>
    </redirdev>
    <redirdev bus='usb' type='spicevmc'>
    </redirdev>
    <redirdev bus='usb' type='spicevmc'>
    </redirdev>
    <redirdev bus='usb' type='spicevmc'>
    </redirdev>
    <memballoon model='virtio'>
      <address type='pci' domain='0x0000' bus='0x00' slot='0x08' function='0x0'/>
    </memballoon>
  </devices>
</domain>
EOF
}


