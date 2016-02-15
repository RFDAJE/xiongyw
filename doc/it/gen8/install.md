HP Gen8 Microserver config and setup memo
=========================================

Firmware configuration
----------------------

* Ordered from `computeruniverse.net` on 2015-12-21 at price (in EURO):
  `229.94=193.19(G1610T/4G)+4.2(packing)+32.55(DHL shipping)`
   and shipped to home on 2016-01-13 by EMS.
* Perchase iLO advanced license: `32CRX-V7BXC-D2MZN-L2DYZ-LZ88W`
* MAC/IP@:


  |     adapter      | mac@            | ip@          |
  |------------------|-----------------|--------------|
  |adapter 1 - iLO   |3c:a8:2a:a0:52:0a|192.168.100.18|
  |adapter 2 - port 1|3c:a8:2a:a0:52:08|192.168.100.19|
  |adapter 2 - port 2|3c:a8:2a:a0:52:09|      -       |

* iLO Administrator passwd: `DE78M2W3`
* Replace CPU: `Intel(R) Xeon(R) CPU E3-1230 V2 @ 3.30GHz`
* Add extra 8GiB DDR3 RAM (Kingstone `KTH-PL316ELV/8G`):


  | Memory Location | Socket |         Status |HP SmartMemory | Part Number |      Type |    Size |  Maximum Frequency | Minimum Voltage | Ranks | Technology |
  |-----------------|--------|----------------|---------------|-------------|-----------|---------|--------------------|-----------------|-------|------------|
  |Processor 1      |       1|    Good, In Use|            Yes|          N/A|  DIMM DDR3|  4096 MB|            1600 MHz|            1.5 V|      1|  UDIMM     |
  |Processor 1      |       2|    Good, In Use|             No|          N/A|  DIMM DDR3|  8192 MB|            1600 MHz|            1.5 V|      2|  UDIMM     |  

* Enable SATA AHCI:
   ```
   RBSU -> System Options -> SATA Controller Options -> Embedded SATA configuration -> Enable SATA AHCI Support
   ```
* Disable VID (Virtual Install Disk):


Power consumption: ~37.5W (w/ 4 HDDs)

Debian jessie 8.2 Installation
------------------------------

* iso: `debian-live-8.2.0-amd64-standard.iso`
* choose manual partition: 230GB for /, and 20GB for swap...reboot after install completes
* add `bruin` as a sudoer, in `/etc/sudoers`:  
    `bruin   ALL=(ALL:ALL) ALL`
* update `/etc/apt/sources.list`: use local mirrors for all (including security), remove cdrom source:
````
deb http://mirros.163.com/debian-security/ jessie/updates main
deb-src http://mirrors.163.com/debian-security/ jessie/updates main
```
then
```
#apt-get update
#apt-get install sudo
```
* replace `vim-tiny` with `vim`:
```
sudo apt-get remove vim-tiny
sudo apt-get install vim
```
* use `bash` instead of `dash` as default shell:
```
rm /bin/sh
ls -s /bin/bash /bin/sh
```
* misc pkgs: `$sudo apt-get install apt-file build-essential acpi lm-sensors stress hdparm iftop htop iotop util-linux gparted zip unzip dos2unix git minidlna aria2 samba tmux`
* x:  `$sudo apt-get install xorg gnome xfonts-wqy ttf-wqy-zenhei`

* chrome:
```
aria2c https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
sudo dpkg -i google-chrome-*.deb
sudo apt-get install -f
google-chrome-stable
```

fonts: http://blog.csdn.net/neosmith/article/details/17366595

* HP Management Component Pack: https://downloads.linux.hpe.com/SDR/project/mcp/

```
bruin@gen8:~$ cat /etc/apt/sources.list.d/mcp.list
# HP Management Component Pack
deb http://downloads.linux.hpe.com/SDR/repo/mcp jessie/current non-free

sudo apt-get update
sudo apt-get install hp-ams
```

gfw
---


Samba
-----
1. samba server config in `/etc/samba/smb.conf`:
```
  [homes]
        comment = Home Directories
        valid users = bruin
        read only = No
        create mask = 0700
        directory mask = 0700
```
```
  testparm
  smbpasswd -a bruin
  /etc/init.d/smbd reload
```
2. samba client
```
$sudo apt-get install cifs-utils
$sudo mount -t cifs -o user=bruin -o pass=qwerty //192.168.100.5/tele /tele
```

uhttpd
------
```
$ cat /etc/uhttpd
listen_ip     0.0.0.0
listen_port   80
max_idle      5
min_idle      5
max_sessions  5
work_dir      /home/bruin
lock_file     /home/bruin/uhttpd.80.lock
# virtual host: domain_name root_dir default_file log_file
vhost         192.168.100.19 /home/bruin index.html /home/bruin/uhttpd.80.log

$ tail /etc/rc.local
# By default this script does nothing.
/usr/local/bin/uhttpd
exit 0

```

Minidlna
--------
```
$ cat /etc/minidlna.conf
...
media_dir=A,/home/bruin/work/2.2t/music
media_dir=V,/home/bruin/work/2.2t/movie
media_dir=P,/home/bruin/work/0.500g/photo
...
friendly_name=gen8
$ sudo /etc/init.d/minidlna restart
```

Transmission
------------
sudo apt-get install transmission transmission-cli transmission-daemon


/etc/transmission-daemon/settings.json:
"dht-enabled": false,
"rpc-whitelist-enabled": false,
"rpc-authentication-required": false
"download-dir": xxx

/etc/init.d/transmission-daemon reload


/etc/sysctl.conf:
net.core.rmem_default = 8388608
net.core.wmem_default = 8388608
net.core.rmem_max = 16777216
net.core.wmem_max = 16777216 


Aria2
-----



R & RStudio
-----------



Book Scan
---------
sudo apt-get install scantailor pdftk texlive asymptote libtiff-tools
- tesseract-ocr
  apt-get install tesseract-ocr
  apt-get install tesseract-ocr-chi-sim

  tesseract -l chi_sim input.tif out hocr

- pdfsandwich: http://www.tobias-elze.de/pdfsandwich/
  sudo dpkg -i pdfsandwich_0.1.0_amd64.deb  # There will be an error message. Ignore it and proceed!
  sudo apt-get -fy install


  pdfsandwich -lang chi_sim -resolution 600 input.pdf -o output600dpi.pdf

- parallel
 sudo apt-get install parallel
 parallel pdfsandwich -lang chi_sim -resolution 600 -o {.}-600dpi.pdf {} ::: *.pdf


git
---
$ git config --global core.editor vim
$ git config --global user.name "Yuwu Xiong"
$ git config --global user.email "5070319@qq.com"

ATOM: markdown editor
---------------------
url: https://github.com/alanfranz/atom-text-editor-repository
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv A1D267C030C00DCB877900ED939C61C5D1270819
add `deb http://www.a9f.eu/apt/atom/debian jessie main` into `/etc/apt/sources.list`
sudo apt-get installa tom



System info
-----------
```
$ ls -la /dev/disk/by-uuid
total 0
drwxr-xr-x 2 root root 140 Jan 18 19:41 .
drwxr-xr-x 5 root root 100 Jan 18 19:41 ..
lrwxrwxrwx 1 root root  10 Jan 18 19:41 4746fc4d-5611-4515-8e2d-dac67774516b -> ../../sda1
lrwxrwxrwx 1 root root  10 Jan 18 19:41 ce8c81a4-d579-47e5-b8b5-5a1e139a85d7 -> ../../sda2
lrwxrwxrwx 1 root root   9 Jan 18 19:41 698e7dfe-8ac8-4b9d-8294-f5a12b214650 -> ../../sdb
lrwxrwxrwx 1 root root   9 Jan 18 19:41 ad37c349-8979-4911-92a7-2afbf3b99708 -> ../../sdc
lrwxrwxrwx 1 root root  10 Jan 18 19:41 A08424098423E090 -> ../../sdd1

$ sudo blkid
/dev/sda1: LABEL="home" UUID="4746fc4d-5611-4515-8e2d-dac67774516b" TYPE="ext4" PARTUUID="5eea44b8-01"
/dev/sda2: UUID="ce8c81a4-d579-47e5-b8b5-5a1e139a85d7" TYPE="swap" PARTUUID="5eea44b8-02"
/dev/sdc: UUID="ad37c349-8979-4911-92a7-2afbf3b99708" TYPE="ext4"
/dev/sdb: UUID="698e7dfe-8ac8-4b9d-8294-f5a12b214650" TYPE="ext4"
/dev/sdd1: LABEL="tele" UUID="A08424098423E090" TYPE="ntfs" PARTUUID="80ddad9b-01"

$ cat /etc/fstab
UUID=4746fc4d-5611-4515-8e2d-dac67774516b /               ext4    errors=remount-ro 0       1
UUID=698e7dfe-8ac8-4b9d-8294-f5a12b214650 /home/bruin/work/0.500g ext4 errors=remount-ro 0 2
UUID=ad37c349-8979-4911-92a7-2afbf3b99708 /home/bruin/work/1.500g ext4 errors=remount-ro 0 3
UUID=A08424098423E090                     /home/bruin/work/2.2t   ntfs errors=remount-ro 0 4
UUID=ce8c81a4-d579-47e5-b8b5-5a1e139a85d7 none            swap    sw              0       0
/dev/sr0        /media/cdrom0   udf,iso9660 user,noauto     0       0

bruin@gen8:~$ df -h
Filesystem      Size  Used Avail Use% Mounted on
/dev/sda1       211G  4.8G  196G   3% /
udev             10M     0   10M   0% /dev
tmpfs           2.4G  9.1M  2.4G   1% /run
tmpfs           5.9G   80K  5.9G   1% /dev/shm
tmpfs           5.0M     0  5.0M   0% /run/lock
tmpfs           5.9G     0  5.9G   0% /sys/fs/cgroup
tmpfs           1.2G   16K  1.2G   1% /run/user/120
tmpfs           1.2G     0  1.2G   0% /run/user/1000
/dev/sdb        459G  207G  229G  48% /home/bruin/work/0.500g
/dev/sdc        459G   93G  343G  22% /home/bruin/work/1.500g
/dev/sdd1       1.9T  1.5T  332G  83% /home/bruin/work/2.2t

bruin@gen8:~$ lsblk -o NAME,TYPE,MOUNTPOINT,SIZE,MODEL
NAME   TYPE MOUNTPOINT                SIZE MODEL
sda    disk                         232.9G ST3250318AS
├─sda1 part /                       214.2G
└─sda2 part [SWAP]                   18.7G
sdb    disk /home/bruin/work/0.500g 465.8G WDC WD5000AADS-0
sdc    disk /home/bruin/work/1.500g 465.8G WDC WD5000AVDS-6
sdd    disk                           1.8T WDC WD20EARX-55P
└─sdd1 part /home/bruin/work/2.2t     1.8T

$ sensors
acpitz-virtual-0
Adapter: Virtual device
temp1:         +8.3°C  (crit = +31.3°C)

power_meter-acpi-0
Adapter: ACPI interface
power1:        0.00 W  (interval = 300.00 s)

coretemp-isa-0000
Adapter: ISA adapter
Physical id 0:  +37.0°C  (high = +85.0°C, crit = +105.0°C)
Core 0:         +37.0°C  (high = +85.0°C, crit = +105.0°C)
Core 1:         +31.0°C  (high = +85.0°C, crit = +105.0°C)
Core 2:         +23.0°C  (high = +85.0°C, crit = +105.0°C)
Core 3:         +23.0°C  (high = +85.0°C, crit = +105.0°C)
```
