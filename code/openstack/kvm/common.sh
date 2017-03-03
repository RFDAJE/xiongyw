#!/bin/bash

# created(bruin, 2017-03-03)

get_ip_from_host() {
  echo $(ping -c1 $1 | head -n1 | sed "s/.*(\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)).*/\1/g")
}

# arguments:
# 1. target name
# 2. target ip
# 3. root passwd
ssh_copy_id() {
  local name=${1}
  local ip=${2}
  local pass=${3}

  script="/tmp/ssh-copy-id.exp";

  echo "removing history in .ssh/* ..."

  sed -i "/\s${name}\s*$/d" /etc/hosts
  sed -i "$ a ${ip} ${name}" /etc/hosts

  ssh-keygen -f "/root/.ssh/known_hosts" -R ${name}
  ssh-keygen -f "/root/.ssh/known_hosts" -R ${ip}

  echo "running ssh-copy-id to ${name}..."
  cat <<-EOF >${script}
	#!/usr/bin/expect

	set password "${pass}"
	set timeout -1

	spawn ssh-copy-id ${name}
	expect {
	    "(yes/no)?" {
	        send "yes\r"
	        exp_continue
	    }
	    "password:" {
	        send \$password
	        send "\r"
	        exp_continue
	    }
	}
	EOF
	chmod +x ${script}
	${script}
}



ok() {
  echo "--------------------------------------------"
  echo "INFO: $*"
}


info() {
  echo "============================================"
  echo "INFO: $*"
}


warning() {
  echo "############################################"
  echo "WARNING: $*"
}

error() {
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  echo "ERROR: $*"
}
