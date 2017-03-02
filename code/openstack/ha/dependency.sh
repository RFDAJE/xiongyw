#!/bin/bash

# created(bruin, 2017-02-08)

# this is a central place to keep all components' dependency. this dependency is
# not pacemaker's order constraints, it's "hard" dependency like pkg dependency
# that a component won't install unless its dependencies are installed first.
#

# the dependencies will be check at both install and delete time, that:
# 1. install: a component won't install unless all its dependencies are installed
# 2. delete: a component won't delete unless all components dependend on it are deleted


#######################################################################
# the dependency meta-data. only the direct dependency are listed.
# the first item is the component itself, followed by its dependencies

#_pacemaker_deps=( ${PACEMAKER_res_name} )
_chronyd_deps=( ${CHRONYD_res_name} )
_memcached_deps=( ${MEMCACHED_res_name} )
_mongod_deps=( ${MONGOD_res_name} )
_rabbitmq_deps=( ${RABBITMQ_res_name} )
# here use VIP0 to represent both VIP0 and VIP1
_vip_deps=( ${VIP0_res_name} )
_haproxy_deps=( ${HAPROXY_res_name} \
                ${VIP0_res_name} )
_mariadb_deps=( ${MARIADB_res_name} )
# keystone requires that maraidb accessible via VIP (haproxy)
_keystone_deps=( ${KEYSTONE_res_name} \
                 ${MARIADB_res_name} \
                 ${RABBITMQ_res_name} \
                 ${HAPROXY_res_name} )
# ceilometer requires mariadb/rabbitmq and keystone
_ceil_deps=( ${CEIL_res_name} \
             ${SNMPD_res_name} \
             ${MARIADB_res_name} \
             ${HAPROXY_res_name} \
             ${MEMCACHED_res_name} \
             ${RABBITMQ_res_name} \
             ${KEYSTONE_res_name} )

_aodh_deps=( ${AODH_res_name} \
             ${MARIADB_res_name} \
             ${HAPROXY_res_name} \
             ${RABBITMQ_res_name} \
             ${KEYSTONE_res_name} \
             ${CEIL_res_name} )
             
_horizon_deps=( ${HORIZON_res_name} \
                ${MARIADB_res_name} \
                ${HAPROXY_res_name} \
                ${KEYSTONE_res_name} \
                ${CEIL_res_name} )
                
_all_deps=( "${_chronyd_deps[*]}" \
            "${_memcached_deps[*]}" \
            "${_mongod_deps[*]}" \
            "${_rabbitmq_deps[*]}" \
            "${_vip_deps[*]}" \
            "${_haproxy_deps[*]}" \
            "${_mariadb_deps[*]}" \
            "${_keystone_deps[*]}" \
            "${_ceil_deps[*]}" \
            "${_horizon_deps[*]}" \
            "${_aodh_deps[*]}" )
#########################################################



# return a space-delimited string contains dependencies
# the 1st argument is the component res name
dep_i_need() {
  local me=$1

  for idx in "${!_all_deps[@]}"; do
    local item=( ${_all_deps[${idx}]} )
    if [[ ${item[0]} == $me ]]; then
      echo "${item[*]:1}"
      return 0
    else
      continue
    fi
  done
  # not found
  echo ""
}

# return a space-delimited string contains components depend on me
# the 1st argument is "me"
dep_need_me() {
  local me=$1
  local ret=()
  local count

  let count=0
  for idx in "${!_all_deps[@]}"; do
    local item=( ${_all_deps[${idx}]} )
    if [[ ${#item[@]} -lt 2 ]]; then
      continue
    fi
    local candidate=${item[0]}
    for needed in "${item[@]:1}"; do
      if [[ ${needed} == ${me} ]]; then
        ret[$count]=${candidate}
        let count+=1
        continue
      fi
    done
  done

  echo "${ret[*]}"
}

# the 1st argument is the component to be checked before install
dep_install_check() {
  local me=$1
  local deps=( $(dep_i_need ${me}) )

  # directly exit if any of it does not exist
  for item in "${deps[@]}"; do
    ssh ${NODES[0]} -- pcs resource show ${item}
    if [[ $? != 0 ]]; then
      echo "ERROR: ${item} needs to be installed first!"
      exit 1
    fi
  done

  return 0
}

# the 1st argument is the component to be checked before delete (uninstall)
dep_delete_check() {
  local me=$1
  local need_me=( $(dep_need_me ${me}) )

  # directly exit if any of it still exists
  for item in "${need_me[@]}"; do
    ssh ${NODES[0]} -- pcs resource show ${item}
    if [[ $? == 0 ]]; then
      echo "ERROR: ${item} still needs ${me}, won't delete ${me} for now!"
      exit 1
    fi
  done

  return 0
}
