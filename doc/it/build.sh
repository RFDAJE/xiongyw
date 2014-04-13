#!/usr/bin/expect

set timeout -1
spawn time  make BUILD_TYPE=sdk CONFIG_TYPE=nx_cab 
expect "password for bruin: "
send "qwerty\r"
expect eof

