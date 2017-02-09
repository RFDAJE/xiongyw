#!/bin/bash

# created(bruin, 2017-02-08)

CEIL_res_name="ceil-clone"



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

# create user/role/service/endpoint
_ceil_prepare_keystone() {
  :
}


_ceil_install_n_config() {
  :
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

  # todo

}

ceil-t() {
  echo "testing ${CEIL_res_name}..."

  # todo
}

