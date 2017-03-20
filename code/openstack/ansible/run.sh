#!/bin/bash


# created(bruin, 2017-03-15): scripts to run ansible

usage() {
  cat <<-EOF
	usage: # $(basename $0) [-v] <site> <playbook> [tags]
          site: home|wukuang|wukuang-qa
          playbook: ctl[-d]|ptl|gw|hot|warm
          tags (optional): pacemaker|...
	e.g.:
	 install ctl cluster: sudo ./run.sh home ctl
         install pacemaker on ctl cluster: sudo ./run.sh home ctl pacemaker
         delete pacemaker on ctl cluster: sudo ./run.sh home ctl-d pacemaker
	EOF
}

main () {
  local verbose=0
  local args=""

  if [[ $(id -u) != 0 ]]; then
      echo "This script must be run by root, please try it with sudo."
      exit 1;
  fi

  if [[ $# < 2 ]]; then
     usage
     exit 1;
  fi

  if [[ $1 == '-v' ]]; then
     verbose=1
     args+=" -vvv"
     shift
  fi
 
  local site=${1}
  local book=${2}
  local tags=${3}

  args+=" -i inventories/${site} ${book}.yml"

  if [[ -n ${tags} ]]; then
    args+=" --tags ${tags}"
  fi
 
  ansible-playbook ${args}
    
}

main $*
