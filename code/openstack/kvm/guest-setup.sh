#!/bin/bash

# created(bruin, 2017-03-06)

# it uses the global CLUSTERS & GUESTS_NIC_NR
# the 1st argument is the idx of CLUSTERS[]
# the 2nd argument is the idx of the guest
get_macs() {
  local idx=${1}
  local idx2=${2}

  local entry=( ${CLUSTERS[${idx}]} )
  local mac_prefix=${entry[4]}

  # generate mac@ in an array
  local mac=""
  let mac_start=GUESTS_NIC_NR*idx2-GUESTS_NIC_NR
  let mac_end=mac_start+GUESTS_NIC_NR-1
  for i in `seq -f %02g ${mac_start} ${mac_end}`; do
    mac+="${mac_prefix}${i} ";
  done

  echo ${mac}
}

# depends on global ${CLUSTERS[@]}
guests_create() {
  local idx=""
  local idx2=""

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
      local name=${cluster}${idx2}
      local xml=${guests_root}/${name}.xml
      local image=${guests_root}/${name}.qcow2
      local size=${GUESTS_IMAGE_SIZE}

      local mac=$(get_macs ${idx} ${idx2})
#      let mac_start=GUESTS_NIC_NR*idx2-GUESTS_NIC_NR
#      let mac_end=mac_start+GUESTS_NIC_NR-1
#      for i in `seq -f %02g ${mac_start} ${mac_end}`; do
#        mac+="${mac_prefix}${i} ";
#      done
      local macs=(${mac})
      #vm_define ${ip1} ${xml} ${name} ${image} ${size} ${macs[*]}
      echo ${ip1} ${xml} ${name} ${image} ${size} ${macs[*]}
    done
  done
}

# depends on global ${CLUSTERS[@]}
guests_delete() {
  local idx=""
  local idx2=""

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
      local name=${cluster}${idx2}
      local xml=${guests_root}/${name}.xml
      local image=${guests_root}/${name}.qcow2
      vm_destroy ${ip1} ${name}
      vm_undefine ${ip1} ${name}
      vm_delete ${ip1} ${image} ${xml}
    done
  done
}

