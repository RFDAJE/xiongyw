diretory structure:

- inventories/: top directory for multiple inventories
- inventories/home: inventory for home environment
- inventories/home/group_vars/ctl: group vars for home environment

- roles/: define each roles

- *.yml: playbook for each group



prerequisites:
- each host is installed and configured
- ssh-copy-id is done from ansible box to all hosts are done


for ctl cluster, run:

sudo ansible-playbook -v -i home ctl.yml

to run a specific task, tag the task and then:

sudo ansible-playbook -v -i home ctl.yml --tags test

