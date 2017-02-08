created(bruin, 2017-01-20)

Scripts for OpenStack controller HA configurations for both kvm and physical deployment.
Probably the better way should be using puppet/chef/etc, but for now just use
scripts to note down the config steps...

terms:
- TOOLS: a centos7 box serves local yum repositories (via http), and provides
  tftp/dhcp/dns services (via dnsmasq), as well as kickstart cfg files (also via
  http). it may provide other services for the cluster.
- HOST: a libvirt server machine for kvm deployment environment. all cluster NODEs
  are guests on this HOST.
- NODEs: the nodes forming the HA cluster for OpenStack controller.

It's assumed that:
- TOOLS, HOST, and NODEs are on the same subnet(s).
- the script is executed on a _BOX_ which can directly ssh to other machines,
  including TOOLS, HOST, and cluster NODEs. as special cases, the _box_ can be
  the same as TOOLS or HOST; further more, in kvm setup, the TOOLS and HOST can
  be the same machine.
- the script is executed as root (or sudo)
- root on this _BOX_ can ssh to TOOLS/HOST without passwd (configured by ssh-copy-id)
- TOOLS/HOST and cluster NODEs are all running CentOS 7.x; _BOX_ could be any
  machine with bash and ssh client.


The installation/configuration process can be roughly divided into the following
steps. (*) means only applicable for kvm deployment:

1. TOOLS setup.
   - yum repo mirrors setup (rsync)
   - httpd (nginx) serving mirrors and kickstart cfg files
   - dnsmasq providing tftp/dhcp services (as well as dns service)
2. network environment setup
   + (*) HOST setup. HOST can be the same machine as TOOLS.
     - install kvm/libvirt related packages
     - bridge/iptable setup
   + in physical deployment:
     - design network topology (e.g., cabling, ip allocation, etc).
     - connect NODEs with switches
3. prepare NODEs (nail down some constants for scripts)
   + (*) guests create, including:
     - creating guest images (qemu-img...) ,and xml config files
     - define guests (virsh define...)
   + in physical deployment:
     - collecting mac@ of all NICs on all NODEs
     - config BIOS of NODEs to allow PXE boot
4. generate pxe and ks config files for each node:
   - generate pxe cfg files under tftpd's directory
   - generate ks cfg files under httpd's directory
5. pxe-kickstart boot & install each node.
   - (*) just run "virsh start"
   - press power button on physical machines
   - A manual reboot is needed after install.
6. post install setup for each node, including:
   - ssh-copy-id to NODEs
   - NIC teaming setup of NODEs
   - set host name
   - update /etc/yum.repos.d/
   - etc
7. openstack ha install/config, including:
   - pacemaker
   - chronyd
   - memcached
   - mariadb
   - rabbitmq
   - mongod
   - vip
   - haproxy
   - keystone
   - ceilometer
   - aodh
