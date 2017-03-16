#!/bin/bash

# created(bruin, 2017-03-15): scripts to run ansible

usage() {
  cat <<-EOF
	usage: # $(basename $0) <site> <playbook> [tags]
          site: home|wukuang|wukuang-qa
          playbook: ctl|ptl|gw|hot|warm
          tags (optional): test|remove
	EOF
}




#####################################################
# do the work...
#####################################################
main () {
  if [[ $(id -u) != 0 ]]; then
      echo "This script must be run by root, please try it with sudo."
      exit 1;
    fi

    if [[ $# < 2 ]]; then
       usage
       exit 1;
    fi
 
    local site=${1}
    local book=${2}
    local tags=${3}

    if [ -z ${tags} ]; then
      ansible-playbook -vvv -i inventories/${site} ${book}.yml
    else
      ansible-playbook -vvv -i inventories/${site} ${book}.yml --tags ${3}
    fi
}

main $*
