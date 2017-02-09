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
  echo "start ${CEIL_res_name} config..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${CEIL_res_name}
  if [[ $? = 0 ]]; then
    echo "info: ${CEIL_res_name} resource already exist!"
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
  echo "preparing mongodb database & user..."
  # note that the user is added into "admin"->"Users"
  cat <<-EOF | ssh -T ${NODES[0]} --
	mongo "${MONGOD_conn_url}" --eval 'db=db.getSiblingDB("ceilometer"); db.createUser({user:"ceilometer", pwd:"qwerty", roles:[ "readWrite","dbAdmin" ]})'
	EOF
}


_ceil_prepare_keystone() {
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


_ceil_install_n_config() {
  echo "installing ceilometer pkgs..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- yum -y install ${CEIL_install_pkgs}
  done

  echo "configuring ceilometer components..."
  # 
}


ceil-d() {
  echo "removing ${CEIL_res_name} resource..."

  dep_delete_check ${CEIL_res_name}
  
  echo "deleting ${CEIL_res_name} resource..."
  ssh ${NODES[0]} -- pcs resource delete ${CEIL_res_name}

  echo "removing mongodb database ceilometer..."
  # https://docs.mongodb.com/manual/reference/command/dropDatabase/
  cat <<-EOF | ssh -T ${NODES[0]} --
	mongo "${MONGOD_conn_url}" --eval 'db=db.getSiblingDB("ceilometer"); db.runCommand({dropDatabase:1})'
	EOF

  echo "removing mongodb user ceilometer..."
  cat <<-EOF | ssh -T ${NODES[0]} --
	mongo "${MONGOD_conn_url}" --eval 'db=db.getSiblingDB("ceilometer"); db.dropUser("ceilometer")'
	EOF

  echo "removing ceilometer's endpoints & service from keystone..."
  cat <<-EOF | ssh -T ${NODES[0]} --
	. ~/admin_openrc
	# no need to explicitly delete endpoints, deleting the service automatically also delete related endpoints
	# openstack endpoint list -c "ID" -f value --service ${CEIL_service_type} --region ${CEIL_service_region}
	# openstack endpoint delete ...
	openstack service delete ${CEIL_service_type}
	EOF

  echo "removing keystone user for ceilometer..."
  cat <<-EOF | ssh -T ${NODES[0]} --
	. ~/admin_openrc
	openstack user delete ${CEIL_keystone_user}
	EOF

  echo "removing ceilometer pkgs..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- yum -y remove ${CEIL_install_pkgs}
  done


  # todo

}

ceil-t() {
  echo "testing ${CEIL_res_name}..."

  # todo
}

ceil-r() {
  ceil-d
  ceil
}
