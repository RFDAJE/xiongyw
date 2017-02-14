#!/bin/bash

# created(bruin, 2017-02-08)

# note that ceilometer service in HA contains several Pacemaker resources:
# - api: clone, wsgi under apache, then under haproxy
# - notification agent: only active on one node
# - collector: only active on one node
# - polling: only active on one node
# - central agent: only active on one node (fixme: what's the relation betw polling and central/ipmi/compute)
# - ipmi agent: note that impi is supposed to run on every node supporting ipmi
# - compute agent: to run on compute node, for effectiveness.
#
# as api service uses the same apache httpd server (the same as keystone), we choose
# collector resource as the representation for all ceilometer services.
CEIL_notification_res_name="ceilometer-notification"
CEIL_collector_res_name="ceilometer-collector"
CEIL_polling_res_name="ceilometer-polling"
CEIL_central_res_name="ceilometer-central"
# FIXME: should ipmi service a clone resource?
CEIL_ipmi_res_name="ceilometer-ipmi"
CEIL_res_name=${CEIL_collector_res_name}

# let ceilometer component has a user "ceilometer" of "admin" role in the "service" project
CEIL_keystone_project=${KEYSTONE_service_project}
CEIL_keystone_user="ceilometer"
CEIL_keystone_pass=${KEYSTONE_bootstrap_pass}
CEIL_keystone_role=${KEYSTONE_bootstrap_role}
# what kind of service ceilometer provides, in which region
CEIL_service_name="ceilometer"
CEIL_service_type="metering"
CEIL_service_region=${KEYSTONE_bootstrap_region}

# mongo mongodb://ceilometer:qwerty@c1m:27017,c2m:27017,c3m:27017/ceilometer?replicaSet=rs0
# note that if omit the db name, mongo shell will report errors.
CEIL_mongod_user="ceilometer"
CEIL_mongod_pass="qwerty"
CEIL_mongod_db="ceilometer"
CEIL_mongod_conn_url="mongodb://${CEIL_mongod_user}:${CEIL_mongod_pass}@${MONGOD_nodes}/${CEIL_mongod_db}?replicaSet=${MONGOD_rs_name}"

CEIL_api_port="8777"
CEIL_public_uri="http://${NODES_VIP_ADDRS[0]}:${CEIL_api_port}"
#CEIL_public_uri="http://10.2.162.165:${CEIL_api_port}"
CEIL_internal_uri=${CEIL_public_uri}
CEIL_admin_uri=${CEIL_public_uri}


#########################################################################
# api configuration
# unlike keystone, the wsgi config file does not exist for ceilometer, we need to create it.
CEIL_api_wsgi_conf="/etc/httpd/conf.d/wsgi-ceilometer.conf"
# https://bugs.launchpad.net/ceilometer/+bug/1632635
CEIL_api_wsgi_app="/usr/lib/python2.7/site-packages/ceilometer/api/app.wsgi"

CEIL_conf_dir="/etc/ceilometer"
CEIL_log_dir="/var/log/ceilometer"
CEIL_api_access_log="/var/log/httpd/ceilometer_access.log"
CEIL_api_error_log="/var/log/httpd/ceilometer_error.log"

CEIL_haproxy_cfg="/etc/haproxy/ceilometer.cfg"

# we don't need "openstack-ceilometer-compute" pkg, which should be installed
# on computer node (as an agent for nova). impi pkg also needs to be installed on nodes supporting impi.
CEIL_install_pkgs="openstack-ceilometer-common \
                   openstack-ceilometer-api \
                   openstack-ceilometer-central \
                   openstack-ceilometer-collector \
                   openstack-ceilometer-notification \
                   openstack-ceilometer-ipmi \
                   openstack-ceilometer-polling \
                   python-ceilometer \
                   python2-ceilometerclient \
                   python-ceilometermiddleware"


ceil() {
  info "start ceilometer config..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${CEIL_res_name}
  if [[ $? = 0 ]]; then
    warning "${CEIL_res_name} resource already exist!"
    return 0;
  fi

  dep_install_check ${CEIL_res_name}

  _ceil_prepare_mongodb

  _ceil_prepare_keystone

  _ceil_install_n_config
  
  _ceil_create_pcmk_resources

  _ceil_haproxy_config

}


# create db and user
_ceil_prepare_mongodb() {
  info "preparing mongodb database & user..."
  local script="/tmp/mongo1.sh"
  ssh ${NODES[0]} -- cat <<-EOF \> ${script}
	#!/bin/bash
	set -x
	mongo "${MONGOD_conn_url}" --eval 'db=db.getSiblingDB("_DBNAME_"); db.createUser({user:"_USERNAME_", pwd:"_USERPASS_", roles:[ "readWrite","dbAdmin" ]})'
	EOF
  cat <<-EOF | ssh -T ${NODES[0]} --
	sed -i -e "s/_DBNAME_/${CEIL_mongod_db}/g" -e "s/_USERNAME_/${CEIL_mongod_user}/g" -e "s/_USERPASS_/${CEIL_mongod_pass}/g" ${script}
	chmod +x ${script}
	${script}
	EOF
}


_ceil_prepare_keystone() {
  info "preparing keystone..."
  cat <<-EOF | ssh -T ${NODES[0]} --
	. ~/admin_openrc
	echo "creating a user 'ceilometer'..."
	openstack user create ${CEIL_keystone_user} --domain ${KEYSTONE_domain_name} --password ${CEIL_keystone_pass}
	openstack role add ${CEIL_keystone_role} --project ${CEIL_keystone_project} --user ${CEIL_keystone_user}

	echo "registering endpoints provided by ceilometer..."
	openstack service create --name ${CEIL_service_name} --description "Telemetry" ${CEIL_service_type}
	openstack endpoint create --region ${CEIL_service_region} ${CEIL_service_type} public   ${CEIL_public_uri}
	openstack endpoint create --region ${CEIL_service_region} ${CEIL_service_type} internal ${CEIL_internal_uri}
	openstack endpoint create --region ${CEIL_service_region} ${CEIL_service_type} admin    ${CEIL_admin_uri}
	EOF
}

# <http://docs.openstack.org/project-install-guide/telemetry/newton/install-base-rdo.html>
_ceil_install_n_config() {
  local script="/tmp/ceil.sh"
  local conf="/etc/ceilometer/ceilometer.conf"
  
  info "installing ceilometer pkgs..."
  # note that the installation will install several systemd unit files
  # under /usr/lib/systemd/system/...which are disabled by default (suitable for pcmk)
  #
  #ls /usr/lib/systemd/system/openstack-ceilometer-*
  #/usr/lib/systemd/system/openstack-ceilometer-api.service
  #/usr/lib/systemd/system/openstack-ceilometer-polling.service
  #/usr/lib/systemd/system/openstack-ceilometer-central.service
  #/usr/lib/systemd/system/openstack-ceilometer-ipmi.service
  #/usr/lib/systemd/system/openstack-ceilometer-notification.service
  #/usr/lib/systemd/system/openstack-ceilometer-collector.service
  
  for node in "${NODES[@]}"; do
    ssh ${node} -- yum -y install ${CEIL_install_pkgs}
  done

  info "configuring ceilometer ${conf}..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- cp ${conf} ${conf}.orig
    ssh ${node} -- cat <<-EOF \>${script}
	#!/bin/bash
	# [default] section
	sed -i "/^\[DEFAULT/a\
rpc_backend = rabbit\n\
auth_strategy = keystone\n" ${conf}
	# [database] section
	sed -i "/^\[database/a connection = ${CEIL_mongod_conn_url}" ${conf}
	# [oslo_messaging_rabbit] section <http://docs.openstack.org/ha-guide/shared-messaging.html>
	sed -i "/^\[oslo_messaging_rabbit/a\
rabbit_hosts = ${RABBITMQ_hosts}\n\
rabbit_userid = ${RABBITMQ_user}\n\
rabbit_password = ${RABBITMQ_pass}\n\
rabbit_retry_interval = 1\n\
rabbit_retry_backoff = 2\n\
rabbit_max_retries = 0\n\
rabbit_durable_queues = true\n\
rabbit_ha_queues = true\n" ${conf}
	# [keystone_authtoken] section
	sed -i "/^\[keystone_authtoken/a\
auth_uri = ${KEYSTONE_public_uri}\n\
auth_url = ${KEYSTONE_internal_uri}\n\
memcached_servers = ${MEMCACHED_hosts}\n\
auth_type = password\n\
project_domain_name = ${KEYSTONE_domain_name}\n\
user_domain_name =  ${KEYSTONE_domain_name}\n\
project_name = ${KEYSTONE_service_project}\n\
username = ${CEIL_keystone_user}\n\
password = ${CEIL_keystone_pass}\n" ${conf}
	# [service_credentials] section
	sed -i "/^\[service_credentials/a\
auth_url = ${KEYSTONE_public_uri}\n\
project_domain_id = ${KEYSTONE_domain_id}\n\
user_domain_id = ${KEYSTONE_domain_id}\n\
project_name = ${KEYSTONE_service_project}\n\
username = ${CEIL_keystone_user}\n\
password = ${CEIL_keystone_pass}\n\
interface = internalURL\n\
region_name = ${KEYSTONE_bootstrap_region}\n" ${conf}
	# [collector]: disable udp socket
	sed -i "/^\[collector/a\
udp_address = \n" ${conf}
	EOF
    ssh ${node} -- chmod +x ${script} \; ${script}
    # display the neat content again
    info "${conf} content on ${node}:"
    cat <<-EOF | ssh -T ${node} --
	sed -n "/^[^#\ ].*/p" ${conf}
	EOF
  done

  info "configuring ceilometer-api service..."
  for idx in "${!NODES[@]}"; do
    local node=${NODES[$idx]}
    local ips=( ${NODES_IP_ADDRS[$idx]} )

    # create wsgi config file. note that apache should not listen on all IP@, otherwise 
    # haproxy will fail when binding vips
    ssh ${node} -- cat <<-EOF \> ${CEIL_api_wsgi_conf}
	Listen ${ips[0]}:${CEIL_api_port} 
	
	<VirtualHost *:${CEIL_api_port}>
	    WSGIDaemonProcess ceilometer-api processes=2 threads=10 user=ceilometer group=ceilometer display-name=%{GROUP}
	    WSGIProcessGroup ceilometer-api
	    WSGIScriptAlias / "${CEIL_api_wsgi_app}"
	    WSGIApplicationGroup %{GLOBAL}
	    ErrorLog /var/log/httpd/ceilometer_error.log
	    CustomLog /var/log/httpd/ceilometer_access.log combined
	
	    <Directory $(dirname ${CEIL_api_wsgi_app})>
	        <IfVersion >= 2.4>
	            Require all granted
	        </IfVersion>
	        <IfVersion < 2.4>
	            Order allow,deny
	            Allow from all
	        </IfVersion>
	    </Directory>
	</VirtualHost>
	
	WSGISocketPrefix /var/run/httpd
	EOF
  done
}

_ceil_create_pcmk_resources() {

  # api: httpd-clone resource is already defined by keystone. just need to reload it on each node
  for node in "${NODES[@]}"; do
    ssh ${node} -- systemctl reload httpd
  done

  # notification service
  ssh ${NODES[0]} -- pcs resource create ${CEIL_notification_res_name} systemd:openstack-ceilometer-notification

  # collector service
  ssh ${NODES[0]} -- pcs resource create ${CEIL_collector_res_name} systemd:openstack-ceilometer-collector

  # polling agent service
  ssh ${NODES[0]} -- pcs resource create ${CEIL_polling_res_name} systemd:openstack-ceilometer-polling

  # central agent service
  ssh ${NODES[0]} -- pcs resource create ${CEIL_central_res_name} systemd:openstack-ceilometer-central

  # ipmi agent service: FIXME: should it be a clone?
  ssh ${NODES[0]} -- pcs resource create ${CEIL_ipmi_res_name} systemd:openstack-ceilometer-ipmi

  # FIXME: some of the service should be seprated on different nodes in the cluster...
}

_ceil_haproxy_config() {
  local tmp_cfg="/tmp/ceilometer.cfg"
  local node=""
  local ips=""

  # update haproxy config on each node, and restart haproxy resource
  # note that according to <http://docs.openstack.org/ha-guide/controller-ha-haproxy.html#configuring-haproxy>
  # "The Telemetry API service configuration does not have the option httpchk directive as it cannot process this check properly."
  echo "creating ${CEIL_haproxy_cfg} on each node..."
  >${tmp_cfg}
  cat <<-EOF >> ${tmp_cfg}
	listen ceilometer-api
	  bind ${NODES_VIP_ADDRS[0]}:${CEIL_api_port}
	  balance  source
	  option  tcpka
	#  option  httpchk
	  option  tcplog
	EOF
  for idx in "${!NODES[@]}"; do
    node=${NODES[${idx}]}
    ips=( ${NODES_IP_ADDRS[${idx}]} )
    cat <<-EOF >> ${tmp_cfg}
	  server ${node} ${ips[0]}:${CEIL_api_port} check inter 2000 rise 2 fall 5
	EOF
  done

  # copy tmp cfg to each node
  for node in "${NODES[@]}"; do
    scp ${tmp_cfg} ${node}:${CEIL_haproxy_cfg}
  done

  # re-define haproxy resource
  haproxy_recreate_res
}

ceil-d() {
  info "removing ${CEIL_res_name} resource..."

  dep_delete_check ${CEIL_res_name}
  
  # remove pcmk resources
  ssh ${NODES[0]} -- pcs resource delete ${CEIL_notification_res_name}
  ssh ${NODES[0]} -- pcs resource delete ${CEIL_collector_res_name}
  ssh ${NODES[0]} -- pcs resource delete ${CEIL_polling_res_name}
  ssh ${NODES[0]} -- pcs resource delete ${CEIL_central_res_name}
  ssh ${NODES[0]} -- pcs resource delete ${CEIL_ipmi_res_name}

  info "removing mongodb database ceilometer..."
  # https://docs.mongodb.com/manual/reference/command/dropDatabase/
  cat <<-EOF | ssh -T ${NODES[0]} --
	set -x
	mongo "${MONGOD_conn_url}" --eval 'db=db.getSiblingDB("${CEIL_mongod_db}"); db.runCommand({dropDatabase:1})'
	EOF

  info "removing mongodb user ceilometer..."
  cat <<-EOF | ssh -T ${NODES[0]} --
	set -x
	mongo "${MONGOD_conn_url}" --eval 'db=db.getSiblingDB("${CEIL_mongod_db}"); db.dropUser("${CEIL_mongod_user}")'
	EOF

  info "removing ceilometer's endpoints & service from keystone..."
  cat <<-EOF | ssh -T ${NODES[0]} --
	. ~/admin_openrc
	# no need to explicitly delete endpoints, deleting the service automatically also delete related endpoints
	# openstack endpoint list -c "ID" -f value --service ${CEIL_service_type} --region ${CEIL_service_region}
	# openstack endpoint delete ...
	openstack service delete ${CEIL_service_type}
	EOF

  info "removing keystone user for ceilometer..."
  cat <<-EOF | ssh -T ${NODES[0]} --
	. ~/admin_openrc
	openstack user delete ${CEIL_keystone_user}
	EOF

  info "removing ceilometer pkgs..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- yum -y remove ${CEIL_install_pkgs}
  done

  info "removing ceilometer config & log files..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- rm -f ${CEIL_api_wsgi_conf}
    ssh ${node} -- rm -rf ${CEIL_conf_dir}
    ssh ${node} -- rm -rf ${CEIL_log_dir}
    ssh ${node} -- rm -f ${CEIL_api_access_log}*
    ssh ${node} -- rm -f ${CEIL_api_error_log}*
  done

  # reload httpd
  for node in "${NODES[@]}"; do
    ssh ${node} -- systemctl reload httpd
  done


  # remove haproxy cfg file
  echo "removing ${CEIL_haproxy_cfg}..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- rm -f ${CEIL_haproxy_cfg}
  done

  # re-define haproxy resource
  haproxy_recreate_res
}

ceil-t() {
  info "testing ceilometer..."
  ssh ${NODES[0]} -- . ~/admin_openrc \; ceilometer meter-list
  ssh ${NODES[0]} -- . ~/admin_openrc \; ceilometer sample-list
  ssh ${NODES[0]} -- . ~/admin_openrc \; ceilometer resource-list
  ssh ${NODES[0]} -- . ~/admin_openrc \; ceilometer event-list
  ssh ${NODES[0]} -- . ~/admin_openrc \; ceilometer capabilities

  # todo
}

ceil-r() {
  ceil-d
  ceil
}
