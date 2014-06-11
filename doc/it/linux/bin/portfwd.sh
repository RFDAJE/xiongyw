#!/bin/bash

# http proxy with a socksParentProxy: browser is to be configured to use http proxy at host:8123
ssh -gfNC -D 9999 user@server 
polipo proxyAddress="0.0.0.0" socksParentProxy=localhost:9999 daemonise=true diskCacheRoot=/home/bruin/tmp/polipo logFile=/home/bruin/tmp/polipo/history.log
