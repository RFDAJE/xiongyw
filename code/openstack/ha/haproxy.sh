#!/bin/bash

# created(bruin, 2017-01-17)

HAPROXY_res_name="haproxy"
HAPROXY_ra_path="/usr/lib/ocf/resource.d/heartbeat/haproxy"
HAPROXY_cfg="/etc/haproxy/haproxy.cfg"

# haproxy colocation resources
HAPROXY_cols=( ${VIP0_res_name} ${VIP1_res_name} )
# haproxy order (before) constraint/resources
HAPROXY_deps=( ${VIP0_res_name} ${VIP1_res_name} ${RABBITMQ_res_name}  ${MARIADB_res_name} ${KEYSTONE_res_name} )

# call with $NODES as the first argument: haproxy $NODES
haproxy() {

  local script="/tmp/haproxy.sh"
  echo "creating haproxy resource..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${HAPROXY_res_name}
  if [[ $? = 0 ]]; then
    echo "info: haproxy resource already exist, do nothing!"
    return 0;
  fi

  dep_install_check ${HAPROXY_res_name}
  : <<SKIP
  # check if vip resources are ready
  ssh ${NODES[0]} -- pcs resource show ${NODES_VIP_NAMES[0]}
  if [[ $? != 0 ]]; then
    echo "ERROR: haproxy depends on VIP ${NODES_VIP_NAMES[0]}!"
    return 1;
  fi
  ssh ${NODES[0]} -- pcs resource show ${NODES_VIP_NAMES[1]}
  if [[ $? != 0 ]]; then
    echo "ERROR: haproxy depends on VIP ${NODES_VIP_NAMES[1]}!"
    return 1;
  fi
SKIP

  #
  # install & config haproxy on each node
  #
  for node in "${NODES[@]}"; do
    ssh ${node} -- cat<<-EOF \>${script}
	#!/bin/bash
	echo "installing haproxy..."
	yum -y install haproxy
	# save the original /etc/haproxy/haproxy.cfg
	cp /etc/haproxy/haproxy.cfg /etc/haproxy/haproxy.cfg.orig
	systemctl stop haproxy
	systemctl disable haproxy
	EOF
    ssh ${node} -- chmod +x ${script} \; ${script}

    echo "configuring haproxy..."
    ssh ${node} -- cat<<-EOF \> ${HAPROXY_cfg}
	#---------------------------------------------------------------------
	# Global settings
	#---------------------------------------------------------------------
	global
	    # to have these messages end up in /var/log/haproxy.log you will
	    # need to:
	    #
	    # 1) configure syslog to accept network log events.  This is done
	    #    by adding the '-r' option to the SYSLOGD_OPTIONS in
	    #    /etc/sysconfig/syslog
	    #
	    # 2) configure local2 events to go to the /var/log/haproxy.log
	    #   file. A line like the following can be added to
	    #   /etc/sysconfig/syslog
	    #
	    #    local2.*                       /var/log/haproxy.log
	    #
	    log         127.0.0.1 local2

	    chroot      /var/lib/haproxy
	    pidfile     /var/run/haproxy.pid
	    maxconn     4000
	    user        haproxy
	    group       haproxy
	    daemon

	    # turn on stats unix socket
	    stats socket /var/lib/haproxy/stats

	#---------------------------------------------------------------------
	# common defaults that all the 'listen' and 'backend' sections will
	# use if not designated in their block
	#---------------------------------------------------------------------
	defaults
	    mode                    http
	    log                     global
	    option                  httplog
	    option                  dontlognull
	    option http-server-close
	    option forwardfor       except 127.0.0.0/8
	    option                  redispatch
	    retries                 3
	    timeout http-request    10s
	    timeout queue           1m
	    timeout connect         10s
	    timeout client          1m
	    timeout server          1m
	    timeout http-keep-alive 10s
	    timeout check           10s
	    maxconn                 3000

	listen haproxy-Stats
	    bind *:8080
	    mode http
	    stats enable
	    stats uri /
	    stats realm Strictly\ Private
	    stats auth haproxy:password
	EOF
  done

  #
  # prepare haproxy resource agent
  #
  for node in "${NODES[@]}"; do
    echo "generating haproxy resource agent..."
    # downloaded from https://raw.githubusercontent.com/russki/cluster-agents/master/haproxy
    ssh ${node} -- cat <<'EOF' \>${HAPROXY_ra_path}
#!/bin/sh
#
# Resource script for haproxy daemon
#
# Description:  Manages haproxy daemon as an OCF resource in
#               an High Availability setup.
#
# HAProxy OCF script's Author: Russki
# Rsync OCF script's Author: Dhairesh Oza <odhairesh@novell.com>
# License: GNU General Public License (GPL)
#
#
#	usage: $0 {start|stop|status|monitor|validate-all|meta-data}
#
#	The "start" arg starts haproxy.
#
#	The "stop" arg stops it.
#
# OCF parameters:
# OCF_RESKEY_binpath
# OCF_RESKEY_conffile
# OCF_RESKEY_extraconf
#
# Note:This RA requires that the haproxy config files has a "pidfile"
# entry so that it is able to act on the correct process
##########################################################################
# Initialization:

: ${OCF_FUNCTIONS_DIR=${OCF_ROOT}/resource.d/heartbeat}
. ${OCF_FUNCTIONS_DIR}/.ocf-shellfuncs

USAGE="Usage: $0 {start|stop|status|monitor|validate-all|meta-data}";

##########################################################################

usage()
{
	echo $USAGE >&2
}

meta_data()
{
cat <<END
<?xml version="1.0"?>
<!DOCTYPE resource-agent SYSTEM "ra-api-1.dtd">
<resource-agent name="haproxy">
<version>1.0</version>
<longdesc lang="en">
This script manages haproxy daemon
</longdesc>
<shortdesc lang="en">Manages an haproxy daemon</shortdesc>

<parameters>

<parameter name="binpath">
<longdesc lang="en">
The haproxy binary path.
For example, "/usr/sbin/haproxy"
</longdesc>
<shortdesc lang="en">Full path to the haproxy binary</shortdesc>
<content type="string" default="/usr/sbin/haproxy"/>
</parameter>

<parameter name="conffile">
<longdesc lang="en">
The haproxy daemon configuration file name with full path.
For example, "/etc/haproxy/haproxy.cfg"
</longdesc>
<shortdesc lang="en">Configuration file name with full path</shortdesc>
<content type="string" default="/etc/haproxy/haproxy.cfg" />
</parameter>

<parameter name="extraconf">
<longdesc lang="en">
Extra command line arguments to pass to haproxy.
For example, "-f /etc/haproxy/shared.cfg"
</longdesc>
<shortdesc lang="en">Extra command line arguments for haproxy</shortdesc>
<content type="string" default="" />
</parameter>

</parameters>

<actions>
<action name="start" timeout="20s"/>
<action name="stop" timeout="20s"/>
<action name="monitor" depth="0" timeout="20s" interval="60s" />
<action name="validate-all" timeout="20s"/>
<action name="meta-data"  timeout="5s"/>
</actions>
</resource-agent>
END
exit $OCF_SUCCESS
}

get_pid_and_conf_file()
{
	if [ -n "$OCF_RESKEY_conffile" ]; then
		CONF_FILE=$OCF_RESKEY_conffile
	else
		CONF_FILE="/etc/haproxy/haproxy.cfg"
	fi

	PIDFILE="`grep -v \"#\" ${CONF_FILE} | grep \"pidfile\" | sed 's/^[ \t]*pidfile[ \t]*//'`"
	if [ "${PIDFILE}" = '' ]; then
		PIDFILE="/var/run/${OCF_RESOURCE_INSTANCE}.pid"
	fi
}

haproxy_status()
{
	if [ -n "$PIDFILE" -a -f "$PIDFILE" ]; then
		# haproxy is probably running
		PID=`cat $PIDFILE`
		if [ -n "$PID" ]; then
			if ps -p $PID | grep haproxy >/dev/null ; then
				ocf_log info "haproxy daemon running"
				return $OCF_SUCCESS
			else
				ocf_log info "haproxy daemon is not running but pid file exists"
				return $OCF_NOT_RUNNING
			fi
		else
			ocf_log err "PID file empty!"
			return $OCF_ERR_GENERIC
		fi
	fi

	# haproxy is not running
	ocf_log info "haproxy daemon is not running"
	return $OCF_NOT_RUNNING
}

haproxy_start()
{
	# if haproxy is running return success
	haproxy_status
	retVal=$?
	if [ $retVal -eq $OCF_SUCCESS ]; then
		exit $OCF_SUCCESS
	elif [ $retVal -ne $OCF_NOT_RUNNING ]; then
		ocf_log err "Error. Unknown status."
		exit $OCF_ERR_GENERIC
	fi

	if [ -n "$OCF_RESKEY_binpath" ]; then
		COMMAND="$OCF_RESKEY_binpath"
	else
		COMMAND="/usr/sbin/haproxy"
	fi

	$COMMAND $OCF_RESKEY_extraconf -f $CONF_FILE -p $PIDFILE;
	if [ $? -ne 0 ]; then
		ocf_log err "Error. haproxy daemon returned error $?."
		exit $OCF_ERR_GENERIC
	fi

	ocf_log info "Started haproxy daemon."
	exit $OCF_SUCCESS
}


haproxy_stop()
{
	if haproxy_status ; then
		PID=`cat $PIDFILE`
		if [ -n "$PID" ] ; then
			kill $PID
			if [ $? -ne 0 ]; then
				kill -SIGKILL $PID
				if [ $? -ne 0 ]; then
					ocf_log err "Error. Could not stop haproxy daemon."
					return $OCF_ERR_GENERIC
				fi
			fi
			rm $PIDFILE 2>/dev/null
		fi
	fi
	ocf_log info "Stopped haproxy daemon."
	exit $OCF_SUCCESS
}

haproxy_monitor()
{
	haproxy_status
}

haproxy_validate_all()
{
	if [ -n "$OCF_RESKEY_binpath" -a ! -x "$OCF_RESKEY_binpath" ]; then
		ocf_log err "Binary path $OCF_RESKEY_binpath does not exist."
		exit $OCF_ERR_ARGS
	fi
	if [ -n "$OCF_RESKEY_conffile" -a ! -f "$OCF_RESKEY_conffile" ]; then
		ocf_log err "Config file $OCF_RESKEY_conffile does not exist."
		exit $OCF_ERR_ARGS
	fi

	if  grep -v "^#" "$CONF_FILE" | grep "pidfile" > /dev/null ; then
		:
	else
		ocf_log err "Error. \"pidfile\" entry required in the haproxy config file by haproxy OCF RA."
		return $OCF_ERR_GENERIC
	fi

	return $OCF_SUCCESS
}


#
# Main
#

if [ $# -ne 1 ]; then
	usage
	exit $OCF_ERR_ARGS
fi

case $1 in
	start)	get_pid_and_conf_file
		haproxy_start
		;;

	stop)	get_pid_and_conf_file
		haproxy_stop
		;;

	status)	get_pid_and_conf_file
		haproxy_status
		;;

	monitor)get_pid_and_conf_file
		haproxy_monitor
		;;

	validate-all)	get_pid_and_conf_file
			haproxy_validate_all
			;;

	meta-data)	meta_data
			;;

	usage)	usage
		exit $OCF_SUCCESS
		;;

	*)	usage
		exit $OCF_ERR_UNIMPLEMENTED
		;;
esac
EOF
    ssh ${node} -- chmod +x ${HAPROXY_ra_path}
  done

  haproxy_recreate_res
}


# re-create haproxy resource
# why re-create haproxy? this is because it needs to load extraconf config
# files created by other resources, which can not be modified on the fly
#
# this function can also be use for the 1st time creation
haproxy_recreate_res() {
  local script="/tmp/haproxy.sh"
  local vip0=${NODES_VIP_NAMES[0]}
  local vip1=${NODES_VIP_NAMES[1]}

  echo "recreating resource ${HAPROXY_res_name}..."
  # if haproxy is not yet created, do nothing
  echo "checking if haproxy is defined..."
  ssh ${NODES[0]} -- pcs resource show ${HAPROXY_res_name}
  if [[ $? != 0 ]]; then
    echo "WARNING: ${HAPROXY_res_name} is not yet defined!"
  else
    echo -n "deleting haproxy resource..."
    ssh ${NODES[0]} -- pcs resource delete ${HAPROXY_res_name}
    echo "done!"
  fi

  echo -n "creating haproxy resource (as disabled)..."
  # create haproxy resource disabled, on one node
  ssh ${NODES[0]} -- cat <<-'EOF' \>${script}
	#!/bin/bash
	#set -x
	#
	# prepare extraconf options for the RA
	#
	extra=(/etc/haproxy/*.cfg)
	# remove haproxy.cfg, otherwise, haproxy will report errors if a cfg file is encluded more than once
	extra=(${extra[@]/*haproxy.cfg})
	# add -f for each cfg file
	extra=(${extra[@]/#/-f })
	pcs resource create _HAPROXY_ ocf:heartbeat:haproxy extraconf="${extra[*]}" op monitor interval=15s --disabled
	EOF
  ssh ${NODES[0]} -- sed -i "s/_HAPROXY_/${HAPROXY_res_name}/g" ${script}
  ssh ${NODES[0]} -- chmod +x ${script} \; ${script}
  echo "done!"

  # colocation constraints
  echo "setting colocation constraints..."
  for col in "${HAPROXY_cols[@]}"; do
    ssh ${NODES[0]} -- pcs constraint colocation add ${HAPROXY_res_name} with ${col}
  done
  echo "done!"
  
  echo "setting order (before) constraints..."
  for dep in "${HAPROXY_deps[@]}"; do
    ssh ${NODES[0]} -- pcs constraint order ${dep} then ${HAPROXY_res_name}
  done
  echo "done!"

  # finally enable haproxy resource  
  echo -n "enabling haproxy resource..."
  ssh ${NODES[0]} -- pcs resource enable ${HAPROXY_res_name}
  echo "done!"
}

# get from CIB a list of resources which starts before haproxy
_haproxy_get_order_constraints() {

  local deps=$(cat <<-EOF| ssh -T ${NODES[0]} -- 
	pcs constraint order show --full|grep haproxy|sed -e "s/.*order-\(.*\)-haproxy.*/\1/g"
	EOF
  )

  echo $deps
}

# get from CIB a list of resources which colocates with haproxy
_haproxy_get_colocation_constraints() {

  local cols=$(cat <<-EOF| ssh -T ${NODES[0]} -- 
	pcs constraint colocation show --full|grep haproxy|sed -e "s/.*colocation-\(.*\)-haproxy.*/\1/g" -e "s/.*colocation-haproxy-\(.*\)-.*/\1/g"
	EOF
  )

  echo $cols
}

haproxy-d() {
  local script="/tmp/haproxy.sh"
  echo "deleting haproxy resource..."

  dep_delete_check ${HAPROXY_res_name}

  ssh ${NODES[0]} -- pcs resource delete ${HAPROXY_res_name}

  for node in "${NODES[@]}"; do
    ssh ${node} -- cat<<-EOF \> ${script}
	#!/bin/bash
	echo "uninstall haproxy..."
	yum -y remove haproxy
	# remove resource agent and config directory
	rm -f ${HAPROXY_ra_path}
	rm -f ${HAPROXY_cfg}
	EOF
    ssh ${node} -- chmod +x ${script} \; ${script}
  done
}

haproxy-t() {
  echo "todo..."
}

# reinstall
haproxy-r() {
  haproxy-d
  haproxy
}

