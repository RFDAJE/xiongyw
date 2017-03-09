#!/bin/bash

# created(bruin, 2017-03-09)

# args
# 1. cluster-name
# 2. nodes (mgmt-subnet)
pacemaker() {

  local script="/tmp/pcmk.sh"
  local cluster_name=${1}
  shift
  local nodes=($*)
  echo "setting up pacemaker ${cluster_name} with ${#nodes[@]} nodes: ${nodes[@]}..."

  # check if the resource already exist
  ssh ${nodes[0]} -- pcs status
  if [[ $? = 0 ]]; then
    echo "info: pacemaker already installed/configured, do nothing."
    return 0;
  fi

  # install & config pacemaker on each node
  for node in "${nodes[@]}"; do
    ssh $node -- cat <<-'EOF' \>${script}
	#!/bin/bash
	echo "installing pacemaker, pcs, psmisc, policycoreutils-python..."
	yum -y install pacemaker pcs psmisc policycoreutils-python
	systemctl enable pcsd
	systemctl start pcsd
	echo "setting passwd for hacluster..."
	echo "hacluster:qwerty" | chpasswd
	EOF
    ssh $node -- chmod +x ${script} \; ${script}
  done

  echo "authorizing cluster..."
  # note that:
  # - we use the mgmt host name as the cluster node name
  # - the galera node names (gcomm://) should exactly match the cluster node names, as
  #   stated in the galera resource agent's metadata.
  ssh ${nodes[0]} -- pcs cluster auth ${nodes[*]} -u hacluster -p qwerty
  echo "setting up cluster..."
  ssh ${nodes[0]} -- pcs cluster setup --name ${cluster_name} ${nodes[*]}
  echo "starting cluster..."
  ssh ${nodes[0]} -- pcs cluster start --all
  echo "waiting for cluster negotiates for DC..."
  sleep 30
  # fixme: temp disable stonith
  echo "disabling stonith..."
  ssh ${nodes[0]} -- pcs property set stonith-enabled=false
  echo "disabling start-failure-is-fatal..."
  ssh ${nodes[0]} -- pcs property set start-failure-is-fatal=false
  ssh ${nodes[0]} -- pcs status
}

# args
# 1. cluster_name
# 2. nodes  (mgmt-subnet)
pacemaker-d() {
  local cluster_name=${1}
  shift
  local nodes=($*)

  echo "stopping the cluster ${cluster_name}..."
  ssh ${nodes[0]} -- pcs cluster stop --all
  echo "destroying the cluster..."
  ssh ${nodes[0]} -- pcs cluster destroy --all
  for node in "${nodes[@]}"; do
    echo "removing pacemaker package and its dependencies..."
    ssh $node -- yum -y remove pacemaker pcs policycoreutils-python
  done
}

