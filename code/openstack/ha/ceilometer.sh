#!/bin/bash

# created(bruin, 2017-02-08)

CEIL_res_name="ceil-clone"

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

# we don't need "openstack-ceilometer-compute" pkg, which should be installed
# on computer node (as an agent for nova).
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
  info "start ${CEIL_res_name} config..."

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

  
  # create pacemaker resource

  # re-define haproxy

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
	openstack user create ${CEIL_keystone_user} --domain default --password ${CEIL_keystone_pass}
	openstack role add ${CEIL_keystone_role} --project ${CEIL_keystone_project} --user ${CEIL_keystone_user}

	echo "registering endpoints provided by ceilometer..."
	openstack service create --name ${CEIL_service_name} --description "Telemetry" ${CEIL_service_type}
	openstack endpoint create --region ${CEIL_service_region} ${CEIL_service_type} public http://10.0.0.14:8777                                                                 
	openstack endpoint create --region ${CEIL_service_region} ${CEIL_service_type} internal http://10.0.1.14:8777
	openstack endpoint create --region ${CEIL_service_region} ${CEIL_service_type} admin http://10.0.1.14:8777
	EOF
}

# <http://docs.openstack.org/project-install-guide/telemetry/newton/install-base-rdo.html>
_ceil_install_n_config() {


  local conf="/etc/ceilometer/ceilometer.conf"
  
  info "installing ceilometer pkgs..."
  # note that the installation will install several systemd unit files
  # under /usr/lib/systemd/system/...which are not enabled by default
  #
  #ls /usr/lib/systemd/system/openstack-ceilometer-*
  #/usr/lib/systemd/system/openstack-ceilometer-api.service
  #/usr/lib/systemd/system/openstack-ceilometer-central.service
  #/usr/lib/systemd/system/openstack-ceilometer-collector.service
  #/usr/lib/systemd/system/openstack-ceilometer-ipmi.service
  #/usr/lib/systemd/system/openstack-ceilometer-notification.service
  #/usr/lib/systemd/system/openstack-ceilometer-polling.service

  for node in "${NODES[@]}"; do
    ssh ${node} -- yum -y install ${CEIL_install_pkgs}
  done


  info "configuring ceilometer ${conf}..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- cp ${conf} ${conf}.orig
    cat <<-EOF | ssh -T ${node} --
	: [default] section
	sed -i "/^\[DEFAULT/,/^#rpc_backend/s/^#rpc_backend/rpc_backend/" ${conf}
	sed -i "/^\[DEFAULT/a auth_strategy = keystone" ${conf}
	: [database] section
	sed -i "/^\[database/,/^#connection/s|^#connection.*|connection = ${CEIL_mongod_conn_url}|" ${conf}
	: [oslo_messaging_rabbit] section
	: [keystone_authtoken] section
	: [service_credentials] section
	EOF
    # display the neat content again
    info "${conf} content on ${node}:"
    cat <<-EOF | ssh -T ${node} --
	sed -n "/^[^#\ ].*/p" ${conf}
	EOF
  done  
}


ceil-d() {
  info "removing ${CEIL_res_name} resource..."

  dep_delete_check ${CEIL_res_name}
  
  info "deleting ${CEIL_res_name} resource..."
  ssh ${NODES[0]} -- pcs resource delete ${CEIL_res_name}

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

  # todo

}

ceil-t() {
  info "testing ${CEIL_res_name}..."

  # todo
}

ceil-r() {
  ceil-d
  ceil
}
