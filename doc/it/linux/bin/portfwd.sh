#!/bin/bash

# http proxy with a socksParentProxy: browser is to be configured to use http proxy at host:8123
ssh -gfNC -D 9999 user@server 
polipo proxyAddress="0.0.0.0" socksParentProxy=localhost:9999 daemonise=true diskCacheRoot=/home/bruin/tmp/polipo logFile=/home/bruin/tmp/polipo/history.log



# install polipo daemon by "apt-get install polipo". then update the config:
ubuntu@ip-172-31-9-247:~/work/xiongyw/doc/it/linux/bin$ cat /etc/polipo/config
# This file only needs to list configuration variables that deviate
# from the default values.  See /usr/share/doc/polipo/examples/config.sample
# and "polipo -v" for variables you can tweak and further information.

logSyslog = true
logFile = /var/log/polipo/polipo.log
proxyPort = 8123
proxyAddress = "::0"
proxyName = "bruin's polipo proxy"
chunkHighMark = 50331648
objectHighMark = 16384
localDocumentRoot = ""
dnsQueryIPv6 = no

# and then restart the polipo:
sudo /etc/init.d/polipo restart

# then configure the proxy for browser to aws-instance:8123 for surfing




# Port forward to a port on the same machine
#   http://askubuntu.com/questions/104824/port-forward-to-a-port-on-the-same-machine
# IT blocks outgoing traffic targetting port 22...so change the default 22 of sshd to 2222 on the public server
#
# [ssh client]  ---->[IT firewall] ----> [public server: 2222 -> 22(sshd)]
#
# the 2nd rule is for ssh from the same host running sshd
cat 1 > /proc/sys/net/ipv4/ip_forward
sudo iptables -t nat -I PREROUTING -p tcp --dport 2222 -j REDIRECT --to-port 22
sudo iptables -t nat -I OUTPUT -p tcp -o lo --dport 2222 -j REDIRECT --to-ports 22

# make rules persistent: https://wiki.debian.org/iptables

