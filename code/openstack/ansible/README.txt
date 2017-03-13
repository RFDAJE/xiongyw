prerequisites:
- each host is installed and configured
- ssh-copy-id is done from ansible box to all hosts are done


run:

sudo ansible-playbook -i site_xxx.ini cluster_yyy.yml
