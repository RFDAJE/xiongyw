#!/bin/bash

# created(bruin, 2017-03-06)

# populating entries into lease file ${DNSMASQ_HOSTSFILE_PATH}, two lines for
# each guest:
# e.g.:
# dhcp-range=192.168.8.16,static,255.255.0.0,infinite
# dhcp-host=52:54:00:00:aa:00,192.168.8.16,c1,infinite
dnsmasq() {

  local idx=""
  local idx2=""
  local tools=${TOOLS_IP_ADDR}

  for idx in "${!CLUSTERS[@]}"; do
    local entry=( ${CLUSTERS[${idx}]} )
    local cluster=${entry[0]}
    local ip1=${entry[1]}
    local ip2=${entry[2]}
    local node_nr=${entry[3]}
    local mac_prefix=${entry[4]}
    local ip_start=${entry[5]}
    local root_pass=${entry[6]}
    local guests_root=${entry[7]}

    for idx2 in `seq 1 $node_nr`; do
      local guest_name=${cluster}${idx2}
      # use the 1st mac@ for pxe boot
      local macs=($(get_macs ${idx} ${idx2}))
      local pxe_mac=${macs[0]}
      # ip@
      let ip_last=ip_start+idx2-1
      local ip=${SUBNET_PREFIX}${ip_last}

      ssh ${tools} -- echo dhcp-range=${ip},static,${HOST_IP_MASK},infinite \>\> ${DNSMASQ_HOSTSFILE_PATH}
      ssh ${tools} -- echo dhcp-host=${pxe_mac},${ip},${guest_name},infinite \>\> ${DNSMASQ_HOSTSFILE_PATH}
    done
  done

  ssh ${tools} -- systemctl restart dnsmasq
}

dnsmasq-d() {
  local idx=""
  local idx2=""
  local tools=${TOOLS_IP_ADDR}

  for idx in "${!CLUSTERS[@]}"; do
    local entry=( ${CLUSTERS[${idx}]} )
    local node_nr=${entry[3]}
    local ip_start=${entry[5]}

    for idx2 in `seq 1 $node_nr`; do
      local macs=($(get_macs ${idx} ${idx2}))
      local pxe_mac=${macs[0]}
      let ip_last=ip_start+idx2-1
      local ip=${SUBNET_PREFIX}${ip_last}

      ssh ${tools} -- sed -i -e "/${ip}/d" ${DNSMASQ_HOSTSFILE_PATH}
      ssh ${tools} -- sed -i -e "/${pxe_mac}/d" ${DNSMASQ_HOSTSFILE_PATH}
    done
  done

  ssh ${tools} -- systemctl restart dnsmasq
}
