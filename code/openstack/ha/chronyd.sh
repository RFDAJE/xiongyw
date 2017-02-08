#!/bin/bash

# created(bruin, 2017-01-17)

CHRONYD_res_name="chronyd-clone"
CHRONYD_res_name_short=${CHRONYD_res_name%-clone}

chronyd() {

  local script="/tmp/chronyd.sh"
  
  echo "setup chronyd service..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${CHRONYD_res_name}
  if [[ $? = 0 ]]; then
    echo "info: chronyd-clone resource already exist!"
    return 0;
  fi

  # install & config chronyd on each node
  for node in "${NODES[@]}"; do
    ssh ${node} -- cat <<-'EOF' \>${script}
	#!/bin/bash
	echo "installing chrony and configuring chronyd..."
	yum -y install chrony
	timedatectl set-ntp 1
	timedatectl set-local-rtc 0
	sed -i.bak -e "/^#allow/callow" -e "/^bindcmdaddress/cbindcmdaddress 0.0.0.0" /etc/chrony.conf
	systemctl stop chronyd
	systemctl disable chronyd
	EOF
    ssh ${node} -- chmod +x ${script} \; ${script}
  done

  # define resource
  ssh ${NODES[0]} -- pcs resource create ${CHRONYD_res_name_short} systemd:chronyd --clone
}

# delete chronyd resource
chronyd-d() {
  echo "removing chrony package..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- yum -y remove chrony
  done
  echo "deleting chronyd-clone resource..."
  ssh ${NODES[0]} -- pcs resource delete ${CHRONYD_res_name}
}

# test chronyd resource on each node
chronyd-t() {
  for node in "${NODES[@]}"; do
    echo "on $node:"
    ssh ${node} -- timedatectl \; chronyc sources -v
  done
}
