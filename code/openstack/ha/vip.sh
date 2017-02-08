#!/bin/bash

# created(bruin, 2017-01-17)

# note that VIP resources have to be defined before haproxy resource.
# this will be checked in haproxy script, that if VIP are not defined,
# haproxy resource won't be created.

VIP0_res_name=${NODES_VIP_NAMES[0]}
VIP1_res_name=${NODES_VIP_NAMES[1]}

vip() {

  local vip0=${VIP0_res_name}
  local vip1=${VIP1_res_name}
  local ip0=${NODES_VIP_ADDRS[0]}
  local ip1=${NODES_VIP_ADDRS[1]}
  local mask0=${NODES_VIP_MASKS[0]}
  local mask1=${NODES_VIP_MASKS[1]}

  echo "creating vip resources ${vip0} & ${vip1}..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${vip0}
  if [ $? = 0 ]; then
    echo "info: ${vip0} resource already exist, do nothing!"
    return 0;
  fi

  ssh ${NODES[0]} -- pcs resource create ${vip0} ocf:heartbeat:IPaddr2 ip=${ip0} cidr_netmask=${mask0} op monitor interval=15s
  ssh ${NODES[0]} -- pcs resource create ${vip1} ocf:heartbeat:IPaddr2 ip=${ip1} cidr_netmask=${mask1} op monitor interval=15s
  ssh ${NODES[0]} -- pcs constraint colocation add ${vip1} with ${vip0}
  ssh ${NODES[0]} -- pcs constraint order ${vip0} then ${vip1}
}

vip-d() {
  local vip0=${VIP0_res_name}
  local vip1=${VIP1_res_name}

  dep_delete_check ${VIP0_res_name}

  echo "removing vip resources ${vip0} & ${vip1}..."
  ssh ${NODES[0]} -- pcs resource delete ${vip0}
  ssh ${NODES[0]} -- pcs resource delete ${vip1}
}

vip-t() {
  local vip0=${VIP0_res_name}
  local vip1=${VIP1_res_name}
  echo "testing vips..."
  for vip in ${vip0} ${vip1}; do
    ssh ${NODES[0]} -- ping -c 3 ${vip}
    if [[ $? = 0 ]]; then
      echo "ping ${vip} success!"
    else
      echo "ping ${vip} fail!"
    fi
  done
}
