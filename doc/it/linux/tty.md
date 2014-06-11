# references

http://en.wikipedia.org/wiki/Pseudo_terminal
http://blog.csdn.net/dbzhang800/article/details/6939742


# terminology

- tty: teletype, a device, of several types, such as serial (/dev/ttyS*), console (/dev/tty*), controlling console (/dev/tty), psedu tty (/dev/pts/*)...
- pty: psedu-tty, a type of tty device, i.e., a psedu tty device
- ptmx: pty master multiplexer, a device file /dev/ptmx representing all master devices from multiple tty pairs
- ptm: pty master (of a pty pair), a logic device represented by a fd returned by open("/dev/ptms")
- pts: pty slave (of a pty pair), a logic device under /dev/pts/, created by open("/dev/ptms")
- console
- vc: virtual console (enter by Ctrl+Alt+F1~6, F7 back), /dev/tty?

# 0. [Pseudo Terminal] (http://en.wikipedia.org/wiki/Pseudo_terminal)

In some operating systems, including Unix, a pseudo terminal is a *pair* of pseudo-devices, one of which, the slave device, emulates a real text terminal device, the other of which, the master device, provides the means by which a terminal emulator process controls the slave device.

- user: local or remote
- tep: terminal emulator process (xterm, konsole, gnome-terminal, telnetd, sshd, script, expect...)
- ptm: master device
- pts: slave device
- app: whose stdin/stdout/stderr are connected to pts (e.g. the login shell)

user <--a--> tep <--b--> ptm <--c--> pts <--d--> shell

communication channels:

a: tcp/ip
b: fd
c: pty driver
d: fd

# 1. tty (终端设备的统称)
　　tty一词源于Teletypes，或者teletypewriters，原来指的是电传打字机，是通过串行线用打印机键盘通过阅读和发送信息的东西，后来这东西被键盘与显示器取代，所以现在叫终端比较合适。

　　终端是一种字符型设备，它有多种类型，通常使用tty来简称各种类型的终端设备。

# 2. pty, ptmx, ptm, pts

　　但是如果我们远程telnet到主机或使用xterm时不也需要一个终端交互么？是的，这就是虚拟终端pty(pseudo-tty)

[Linux man page: pts](http://linux.die.net/man/4/pts)
The file /dev/ptmx is a character file with major number 5 and minor number 2, usually of mode 0666 and owner.group of root.root. It is used to create a pseudoterminal master and slave *pair*.

When a process opens /dev/ptmx, it:
- gets a file descriptor for a pseudoterminal master (PTM), and 
- a pseudoterminal slave (PTS) device is *created* in the /dev/pts/ directory. 

Each file descriptor obtained by opening /dev/ptmx is an independent PTM with its own associated PTS, whose path can be found by passing the descriptor to ptsname(3).


# Linux终端：

　　在Linux系统的设备特殊文件目录/dev/下，终端特殊设备文件一般有以下几种：

## Serial tty (/dev/ttyS*)

## Psedu tty (/dev/ptmx & /dev/pts/*)

　　伪终端(Pseudo Terminal)是成对的逻辑终端设备(即master和slave设备, 对master的操作会反映到slave上)。

　　在使用设备文件系统 (device filesystem)之前，为了得到大量的伪终端设备特殊文件，使用了比较复杂的文件名命名方式。因为只存在16个ttyp(ttyp0—ttypf) 的设备文件，为了得到更多的逻辑设备对，就使用了象q、r、s等字符来代替p。例如，ttys8和ptys8就是一个伪终端设备对。不过这种命名方式目前 仍然在RedHat等Linux系统中使用着。

　　但Linux系统上的Unix98并不使用上述方法，而使用了”pty master multiplexer”方式,/dev/ptmx。它的对应端则会被自动地创建成/dev/pts/3。这样就可以在需要时提供一个pty伪终端。目录 /dev/pts是一个类型为devpts的文件系统，并且可以在被加载文件系统列表中看到。虽然“文件”/dev/pts/3看上去是设备文件系统中的一项，但其实它完全是一种不同的文件系统。

bruin@localhost:/dev$ df -a
文件系统                                                    1K-块       已用      可用 已用% 挂载点
rootfs                                                   22107004    5249544  15734492   26% /
sysfs                                                           0          0         0     - /sys
proc                                                            0          0         0     - /proc
udev                                                        10240          0     10240    0% /dev
devpts                                                          0          0         0     - /dev/pts


　　3、控制终端(/dev/tty)

　　如果当前进程有控制终端(Controlling Terminal)的话，那么/dev/tty就是当前进程的控制终端的设备特殊文件。可以使用命令”ps –ax”来查看进程与哪个控制终端相连。对于你登录的shell，/dev/tty就是你使用的终端，设备号是(5,0)。使用命令”tty”可以查看它 具体对应哪个实际终端设备。/dev/tty有些类似于到实际所使用终端设备的一个联接。

　　4、控制台终端(/dev/ttyn, /dev/console)

　　在Linux 系统中，计算机显示器通常被称为控制台终端 (Console)。它仿真了类型为Linux的一种终端(TERM=Linux)，并且有一些设备特殊文件与之相关联：tty0、tty1、tty2 等。当你在控制台上登录时，使用的是tty1。使用Alt+[F1—F6]组合键时，我们就可以切换到tty2、tty3等上面去。tty1–tty6等 称为虚拟终端，而tty0则是当前所使用虚拟终端的一个别名，系统所产生的信息会发送到该终端上。因此不管当前正在使用哪个虚拟终端，系统信息都会发送到 控制台终端上。你可以登录到不同的虚拟终端上去，因而可以让系统同时有几个不同的会话期存在。只有系统或超级用户root可以向 /dev/tty0进行写操作 即下例：

　　1、# tty(查看当前TTY)

　　/dev/tty1

　　2、#echo "test tty0" > /dev/tty0

　　test tty0

　　5 虚拟终端(/dev/pts/n)

　　在Xwindows模式下的伪终端.

　　6 其它类型

　　Linux系统中还针对很多不同的字符设备存在有很多其它种类的终端设备特殊文件。例如针对ISDN设备的/dev/ttyIn终端设备等。这里不再赘述。