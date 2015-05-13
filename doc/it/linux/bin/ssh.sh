#!/bin/bash
#
# http://blog.csdn.net/xyw_blog/article/details/30105533
#
# destination <-- |NAT| <-- source <-- client
# 
# To enable 'client' to ssh to 'destination' which is behind the NAT (gw and/or firewall),
# a ssh tunnel is to be established between 'destionation' and 'source', where 'source' can
# be accessed from client directly.
# once the tunnel (remote port forwarding, or reverse ssh tunneling) is established, 'client' 
# can access 'destionation' in two steps:
# 1. ssh to 'source'
# 2. ssh to 'destination', by 'ssh localhost -p 2000' from 'source'


#
# - create a dedicated tmux session
# - establish the ssh remote port forwarding: (fc13:2000) ==> (localhost:22) 
# - and detach the tmux session
tmux new-session -s "ssh" -d "ssh -R 2000:localhost:22 bruin@fc13"




