#!/usr/bin/expect

set password "xy123456"

set timeout -1

#
# otv5 foss packages
#
spawn rsync -varh ywxiong@mtv-lnx-131.hq.k.grp:/nfs/opentv/Comet/buildroot/dl  /nfs/opentv/Comet/buildroot
expect "assword:"
send $password
send "\r"
expect eof

#
# net daily build
#
spawn rsync -varh ywxiong@mtv-lnx-131.hq.k.grp:/nfs/opentv/Opentv5.1.2/daily_net  /nfs/opentv/Opentv5.1.2
expect "assword:"
send $password
send "\r"
expect eof


#
# net p2 build
#
spawn rsync -varh ywxiong@mtv-lnx-131.hq.k.grp:/nfs/opentv/Opentv5.1.2/BLD_2_1_net_p2  /nfs/opentv/Opentv5.1.2
expect "assword:"
send $password
send "\r"
expect eof

#
# net p2 mw engineering build
#
spawn rsync -varh ywxiong@mtv-lnx-131.hq.k.grp:/nfs/Opentv4/zinfandel/BLD_2_0_net_p2  /nfs/Opentv4/zinfandel
expect "assword:"
send $password
send "\r"
expect eof

#
# net p2 mw engineering build, again
#
spawn rsync -varh ywxiong@mtv-lnx-131.hq.k.grp:/nfs/public/NET_Phase2/Engineering  /nfs/public/NET_Phase2
expect "assword:"
send $password
send "\r"
expect eof

#
# gravity release
# 
spawn rsync -varh ywxiong@otvftp.opentv.com:/nfs/public/ftp163/gravity_release /nfs/public/ftp163
expect "assword:"
send $password
send "\r"
expect eof
