#!/usr/bin/expect

set REBOOT_LOG "BCM97430B0 CFE v.*"
set CFE_PROMPT "CFE> "
set LNX_PROMPT "# "
set CTRL_C     \x03       ;# http://wiki.tcl.tk/3038
set CTRL_C_ACCEPTED "Automatic startup canceled via Ctrl-C"
set CFE_SUCCESS "*** command status = 0"

########################################################
# customize the following to fit your stb/environment!!!
########################################################
# IP@ of the tftp serer
set tftp  192.168.1.2
# files' path/name on the tftp server 
set images_path "humax7430/hnb100/p2/BLD_2_1"
set kernel_name "vmlinuz-main"
set initrd_kernel "humax7430/vmlinuz-initrd-humax-7430" 
# cfe commands
set cfe_startup "setenv -p STARTUP \"boot -z -elf nandflash0.opentv: 'ubi.mtd=0 root=ubi0:rootfs rootfstype=ubifs rw bmem=192M@64M bmem=512M@512M mtdparts=spi0.0:64K@2304K(mfr)ro,64K(mbox);brcmnand.0:0xDA00000@0x2600000(rootfs)'\"\r"
set cfe_ifconfig "ifconfig eth0 -auto\r"
set cfe_flash_kernel "flash -noheader ${tftp}:${images_path}/${kernel_name} nandflash0.opentv\r"
set cfe_boot_initrd "boot -elf ${tftp}:${initrd_kernel} 'bmem=192M@64M mtdparts=brcmnand.0:0xDA00000@0x2600000(rootfs)'\r"
# stbutil cmd
set stbutil "stbutil -a 2 ${tftp}:${images_path}\r"





#
# define procedures
#
proc my_send_user { msg } {
    send_user "\r\n"
    send_user "######################################\r\n"
    send_user "# $msg \r\n" 
    send_user "######################################\r\n"
}

proc reboot_into_cfe {} {
    global REBOOT_LOG
    global CFE_PROMPT
    global LNX_PROMPT
    global CTRL_C
    global CTRL_C_ACCEPTED

    # press return several times 
    send "\r\r\r\r"

    # reboot
    expect {
        $CFE_PROMPT  { send "reboot\r" }
        $LNX_PROMPT  { send "reboot\r" }
    }

    # entering the CFE mode by sending CTRL-C
    expect -re $REBOOT_LOG
    my_send_user "Sending ^C"
    send $CTRL_C$CTRL_C$CTRL_C$CTRL_C
    expect -timeout 10 {
        $CTRL_C_ACCEPTED { 
            my_send_user "Entering CFE..." 
        }
        timeout { 
            my_send_user "Failure: timeout!" 
            exit 1
        } 
    }

    # let CFE calms down
    # sleep 10
    expect $CFE_PROMPT
    send "\r\r\r"
    expect $CFE_PROMPT
}

#
# starting...
#

set timeout -1              ;# wait forever by default
set send_slow { 1  0.05 }   ;# send each character at 50ms

#
# get connected to the serial port
#
spawn killall screen
spawn screen /dev/ttyS0 115200
set screen_pid [exp_pid]     ;# kill this process at the end

#
# reboot into CFE
#
reboot_into_cfe

my_send_user "Set STARTUP for normal boot..."
send $cfe_startup

my_send_user "Flashing the kernel..."
send $cfe_ifconfig
expect $CFE_SUCCESS
send $cfe_flash_kernel
expect $CFE_SUCCESS

send "\r\r"
my_send_user "Booting into a kernel with initrd..."
send $cfe_ifconfig
expect $CFE_SUCCESS
send $cfe_boot_initrd
expect "eth0: link up,"
send "\r\r\r"
expect $LNX_PROMPT

my_send_user "Run stbutil for flashing the rootfs..."
send $stbutil
expect "Finished writing rootfs to flash."
send "\r\r\r"


my_send_user "Reboot to the new kernel/rootfs..."
send "reboot\r"
expect "DirectFB"
sleep 10
send "\r\r\runame -a\r"
expect "Linux "

my_send_user "Update /etc/dhcp/dhclient.conf..."
sleep 3
send "cp /etc/dhcp/dhclient.conf /etc/dhcp/dhclient.conf.orig\r"
expect $LNX_PROMPT
send "sed -i \"s/domain-name/routers,domain-name/g\" /etc/dhcp/dhclient.conf\r"
expect $LNX_PROMPT
send "diff /etc/dhcp/dhclient.conf.orig /etc/dhcp/dhclient.conf\r"
expect $LNX_PROMPT
sleep 3
my_send_user "Reboot..."
send "Reboot\r"

#
# enfin
#
#spawn kill -9 $screen_pid
spawn killall screen
sleep 2
#interact
close

