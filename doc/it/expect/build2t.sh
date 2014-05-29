#!/usr/bin/expect

# p4 login
spawn p4 login
expect "Enter password:"
send "Sorry12345\r"
expect eof

# checkout
set timeout -1
set p2path "//OTV_OS/Opentv5/DEVELOP/NET/Phase2/"
set buildroot "buildroot/..."
set netcfg "netcfg/..."
set opentv "opentv/..."
set toolchains "toolchains/..."
set otvtarg "otvtarg/..."

spawn p4 sync $p2path$buildroot
expect eof
spawn p4 sync $p2path$netcfg
expect eof
spawn p4 sync $p2path$opentv
expect eof
spawn p4 sync $p2path$otvtarg
expect eof
spawn p4 sync $p2path$toolchains
expect eof

# 2t
set timeout -1
set datetime [exec date +%Y%m%d-%H]
cd ~/work/p4/OTV_OS/Opentv5/DEVELOP/NET/Phase2/otvtarg/humax7430_uclibc_bc
spawn time  make BUILD_TYPE=sdk CONFIG_TYPE=netbrazil_2t 2>&1|tee netbrazil_2t-$datetime.log
expect "password for bruin: "
send "qwerty\r"
expect eof
spawn make BUILD_TYPE=sdk CONFIG_TYPE=netbrazil_2t clean_licmgr clean_sdp_client
spawn make BUILD_TYPE=sdk CONFIG_TYPE=netbrazil_2t LOG_LEVEL=O_TRACE
expect "password for bruin: "
send "qwerty\r"
expect eof



