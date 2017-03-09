#!/bin/bash

# created(bruin, 2017-01-25)

# mariadb root passwd
MARIADB_root_pass="qwerty"
# full path of the galera resource agent script
MARIADB_galera_ra="/usr/lib/ocf/resource.d/heartbeat/galera"
# maraidb resource name
MARIADB_res_name="mariadb-master"
# this name is used for creating the resource
MARIADB_res_name_short=${MARIADB_res_name%-master}
# haproxy config file for mariadb cluster
MARIADB_haproxy_cfg="/etc/haproxy/mariadb.cfg"

# no argument; it uses global variables NODES
mariadb() {
  local script="/tmp/mariadb.sh"

  # gcomm format: "gcomm://node1,node2,node3"
  local gcomm="${NODES[@]/%/${MGMT_SUFFIX}}" # database binds/talks on mgmt subnet
  gcomm=${gcomm// /,}                     # replace space with ,
  gcomm="gcomm://${gcomm}"

  echo "creating mariadb resource..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${MARIADB_res_name}
  if [ $? = 0 ]; then
    echo "info: mariadb resource already exist!"
    return 0;
  fi

  dep_install_check ${MARIADB_res_name}

  #
  # on each node, do the following:
  #
  # - install mariadb
  # - start mariadb
  # - run mysql_secure_installation
  # - stop mariadb
  # - config mariadb (also for galera cluster)
  # - add ocf resource agent
  #
  for node in "${NODES[@]}"; do
    ssh ${node} -- cat <<-EOF \>${script}
	#!/bin/bash
	echo "installing MariaDB-server, MariaDB-client, and their dependencies MariaDB-common, galera, jemalloc..."
	yum -y install MariaDB-server MariaDB-client
	systemctl disable mariadb
	# Also need to disable System V config, otherwise, mysql will still auto-start on reboot.
	# This is a bug of MariaDB-server, see "https://mariadb.com/kb/en/mariadb/systemd/"
	chkconfig --del mysql

    echo "creating log directory for mariadb..."
	mkdir -p /var/log/mariadb
	chown -R mysql:mysql /var/log/mariadb

	echo "starting mariadb the 1st time..."
	systemctl start mariadb
	echo "running mysql_secure_installation..."
	# secure setup: <http://stackoverflow.com/questions/24270733/automate-mysql-secure-installation-with-echo-command-via-a-shell-script>
	mysql_secure_installation <<EOF2

	y
	qwerty
	qwerty
	y
	y
	y
	y
	EOF2
	echo "stopping mariadb..."
	systemctl stop mariadb

	echo "configuring mariadb server..."
	# config logs section and galera section
	sed -i.bak "{
	/^\[mysqld\]/a# general query log\ngeneral_log\ngeneral_log_file = /var/log/mariadb/query.log\n\# error log\nlog_error = /var/log/mariadb/error.log\n\# slow query log\nslow_query_log = 1\nslow_query_log_file = /var/log/mariadb/slow.log\nlong_query_time = 2\nlog-queries-not-using-indexes
	s|^#wsrep_on.*|wsrep_on=ON|
	s|^#wsrep_provider.*|wsrep_provider=/usr/lib64/galera/libgalera_smm.so|
	s|^#wsrep_cluster_address.*|wsrep_cluster_address=\"${gcomm}\"|
	s|^#binlog_format.*|binlog_format=row|
	s|^#default_storage_engine.*|default_storage_engine=InnoDB|
	s|^#innodb_autoinc_lock_mode.*|innodb_autoinc_lock_mode=2|
	s|^#bind-address.*|bind-address="${node}${MGMT_SUFFIX}"|
	}" /etc/my.cnf.d/server.cnf
	EOF
    ssh ${node} -- chmod +x ${script} \; ${script}

    echo "generating mariadb resource agent..."
    mariadb_generate_galera_ra ${node}
  done

  # making sure all mariadb are stopped.
  for ((;;)) ; do
    local count=${#NODES[@]}
    for node in "${NODES[@]}"; do
      echo "mariadb status on ${node}..."
      ssh ${node} -- systemctl status mariadb \|grep running
      if [[ $? = 1 ]]; then
        let count-=1
      fi
    done
    echo -n "$count instance(s) are running..."
    if [[ $count = 0 ]]; then
      echo "!"
      break;
    fi
    sleep 5;
    echo "....."
  done

  echo "bootstrapping galera cluster..."
  ssh ${NODES[0]} -- galera_new_cluster

  sleep 10;
  #ssh ${NODES[0]} -- mysql -uroot -pqwerty -e \"show status like \'wsrep_cluster_size\'\;\" | tail -1
  cat<<-'EOF' | ssh -T ${NODES[0]} --
	mysql -uroot -pqwerty -e "show status like 'wsrep_cluster_size';" | tail -1
	EOF

  echo "joining the rest nodes into the cluster..."
  for node in "${NODES[@]:1}"; do
    ssh ${node} -- systemctl start mariadb
  done

  echo "waiting galera cluster to reach consistency..."
  for i in $(seq 1 5); do
    sleep 1
    cat<<-'EOF' | ssh -T ${NODES[0]} --
	mysql -uroot -pqwerty -e "show status like 'wsrep_cluster_size';" | tail -1
	EOF
  done

  echo "testing galera cluster status..."
  cat<<-'EOF' | ssh -T ${NODES[0]} --
	mysql -uroot -pqwerty -e "show status like 'wsrep_cluster%';" | tail -4
	EOF

  #
  # at this point, the galera cluster is up running!
  #

  echo "changing root's privileges and add user 'haproxy_check' with empty passwd..."
  : <<-'SKIP'
  ssh ${NODES[0]} -- cat <<-EOF \>${script}
	#!/bin/bash
	# at this moment, 'root' can only login from localhost.
	# let's allow root to login from network, so pacemaker can check cluster status
	echo "allowing root to login from network..."
	#mysql -uroot -p${MARIADB_root_pass} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'${NODES_SUBNET_FOR_MARIADB[0]}' IDENTIFIED BY '${MARIADB_root_pass}' WITH GRANT OPTION; FLUSH PRIVILEGES;"
	mysql -uroot -p${MARIADB_root_pass} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'${NODES_SUBNET_FOR_MARIADB[1]}' IDENTIFIED BY '${MARIADB_root_pass}' WITH GRANT OPTION; FLUSH PRIVILEGES;"

	echo "adding user haproxy_check..."
	mysql -uroot -p${MARIADB_root_pass} -e "CREATE USER haproxy_check@'${NODES_SUBNET_FOR_MARIADB[0]}';"
	mysql -uroot -p${MARIADB_root_pass} -e "GRANT USAGE ON *.* TO 'haproxy_check'@'${NODES_SUBNET_FOR_MARIADB[0]}' IDENTIFIED BY '' WITH GRANT OPTION; FLUSH PRIVILEGES;"
	mysql -uroot -p${MARIADB_root_pass} -e "CREATE USER haproxy_check@'${NODES_SUBNET_FOR_MARIADB[1]}';"
	mysql -uroot -p${MARIADB_root_pass} -e "GRANT USAGE ON *.* TO 'haproxy_check'@'${NODES_SUBNET_FOR_MARIADB[1]}' IDENTIFIED BY '' WITH GRANT OPTION; FLUSH PRIVILEGES;"
	EOF
  ssh ${NODES[0]} -- chmod +x ${script} \; ${script}
	SKIP

  cat <<-EOF | ssh -T ${NODES[0]} --
	mysql -uroot -p${MARIADB_root_pass} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'${NODES_SUBNET_FOR_MARIADB[0]}' IDENTIFIED BY '${MARIADB_root_pass}' WITH GRANT OPTION; FLUSH PRIVILEGES;"
	mysql -uroot -p${MARIADB_root_pass} -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'${NODES_SUBNET_FOR_MARIADB[1]}' IDENTIFIED BY '${MARIADB_root_pass}' WITH GRANT OPTION; FLUSH PRIVILEGES;"
	mysql -uroot -p${MARIADB_root_pass} -e "CREATE USER haproxy_check@'${NODES_SUBNET_FOR_MARIADB[0]}';"
	mysql -uroot -p${MARIADB_root_pass} -e "GRANT USAGE ON *.* TO 'haproxy_check'@'${NODES_SUBNET_FOR_MARIADB[0]}' IDENTIFIED BY '' WITH GRANT OPTION; FLUSH PRIVILEGES;"
	mysql -uroot -p${MARIADB_root_pass} -e "CREATE USER haproxy_check@'${NODES_SUBNET_FOR_MARIADB[1]}';"
	mysql -uroot -p${MARIADB_root_pass} -e "GRANT USAGE ON *.* TO 'haproxy_check'@'${NODES_SUBNET_FOR_MARIADB[1]}' IDENTIFIED BY '' WITH GRANT OPTION; FLUSH PRIVILEGES;"
	EOF


  # making sure the changes are stored and replicated
  sleep 10

  echo "stopping mariadb on all nodes..."
  # if mariadb is still running on any node, the pcs resource will not successfuly start, unless reboot all nodes.
  for node in "${NODES[@]}"; do
    echo -n "stopping mariadb on ${node}..."
    ssh ${node} -- systemctl stop mariadb
    echo "done!"
  done

  # making sure all mariadb are stopped.
  sleep 10

  echo "creating pacemaker galera resource for mariadb ..."
  ssh ${NODES[0]} -- pcs resource create ${MARIADB_res_name_short} ocf:heartbeat:galera wsrep_cluster_address=\"${gcomm}\" check_user=root check_passwd=qwerty meta master-max=3 migration-threshold=100 --master

  # create haproxy setting for mariadb cluster, on each node
  for node in "${NODES[@]}"; do
    echo "adding haproxy config for mariadb..."
    ssh ${node} -- mkdir -p /etc/haproxy
    ssh ${node} -- cat<<-EOF \>${MARIADB_haproxy_cfg}
	# db listens on mgmt ip@, since it is not supposed to be access externally
	listen mariadb_cluster
	  bind ${NODES_VIP_ADDRS[1]}:3306
	  mode tcp
	  balance source
	  option tcplog
	  option mysql-check user haproxy_check
	#  server g1 10.0.1.31:3306 check
	#  server g2 10.0.1.32:3306 check
	#  server g3 10.0.1.33:3306 check
	EOF
    # append the server lists into haproxy cfg file
    for idx in "${!NODES[@]}"; do
      local srv="${NODES[$idx]}${MGMT_SUFFIX}"
      local ips=( ${NODES_IP_ADDRS[$idx]} )
      local ip=${ips[1]}
      ssh ${node} -- echo "\ \ server ${srv} ${ip}:3306 check" \>\>${MARIADB_haproxy_cfg}
    done
  done

  # re-define haproxy resource
  haproxy_recreate_res
}

# no argument; it uses global variables NODES
mariadb-d() {
  local script="/tmp/mariadb0.sh"
  echo "deleting mariadb resource..."

  dep_delete_check ${MARIADB_res_name}

  ssh ${NODES[0]} -- pcs resource delete ${MARIADB_res_name}

  for node in "${NODES[@]}"; do
    ssh ${node} -- cat<<-EOF \>${script}
	#!/bin/bash
	echo "uninstall mariadb..."
	systemctl stop mariadb
	yum -y remove MariaDB-client MariaDB-server MariaDB-common galera jemalloc

	echo "removing mysql config files..."
	rm -rf /etc/my.cnf.d
	rm -f /etc/init.d/mysql
	rm -f /etc/logrotate.d/mysql

	echo "removing mariadb log file..."
	rm -f /var/log/mariadb/*

	echo "removing mysql data files..."
	# FIXME: ask feedback from user!
	rm -rf /var/lib/mysql/*

	echo "removing galera resource agent..."
	if [[ -x ${MARIADB_galera_ra}.orig ]]; then
	  rm -f $MARIADB_galera_ra
	  mv ${MARIADB_galera_ra}.orig $MARIADB_galera_ra
	fi

	echo "removing mariadb's haproxy cfg file..."
	rm -f /etc/haproxy/mariadb.cfg
	EOF
    ssh ${node} -- chmod +x ${script} \; ${script}
  done

  # re-define haproxy
  haproxy_recreate_res
}

# re-install: first delete and then install
mariadb-r() {
  mariadb-d
  mariadb
}

mariadb-t() {

  echo "checking pacemaker resource"
  ssh ${NODES[0]} -- pcs resource show ${MARIADB_res_name}

  for node in "${NODES[@]}"; do
    echo "checking mariadb databases via ${node}..."
    cat <<-EOF | ssh -T ${node} --
	mysql -h "${node}${MGMT_SUFFIX}" -uroot -p${MARIADB_root_pass} -e "show databases;"
	EOF
  done

  echo "checking mariadb service via vip..."
  cat <<-EOF | ssh -T ${NODES[0]} --
	mysql -h "${NODES_VIP_NAMES[1]}" -uroot -p${MARIADB_root_pass} -e "show databases;"
	EOF

  #
  # standby test
  #
  echo "standby test: checking wsrep_node_name...press any key to stop."
  local count=0
  local GAP=60  # in seconds: put the next node into standby
  local idx=0
  for ((;;)) ; do

    # infinite loop until a key is pressed
    echo -n "$(date) : "
    cat <<-EOF | ssh -T ${NODES[0]} --
	mysql -h "${NODES_VIP_NAMES[1]}" -uroot -p${MARIADB_root_pass} -e "show variables like 'wsrep_node_name';" | tail -1
	EOF
    read -t 1 -n 1
    if [[ $? = 0 ]]; then
      break;
    fi

    # for every $GAP seconds, put a node into standby
    let count+=1
    if [[ ${count} -gt ${GAP} ]]; then
      let count=0
      ssh ${NODES[$idx]} -- pcs cluster unstandby
      let idx+=1
      let idx%=${#NODES[@]}
      echo "standby ${NODES[$idx]}..."
      ssh ${NODES[$idx]} -- pcs cluster standby
    fi
  done
  # unstandby the last node
  echo "\nput ${NODES[$idx]} out of standby..."
  ssh ${NODES[$idx]} -- pcs cluster unstandby

  # cleanup possible fail counts
  ssh ${NODES[$idx]} -- pcs resource cleanup

  #
  # reboot test
  #
  echo "reboot test: checking wsrep_node_name...press any key to stop."
  count=0
  GAP=120  # in seconds: for a node to reboot
  idx=0
  for ((;;)) ; do

    # infinite loop until a key is pressed
    echo -n "$(date) : "
    mysql -h "${NODES_VIP_NAMES[1]}" -uroot -p${MARIADB_root_pass} -e "show variables like 'wsrep_node_name';" | tail -1
    read -t 1 -n 1
    if [[ $? = 0 ]]; then
      break;
    fi

    # for every $GAP seconds, reboot a node brutely
    let count+=1
    if [[ ${count} -gt ${GAP} ]]; then
      let count=0
      ssh ${NODES[$idx]} -- pcs cluster start
      let idx+=1
      let idx%=${#NODES[@]}
      echo "rebooting ${NODES[$idx]}..."
      ssh ${NODES[$idx]} -- reboot
    fi
  done
  # start the last node
  echo "\nstarting ${NODES[$idx]} ..."
  ssh ${NODES[$idx]} -- pcs cluster start

  # cleanup possible fail counts
  ssh ${NODES[$idx]} -- pcs resource cleanup
  }


# the argument is the node name
mariadb_generate_galera_ra() {
  local node=${1}
  # the galera RA is downloaded from <https://github.com/ClusterLabs/resource-agents/blob/280564385541393546a6327c53ebf21b66e505ec/heartbeat/galera>
  ssh ${node} -- mv ${MARIADB_galera_ra} ${MARIADB_galera_ra}.orig
  ssh ${node} -- cat<<'RA_EOF' \>${MARIADB_galera_ra}
#!/bin/sh
#
# Copyright (c) 2014 David Vossel <davidvossel@gmail.com>
#                    All Rights Reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of version 2 of the GNU General Public License as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it would be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
#
# Further, this software is distributed without any warranty that it is
# free of the rightful claim of any third person regarding infringement
# or the like.  Any license provided herein, whether implied or
# otherwise, applies only to this software file.  Patent licenses, if
# any, provided herein do not apply to combinations of this program with
# other software, or any other product whatsoever.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write the Free Software Foundation,
# Inc., 59 Temple Place - Suite 330, Boston MA 02111-1307, USA.
#

##
# README.
#
# This agent only supports being configured as a multistate Master
# resource.
#
# Slave vs Master role:
#
# During the 'Slave' role, galera instances are in read-only mode and
# will not attempt to connect to the cluster. This role exists as
# a means to determine which galera instance is the most up-to-date. The
# most up-to-date node will be used to bootstrap a galera cluster that
# has no current members.
#
# The galera instances will only begin to be promoted to the Master role
# once all the nodes in the 'wsrep_cluster_address' connection address
# have entered read-only mode. At that point the node containing the
# database that is most current will be promoted to Master.
#
# Once the first Master instance bootstraps the galera cluster, the
# other nodes will join the cluster and start synchronizing via SST.
# They will stay in Slave role as long as the SST is running. Their
# promotion to Master will happen once synchronization is finished.
#
# Example: Create a galera cluster using nodes rhel7-node1 rhel7-node2 rhel7-node3
#
# pcs resource create db galera enable_creation=true \
# wsrep_cluster_address="gcomm://rhel7-auto1,rhel7-auto2,rhel7-auto3" meta master-max=3 --master
#
# By setting the 'enable_creation' option, the database will be automatically
# generated at startup. The meta attribute 'master-max=3' means that all 3
# nodes listed in the wsrep_cluster_address list will be allowed to connect
# to the galera cluster and perform replication.
#
# NOTE: If you have more nodes in the pacemaker cluster then you wish
# to have in the galera cluster, make sure to use location contraints to prevent
# pacemaker from attempting to place a galera instance on a node that is
# not in the 'wsrep_cluster_address" list.
#
##

#######################################################################
# Initialization:

: ${OCF_FUNCTIONS_DIR=${OCF_ROOT}/lib/heartbeat}
. ${OCF_FUNCTIONS_DIR}/ocf-shellfuncs
. ${OCF_FUNCTIONS_DIR}/mysql-common.sh

# It is common for some galera instances to store
# check user that can be used to query status
# in this file
if [ -f "/etc/sysconfig/clustercheck" ]; then
    . /etc/sysconfig/clustercheck
elif [ -f "/etc/default/clustercheck" ]; then
    . /etc/default/clustercheck
fi

#######################################################################

usage() {
  cat <<UEND
usage: $0 (start|stop|validate-all|meta-data|monitor|promote|demote)

$0 manages a galera Database as an HA resource.

The 'start' operation starts the database.
The 'stop' operation stops the database.
The 'status' operation reports whether the database is running
The 'monitor' operation reports whether the database seems to be working
The 'promote' operation makes this mysql server run as master
The 'demote' operation makes this mysql server run as slave
The 'validate-all' operation reports whether the parameters are valid

UEND
}

meta_data() {
   cat <<END
<?xml version="1.0"?>
<!DOCTYPE resource-agent SYSTEM "ra-api-1.dtd">
<resource-agent name="galera">
<version>1.0</version>

<longdesc lang="en">
Resource script for managing galara database.
</longdesc>
<shortdesc lang="en">Manages a galara instance</shortdesc>
<parameters>

<parameter name="binary" unique="0" required="0">
<longdesc lang="en">
Location of the MySQL server binary
</longdesc>
<shortdesc lang="en">MySQL server binary</shortdesc>
<content type="string" default="${OCF_RESKEY_binary_default}" />
</parameter>

<parameter name="client_binary" unique="0" required="0">
<longdesc lang="en">
Location of the MySQL client binary
</longdesc>
<shortdesc lang="en">MySQL client binary</shortdesc>
<content type="string" default="${OCF_RESKEY_client_binary_default}" />
</parameter>

<parameter name="config" unique="0" required="0">
<longdesc lang="en">
Configuration file
</longdesc>
<shortdesc lang="en">MySQL config</shortdesc>
<content type="string" default="${OCF_RESKEY_config_default}" />
</parameter>

<parameter name="datadir" unique="0" required="0">
<longdesc lang="en">
Directory containing databases
</longdesc>
<shortdesc lang="en">MySQL datadir</shortdesc>
<content type="string" default="${OCF_RESKEY_datadir_default}" />
</parameter>

<parameter name="user" unique="0" required="0">
<longdesc lang="en">
User running MySQL daemon
</longdesc>
<shortdesc lang="en">MySQL user</shortdesc>
<content type="string" default="${OCF_RESKEY_user_default}" />
</parameter>

<parameter name="group" unique="0" required="0">
<longdesc lang="en">
Group running MySQL daemon (for logfile and directory permissions)
</longdesc>
<shortdesc lang="en">MySQL group</shortdesc>
<content type="string" default="${OCF_RESKEY_group_default}"/>
</parameter>

<parameter name="log" unique="0" required="0">
<longdesc lang="en">
The logfile to be used for mysqld.
</longdesc>
<shortdesc lang="en">MySQL log file</shortdesc>
<content type="string" default="${OCF_RESKEY_log_default}"/>
</parameter>

<parameter name="pid" unique="0" required="0">
<longdesc lang="en">
The pidfile to be used for mysqld.
</longdesc>
<shortdesc lang="en">MySQL pid file</shortdesc>
<content type="string" default="${OCF_RESKEY_pid_default}"/>
</parameter>

<parameter name="socket" unique="0" required="0">
<longdesc lang="en">
The socket to be used for mysqld.
</longdesc>
<shortdesc lang="en">MySQL socket</shortdesc>
<content type="string" default="${OCF_RESKEY_socket_default}"/>
</parameter>

<parameter name="enable_creation" unique="0" required="0">
<longdesc lang="en">
If the MySQL database does not exist, it will be created
</longdesc>
<shortdesc lang="en">Create the database if it does not exist</shortdesc>
<content type="boolean" default="${OCF_RESKEY_enable_creation_default}"/>
</parameter>

<parameter name="additional_parameters" unique="0" required="0">
<longdesc lang="en">
Additional parameters which are passed to the mysqld on startup.
(e.g. --skip-external-locking or --skip-grant-tables)
</longdesc>
<shortdesc lang="en">Additional parameters to pass to mysqld</shortdesc>
<content type="string" default="${OCF_RESKEY_additional_parameters_default}"/>
</parameter>


<parameter name="wsrep_cluster_address" unique="0" required="1">
<longdesc lang="en">
The galera cluster address. This takes the form of:
gcomm://node,node,node

Only nodes present in this node list will be allowed to start a galera instance.
It is expected that the galera node names listed in this address match valid
pacemaker node names.
</longdesc>
<shortdesc lang="en">Galera cluster address</shortdesc>
<content type="string" default=""/>
</parameter>

<parameter name="check_user" unique="0" required="0">
<longdesc lang="en">
Cluster check user.
</longdesc>
<shortdesc lang="en">MySQL test user</shortdesc>
<content type="string" default="root" />
</parameter>

<parameter name="check_passwd" unique="0" required="0">
<longdesc lang="en">
Cluster check user password
</longdesc>
<shortdesc lang="en">check password</shortdesc>
<content type="string" default="" />
</parameter>

</parameters>

<actions>
<action name="start" timeout="120" />
<action name="stop" timeout="120" />
<action name="status" timeout="60" />
<action name="monitor" depth="0" timeout="30" interval="20" />
<action name="monitor" role="Master" depth="0" timeout="30" interval="10" />
<action name="monitor" role="Slave" depth="0" timeout="30" interval="30" />
<action name="promote" timeout="300" />
<action name="demote" timeout="120" />
<action name="validate-all" timeout="5" />
<action name="meta-data" timeout="5" />
</actions>
</resource-agent>
END
}

get_option_variable()
{
    local key=$1

    $MYSQL $MYSQL_OPTIONS_CHECK  -e "SHOW VARIABLES like '$key';" | tail -1
}

get_status_variable()
{
    local key=$1

    $MYSQL $MYSQL_OPTIONS_CHECK -e "show status like '$key';" | tail -1
}

set_bootstrap_node()
{
    local node=$1

    ${HA_SBIN_DIR}/crm_attribute -N $node -l reboot --name "${INSTANCE_ATTR_NAME}-bootstrap" -v "true"
}

clear_bootstrap_node()
{
    ${HA_SBIN_DIR}/crm_attribute -N $NODENAME -l reboot --name "${INSTANCE_ATTR_NAME}-bootstrap" -D
}

is_bootstrap()
{
    ${HA_SBIN_DIR}/crm_attribute -N $NODENAME -l reboot --name "${INSTANCE_ATTR_NAME}-bootstrap" -Q 2>/dev/null

}

set_no_grastate()
{
    ${HA_SBIN_DIR}/crm_attribute -N $NODENAME -l reboot --name "${INSTANCE_ATTR_NAME}-no-grastate" -v "true"
}

clear_no_grastate()
{
    ${HA_SBIN_DIR}/crm_attribute -N $NODENAME -l reboot --name "${INSTANCE_ATTR_NAME}-no-grastate" -D
}

is_no_grastate()
{
    local node=$1
    ${HA_SBIN_DIR}/crm_attribute -N $node -l reboot --name "${INSTANCE_ATTR_NAME}-no-grastate" -Q 2>/dev/null
}

clear_last_commit()
{
    ${HA_SBIN_DIR}/crm_attribute -N $NODENAME -l reboot --name "${INSTANCE_ATTR_NAME}-last-committed" -D
}

set_last_commit()
{
    ${HA_SBIN_DIR}/crm_attribute -N $NODENAME -l reboot --name "${INSTANCE_ATTR_NAME}-last-committed" -v $1
}

get_last_commit()
{
    local node=$1

    if [ -z "$node" ]; then
       ${HA_SBIN_DIR}/crm_attribute -N $NODENAME -l reboot --name "${INSTANCE_ATTR_NAME}-last-committed" -Q 2>/dev/null
    else
       ${HA_SBIN_DIR}/crm_attribute -N $node -l reboot --name "${INSTANCE_ATTR_NAME}-last-committed" -Q 2>/dev/null
    fi
}

wait_for_sync()
{
    local state=$(get_status_variable "wsrep_local_state")

    ocf_log info "Waiting for database to sync with the cluster. "
    while [ "$state" != "4" ]; do
        sleep 1
        state=$(get_status_variable "wsrep_local_state")
    done
    ocf_log info "Database synced."
}

set_sync_needed()
{
    ${HA_SBIN_DIR}/crm_attribute -N $NODENAME -l reboot --name "${INSTANCE_ATTR_NAME}-sync-needed" -v "true"
}

clear_sync_needed()
{
    ${HA_SBIN_DIR}/crm_attribute -N $NODENAME -l reboot --name "${INSTANCE_ATTR_NAME}-sync-needed" -D
}

check_sync_needed()
{
    ${HA_SBIN_DIR}/crm_attribute -N $NODENAME -l reboot --name "${INSTANCE_ATTR_NAME}-sync-needed" -Q 2>/dev/null
}


# this function is called when attribute sync-needed is set in the CIB
check_sync_status()
{
    # if the pidfile is created, mysqld is up and running
    # an IST might still be in progress, check wsrep status
    if [ -e $OCF_RESKEY_pid ]; then
        local cluster_status=$(get_status_variable "wsrep_cluster_status")
        local state=$(get_status_variable "wsrep_local_state")
        local ready=$(get_status_variable "wsrep_ready")

        if [ -z "$cluster_status" -o -z "$state" -o -z "$ready" ]; then
            ocf_exit_reason "Unable to retrieve state transfer status, verify check_user '$OCF_RESKEY_check_user' has permissions to view status"
            return $OCF_ERR_GENERIC
        fi

        if [ "$cluster_status" != "Primary" ]; then
            ocf_exit_reason "local node <${NODENAME}> is started, but not in primary mode. Unknown state."
            return $OCF_ERR_GENERIC
        fi

        if [ "$state" = "4" -a "$ready" = "ON" ]; then
            ocf_log info "local node synced with the cluster"
            # when sync is finished, we are ready to switch to Master
            clear_sync_needed
            set_master_score
            return $OCF_SUCCESS
        fi
    fi

    # if we pass here, an IST or SST is still in progress
    ocf_log info "local node syncing"
    return $OCF_SUCCESS
}

is_primary()
{
    cluster_status=$(get_status_variable "wsrep_cluster_status")
    if [ "$cluster_status" = "Primary" ]; then
        return 0
    fi

    if [ -z "$cluster_status" ]; then
        ocf_exit_reason "Unable to retrieve wsrep_cluster_status, verify check_user '$OCF_RESKEY_check_user' has permissions to view status"
    else
        ocf_log info "Galera instance wsrep_cluster_status=${cluster_status}"
    fi
    return 1
}

is_readonly()
{
    local res=$(get_option_variable "read_only")

    if ! ocf_is_true "$res"; then
        return 1
    fi

    cluster_status=$(get_status_variable "wsrep_cluster_status")
    if ! [ "$cluster_status" = "Disconnected" ]; then
        return 1
    fi

    return 0
}

master_exists()
{
    if [ "$__OCF_ACTION" = "demote" ]; then
        # We don't want to detect master instances during demote.
        # 1. we could be detecting ourselves as being master, which is no longer the case.
        # 2. we could be detecting other master instances that are in the process of shutting down.
        # by not detecting other master instances in "demote" we are deferring this check
        # to the next recurring monitor operation which will be much more accurate
        return 1
    fi
    # determine if a master instance is already up and is healthy
    crm_mon --as-xml | grep "resource.*id=\"${OCF_RESOURCE_INSTANCE}\".*role=\"Master\".*active=\"true\".*orphaned=\"false\".*failed=\"false\"" > /dev/null 2>&1
    return $?
}

clear_master_score()
{
    local node=$1
    if [ -z "$node" ]; then
        $CRM_MASTER -D
    else
        $CRM_MASTER -D -N $node
    fi
}

set_master_score()
{
    local node=$1

    if [ -z "$node" ]; then
        $CRM_MASTER -v 100
    else
        $CRM_MASTER -N $node -v 100
    fi
}

greater_than_equal_long()
{
    # there are values we need to compare in this script
    # that are too large for shell -gt to process
    echo | awk -v n1="$1" -v n2="$2"  '{if (n1>=n2) printf ("true"); else printf ("false");}' |  grep -q "true"
}

detect_first_master()
{
    local best_commit=0
    local best_node="$NODENAME"
    local last_commit=0
    local missing_nodes=0
    local nodes=""
    local nodes_recovered=""

    # avoid selecting a recovered node as bootstrap if possible
    for node in $(echo "$OCF_RESKEY_wsrep_cluster_address" | sed 's/gcomm:\/\///g' | tr -d ' ' | tr -s ',' ' '); do
        if is_no_grastate $node; then
            nodes_recovered="$nodes_recovered $node"
        else
            nodes="$nodes $node"
        fi
    done

    for node in $nodes_recovered $nodes; do
        last_commit=$(get_last_commit $node)

        if [ -z "$last_commit" ]; then
            ocf_log info "Waiting on node <${node}> to report database status before Master instances can start."
            missing_nodes=1
            continue
        fi

        # this means -1, or that no commit has occured yet.
        if [ "$last_commit" = "18446744073709551615" ]; then
            last_commit="0"
        fi

        greater_than_equal_long "$last_commit" "$best_commit"
        if [ $? -eq 0 ]; then
            best_node=$node
            best_commit=$last_commit
        fi

    done

    if [ $missing_nodes -eq 1 ]; then
        return
    fi

    ocf_log info "Promoting $best_node to be our bootstrap node"
    set_master_score $best_node
    set_bootstrap_node $best_node
}

detect_galera_pid()
{
    ps auxww | grep -v -e "${OCF_RESKEY_binary}" -e grep | grep -qe "--pid-file=$OCF_RESKEY_pid"
}

galera_status()
{
    local loglevel=$1
    local rc
    local running

    if [ -e $OCF_RESKEY_pid ]; then
        mysql_common_status $loglevel
        rc=$?
    else
        # if pidfile is not created, the server may
        # still be starting up, e.g. running SST
        detect_galera_pid
        running=$?
        if [ $running -eq 0 ]; then
            rc=$OCF_SUCCESS
        else
            ocf_log $loglevel "MySQL is not running"
            rc=$OCF_NOT_RUNNING
        fi
    fi

    return $rc
}

galera_start_nowait()
{
    local mysql_extra_params="$1"
    local pid
    local running

    ${OCF_RESKEY_binary} --defaults-file=$OCF_RESKEY_config \
    --pid-file=$OCF_RESKEY_pid \
    --socket=$OCF_RESKEY_socket \
    --datadir=$OCF_RESKEY_datadir \
    --log-error=$OCF_RESKEY_log \
    --user=$OCF_RESKEY_user $OCF_RESKEY_additional_parameters \
    $mysql_extra_params >/dev/null 2>&1 &
    pid=$!

    # Spin waiting for the server to be spawned.
    # Let the CRM/LRM time us out if required.
    start_wait=1
    while [ $start_wait = 1 ]; do
        if ! ps $pid > /dev/null 2>&1; then
            wait $pid
            ocf_exit_reason "MySQL server failed to start (pid=$pid) (rc=$?), please check your installation"
            return $OCF_ERR_GENERIC
        fi
        detect_galera_pid
        running=$?
        if [ $running -eq 0 ]; then
            start_wait=0
        else
            ocf_log info "MySQL is not running"
        fi
        sleep 2
    done

    return $OCF_SUCCESS
}

galera_start_local_node()
{
    local rc
    local extra_opts
    local bootstrap

    bootstrap=$(is_bootstrap)

    master_exists
    if [ $? -eq 0 ]; then
        # join without bootstrapping
        ocf_log info "Node <${NODENAME}> is joining the cluster"
        extra_opts="--wsrep-cluster-address=${OCF_RESKEY_wsrep_cluster_address}"
    elif ocf_is_true $bootstrap; then
        ocf_log info "Node <${NODENAME}> is bootstrapping the cluster"
        extra_opts="--wsrep-cluster-address=gcomm://"
    else
        ocf_exit_reason "Failure, Attempted to join cluster of $OCF_RESOURCE_INSTANCE before master node has been detected."
        clear_last_commit
        return $OCF_ERR_GENERIC
    fi

    # clear last_commit before we start galera to make sure there
    # won't be discrepency between the cib and galera if this node
    # processes a few transactions and fails before we detect it
    clear_last_commit

    mysql_common_prepare_dirs

    # At start time, if galera requires a SST rather than an IST, the
    # mysql server's pidfile won't be available until SST finishes,
    # which can be longer than the start timeout.  So we only check
    # bootstrap node extensively. Joiner nodes are monitored in the
    # "monitor" op
    if ocf_is_true $bootstrap; then
        # start server and wait until it's up and running
        mysql_common_start "$extra_opts"
        rc=$?
        if [ $rc != $OCF_SUCCESS ]; then
            return $rc
        fi

        mysql_common_status info
        rc=$?

        if [ $rc != $OCF_SUCCESS ]; then
            ocf_exit_reason "Failed initial monitor action"
            return $rc
        fi

        is_readonly
        if [ $? -eq 0 ]; then
            ocf_exit_reason "Failure. Master instance started in read-only mode, check configuration."
            return $OCF_ERR_GENERIC
        fi

        is_primary
        if [ $? -ne 0 ]; then
            ocf_exit_reason "Failure. Master instance started, but is not in Primary mode."
            return $OCF_ERR_GENERIC
        fi

        clear_bootstrap_node
        # clear attribute no-grastate. if last shutdown was
        # not clean, we cannot be extra-cautious by requesting a SST
        # since this is the bootstrap node
        clear_no_grastate
    else
        # only start server, defer full checks to "monitor" op
        galera_start_nowait "$extra_opts"
        rc=$?
        if [ $rc != $OCF_SUCCESS ]; then
            return $rc
        fi

        set_sync_needed
        # attribute no-grastate will be cleared once the joiner
        # has finished syncing and is promoted to Master
    fi

    ocf_log info "Galera started"
    return $OCF_SUCCESS
}

detect_last_commit()
{
    local last_commit
    local recover_args="--defaults-file=$OCF_RESKEY_config \
                        --pid-file=$OCF_RESKEY_pid \
                        --socket=$OCF_RESKEY_socket \
                        --datadir=$OCF_RESKEY_datadir \
                        --user=$OCF_RESKEY_user"
    local recovery_file_regex='s/.*WSREP\:.*position\s*recovery.*--log_error='\''\([^'\'']*\)'\''.*/\1/p'
    local recovered_position_regex='s/.*WSREP\:\s*[R|r]ecovered\s*position.*\:\(.*\)\s*$/\1/p'

    ocf_log info "attempting to detect last commit version by reading ${OCF_RESKEY_datadir}/grastate.dat"
    last_commit="$(cat ${OCF_RESKEY_datadir}/grastate.dat | sed -n 's/^seqno.\s*\(.*\)\s*$/\1/p')"
    if [ -z "$last_commit" ] || [ "$last_commit" = "-1" ]; then
        local tmp=$(mktemp)

        # if we pass here because grastate.dat doesn't exist,
        # try not to bootstrap from this node if possible
        if [ ! -f ${OCF_RESKEY_datadir}/grastate.dat ]; then
            set_no_grastate
        fi

        ocf_log info "now attempting to detect last commit version using 'mysqld_safe --wsrep-recover'"

        ${OCF_RESKEY_binary} $recover_args --wsrep-recover --log-error=$tmp 2>/dev/null

        last_commit="$(cat $tmp | sed -n $recovered_position_regex | tail -1)"
        if [ -z "$last_commit" ]; then
            # Galera uses InnoDB's 2pc transactions internally. If
            # server was stopped in the middle of a replication, the
            # recovery may find a "prepared" XA transaction in the
            # redo log, and mysql won't recover automatically

            local recovery_file="$(cat $tmp | sed -n $recovery_file_regex)"
            if [ -e $recovery_file ]; then
                cat $recovery_file | grep -q -E '\[ERROR\]\s+Found\s+[0-9]+\s+prepared\s+transactions!' 2>/dev/null
                if [ $? -eq 0 ]; then
                    # we can only rollback the transaction, but that's OK
                    # since the DB will get resynchronized anyway
                    ocf_log warn "local node <${NODENAME}> was not shutdown properly. Rollback stuck transaction with --tc-heuristic-recover"
                    ${OCF_RESKEY_binary} $recover_args --wsrep-recover \
                                         --tc-heuristic-recover=rollback --log-error=$tmp 2>/dev/null

                    last_commit="$(cat $tmp | sed -n $recovered_position_regex | tail -1)"
                    if [ ! -z "$last_commit" ]; then
                        ocf_log warn "State recovered. force SST at next restart for full resynchronization"
                        rm -f ${OCF_RESKEY_datadir}/grastate.dat
                        # try not to bootstrap from this node if possible
                        set_no_grastate
                    fi
                fi
            fi
        fi
        rm -f $tmp
    fi

    if [ ! -z "$last_commit" ]; then
        ocf_log info "Last commit version found:  $last_commit"
        set_last_commit $last_commit
        return $OCF_SUCCESS
    else
        ocf_exit_reason "Unable to detect last known write sequence number"
        clear_last_commit
        return $OCF_ERR_GENERIC
    fi
}

galera_promote()
{
    local rc
    local extra_opts
    local bootstrap

    master_exists
    if [ $? -ne 0 ]; then
        # promoting the first master will bootstrap the cluster
        if is_bootstrap; then
            galera_start_local_node
            rc=$?
            return $rc
        else
            ocf_exit_reason "Attempted to start the cluster without being a bootstrap node."
            return $OCF_ERR_GENERIC
        fi
    else
        # promoting other masters only performs sanity checks
        # as the joining nodes were started during the "monitor" op
        if ! check_sync_needed; then
            # sync is done, clear info about last startup
            clear_no_grastate
            return $OCF_SUCCESS
        else
            ocf_exit_reason "Attempted to promote local node while sync was still needed."
            return $OCF_ERR_GENERIC
        fi
    fi
}

galera_demote()
{
    mysql_common_stop
    rc=$?
    if [ $rc -ne $OCF_SUCCESS ] && [ $rc -ne $OCF_NOT_RUNNING ]; then
        ocf_exit_reason "Failed to stop Master galera instance during demotion to Master"
        return $rc
    fi

    # if this node was previously a bootstrap node, that is no longer the case.
    clear_bootstrap_node
    clear_last_commit
    clear_sync_needed
    clear_no_grastate

    # Clear master score here rather than letting pacemaker do so once
    # demote finishes. This way a promote cannot take place right
    # after this demote even if pacemaker is requested to do so. It
    # will first have to run a start/monitor op, to reprobe the state
    # of the other galera nodes and act accordingly.
    clear_master_score

    # record last commit for next promotion
    detect_last_commit
    rc=$?
    return $rc
}

galera_start()
{
    local rc

    echo $OCF_RESKEY_wsrep_cluster_address | grep -q $NODENAME
    if [ $? -ne 0 ]; then
        ocf_exit_reason "local node <${NODENAME}> must be a member of the wsrep_cluster_address <${OCF_RESKEY_wsrep_cluster_address}>to start this galera instance"
        return $OCF_ERR_CONFIGURED
    fi

    galera_status info
    if [ $? -ne $OCF_NOT_RUNNING ]; then
        ocf_exit_reason "master galera instance started outside of the cluster's control"
        return $OCF_ERR_GENERIC
    fi

    mysql_common_prepare_dirs

    detect_last_commit
    rc=$?
    if [ $rc -ne $OCF_SUCCESS ]; then
        return $rc
    fi

    master_exists
    if [ $? -eq 0 ]; then
        ocf_log info "Master instances are already up, local node will join in when started"
    else
        clear_master_score
        detect_first_master
    fi

    return $OCF_SUCCESS
}

galera_monitor()
{
    local rc
    local status_loglevel="err"

    # Set loglevel to info during probe
    if ocf_is_probe; then
        status_loglevel="info"
    fi

    # Check whether mysql is running or about to start after sync
    galera_status $status_loglevel
    rc=$?

    if [ $rc -eq $OCF_NOT_RUNNING ]; then
        last_commit=$(get_last_commit $NODENAME)
        if [ -n "$last_commit" ];then
            rc=$OCF_SUCCESS

            if ocf_is_probe; then
                # prevent state change during probe
                return $rc
            fi

            master_exists
            if [ $? -ne 0 ]; then
                detect_first_master
            else
                # a master instance exists and is healthy.
                # start this node and mark it as "pending sync"
                ocf_log info "cluster is running. start local node to join in"
                galera_start_local_node
                rc=$?
            fi
        fi
        return $rc
    elif [ $rc -ne $OCF_SUCCESS ]; then
        return $rc
    fi

    # if we make it here, mysql is running or about to start after sync.
    # Check cluster status now.

    echo $OCF_RESKEY_wsrep_cluster_address | grep -q $NODENAME
    if [ $? -ne 0 ]; then
        ocf_exit_reason "local node <${NODENAME}> is started, but is not a member of the wsrep_cluster_address <${OCF_RESKEY_wsrep_cluster_address}>"
        return $OCF_ERR_GENERIC
    fi

    check_sync_needed
    if [ $? -eq 0 ]; then
        # galera running and sync is needed: slave state
        if ocf_is_probe; then
            # prevent state change during probe
            rc=$OCF_SUCCESS
        else
            check_sync_status
            rc=$?
        fi
    else
        is_primary
        if [ $? -ne 0 ]; then
            ocf_exit_reason "local node <${NODENAME}> is started, but not in primary mode. Unknown state."
            rc=$OCF_ERR_GENERIC
        else
            # galera running, no need to sync: master state and everything's clear
            rc=$OCF_RUNNING_MASTER

            if ocf_is_probe; then
                # restore master score during probe
                # if we detect this is a master instance
                set_master_score
            fi
        fi
    fi

    return $rc
}

galera_stop()
{
    local rc
    # make sure the process is stopped
    mysql_common_stop
    rc=$?

    clear_last_commit
    clear_master_score
    clear_bootstrap_node
    clear_sync_needed
    clear_no_grastate
    return $rc
}

galera_validate()
{
    if ! ocf_is_ms; then
        ocf_exit_reason "Galera must be configured as a multistate Master/Slave resource."
        return $OCF_ERR_CONFIGURED
    fi

    if [ -z "$OCF_RESKEY_wsrep_cluster_address" ]; then
        ocf_exit_reason "Galera must be configured with a wsrep_cluster_address value."
        return $OCF_ERR_CONFIGURED
    fi

    mysql_common_validate
}

case "$1" in
  meta-data)    meta_data
        exit $OCF_SUCCESS;;
  usage|help)   usage
        exit $OCF_SUCCESS;;
esac

galera_validate
rc=$?
LSB_STATUS_STOPPED=3
if [ $rc -ne 0 ]; then
    case "$1" in
        stop) exit $OCF_SUCCESS;;
        monitor) exit $OCF_NOT_RUNNING;;
        status) exit $LSB_STATUS_STOPPED;;
        *) exit $rc;;
    esac
fi

if [ -z "${OCF_RESKEY_check_passwd}" ]; then
    # This value is automatically sourced from /etc/sysconfig/checkcluster if available
    OCF_RESKEY_check_passwd=${MYSQL_PASSWORD}
fi
if [ -z "${OCF_RESKEY_check_user}" ]; then
    # This value is automatically sourced from /etc/sysconfig/checkcluster if available
    OCF_RESKEY_check_user=${MYSQL_USERNAME}
fi
: ${OCF_RESKEY_check_user="root"}

MYSQL_OPTIONS_CHECK="-nNE --user=${OCF_RESKEY_check_user}"
if [ -n "${OCF_RESKEY_check_passwd}" ]; then
    MYSQL_OPTIONS_CHECK="$MYSQL_OPTIONS_CHECK --password=${OCF_RESKEY_check_passwd}"
fi

# This value is automatically sourced from /etc/sysconfig/checkcluster if available
if [ -n "${MYSQL_HOST}" ]; then
    MYSQL_OPTIONS_CHECK="$MYSQL_OPTIONS_CHECK -h ${MYSQL_HOST}"
fi

# This value is automatically sourced from /etc/sysconfig/checkcluster if available
if [ -n "${MYSQL_PORT}" ]; then
    MYSQL_OPTIONS_CHECK="$MYSQL_OPTIONS_CHECK -P ${MYSQL_PORT}"
fi



# What kind of method was invoked?
case "$1" in
  start)    galera_start;;
  stop)     galera_stop;;
  status)   galera_status err;;
  monitor)  galera_monitor;;
  promote)  galera_promote;;
  demote)   galera_demote;;
  validate-all) exit $OCF_SUCCESS;;

 *)     usage
        exit $OCF_ERR_UNIMPLEMENTED;;
esac

# vi:sw=4:ts=4:et:
RA_EOF
  ssh ${node} -- chmod +x ${MARIADB_galera_ra}
}
