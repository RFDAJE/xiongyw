#!/bin/bash

# created(bruin, 2017-02-27)

# dev ref: https://docs.openstack.org/developer/aodh/
# install guide: https://docs.openstack.org/project-install-guide/telemetry-alarming/draft/

# note that aodh HA contains several Pacemaker resources:
# - api: clone, wsgi under apache, then under haproxy
# - evaluator: only active on one node
# - notifier: only active on one node
# - listener: only active on one node
# - expirer: only active on one node
AODH_api_res_name=${KEYSTONE_res_name}
AODH_evaluator_res_name="aodh-evaluator"
AODH_notifier_res_name="aodh-notifier"
AODH_listener_res_name="aodh-listener"
AODH_expirer_res_name="aodh-expirer"
# as api service uses the same apache httpd server (the same as keystone), we choose
# evaluator resource as the representation for all aodh services.
AODH_res_name=${AODH_evaluator_res_name}

AODH_mariadb_user="aodh"
AODH_mariadb_pass="qwerty"
AODH_mariadb_db="aodh"
AODH_sqlalchemy_connection="mysql+pymysql://${AODH_mariadb_user}:${AODH_mariadb_pass}@${NODES_VIP_ADDRS[1]}/${AODH_mariadb_db}?charset=utf8"

AODH_keystone_user="aodh"
AODH_keystone_pass="qwerty"
AODH_keystone_role=${KEYSTONE_bootstrap_role}
AODH_keystone_project=${KEYSTONE_service_project}

AODH_service_name="aodh"
AODH_service_type="alarming"
AODH_service_region=${KEYSTONE_bootstrap_region}
AODH_service_description=${CEIL_service_description}

AODH_api_port="8042"
AODH_public_uri="http://${NODES_VIP_ADDRS[0]}:${AODH_api_port}"
AODH_internal_uri=${AODH_public_uri}
AODH_admin_uri=${AODH_public_uri}

AODH_install_pkgs="openstack-aodh-common \
                   openstack-aodh-api \
                   openstack-aodh-evaluator \
                   openstack-aodh-expirer \
                   openstack-aodh-listener \
                   openstack-aodh-notifier \
                   python2-aodhclient"

AODH_api_wsgi_conf="/etc/httpd/conf.d/wsgi-aodh.conf"
AODH_api_wsgi_app="/usr/lib/python2.7/site-packages/aodh/api/app.wsgi"

AODH_conf_dir="/etc/aodh"
AODH_log_dir="/var/log/aodh"
AODH_api_access_log="/var/log/httpd/aodh_access.log"
AODH_api_error_log="/var/log/httpd/aodh_error.log"
AODH_haproxy_cfg="/etc/haproxy/aodh.cfg"
AODH_conf_file="${AODH_conf_dir}/aodh.conf"

aodh() {
  echo "start ${AODH_res_name} config..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${AODH_res_name}
  if [[ $? = 0 ]]; then
    echo "info: ${AODH_res_name} resource already exist!"
    return 0;
  fi

  dep_install_check ${AODH_res_name}

  _aodh_prepare_alarm_storage

  _aodh_prepare_keystone

  _aodh_install_n_config

  _aodh_create_pcmk_resources

  _aodh_haproxy_config
}

# we put the data into a SQLAlchemy database (mariadb), as it
# does not support mongodb as for Newton release
# https://docs.openstack.org/project-install-guide/telemetry-alarming/draft/install-rdo.html
# https://docs.openstack.org/developer/aodh/install/manual.html#database-configuration
_aodh_prepare_alarm_storage() {
  local script="/tmp/aodh1.sh"
  # prepare mariadb: create aodh db and account
  # we ssh to one of the nodes is to ensure that mysql binary is available.
  ssh ${NODES[0]} -- cat<<-EOF \>${script}
	#!/bin/bash
	echo "creating aodh database and account..."
	mysql -hVIP_NAME -uroot -pqwerty -e "CREATE DATABASE ${AODH_mariadb_db};"
	mysql -hVIP_NAME -uroot -pqwerty -e "GRANT ALL PRIVILEGES ON ${AODH_mariadb_user}.* TO 'aodh'@'localhost' IDENTIFIED BY '${AODH_mariadb_pass}';"
	mysql -hVIP_NAME -uroot -pqwerty -e "GRANT ALL PRIVILEGES ON ${AODH_mariadb_user}.* TO 'aodh'@'SUBNET_ADDR' IDENTIFIED BY '${AODH_mariadb_pass}';"
	EOF
  cat <<-EOF | ssh -T ${NODES[0]} --
	sed -i -e "s/VIP_NAME/${NODES_VIP_NAMES[1]}/" -e "s/SUBNET_ADDR/${NODES_SUBNET_FOR_MARIADB[1]}/" ${script}
	EOF
  ssh ${NODES[0]} -- chmod +x ${script} \; ${script}
}

# add aodh's account/role/service/endpoints into keystone
_aodh_prepare_keystone() {
  info "preparing keystone for aodh..."
  cat <<-EOF | ssh -T ${NODES[0]} --
	. ~/admin_openrc
	echo "creating a user/role/service, aka 'service credentials' for aodh..."
	# create 'aodh' user
	openstack user create ${AODH_keystone_user} --domain ${KEYSTONE_domain_name} --password ${AODH_keystone_pass}
	# add 'admin' role to user 'aodh'
	openstack role add ${AODH_keystone_role} --project ${AODH_keystone_project} --user ${AODH_keystone_user}

	echo "registering endpoints provided by aodh..."

	# create service entry for aodh
	openstack service create --name ${AODH_service_name} --description ${AODH_service_description} ${AODH_service_type}

	# register endpoints of aodh
	openstack endpoint create --region ${AODH_service_region} ${AODH_service_type} public   ${AODH_public_uri}
	openstack endpoint create --region ${AODH_service_region} ${AODH_service_type} internal ${AODH_internal_uri}
	openstack endpoint create --region ${AODH_service_region} ${AODH_service_type} admin    ${AODH_admin_uri}
	EOF
}

_aodh_install_n_config() {
  local script="/tmp/aodh-pkg.h"


  for node in "${NODES[@]}"; do
    info "installing aodh pkgs on ${node}..."
    ssh ${node} -- yum -y install ${AODH_install_pkgs}
  done

  #####################################
  # /etc/aodh/aodh.conf
  #####################################
  for node in "${NODES[@]}"; do
    info "configuring ${AODH_conf_file} on ${node}..."
    ssh ${node} -- cp ${AODH_conf_file} ${AODH_conf_file}.orig
    ssh ${node} -- cat <<-EOF \>${script}
	#!/bin/bash

	# [default]
	sed -i -e "/^\[DEFAULT/a\
transport_url = ${RABBITMQ_transport_url}\n\
auth_strategy = keystone\n" ${AODH_conf_file}

	# [database]
sed -i -e "/^\[database/a\
connection = ${AODH_sqlalchemy_connection}\n" ${AODH_conf_file}

	# [keystone_authtoken]
	sed -i -e "/^\[keystone_authtoken/a\
auth_uri = ${KEYSTONE_public_uri}\n\
auth_url = ${KEYSTONE_internal_url}\n\
memcached_servers = ${MEMCACHED_hosts}\n\
auth_type = password\n\
project_domain_name = ${KEYSTONE_domain_name}\n\
user_domain_name =  ${KEYSTONE_domain_name}\n\
project_name = ${KEYSTONE_service_project}\n\
username = ${AODH_keystone_user}\n\
password = ${AODH_keystone_pass}\n" ${AODH_conf_file}

	# [service_credentials]: credentials for accessing aodh service
	sed -i "/^\[service_credentials/a\
auth_url = ${KEYSTONE_public_url}\n\
project_domain_id = ${KEYSTONE_domain_id}\n\
user_domain_id = ${KEYSTONE_domain_id}\n\
project_name = ${KEYSTONE_service_project}\n\
username = ${AODH_keystone_user}\n\
password = ${AODH_keystone_pass}\n\
interface = internalURL\n\
region_name = ${KEYSTONE_bootstrap_region}\n" ${AODH_conf_file}
	EOF
    ssh ${node} -- chmod +x ${script} \; ${script}
    # display the neat content again
    info "${AODH_conf_file} content on ${node}:"
    cat <<-EOF | ssh -T ${node} --
	sed -n "/^[^#\ ].*/p" ${AODH_conf_file}
	EOF
  done
  
  # run 'aodh-dbsync'
  # <https://docs.openstack.org/project-install-guide/telemetry-alarming/draft/install-rdo.html>:
  # "The aodh-dbsync script is only necessary if you are using an SQL database."
  ssh ${NODES[0]} -- /usr/bin/aodh-dbsync

  ########################################################
  # aodh-api service
  #
  # there are 3 ways to run aodh-api service:
  # - mod_wsgi
  # - uwsgi
  # - /usr/bin/aodh-api
  #
  # the 3rd one is not recommended for production (only for tests). 
  # we choose the 1st option (mod_wsgi) here.
  #
  # refs: 
  # https://docs.openstack.org/developer/aodh/install/mod_wsgi.html
  # https://docs.openstack.org/developer/aodh/install/manual.html#installing-the-api-server
  ########################################################
  info "configuring aodh-api service..."
  for idx in "${!NODES[@]}"; do
    local node=${NODES[$idx]}
    local ips=( ${NODES_IP_ADDRS[$idx]} )

    # create wsgi config file. note that apache should not listen on all IP@, otherwise 
    # haproxy will fail when binding vips
    ssh ${node} -- cat <<-EOF \> ${AODH_api_wsgi_conf}
	Listen ${ips[0]}:${AODH_api_port} 
	
	<VirtualHost *:${AODH_api_port}>
	    WSGIDaemonProcess aodh-api processes=2 threads=10 user=aodh group=aodh display-name=%{GROUP}
	    WSGIProcessGroup aodh-api
	    WSGIScriptAlias / "${AODH_api_wsgi_app}"
	    WSGIApplicationGroup %{GLOBAL}
	    ErrorLog /var/log/httpd/aodh_error.log
	    CustomLog /var/log/httpd/aodh_access.log combined
	
	    <Directory $(dirname ${AODH_api_wsgi_app})>
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


_aodh_create_pcmk_resources() {

  # api: httpd-clone resource is already defined by keystone. just need to reload it on each node
  for node in "${NODES[@]}"; do
    ssh ${node} -- systemctl reload httpd
  done

  # evaluator service
  ssh ${NODES[0]} -- pcs resource create ${AODH_evaluator_res_name} systemd:openstack-aodh-evaluator

  # notifier service
  ssh ${NODES[0]} -- pcs resource create ${AODH_notifier_res_name} systemd:openstack-aodh-notifier

  # listener service
  # event-alarm: https://docs.openstack.org/developer/aodh/event-alarm.html
  #ssh ${NODES[0]} -- pcs resource create ${AODH_listener_res_name} systemd:openstack-aodh-listener

  # expirer service: 
  # alarm_history_time_to_live = -1 means keeping the alarm history for ever.
  #ssh ${NODES[0]} -- pcs resource create ${AODH_expirer_res_name} systemd:openstack-aodh-expirer
}

_aodh_haproxy_config() {
  local tmp_cfg="/tmp/aodh.cfg"
  local node=""
  local ips=""

  # update haproxy config on each node, and restart haproxy resource
  echo "creating ${AODH_haproxy_cfg} on each node..."
  >${tmp_cfg}
  cat <<-EOF >> ${tmp_cfg}
	listen aodh-api
	  bind ${NODES_VIP_ADDRS[0]}:${AODH_api_port}
	  balance  source
	  option  tcpka
	#  option  httpchk
	  option  tcplog
	EOF
  for idx in "${!NODES[@]}"; do
    node=${NODES[${idx}]}
    ips=( ${NODES_IP_ADDRS[${idx}]} )
    cat <<-EOF >> ${tmp_cfg}
	  server ${node} ${ips[0]}:${AODH_api_port} check inter 2000 rise 2 fall 5
	EOF
  done

  # copy tmp cfg to each node
  for node in "${NODES[@]}"; do
    scp ${tmp_cfg} ${node}:${AODH_haproxy_cfg}
  done

  # re-define haproxy resource
  haproxy_recreate_res
}

aodh-d() {
  local script="/tmp/aodh-d.sh"
  
  dep_delete_check ${AODH_res_name}
  
  info "deleting aodh related pcmk resource..."
  ssh ${NODES[0]} -- pcs resource delete ${AODH_evaluator_res_name}
  ssh ${NODES[0]} -- pcs resource delete ${AODH_notifier_res_name}
  ssh ${NODES[0]} -- pcs resource delete ${AODH_listener_res_name}
  ssh ${NODES[0]} -- pcs resource delete ${AODH_expirer_res_name}

  info "removing aodh-api service..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- rm -f ${AODH_api_wsgi_conf}
  done

  # reload httpd
  for node in "${NODES[@]}"; do
    ssh ${node} -- systemctl reload httpd
  done

  echo "removing ${AODH_haproxy_cfg} for haproxy..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- rm -f ${AODH_haproxy_cfg}
  done

  # re-define haproxy resource
  haproxy_recreate_res
  

  info "removing aodh's endpoints & service from keystone..."
  cat <<-EOF | ssh -T ${NODES[0]} --
	. ~/admin_openrc
	# no need to explicitly delete endpoints, deleting the service automatically also delete related endpoints
	openstack service delete ${AODH_service_type}
	EOF

  info "removing keystone user for aodh..."
  cat <<-EOF | ssh -T ${NODES[0]} --
	. ~/admin_openrc
	openstack user delete ${AODH_keystone_user}
	EOF

  info "dropping aodh database from mariadb..."
  # drop keystone db and remove keystone user, redefine haproxy resource
  echo "drop keystone database and user..."
  ssh ${NODES[0]} -- cat <<-EOF \>${script}
	#!/bin/bash
	echo "dropping aodh db & users..."
	mysql -h${NODES_VIP_ADDRS[1]} -uroot -pqwerty -e "DROP DATABASE IF EXISTS aodh;"
	mysql -h${NODES_VIP_ADDRS[1]} -uroot -pqwerty -e "DROP USER IF EXISTS 'aodh'@'localhost';"
	mysql -h${NODES_VIP_ADDRS[1]} -uroot -pqwerty -e "DROP USER IF EXISTS 'aodh'@'SUBNET_ADDR';"
	EOF
  cat <<-EOF | ssh -T ${NODES[0]} --
	sed -i -e "s/SUBNET_ADDR/${NODES_SUBNET_FOR_MARIADB[1]}/" ${script}
	EOF
  ssh ${NODES[0]} -- chmod +x ${script} \; ${script}

  info "removing aodh pkgs..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- yum -y remove ${AODH_install_pkgs}
  done

  info "removing aodh config & log files..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- rm -rf ${AODH_conf_dir}
    ssh ${node} -- rm -rf ${AODH_log_dir}
    ssh ${node} -- rm -f ${AODH_api_access_log}*
    ssh ${node} -- rm -f ${AODH_api_error_log}*
  done
}

aodh-t() {
  info "testing aodh-api..."

  ssh ${NODES[0]} -- aodh alarm list
  ssh ${NODES[0]} -- aodh capabilities list

}
