prerequisites:
- each host is installed and configured
- ssh-copy-id is done from ansible box to all hosts are done


for ctl cluster, run:

sudo ansible-playbook -v -i home.ini ctl.yml

to run a specific task, tag the task and then:

sudo ansible-playbook -v -i home.ini ctl.yml --tags test

