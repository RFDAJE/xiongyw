# How it works?

## Controlling terminal, daemon, SIGHUP
[How to daemonize a process](http://world.std.com/~swmcd/steven/tech/daemon.html)
+ A daemon does not need the following 3 things provided from a controlling terminal:
  - input: no need for daemon
  - output: no need for daemon
  - signal: to be *avoided* for daemon, especially the SIGHUP signal which is sent to a process when the connection of its controlling terminal is broken.

[An Introduction to Terminal Multiplexing with GNU Screen](http://omniti.com/seeds/an-introduction-to-terminal-multiplexing-with-gnu-screen)
One of the problems the terminal multiplexer addresses is the "connection broken" situation:
- modem connection broken between the user and the terminal driver (plus line decipline), or
- tcp/ip connection broken between ssh/telnet client and the sshd/telnetd (which are terminal emulator process).




# the current shell and its pty

bruin@localhost:~$ echo $$
13246
bruin@localhost:~$ ps x |tail -3
13246 pts/0    Ss     0:00 bash
14237 pts/0    R+     0:00 ps x
14238 pts/0    S+     0:00 tail -3
bruin@localhost:~$ 

* the shell pid is 13246
* its associated pty is pts/0


# after executing tmux once from within the shell

bruin@localhost:~$ ps x|tail -6
13246 pts/0    Ss     0:00 bash
14243 pts/0    S+     0:00 tmux
14245 ?        Ss     0:00 tmux
14246 pts/1    Ss     0:00 -bash
14334 pts/1    R+     0:00 ps x
14335 pts/1    S+     0:00 tail -6

bruin@localhost:~$ ls -la /tmp/tmux-1000/
srwxrwx---  1 bruin bruin    0  4月 11 23:31 default
bruin@localhost:~$ file /tmp/tmux-1000/default 
/tmp/tmux-1000/default: socket

bruin@localhost:~$ lsof /tmp/tmux-1000/default 
COMMAND   PID  USER   FD   TYPE             DEVICE SIZE/OFF   NODE NAME
tmux    14245 bruin    7u  unix 0xffff88010046e480      0t0 294883 /tmp/tmux-1000/default

two tmux processes are created:

* the server tmux, pid 14245, a child of init, w/o pty
* the client tmux, pid 14243, a child of the previous shell (13246), with the same pty (pts/0)
* and we are in a new shell (pid 14246 with a new pty pts/1), a child of the server tmux. A `-` in '-bash' probably means it's a login shell. 


           1     init
?       14245      \_ tmux
pts/1  14246           \_ -bash

pts/0  13246          \_ bash
pts/0  14243               \_ tmux


