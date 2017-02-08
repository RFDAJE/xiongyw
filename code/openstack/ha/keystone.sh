#!/bin/bash

# created(bruin, 2017-01-17)

KEYSTONE_haproxy_cfg="/etc/haproxy/keystone.cfg"
KEYSTONE_res_name="httpd-clone"
KEYSTONE_res_name_short="httpd"


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

		echo "initializing fernet key repository..."
		keystone-manage fernet_setup --keystone-user keystone --keystone-group keystone
		keystone-manage credential_setup --keystone-user keystone --keystone-group keystone

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
}

_keystone_bootstrap () {
  local script3="/tmp/keystone3.sh"
  # populate the keystone db and bootstrap the service
  ssh ${NODES[0]} -- cat<<-EOF \>${script3}
	#!/bin/bash
	echo "populating keystone db..."
	# populate the identity service database, once.
	su -s /bin/sh -c "keystone-manage db_sync" keystone
	echo "bootstrapping keystone service..."
	# bootstrap the identity service, once. use VIPs
	keystone-manage bootstrap --bootstrap-password qwerty \
	                          --bootstrap-admin-url    http://VIP_MGMT:35357/v3/ \
	                          --bootstrap-internal-url http://VIP_MGMT:35357/v3/ \
	                          --bootstrap-public-url   http://VIP_EXT:5000/v3/ \
	                          --bootstrap-region-id RegionOne
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
  set -x
  for node in "${NODES[@]}"; do
    scp ${tmp_cfg} ${node}:${KEYSTONE_haproxy_cfg}
  done
  set +x

  # re-define haproxy resource
  haproxy_recreate_res
}

_keystone_create_domain_n_project() {
  local script4="/tmp/keystone4.sh"
  # create domain/project/user/role...
  ssh ${NODES[0]} -- cat<<-EOF \>${script4}
	#!/bin/bash

	. ~/admin_openrc

	echo "creating domain, project, user, role..."
	set -x
	# service project is for all openstack components
	openstack project create --domain default --description "Service Project" service
	# project specific domain/project/user/role
	openstack domain create --description "ehualu domain" ehualu
	openstack project create --domain ehualu --description "OceanRay Project" oceanray
	openstack user create --domain ehualu --project oceanray --password qwerty admin
	openstack role create --domain ehualu admin
	openstack role add --domain ehualu --user admin admin
	EOF
  ssh ${NODES[0]} -- chmod +x ${script4} \; . ~/admin_openrc \; ${script4}
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
	rm -rf /etc/keystone
	rm -rf /etc/httpd
	rm -f ~/admin_openrc
	echo "deleting environment variables in /etc/profile..."
	sed -i.bak '/OS_USERNAME/,+6d' /etc/profile
	echo "removing haproxy cfg file..."
	rm -f ${KEYSTONE_haproxy_cfg}
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
  ssh ${NODES[0]} -- . ~/admin_openrc \; openstack project list --domain default
  echo "project list --domain ehualu:"
  ssh ${NODES[0]} -- . ~/admin_openrc \; openstack project list --domain ehualu
  echo "user list --domain default --project service:"
  ssh ${NODES[0]} -- . ~/admin_openrc \; openstack user list --domain default --project service
  echo "user list --domain ehualu --project oceanray:"
  ssh ${NODES[0]} -- . ~/admin_openrc \; openstack user list --domain ehualu --project oceanray
  echo "role list --domain ehualu:"
  ssh ${NODES[0]} -- . ~/admin_openrc \; openstack role list --domain ehualu
}
