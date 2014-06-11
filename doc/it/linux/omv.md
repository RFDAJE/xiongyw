high-level steps:

- usb iso install
- apt-get update/upgrade
- omv-extras install
- gparted iso
- ghost
- zfs
- kvm
- ghost
- X & miscs
- zpool create





basics: dpkg/apt/apt-cache/apt-file/aptitue

- update apt db: apt-get update
- upgrade: apt-get upgrade
- distro upgrade: apt-get dist-upgrade

- list all pkgs: dpkg -l apt
- list pkg files: dpkg -L apt
- search pkg by keyword: apt-cache search linux-sources-`uname -r`
- check pkg deps: apt-cache depends debian-zfs
- check pkg rdeps: apt-cache rdepends debian-zfs
- show pkg info: apt-cache show debian-zfs
- find file belongs to which pkg: apt-file search `which apt-cache` 
- aptitude/synaptic




omv-extras: http://omv-extras.org/simple/index.php?id=how-to-install-omv-extras-plugin
- wget http://omv-extras.org/debian/pool/main/o/openmediavault-omvextrasorg/openmediavault-omvextrasorg_0.5.39_all.deb
- dpkg -i openmediavault-omvextrasorg_0.5.39_all.deb
- apt-get update




omv plugins: http://songming.me/openmediavault-plexmediaserver-setup.html
uuid: https://wiki.debian.org/Part-UUID




1. first install via usb iso
[list]
[*] (optional) disable serial port to boot: http://www.overclock.net/t/1423729/cant-get-openmediavault-debian-installer-to-boot
[*] default install and reboot
[*] log into webgui by "admin/openmediavault" 
[*] do the following in webgui:
	[list]
	[*] change passwd for web "admin": system->general settings->web administrator passwd
	[*] config ip@: system->network
	[*]	add user: access right mgmt->users
	[*]	enable sshd: services->ssh
	[/list]	 
[*] login via ssh
[code]
bruin@u1310:~$ ssh 192.168.122.143
bruin@192.168.122.143's password: 
Linux ovm32 2.6.32-5-486 #1 Fri May 10 08:01:28 UTC 2013 i686

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
Last login: Sun Mar 30 20:03:10 2014 from 192.168.122.1
Could not chdir to home directory /home/bruin: No such file or directory
bruin@ovm32:/$ 
bruin@ovm32:/$ sudo mkdir /home/bruin

We trust you have received the usual lecture from the local System
Administrator. It usually boils down to these three things:

    #1) Respect the privacy of others.
    #2) Think before you type.
    #3) With great power comes great responsibility.

[sudo] password for bruin: 
bruin@ovm32:/$ sudo chown -R bruin /home/bruin
bruin@ovm32:/$ 
bruin@ovm32:/$ uname -a
Linux ovm32 2.6.32-5-486 #1 Fri May 10 08:01:28 UTC 2013 i686 GNU/Linux
bruin@ovm32:/$ df -ha
文件系统	      容量  已用  可用 已用%% 挂载点
/dev/vda1             7.6G  738M  6.5G  11% /
tmpfs                1013M     0 1013M   0% /lib/init/rw
proc                     0     0     0   -  /proc
sysfs                    0     0     0   -  /sys
udev                 1008M  132K 1008M   1% /dev
tmpfs                1013M     0 1013M   0% /dev/shm
devpts                   0     0     0   -  /dev/pts
tmpfs                1013M   12K 1013M   1% /tmp
bruin@ovm32:/$ 
bruin@ovm32:~$ dpkg -l >pkg.list.0
bruin@ovm32:~$ wc -l pkg.list.0
300 pkg.list.0
bruin@ovm32:~$
bruin@ovm32:~$ sudo cp -a /etc/apt apt.0
bruin@ovm32:~$ find apt.0
apt.0
apt.0/trusted.gpg.d
apt.0/preferences.d
apt.0/preferences.d/99openmediavault-local
apt.0/apt
apt.0/apt/trusted.gpg.d
apt.0/apt/preferences.d
apt.0/apt/preferences.d/99openmediavault-local
apt.0/apt/trusted.gpg
apt.0/apt/trustdb.gpg
apt.0/apt/apt.conf
apt.0/apt/sources.list
apt.0/apt/sources.list.d
apt.0/apt/sources.list.d/openmediavault-local.list
apt.0/apt/sources.list.d/openmediavault.list
apt.0/apt/sources.list~
apt.0/apt/apt.conf.d
apt.0/apt/apt.conf.d/00recommends
apt.0/apt/apt.conf.d/00trustcdrom
apt.0/apt/apt.conf.d/70debconf
apt.0/apt/apt.conf.d/01autoremove
apt.0/apt/apt.conf.d/00CDMountPoint
apt.0/apt/secring.gpg
apt.0/apt/preferences
apt.0/apt.conf
apt.0/sources.list
apt.0/sources.list.d
apt.0/sources.list.d/openmediavault-local.list
apt.0/sources.list.d/openmediavault.list
apt.0/sources.list~
apt.0/apt.conf.d
apt.0/apt.conf.d/00recommends
apt.0/apt.conf.d/00trustcdrom
apt.0/apt.conf.d/70debconf
apt.0/apt.conf.d/01autoremove
apt.0/apt.conf.d/00CDMountPoint
apt.0/preferences
bruin@ovm32:~$ cat /etc/apt/sources.list
# 

# deb cdrom:[Debian GNU/Linux 6.0.0 _Squeeze_ - Official Snapshot i386 LIVE/INSTALL Binary 20130824-12:51]/ squeeze main non-free

#deb cdrom:[Debian GNU/Linux 6.0.0 _Squeeze_ - Official Snapshot i386 LIVE/INSTALL Binary 20130824-12:51]/ squeeze main non-free

deb http://mirrors.163.com/debian/ squeeze main
deb-src http://mirrors.163.com/debian/ squeeze main

deb http://security.debian.org/ squeeze/updates main non-free
deb-src http://security.debian.org/ squeeze/updates main non-free

# squeeze-updates, previously known as 'volatile'
deb http://mirrors.163.com/debian/ squeeze-updates main non-free
deb-src http://mirrors.163.com/debian/ squeeze-updates main non-free
bruin@ovm32:~$ 
[/code]
[/list]	 

2. upgrade to backport kernel
[list]
[*] install omv-extras-plugin via ssh: http://omv-extras.org/simple/index.php?id=how-to-install-omv-extras-plugin
[code]
[b]bruin@ovm32:~$ wget http://omv-extras.org/debian/pool/main/o/openmediavault-omvextrasorg/openmediavault-omvextrasorg_0.5.39_all.deb[/b]
--2014-03-30 20:13:25--  http://omv-extras.org/debian/pool/main/o/openmediavault-omvextrasorg/openmediavault-omvextrasorg_0.5.39_all.deb
正在解析主机 omv-extras.org... 75.100.121.227
正在连接 omv-extras.org|75.100.121.227|:80... 已连接。
已发出 HTTP 请求，正在等待回应... 200 OK
长度：148726 (145K) [application/x-debian-package]
正在保存至: “openmediavault-omvextrasorg_0.5.39_all.deb”

100%[============================================================================================>] 148,726     28.3K/s 花时 5.1s    

2014-03-30 20:13:32 (28.3 KB/s) - 已保存 “openmediavault-omvextrasorg_0.5.39_all.deb” [148726/148726])

[b]bruin@ovm32:~$ sudo dpkg -i openmediavault-omvextrasorg_0.5.39_all.deb [/b]
选中了曾被取消选择的软件包 openmediavault-omvextrasorg。
(正在读取数据库 ... 系统当前共安装有 23601 个文件和目录。)
正在解压缩 openmediavault-omvextrasorg (从 openmediavault-omvextrasorg_0.5.39_all.deb) ...
正在设置 openmediavault-omvextrasorg (0.5.39) ...
Initialize configuration
OK
OK
OK
OK
OK
OK
gpg: 警告：不建议使用散列算法 MD5
gpg: 请参见 http://www.gnupg.org/faq/weak-digest-algos.html 以得到更多信息。
OK
OK
正在处理用于 openmediavault 的触发器...
Restarting engine daemon ...
Updating file permissions ...
Updating locale files ...
[b]bruin@ovm32:~$ sudo apt-get update[/b]
...
[/code]
What's changed in pkgs db:
[code]
bruin@ovm32:~$ dpkg -l > pkg.list.1
bruin@ovm32:~$ diff pkg.list.1 pkg.list.0
239d238
< ii  openmediavault-omvextrasorg        0.5.39                       OMV-Extras.org Package Repositories for OpenMediaVault
bruin@ovm32:~$ 
bruin@ovm32:~$ sudo cp -a /etc/apt apt.1
bruin@ovm32:~$ diff -r apt.1 apt
只在 apt 存在：apt
只在 apt.1/preferences.d 存在：99omv-extras-org
只在 apt.1 存在：secring.gpg
只在 apt.1/sources.list.d 存在：omv-extras-org-sardaukar.list
只在 apt.1 存在：trustdb.gpg
只在 apt.1 存在：trusted.gpg
只在 apt.1 存在：trusted.gpg~
bruin@ovm32:~$ cat /etc/apt/preferences.d/99omv-extras-org 
Package: *
Pin: release n=sardaukar, origin packages.omv-extras.org
Pin-Priority: 995

Package: *
Pin: release n=sardaukar-dotdeb, origin packages.omv-extras.org
Pin-Priority: 996

Package: *
Pin: release n=sardaukar-greyhole, origin packages.omv-extras.org
Pin-Priority: 995

Package: *
Pin: release n=sardaukar-plex, origin packages.omv-extras.org
Pin-Priority: 995

Package: *
Pin: release n=sardaukar-testing, origin packages.omv-extras.org
Pin-Priority: 996

Package: *
Pin: release n=sardaukar-backports, origin packages.omv-extras.org
Pin-Priority: 995

Package: *
Pin: release n=sardaukar-vb, origin packages.omv-extras.org
Pin-Priority: 995

Package: *
Pin: release n=sardaukar-miller, origin dh2k.omv-extras.org
Pin-Priority: 995

Package: *
Pin: release n=sardaukar-miller-testing, origin dh2k.omv-extras.org
Pin-Priority: 995

Package: *
Pin: release n=sardaukar-beta, origin packages.omv-extras.org
Pin-Priority: 995

Package: *
Pin: release n=sardaukar-btsync, origin packages.omv-extras.org
Pin-Priority: 995

Package: *
Pin: release n=sardaukar-vdr, origin packages.omv-extras.org
Pin-Priority: 995

Package: *
Pin: release n=squeeze, origin debian.yeasoft.net
Pin-Priority: 995

Package: *
Pin: release o=e-tobi.net
Pin-Priority: 995
bruin@ovm32:~$ cat /etc/apt/sources.list.d/o
omv-extras-org-sardaukar.list  openmediavault.list            openmediavault-local.list      
bruin@ovm32:~$ cat /etc/apt/sources.list.d/omv-extras-org-sardaukar.list 
deb http://packages.omv-extras.org/debian/ sardaukar main
bruin@ovm32:~$ 
[/code]
also, by logging into the webui again (as webgui has restarted), check that "System->OMV-Extras.org" exists now.
[*] upgrade kernel from webui, by clicking "system->omv-extras.org->install backports 3.2 kernel" and then clicking "start" button.
the webui output:
[code]

[/code]
[*] reboot the box via webui.
what's changed in pkgs db:

[/list]

     - apt-get install vim less htop manpages man-db build-essential apt-file util-linux aptitude
     - apt-file update
     - apt-get update
     - apt-get upgrade
     - apt-get dist-upgrade: does not necessay.
     - reboot to verify webgui is still ok
     - /etc/apt/sources.list: http://forums.openmediavault.org/viewtopic.php?f=14&t=578
      . add: deb http://backports.debian.org/debian-backports squeeze-backports main non-free
      . update db: apt-get update
      . check kernel version: apt-cache search linux-image-3
      . install new kernel: apt-get -t squeeze-backports install linux-image-3.2.0-0.bpo.4-amd64 firmware-linux-free firmware-linux-nonfree
      . reboot to check everything (including webui) is still ok.
     - X: 
      . apt-get install xorg gnome gdm
      . /etc/inittab: change run level from 2 to 5
      . reboot and login
     - kvm: https://wiki.debian.org/KVM
      . apt-get install qemu-kvm libvirt-bin: after that, verify:
            bruin@omv:/$ lsmod|grep kvm
            kvm_intel             120947  0 
            kvm                   292670  1 kvm_intel
            bruin@omv:/$ ls /dev/kvm
            /dev/kvm
            bruin@omv:/$ 
       . add user into libvirt group:
            bruin@omv:/$ sudo adduser bruin libvirt
            Adding user `bruin' to group `libvirt' ...
            Adding user bruin to group libvirt
            Done.
            bruin@omv:/$ 
       . setup bridge networking: already installed.
            bruin@omv:/$ dpkg --list|grep bridge-utils
            ii  bridge-utils                        1.4-5                        Utilities for configuring the Linux Ethernet bridge
            bruin@omv:/$ 
       . change /etc/network/interfaces:

+ gparted:
  apt-get install gparted: for review the partitions, not able to make changes online.
  gparted-live-0.16.2-11-i686-pae.iso
  apt-file search blkid
bruin@omv:~$ /sbin/blkid
/dev/sda1: LABEL="root" UUID="5cac462c-6692-45bf-9de2-3f7e425104a4" TYPE="ext4" 
/dev/sda3: LABEL="backup" UUID="81a55061-e905-4fd5-9076-f13488cafd47" TYPE="ext4" 
/dev/sda4: LABEL="tank" UUID="8b5026ab-5a79-40e2-b328-58cee27187f8" TYPE="ext2" 
/dev/sda5: LABEL="swap" UUID="a76cea18-fb07-4f68-b36e-4f5ba78aa7f9" TYPE="swap" 
bruin@omv:~$ df -mh
Filesystem            Size  Used Avail Use% Mounted on
/dev/sda1              49G  3.1G   43G   7% /
tmpfs                 3.9G     0  3.9G   0% /lib/init/rw
udev                   10M  208K  9.8M   3% /dev
tmpfs                 3.9G     0  3.9G   0% /dev/shm
tmpfs                 3.9G  8.0K  3.9G   1% /tmp
bruin@omv:~$ cat /etc/fstab
# /etc/fstab: static file system information.
#
# Use 'blkid' to print the universally unique identifier for a
# device; this may be used with UUID= as a more robust way to name devices
# that works even if disks are added and removed. See fstab(5).
#
# <file system> <mount point>   <type>  <options>       <dump>  <pass>
proc            /proc           proc    defaults        0       0
# / was on /dev/sda1 during installation
UUID=5cac462c-6692-45bf-9de2-3f7e425104a4 /               ext4    errors=remount-ro 0       1
# swap was on /dev/sda5 during installation
UUID=a76cea18-fb07-4f68-b36e-4f5ba78aa7f9 none            swap    sw              0       0
/dev/sdb1       /media/usb0     auto    rw,user,noauto  0       0
tmpfs           /tmp            tmpfs   defaults        0       0
bruin@omv:~$ 
bruin@omv:~$ sudo fdisk -l

Disk /dev/sda: 320.1 GB, 320072933376 bytes
255 heads, 63 sectors/track, 38913 cylinders
Units = cylinders of 16065 * 512 = 8225280 bytes
Sector size (logical/physical): 512 bytes / 512 bytes
I/O size (minimum/optimal): 512 bytes / 512 bytes
Disk identifier: 0x000c72ad

   Device Boot      Start         End      Blocks   Id  System
/dev/sda1   *           1        6374    51198131   83  Linux
/dev/sda2           37335       38914    12683265    5  Extended
/dev/sda3            6375       36970   245762370   83  Linux
/dev/sda4           36971       37335     2924544   83  Linux
/dev/sda5           37335       38914    12683264   82  Linux swap / Solaris

Partition table entries are not in disk order
bruin@omv:~$ 


zfs for debian 7: http://zfsonlinux.org/debian.html
zfs: http://bernaerts.dyndns.org/linux/75-debian/279-debian-wheezy-zfs-raidz-pool


root@omv:/usr/src# apt-cache search linux-headers
linux-headers-2.6.32-5-all-amd64 - All header files for Linux 2.6.32 (meta-package)
linux-headers-2.6.32-5-all - All header files for Linux 2.6.32 (meta-package)
linux-headers-2.6.32-5-amd64 - Header files for Linux 2.6.32-5-amd64
linux-headers-2.6.32-5-common-openvz - Common header files for Linux 2.6.32-5-openvz
linux-headers-2.6.32-5-common-vserver - Common header files for Linux 2.6.32-5-vserver
linux-headers-2.6.32-5-common-xen - Common header files for Linux 2.6.32-5-xen
linux-headers-2.6.32-5-common - Common header files for Linux 2.6.32-5
linux-headers-2.6.32-5-openvz-amd64 - Header files for Linux 2.6.32-5-openvz-amd64
linux-headers-2.6.32-5-vserver-amd64 - Header files for Linux 2.6.32-5-vserver-amd64
linux-headers-2.6.32-5-xen-amd64 - Header files for Linux 2.6.32-5-xen-amd64
linux-headers-2.6-amd64 - Header files for Linux 2.6-amd64 (meta-package)
linux-headers-2.6-openvz-amd64 - Header files for Linux 2.6-openvz-amd64 (meta-package)
linux-headers-2.6-vserver-amd64 - Header files for Linux 2.6-vserver-amd64 (meta-package)
linux-headers-2.6-xen-amd64 - Header files for Linux 2.6-xen-amd64 (meta-package)
linux-headers-3.2.0-0.bpo.4-all - All header files for Linux 3.2 (meta-package)
linux-headers-3.2.0-0.bpo.4-all-amd64 - All header files for Linux 3.2 (meta-package)
linux-headers-3.2.0-0.bpo.4-amd64 - Header files for Linux 3.2.0-0.bpo.4-amd64
linux-headers-3.2.0-0.bpo.4-common - Common header files for Linux 3.2.0-0.bpo.4
linux-headers-3.2.0-0.bpo.4-common-rt - Common header files for Linux 3.2.0-0.bpo.4-rt
linux-headers-3.2.0-0.bpo.4-rt-amd64 - Header files for Linux 3.2.0-0.bpo.4-rt-amd64
linux-headers-amd64 - Header files for Linux amd64 configuration (meta-package)
linux-headers-rt-amd64 - Header files for Linux rt-amd64 configuration (meta-package)
root@omv:/usr/src# uname -r
3.2.0-0.bpo.4-amd64
root@omv:/usr/src# apt-get install linux-headers-`uname -r`
Reading package lists... Done
Building dependency tree       
Reading state information... Done
The following extra packages will be installed:
  linux-headers-3.2.0-0.bpo.4-common linux-kbuild-3.2
The following NEW packages will be installed:
  linux-headers-3.2.0-0.bpo.4-amd64 linux-headers-3.2.0-0.bpo.4-common linux-kbuild-3.2
0 upgraded, 3 newly installed, 0 to remove and 4 not upgraded.
Need to get 4,408 kB of archives.
After this operation, 28.2 MB of additional disk space will be used.
Do you want to continue [Y/n]? 
Get:1 http://mirrors.sohu.com/debian-backports/ squeeze-backports/main linux-headers-3.2.0-0.bpo.4-common amd64 3.2.54-2~bpo60+1 [3,562 kB]
Get:2 http://mirrors.sohu.com/debian-backports/ squeeze-backports/main linux-kbuild-3.2 amd64 3.2.17-1~bpo60+1 [236 kB]
Get:3 http://mirrors.sohu.com/debian-backports/ squeeze-backports/main linux-headers-3.2.0-0.bpo.4-amd64 amd64 3.2.54-2~bpo60+1 [610 kB]
Fetched 4,408 kB in 4s (991 kB/s)                          
Selecting previously deselected package linux-headers-3.2.0-0.bpo.4-common.
(Reading database ... 96007 files and directories currently installed.)
Unpacking linux-headers-3.2.0-0.bpo.4-common (from .../linux-headers-3.2.0-0.bpo.4-common_3.2.54-2~bpo60+1_amd64.deb) ...
Selecting previously deselected package linux-kbuild-3.2.
Unpacking linux-kbuild-3.2 (from .../linux-kbuild-3.2_3.2.17-1~bpo60+1_amd64.deb) ...
Selecting previously deselected package linux-headers-3.2.0-0.bpo.4-amd64.
Unpacking linux-headers-3.2.0-0.bpo.4-amd64 (from .../linux-headers-3.2.0-0.bpo.4-amd64_3.2.54-2~bpo60+1_amd64.deb) ...
Setting up linux-headers-3.2.0-0.bpo.4-common (3.2.54-2~bpo60+1) ...
Setting up linux-kbuild-3.2 (3.2.17-1~bpo60+1) ...
Setting up linux-headers-3.2.0-0.bpo.4-amd64 (3.2.54-2~bpo60+1) ...
Examining /etc/kernel/header_postinst.d.
run-parts: executing /etc/kernel/header_postinst.d/dkms 3.2.0-0.bpo.4-amd64
root@omv:/usr/src# apt-cache showpkg linux-headers
Package: linux-headers
Versions: 

Reverse Depends: 
  dkms,linux-headers
  debian-zfs,linux-headers
  dkms,linux-headers
  oss4-dkms,linux-headers
  openswan-modules-source,linux-headers
  dkms,linux-headers
  blcr-dkms,linux-headers
  alsa-source,linux-headers
Dependencies: 
Provides: 
Reverse Provides: 
linux-headers-rt-amd64 3.2+46~bpo60+1
linux-headers-amd64 3.2+46~bpo60+1
linux-headers-3.2.0-0.bpo.4-rt-amd64 3.2.54-2~bpo60+1
linux-headers-3.2.0-0.bpo.4-amd64 3.2.54-2~bpo60+1
linux-headers-2.6-xen-amd64 2.6.32+29
linux-headers-2.6-vserver-amd64 2.6.32+29
linux-headers-2.6-openvz-amd64 2.6.32+29
linux-headers-2.6-amd64 2.6.32+29
linux-headers-2.6.32-5-xen-amd64 2.6.32-48squeeze4
linux-headers-2.6.32-5-vserver-amd64 2.6.32-48squeeze4
linux-headers-2.6.32-5-openvz-amd64 2.6.32-48squeeze4
linux-headers-2.6.32-5-amd64 2.6.32-48squeeze4
root@omv:/usr/src# apt-get install aptitude







	
