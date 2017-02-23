#!/bin/bash

# created(bruin, 2017-01-22)

# maraidb resource name
RABBITMQ_res_name="rabbitmq-master"
# this name is used for creating the resource
RABBITMQ_res_name_short=${RABBITMQ_res_name%-master}
# cookie path
RABBITMQ_erlang_cookie="/var/lib/rabbitmq/.erlang.cookie"
# haproxy config file for rabbitmq mirror
RABBITMQ_haproxy_cfg="/etc/haproxy/rabbitmq.cfg"
RABBITMQ_port="5672"
# for oslo.messaging config, <http://docs.openstack.org/ha-guide/shared-messaging.html>
RABBITMQ_hosts="${NODES[@]/%/${MGMT_SUFFIX}:${RABBITMQ_port}}"
RABBITMQ_hosts="${RABBITMQ_hosts// /,}"
# user/pass
RABBITMQ_user="openstack"
RABBITMQ_pass="qwerty"

# https://www.rabbitmq.com/man/rabbitmq-env.conf.5.man.html
#RABBITMQ_env_conf="/etc/rabbitmq/rabbitmq-env.conf"

rabbitmq() {
  local tmp_file="/tmp/.erlang.cookie"
  local cookie=""

  info "start rabbitmq HA install & config..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${RABBITMQ_res_name}
  if [ $? = 0 ]; then
    echo "info: ${RABBITMQ_res_name} resource already exist, do nothing!"
    return 0;
  fi

  # install packages on each node
  for node in "${NODES[@]}"; do
    info "installing rabbitmq packages on ${node}..."
    ssh ${node} -- yum -y install rabbitmq-server rabbitmq-java-client librabbitmq librabbitmq-tools
    #echo "configuring node name..."
    #ssh ${node} -- echo "NODENAME=rabbit@${node}${MGMT_SUFFIX}" \> ${RABBITMQ_env_conf}
    echo "enabling rabbitmq-management plugin (need start service first)..."
    ssh ${node} -- systemctl start rabbitmq-server
    sleep 5;
    ssh ${node} -- rabbitmq-plugins enable rabbitmq_management
    ssh ${node} -- systemctl stop rabbitmq-server
    ssh ${node} -- systemctl disable rabbitmq-server
  done

  info "preparing erlang cookie for all NODES..."
  scp ${NODES[0]}:${RABBITMQ_erlang_cookie} ${tmp_file}
  for node in "${NODES[@]:1}"; do
    scp ${tmp_file} ${node}:${RABBITMQ_erlang_cookie}
  done
  # making sure the cookie mode is 0400 (ready-only)
  for node in "${NODES[@]}"; do
    ssh ${node} -- chmod 0400 ${RABBITMQ_erlang_cookie}
  done

  # it seems that the RA uses the cookie to find all nodes in the cluster,
  # so just defining the resource from any node will do...
  info "creating rabbitmq resource..."
  cookie=$(cat ${tmp_file})
  cat <<-EOF | ssh -T ${NODES[0]} --
	echo "creating mq-master resource..."
	set -x
	pcs resource create ${RABBITMQ_res_name_short} ocf:rabbitmq:rabbitmq-server-ha \
	  erlang_cookie=${cookie} node_port=5672 \
	  op monitor interval=30 timeout=60 \
	  op monitor interval=27 role=Master timeout=60 \
	  op start interval=0 timeout=360 \
	  op stop interval=0 timeout=120 \
	  op promote interval=0 timeout=120 \
	  op demote interval=0 timeout=120 \
	  op notify interval=0 timeout=180 \
	  meta notify=true ordered=false interleave=false master-max=1 master-node-max=1 \
	  --master
	EOF

  echo -n "Waiting rabbitmq-master resource up-running..."
  sleep 60;
  

  # set ha policy to ha-all
  cat <<-'EOF' | ssh -T ${NODES[0]} --
	echo "setting ha-all policy..."
	rabbitmqctl set_policy ha-all '^(?!amq\.).*' '{"ha-mode": "all"}'
	EOF

  # create a openstack account
  cat <<-EOF | ssh -T ${NODES[0]} --
	echo "adding user ${RABBITMQ_user}..."
	set -x
	rabbitmqctl add_user ${RABBITMQ_user} ${RABBITMQ_pass}
	rabbitmqctl set_permissions ${RABBITMQ_user} ".*" ".*" ".*"
	EOF

  # fixme: need to config rabbitmq to listen on specific i/f, instead of all.
  # otherwise, haproxy will not work, because of bind fail.
: <<'SKIP'
  # create haproxy setting for rabbitmq mirror, on each node
  for node in "${NODES[@]}"; do
    # ip:5672 for mq services
    echo "adding haproxy config for rabbitmq..."
    ssh ${node} -- mkdir -p /etc/haproxy
    ssh ${node} -- cat<<-EOF \>${RABBITMQ_haproxy_cfg}
	# mq listens on mgmt ip@, since it is not supposed to be access externally
	listen rabbitmq_mirror
	  bind ${NODES_VIP_ADDRS[1]}:5672
	  mode tcp
	  balance source
	  option tcplog
	  option tcp-check
	#  server g1 10.0.1.31:3306 check
	#  server g2 10.0.1.32:3306 check
	#  server g3 10.0.1.33:3306 check
	EOF
    # append the server lists into haproxy cfg file
    for idx in "${!NODES[@]}"; do
      local srv="${NODES[$idx]}${MGMT_SUFFIX}"
      local ips=( ${NODES_IP_ADDRS[$idx]} )
      local ip=${ips[1]}
      ssh ${node} -- echo "\ \ server ${srv} ${ip}:5672 check" \>\>${RABBITMQ_haproxy_cfg}
    done

    # http://ip:15672/ for web ui
    echo "adding haproxy config for rabbitmq web ui..."
    ssh ${node} -- cat<<-EOF \>\>${RABBITMQ_haproxy_cfg}
	listen rabbitmq_webui
	  bind ${NODES_VIP_ADDRS[0]}:15672
	  bind ${NODES_VIP_ADDRS[1]}:15672
	  balance  source
	  option  tcpka
	  option  httpchk
	  option  tcplog
	EOF
    # append the server lists into haproxy cfg file
    for idx in "${!NODES[@]}"; do
      local srv="${NODES[$idx]}${MGMT_SUFFIX}"
      local ips=( ${NODES_IP_ADDRS[$idx]} )
      local ip=${ips[1]}
      ssh ${node} -- echo "\ \ server ${srv} ${ip}:15672 check inter 2000 rise 2 fall 5" \>\>${RABBITMQ_haproxy_cfg}
    done
  done
   
  # re-define haproxy resource
  haproxy_recreate_res
SKIP
}

# delete rabbitmq resource completely
rabbitmq-d() {
  echo "removing rabbitmq HA config..."

  dep_delete_check ${RABBITMQ_res_name}

  echo "deleting resource ${RABBITMQ_res_name}..."
  ssh ${NODES[0]} -- pcs resource delete ${RABBITMQ_res_name}

  # uninstall packages on each node
  for node in "${NODES[@]}"; do
    echo "removing packages: rabbitmq-server rabbitmq-java-client librabbitmq librabbitmq-tools..."
    ssh ${node} -- yum -y remove rabbitmq-server rabbitmq-java-client librabbitmq librabbitmq-tools
    echo "removing rabbitmq config files..."
    ssh ${node} -- rm -rf /etc/rabbitmq
    echo "removing rabbitmq data files..."
    ssh ${node} -- rm -rf /var/lib/rabbitmq/*
    echo "removing haproxy file for rabbitmq..."
    ssh ${node} -- rm -rf ${RABBITMQ_haproxy_cfg}
  done

  # re-define haproxy resoruce
  haproxy_recreate_res
}

# reinstall
rabbitmq-r() {
  rabbitmq-d
  rabbitmq
}

# testing rabbitmq ha
rabbitmq-t() {
  ssh ${NODES[0]} -- rabbitmqctl cluster_status

  cat <<-'EOF' | ssh -T ${NODES[0]} --
	rabbitmqctl list_users | grep openstack
	EOF
  if [[ $? != 0 ]]; then
    error "rabbitmq user 'openstack does not exist! Fix this before proceeding..."
    exit 1
  fi
  
  ssh ${NODES[0]} -- rabbitmqctl list_policies
  ssh ${NODES[0]} -- pcs resource show ${RABBITMQ_res_name}
}
