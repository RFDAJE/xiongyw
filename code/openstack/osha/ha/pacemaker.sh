#!/bin/bash

# created(bruin, 2017-01-24)

pacemaker() {
  echo "setup pacemaker..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs status
  if [[ $? = 0 ]]; then
    echo "info: pacemaker already installed/configured, do nothing."
    return 0;
  fi

  # install & config pacemaker on each node
  for node in "${NODES[@]}"; do
    ssh $node -- cat <<-'EOF' \>/tmp/chronyd.sh
	#!/bin/bash
	echo "installing pacemaker, pcs, psmisc, policycoreutils-python..."
	yum -y install pacemaker pcs psmisc policycoreutils-python
	systemctl enable pcsd
	systemctl start pcsd
	echo "setting passwd for hacluster..."
	echo "hacluster:qwerty" | chpasswd
	EOF
    ssh $node -- chmod +x /tmp/chronyd.sh \; /tmp/chronyd.sh
  done

  echo "authorizing cluster..."
  # note that:
  # - we use the mgmt host name as the cluster node name
  # - the galera node names (gcomm://) should exactly match the cluster node names, as
  #   stated in the galera resource agent's metadata.
  ssh ${NODES[0]} -- pcs cluster auth ${NODES[*]/%/${MGMT_SUFFIX}} -u hacluster -p qwerty
  echo "setting up cluster..."
  ssh ${NODES[0]} -- pcs cluster setup --name controller ${NODES[*]/%/${MGMT_SUFFIX}}
  echo "starting cluster..."
  ssh ${NODES[0]} -- pcs cluster start --all
  echo "waiting for cluster negotiates for DC..."
  sleep 30
  # fixme: temp disable stonith
  echo "disabling stonith..."
  ssh ${NODES[0]} -- pcs property set stonith-enabled=false
  echo "disabling start-failure-is-fatal..."
  ssh ${NODES[0]} -- pcs property set start-failure-is-fatal=false
  ssh ${NODES[0]} -- pcs status
}

pacemaker-d() {
  echo "stopping the cluster..."
  ssh ${NODES[0]} -- pcs cluster stop --all
  echo "destroying the cluster..."
  ssh ${NODES[0]} -- pcs cluster destroy --all
  for node in "${NODES[@]}"; do
    echo "removing pacemaker package and its dependencies..."
    ssh $node -- yum -y remove pacemaker pcs policycoreutils-python
  done
}

