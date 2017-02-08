#!/bin/bash

# created(bruin, 2017-01-17)

MEMCACHED_res_name="memcached-clone"
MEMCACHED_res_name_short=${MEMCACHED_res_name%-clone}

memcached() {

  local script="/tmp/memcached.sh"
  
  echo "memcached..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${MEMCACHED_res_name}
  if [ $? = 0 ]; then
    echo "info: memcached-clone resource already exist!"
    return 0;
  fi

  for node in "${NODES[@]}"; do
    ssh ${node} -- cat<<-'EOF' \>${script}
	#!/bin/bash
	echo "installing memcached python-memcached..."
	yum -y install memcached python-memcached
	echo "configuring /etc/sysconfig/memcached..."
	sed -i.bak '{
	  /^CACHESIZE/cCACHESIZE="128"
	  /^OPTIONS/cOPTIONS=""
	}' /etc/sysconfig/memcached
	systemctl stop memcached
	systemctl disable memcached
	EOF
    ssh ${node} -- chmod +x ${script} \; ${script}
  done

  ssh ${NODES[0]} -- pcs resource create ${MEMCACHED_res_name_short} systemd:memcached --clone
}

# delete the resource
memcached-d() {
  for node in "${NODES[@]}"; do
    ssh ${node} -- yum -y remove memcached python-memcached
    ssh ${node} -- rm -f /etc/sysconfig/memcached*
  done
  ssh ${NODES[0]} -- pcs resource delete ${MEMCACHED_res_name}
}

memcached-t() {
  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${MEMCACHED_res_name}
  if [[ $? != 0 ]]; then
    echo "ERROR: ${MEMCACHED_res_name} resource is not yet defined!"
    exit 1;
  fi

  for node in "${NODES[@]}"; do
    ssh ${node} -- ss -antp \|grep LIST \|grep memcached
  done
}  
