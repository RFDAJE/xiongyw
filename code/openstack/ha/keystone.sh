#!/bin/bash

# created(bruin, 2017-01-17)

KEYSTONE_haproxy_cfg="/etc/haproxy/keystone.cfg"
KEYSTONE_res_name="httpd-clone"
KEYSTONE_res_name_short="httpd"

# bootstrap project/role/user
KEYSTONE_bootstrap_project="admin"
KEYSTONE_bootstrap_user="admin"
KEYSTONE_bootstrap_pass="qwerty"
KEYSTONE_bootstrap_role="admin"
KEYSTONE_bootstrap_region="RegionOne"
KEYSTONE_bootstrap_service="keystone"
KEYSTONE_admin_url="http://${NODES_VIP_ADDRS[1]}:35357/v3/"
KEYSTONE_internal_url="http://${NODES_VIP_ADDRS[1]}:35357/v3/"
KEYSTONE_public_url="http://${NODES_VIP_ADDRS[0]}:5000/v3/"
# http://adam.younglogic.com/2016/06/auth_uri-vs-auth_url/
KEYSTONE_public_uri="http://${NODES_VIP_ADDRS[0]}:5000/"


# the project name for other openstack services
KEYSTONE_service_project="service"
# the default domain name/id
KEYSTONE_domain_name="Default"
KEYSTONE_domain_id="default"

KEYSTONE_conf_dir="/etc/keystone"
KEYSTONE_httpd_conf_dir="/etc/httpd"
KEYSTONE_log_dir="/var/log/keystone"
KEYSTONE_httpd_log_dir="/var/log/httpd"

KEYSTONE_fernet_keys_dir="/etc/keystone/fernet-keys"
KEYSTONE_credential_keys_dir="/etc/keystone/credential-keys"

keystone() {

  echo "start keystone HA config..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${KEYSTONE_res_name}
  if [ $? = 0 ]; then
    echo "info: ${KEYSTONE_res_name} resource already exist!"
    return 0;
  fi

  dep_install_check ${KEYSTONE_res_name}
  
  _keystone_create_db_n_account

  _keystone_install_n_config

  _keystone_bootstrap


  echo "defining resource httpd-clone..."
  ssh ${NODES[0]} -- pcs resource create ${KEYSTONE_res_name_short} systemd:httpd --clone

  _keystone_haproxy_config

  _keystone_create_domain_n_project
}

_keystone_create_db_n_account() {
  local script="/tmp/keystone1.sh"
  # prepare mariadb: create keystone db and account
  # we ssh to one of the nodes is to ensure that mysql binary is available.
  ssh ${NODES[0]} -- cat<<-EOF \>${script}
	#!/bin/bash
	echo "creating keystone database and account..."
	mysql -hVIP_NAME -uroot -pqwerty -e "CREATE DATABASE keystone;"
	mysql -hVIP_NAME -uroot -pqwerty -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'qwerty';"
	mysql -hVIP_NAME -uroot -pqwerty -e "GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'SUBNET_ADDR' IDENTIFIED BY 'qwerty';"
	EOF
  cat <<-EOF | ssh -T ${NODES[0]} --
	sed -i -e "s/VIP_NAME/${NODES_VIP_NAMES[1]}/" -e "s/SUBNET_ADDR/${NODES_SUBNET_FOR_MARIADB[1]}/" ${script}
	EOF
  ssh ${NODES[0]} -- chmod +x ${script} \; ${script}
}

_keystone_install_n_config() {
  local script2="/tmp/keystone2.sh"
  local node=""
  local ips=""

  # on each node: install keystone/apache and config them
  for idx in "${!NODES[@]}"; do
    node=${NODES[$idx]}
    ips=( ${NODES_IP_ADDRS[$idx]} )
    ssh ${node} -- yum -y install openstack-keystone httpd mod_wsgi python-openstackclient

    ssh ${node} -- cat<<-EOF \>${script2}
		#!/bin/bash
		echo "configuring keystone..."
		# config keystone;  keystone does not rely on rabbitmq, so we omit that part.
		sed -i.bak '{
			/^\[database/,/^#connection/s|^#connection.*$|connection = mysql+pymysql://keystone:qwerty@${NODES_VIP_ADDRS[1]}/keystone|
			/^\[token/,/^#provider/s/^#provider.*$/provider = fernet/
		}' /etc/keystone/keystone.conf

		# note that fernet keys must be idential on all nodes of the cluster
		#echo "initializing fernet key repository..."
		#keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
		#keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

		echo "configuring apache..."
		sed -i.bak "/^#ServerName.*/cServerName\ ${node}:80" /etc/httpd/conf/httpd.conf
		ln -s /usr/share/keystone/wsgi-keystone.conf /etc/httpd/conf.d/
		# don't let apache bind on VIPs, otherwise haproxy may fail
		# note: 35357 port should be on internal IP@
		sed -i.bak -e "/Listen 5000/cListen ${ips[0]}:5000" -e "/Listen 35357/cListen ${ips[1]}:35357" /usr/share/keystone/wsgi-keystone.conf
		EOF
    ssh ${node} -- chmod +x ${script2} \; ${script2}

    # add environment varialbes for CLI tool 'openstack'
    ssh ${node} -- cat<<-'EOF' \>~/admin_openrc
	export OS_USERNAME=admin
	export OS_PASSWORD=qwerty
	export OS_PROJECT_NAME=admin
	export OS_USER_DOMAIN_NAME=Default
	export OS_PROJECT_DOMAIN_NAME=Default
	# note that the IP@ in the url should be exactly the same one as used
	# in bootstrap step (which is registered in db). in our case, the ip@
	# is the mgmt VIP. otherwise, cmds such as "openstack service list"
	# will fail, complaining "The request you have made requires authentication. (HTTP 401)..."
	# this clue is tracked by using --debug option of openstack cmd.
	export OS_AUTH_URL=http://IP_ADDRESS:35357/v3
	export OS_IDENTITY_API_VERSION=3
	EOF
    cat <<-EOF | ssh -T ${node} --
		sed -i -e "s/IP_ADDRESS/${NODES_VIP_ADDRS[1]}/" ~/admin_openrc
	EOF
    ssh ${node} -- cat ~/admin_openrc \>\>/etc/profile

    # disable apache by default
    ssh ${node} -- systemctl stop httpd
    ssh ${node} -- systemctl disable httpd
  done

  info "preparing fernet-keys and credential-keys repository..."
  ssh ${NODES[0]} -- keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
  ssh ${NODES[0]} -- keystone-manage credential_setup --keystone-user keystone --keystone-group keystone
  scp -r ${NODES[0]}:${KEYSTONE_fernet_keys_dir} /tmp
  scp -r ${NODES[0]}:${KEYSTONE_credential_keys_dir} /tmp
  for node in "${NODES[@]:1}"; do
    scp -r /tmp/${KEYSTONE_fernet_keys_dir##/*/} ${node}:/etc/keystone
    scp -r /tmp/${KEYSTONE_credential_keys_dir##/*/} ${node}:/etc/keystone
    ssh ${node} -- chown -R keystone:keystone ${KEYSTONE_fernet_keys_dir}
    ssh ${node} -- chown -R keystone:keystone ${KEYSTONE_credential_keys_dir}
  done
}

# <http://docs.openstack.org/developer/keystone/configuration.html#bootstrapping-keystone-with-keystone-manage-bootstrap>
_keystone_bootstrap () {
  local script3="/tmp/keystone3.sh"
  # populate the keystone db and bootstrap the service
  ssh ${NODES[0]} -- cat<<-EOF \>${script3}
	#!/bin/bash
	
	echo "populating keystone db..."
	su -s /bin/sh -c "keystone-manage db_sync" keystone
	
	# bootstrap the identity service. 
	#
	# This will create "default" domain, and an admin user with the admin role on the
	# admin project. Both the user and the project will be created in the "default" domain.
	# By creating an admin user and an identity endpoint, deployers may authenticate
	# to keystone and perform identity operations like creating additional services
	# and endpoints using that admin user.
	
	# The command will also create an identity service with the specified endpoint
	# information. Note that the identity service endpoints use VIPs.
	echo "bootstrapping keystone service..."
	: keystone-manage bootstrap --bootstrap-password qwerty \
	                          --bootstrap-admin-url    http://VIP_MGMT:35357/v3/ \
	                          --bootstrap-internal-url http://VIP_MGMT:35357/v3/ \
	                          --bootstrap-public-url   http://VIP_EXT:5000/v3/ \
	                          --bootstrap-region-id RegionOne
	
	keystone-manage bootstrap --bootstrap-username ${KEYSTONE_bootstrap_user} \
	                          --bootstrap-password ${KEYSTONE_bootstrap_pass} \
	                          --bootstrap-project-name ${KEYSTONE_bootstrap_project} \
	                          --bootstrap-role-name ${KEYSTONE_bootstrap_role} \
	                          --bootstrap-service-name ${KEYSTONE_bootstrap_service} \
	                          --bootstrap-admin-url    ${KEYSTONE_admin_url} \
	                          --bootstrap-internal-url ${KEYSTONE_internal_url} \
	                          --bootstrap-public-url   ${KEYSTONE_public_url} \
	                          --bootstrap-region-id    ${KEYSTONE_bootstrap_region}
	EOF
  cat <<-EOF | ssh -T ${NODES[0]} --
	sed -i -e "s/VIP_MGMT/${NODES_VIP_ADDRS[1]}/g" -e "s/VIP_EXT/${NODES_VIP_ADDRS[0]}/g" ${script3}
	EOF
  ssh ${NODES[0]} -- chmod +x ${script3} \; ${script3}
}

_keystone_haproxy_config() {
  local tmp_cfg="/tmp/keystone.cfg"
  local node=""
  local ips=""

  # update haproxy config on each node, and restart haproxy resource
  echo "creating /etc/haproxy/keystone.cfg..."
  >${tmp_cfg}
  # keystone_admin: mgmt subnet
  cat <<-EOF >> ${tmp_cfg}
	listen keystone_admin
	  bind ${NODES_VIP_ADDRS[1]}:35357
	  balance  source
	  option  tcpka
	  option  httpchk
	  option  tcplog
	EOF
  for idx in "${!NODES[@]}"; do
    node=${NODES[${idx}]}
    ips=( ${NODES_IP_ADDRS[${idx}]} )
    cat <<-EOF >> ${tmp_cfg}
	  server ${node}${MGMT_SUFFIX} ${ips[1]}:35357 check inter 2000 rise 2 fall 5
	EOF
  done

  # keystone_public: external subnet
  cat <<-EOF >> ${tmp_cfg}
	listen keystone_public
	  bind ${NODES_VIP_ADDRS[0]}:5000
	  balance  source
	  option  tcpka
	  option  httpchk
	  option  tcplog
	EOF
  for idx in "${!NODES[@]}"; do
    node=${NODES[${idx}]}
    ips=( ${NODES_IP_ADDRS[${idx}]} )
    cat <<-EOF >> ${tmp_cfg}
	  server ${node} ${ips[0]}:5000 check inter 2000 rise 2 fall 5
	EOF
  done

  # copy tmp cfg to each node
  for node in "${NODES[@]}"; do
    scp ${tmp_cfg} ${node}:${KEYSTONE_haproxy_cfg}
  done

  # re-define haproxy resource
  haproxy_recreate_res
}

# use openstack CLI to create additional project "service" for other openstack components.
# see <http://docs.openstack.org/developer/keystone/configuration.html#id1>
#
# the CLI uses the endpoint specified in admin_openrc...so the endpoint should
# be available, that's why this step must happen after haproxy is correctly
# configured for keystone.
_keystone_create_domain_n_project() {

  echo "creating service project for openstack services..."
  cat <<-EOF | ssh -T ${NODES[0]} -- 
	. ~/admin_openrc
	openstack project create ${KEYSTONE_service_project} --domain ${KEYSTONE_domain_name} --description "Service Project"
	EOF
}


# delete keystone resource completely
keystone-d() {
  local script="/tmp/keystone0.sh"
  local script2="/tmp/db0.sh"

  echo "removing keystone HA config..."

  dep_delete_check ${KEYSTONE_res_name}
  
  # check if the resource exist
  ssh ${NODES[0]} -- pcs resource show ${KEYSTONE_res_name}
  if [ $? != 0 ]; then
    echo "WARNING: httpd-clone resource does not exist!"
  else
    echo "deleting httpd-clone resource..."
    ssh ${NODES[0]} -- pcs resource delete ${KEYSTONE_res_name}
  fi

  # uninstall keystone packages on each node
  for node in "${NODES[@]}"; do
    ssh ${node} -- cat<<-EOF \>${script}
	#!/bin/bash
	echo "removing openstack-keystone httpd mod_wsgi packages..."
	unlink /etc/httpd/conf.d/wsgi-keystone.conf
	yum -y remove openstack-keystone httpd mod_wsgi
	rm -rf ${KEYSTONE_conf_dir}
	rm -rf ${KEYSTONE_httpd_conf_dir}
	rm -rf ${KEYSTONE_log_dir}
	rm -rf ${KEYSTONE_httpd_log_dir}
	echo "deleting environment variables in /etc/profile..."
	rm -f ~/admin_openrc
	sed -i.bak '/OS_USERNAME/,+6d' /etc/profile
	EOF
    ssh ${node} -- chmod +x ${script} \; ${script}
  done

  # drop keystone db and remove keystone user, redefine haproxy resource
  echo "drop keystone database and user..."
  ssh ${NODES[0]} -- cat <<-EOF \>${script2}
	#!/bin/bash
	echo "dropping keystone db & users..."
	mysql -h${NODES_VIP_ADDRS[1]} -uroot -pqwerty -e "DROP DATABASE IF EXISTS keystone;"
	#mysql -h${NODES_VIP_ADDRS[1]} -uroot -pqwerty -e "DELETE FROM mysql.user WHERE User='keystone';"
	mysql -h${NODES_VIP_ADDRS[1]} -uroot -pqwerty -e "DROP USER IF EXISTS 'keystone'@'localhost';"
	mysql -h${NODES_VIP_ADDRS[1]} -uroot -pqwerty -e "DROP USER IF EXISTS 'keystone'@'SUBNET_ADDR';"
	EOF
  cat <<-EOF | ssh -T ${NODES[0]} --
	sed -i -e "s/SUBNET_ADDR/${NODES_SUBNET_FOR_MARIADB[1]}/" ${script2}
	EOF
  ssh ${NODES[0]} -- chmod +x ${script2} \; ${script2}

  # remove haproxy cfg for keystone
  echo "removing ${KEYSTONE_haproxy_cfg}..."
  for node in "${NODES[@]}"; do
    ssh ${node} -- rm -f ${KEYSTONE_haproxy_cfg}
  done

  # re-define haproxy resource
  haproxy_recreate_res
}

# testing keystone ha
keystone-t() {
  echo "testing keystone public endpoint..."

  ssh ${NODES[0]} -- set -x \; curl http://${NODES_VIP_ADDRS[0]}:5000/ \| python -mjson.tool

  echo "testing keystone admin endpoint..."
  cat <<-EOF | ssh -T ${NODES[0]} --
	curl http://${NODES_VIP_ADDRS[1]}:35357/ | python -mjson.tool
	EOF

  echo "domain list:"
  ssh ${NODES[0]} -- . ~/admin_openrc \; openstack domain list
  echo "project list --domain default:"
  ssh ${NODES[0]} -- . ~/admin_openrc \; openstack project list --domain ${KEYSTONE_domain_name}
  echo "user list --domain default --project service:"
  ssh ${NODES[0]} -- . ~/admin_openrc \; openstack user list --domain ${KEYSTONE_domain_name} --project ${KEYSTONE_service_project}
}

# re-install keystone
keystone-r() {
  keystone-d
  keystone
}
