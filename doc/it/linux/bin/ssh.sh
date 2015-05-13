#!/bin/bash
#
# - create a dedicated tmux session
# - establish the ssh remote port forwarding: (fc13:2000) ==> (localhost:22) 
# - and detach the tmux session
tmux new-session -s "ssh" -d "ssh -R 2000:localhost:22 bruin@fc13"

