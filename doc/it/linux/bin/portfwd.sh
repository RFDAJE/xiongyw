#!/bin/bash

# http proxy with a socksParentProxy: browser is to be configured to use http proxy at host:8123
ssh -gfNC -D 9999 user@server 
polipo proxyAddress="0.0.0.0" socksParentProxy=localhost:9999 daemonise=true diskCacheRoot=/home/bruin/tmp/polipo logFile=/home/bruin/tmp/polipo/history.log



# aws ubuntu instance has polipo daemon setup by default. only need to update the config:
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
