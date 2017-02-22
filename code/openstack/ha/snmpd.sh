#!/bin/bash

# created(bruin, 2017-02-22)

# this is not a cluster service, but a meter source for ceilometer, which
# collects snmp info from all hosts, including the nodes of the cluster itself

SNMPD_res_name="snmpd-clone"
SNMPD_res_short_name=${SNMPD_res_name%-clone}
SNMPD_pkgs="net-snmp net-snmp-utils"
SNMPD_conf="/etc/snmp/snmpd.conf"

snmpd() {

  info "creating snmpd resources ..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${SNMPD_res_name}
  if [[ $? = 0 ]]; then
    warning "${SNMPD_res_name} resource already exist, do nothing."
    return 0;
  fi

  dep_install_check ${SNMPD_res_name}

  # http://www.cnblogs.com/linyihan/p/5804745.html
  for node in "${NODES[@]}"; do
    info "installing snmp packages on ${node}: ${SNMPD_pkgs} ..."
    ssh ${node} -- yum -y install ${SNMPD_pkgs}

    info "configuring snmpd on ${node}..."
    ssh ${node} -- sed -i -e "/^access/s/systemview/all/" ${SNMPD_conf}
    ssh ${node} -- sed -i -e \"56 a view    all           included   .1\" ${SNMPD_conf}

    # snmpd service is disabled by default, so no need to turn it off
  done

  ssh ${NODES[0]} -- pcs resource create ${SNMPD_res_short_name} systemd:snmpd --clone
}

snmpd-d() {
  info "removing ${SNMPD_res_name} resource..."

  dep_delete_check ${SNMPD_res_name}
  
  info "deleting ${SNMPD_res_name} resource..."
  ssh ${NODES[0]} -- pcs resource delete ${SNMPD_res_name}

  for node in "${NODES[@]}"; do
    info "removing snmpd packages on ${node}: ${SNMPD_pkgs}..."
    ssh ${node} -- yum -y remove ${SNMPD_pkgs}
  done
}

snmpd-t() {
  warning "todo..."
}

snmpd-r() {
  snmpd-d
  snmpd
}
