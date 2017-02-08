#!/bin/bash

# created(bruin, 2017-01-24)

get_ip_from_host() {
  echo $(ping -c1 $1 | head -n1 | sed "s/.*(\([0-9]*\.[0-9]*\.[0-9]*\.[0-9]*\)).*/\1/g")
}


