#!/bin/bash

# created(bruin, 2017-01-22)

MONGOD_res_name="mongod-clone"
MONGOD_res_name_short=${MONGOD_res_name%-clone}
# replica set name
MONGOD_rs_name="rs0"
# connection string: <https://docs.mongodb.com/manual/reference/connection-string/>
MONGOD_nodes="${NODES[@]/%/${MGMT_SUFFIX}:27017}"   # mgmt interface
MONGOD_nodes=${MONGOD_nodes// /,} # replace all space with comma: "n1:port,n2:port,n3:port"
MONGOD_conn_url="mongodb://${MONGOD_nodes}/?replicaSet=${MONGOD_rs_name}"


# call w/o arguments. it uses global variables such as $NODES etc.
mongod() {
  echo "start mongodb HA config..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${MONGOD_res_name}
  if [[ $? = 0 ]]; then
    echo "info: ${MONGOD_res_name} resource already exist!"
    return 0;
  fi

  dep_install_check ${MONGOD_res_name}

  # install packages on each node
  for node in "${NODES[@]}"; do
    echo "installing mongodb packages..."
    ssh ${node} -- yum -y install mongodb-org
    echo "configuring /etc/mongod.conf ..."
    cat <<-EOF | ssh -T ${node} --
	sed -i.bak '{
	/bindIp/c\ \ bindIp: ${node}${MGMT_SUFFIX}
	/^#replication/creplication:\n  replSetName: ${MONGOD_rs_name}\n  #oplogSizeMB:\n  #secondaryIndexPrefetch:\n  #enableMajorityReadConcern:
	}' /etc/mongod.conf
	EOF

    echo "disabling hugepage in kernel mm..."
    ssh ${node} -- cat<<-EOF \>\>/etc/rc.d/rc.local
	if test -f /sys/kernel/mm/transparent_hugepage/enabled; then
	   echo never > /sys/kernel/mm/transparent_hugepage/enabled
	fi
	if test -f /sys/kernel/mm/transparent_hugepage/defrag; then
	   echo never > /sys/kernel/mm/transparent_hugepage/defrag
	fi
	EOF
    ssh ${node} -- chmod +x /etc/rc.d/rc.local \; /etc/rc.d/rc.local
    ssh ${node} -- systemctl disable mongod
    echo "starting mongod on $node..."
    ssh ${node} -- systemctl start mongod
  done

  # setup replica set
  echo "initializing the replica set..."
  cat <<-EOF | ssh -T ${NODES[0]} --
	: set -x
	mongo --host ${NODES[0]}${MGMT_SUFFIX} --eval 'rs.initiate({_id:"${MONGOD_rs_name}", members:[{_id:0, host:"${NODES[0]}${MGMT_SUFFIX}:27017"}]})'
	: fixme: how to make sure the first node becomes PRIMARY?
	sleep 10
	mongo --host ${NODES[0]}${MGMT_SUFFIX} --eval 'rs.conf()'
	EOF
  echo "adding more NODES into the replica set..."
  for node in "${NODES[@]:1}"; do
    cat <<-EOF | ssh -T ${NODES[0]} --
	: set -x
	mongo --host ${NODES[0]}${MGMT_SUFFIX} --eval 'rs.add("${node}${MGMT_SUFFIX}")'
	EOF
  done

  echo "stopping mongod on all nodes..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- systemctl stop mongod
  done

  echo "defining mongod-clone resource..."
  ssh ${NODES[0]} -- pcs resource create ${MONGOD_res_name_short} systemd:mongod op monitor interval=20s --clone
}

# delete mongod resource completely
mongod-d() {
  echo "removing mongodb HA config..."

  dep_delete_check ${MONGOD_res_name}
  
  echo "deleting mongod-clone resource..."
  ssh ${NODES[0]} -- pcs resource delete ${MONGOD_res_name}

  # uninstall packages on each node
  for node in "${NODES[@]}"; do
    echo "removing mongodb-org-* packages ..."
    ssh ${node} -- yum -y remove mongodb-org-server mongodb-org-shell mongodb-org-tools mongodb-org-mongos
    ssh ${node} -- rm -f /etc/mongod.conf*
    echo "undoing changes in /etc/rc.d/rc.local ..."
    ssh ${node} -- sed -i.bak '/transparent_hugepage/,+5d' /etc/rc.d/rc.local
    # fixme: need confirmation from user
    echo "removing mongodb data files..."
    ssh ${node} -- rm -rf /var/lib/mongo/*
  done
}

# reinstall
mongod-r() {
  mongod-d
  mongod
}


# testing rabbitmq ha. TODO: add more meaningful tests...
mongod-t() {
  ssh ${NODES[0]} -- pcs resource show ${MONGOD_res_name}
  echo "press any key to continue..."
  read -n 1
  ssh ${NODES[0]} -- mongo --host ${NODES[0]}${MGMT_SUFFIX} --eval 'rs.conf\(\)'
  echo "press any key to continue..."
  read -n 1
  ssh ${NODES[0]} -- mongo --host ${NODES[0]}${MGMT_SUFFIX} --eval 'rs.status\(\)'
  echo "press any key to continue..."
  read -n 1
  ssh ${NODES[0]} -- mongo --host ${NODES[0]}${MGMT_SUFFIX} --eval 'rs.isMaster\(\)'
  echo "press any key to continue..."
  read -n 1
  ssh ${NODES[0]} -- mongo "${MONGOD_conn_url}" --eval 'rs.isMaster\(\)'
}
