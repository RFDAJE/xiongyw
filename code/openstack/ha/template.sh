#!/bin/bash

# created(bruin, 2017-02-08)

XXX_res_name="xxx-clone"

xxx() {
  echo "start ${XXX_res_name} config..."

  # check if the resource already exist
  ssh ${NODES[0]} -- pcs resource show ${XXX_res_name}
  if [[ $? = 0 ]]; then
    echo "info: ${XXX_res_name} resource already exist!"
    return 0;
  fi

  dep_install_check ${XXX_res_name}

  # todo
}

xxx-d() {
  echo "removing ${XXX_res_name} resource..."

  dep_delete_check ${XXX_res_name}
  
  echo "deleting ${XXX_res_name} resource..."
  ssh ${NODES[0]} -- pcs resource delete ${XXX_res_name}

  # todo

}

xxx-t() {
  echo "testing ${XXX_res_name}..."

  # todo
}
