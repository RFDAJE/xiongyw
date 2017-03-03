#!/bin/bash

# created(bruin, 2017-01-27)

# the first argument is the HOST's hostname or ip@
guests_create() {
  local host=${1}

  ssh ${host} -- mkdir -p ${GUESTS_ROOT}
  # fixme: making sure that qemu:qemu can access the folder:
  #   for any subdirectory to that, chmod go+xr <dir>

  for idx in "${!NODES[@]}"; do
    local xml=${GUESTS_ROOT}/${GUESTS_CONFIG_FILES[$idx]}
    local name=${NODES[$idx]}
    local image=${GUESTS_ROOT}/${GUESTS_IMAGES[$idx]}
    local size=${GUESTS_IMAGE_SIZE}
    local mac=( ${NODES_MAC_ADDR[$idx]} )

    vm_define ${host} ${xml} ${name} ${image} ${size} ${mac[*]}
  done
}


# the first argument is the HOST's hostname or ip@
guests_delete() {
  local host=${1}

  echo "deleting guests..."

  for guest in "${NODES[@]}"; do
    vm_destroy ${host} ${guest}
    vm_undefine ${host} ${guest}
  done

  # remove VM images and xml
  for idx in "${!GUESTS_IMAGES[@]}"; do
    vm_delete ${host} "${GUESTS_ROOT}/${GUESTS_IMAGES[$idx]}" "${GUESTS_ROOT}/${GUESTS_CONFIG_FILES[$idx]}"
  done
}

