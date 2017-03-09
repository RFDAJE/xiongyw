#!/bin/bash

# created(bruin, 2017-03-09)

summary() {
  info "service summary list"

  local EXT_IPS=()
  local MGMT_IPS=()
  local IPMI_IPS=()
  for idx in "${!NODES[@]}"; do
    local ips=( ${NODES_IP_ADDRS[$idx]} )
    EXT_IPS+=(${ips[0]})
    MGMT_IPS+=(${ips[1]})
    IPMI_IPS+=(${ips[2]})
  done

  echo "+ nodes info (hostname, ext_ip, mgmt_ip, ipmi_ip):"
  for idx in "${!NODES[@]}"; do
    echo "  - ${NODES[${idx}]}${MGMT_SUFFIXE} ${EXT_IPS[${idx}]} ${MGMT_IPS[${idx}]} ${IPMI_IPS[${idx}]}"
  done

  # pacemaker web-ui
  echo "+ pacemaker web-ui:"
  for idx in "${!NODES[@]}"; do
    echo "  - https://hacluster:qwerty@${EXT_IPS[${idx}]}:2224/"
  done

  # haproxy web-ui
  echo "+ haproxy web-ui:"
  echo "  - http://haproxy:password@${NODES_VIP_ADDRS[0]}:8080/"

  # ntp servers
  echo "+ ntp servers: "
  for idx in "${!MGMT_IPS[@]}"; do
    echo "  - ${MGMT_IPS[${idx}]}"
  done

  # memcached servers
  echo "+ memcached servers:"
  for idx in "${!MGMT_IPS[@]}"; do
    echo "  - ${MGMT_IPS[${idx}]}:${MEMCACHED_port}"
  done

  # rabbitmq cluster
  echo "+ rabbitmq cluster:"
  for idx in "${!NODES[@]}"; do
    local node=${NODES[$idx]}
    local ips=( ${NODES_IP_ADDRS[$idx]} )
    echo "  - ${ips[1]}:${RABBITMQ_port}"
  done

  local rabbitmq_host_n_port=(${MGMT_IPS[@]/%/:${RABBITMQ_port}})
  local rabbitmq_host_n_port_user_pass="${rabbitmq_host_n_port[@]/#/${RABBITMQ_user}:${RABBITMQ_pass}}"
  local rabbitmq_transport_url="rabbit://${rabbitmq_host_n_port_user_pass// /,}/"

  echo "  - transport url: ${rabbitmq_transport_url}"
  echo "  - vip access (not recommended to use): ${NODES_VIP_ADDRS[1]}:${RABBITMQ_mgmt_port}"
  echo "  - web ui for mgmt: http://guest:guest@${NODES_VIP_ADDRS[0]}:${RABBITMQ_mgmt_port}/"
  echo "                     http://guest:guest@${NODES_VIP_ADDRS[1]}:${RABBITMQ_mgmt_port}/"

  # mariadb cluster
  echo "+ mariadb cluster:"
  echo "  - vip access: ${NODES_VIP_ADDRS[1]}:3306"
  echo "  - connection url for keystone: ${KEYSTONE_sqlalchemy_connection}"
  echo "  - connection url for aodh:     ${AODH_sqlalchemy_connection}"

  # mongodb replica set
  echo "+ mongodb replica set:"
  local mongod_nodes="${MGMT_IPS[@]/%/:27017}"
  local mongod_nodes=${mongod_nodes// /,}
  local mongod_conn_url="mongodb://${mongod_nodes}/?replicaSet=${mongod_rs_name}"
  echo "  - connection url: ${mongod_conn_url}"

  # keystone endpoints:
  echo "+ keystone endpoints:"
  echo "  - public url:   ${KEYSTONE_public_url}"
  echo "  - internal url: ${KEYSTONE_internal_url}"
  echo "  - admin url:    ${KEYSTONE_admin_url}"

  # ceilometer api endpoint:
  echo "+ ceilometer endpoints:"
  echo "  - public url:   ${CEIL_public_uri}"
  echo "  - internal url: ${CEIL_internal_uri}"
  echo "  - admin url:    ${CEIL_admin_uri}"

  # aodh api endpoint:
  echo "+ aodh endpoints:"
  echo "  - public url:   ${AODH_public_uri}"
  echo "  - internal url: ${AODH_internal_uri}"
  echo "  - admin url:    ${AODH_admin_uri}"
}

