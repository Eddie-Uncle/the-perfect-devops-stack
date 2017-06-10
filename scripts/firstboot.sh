#!/bin/bash
STACK_HEAD_IP_ADDRESS="$1"
INSTANCE_ROLE="$2"

sudo rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

sudo bash -c 'cat << EOF > /etc/yum.repos.d/saltstack.repo
[saltstack-repo]
name=SaltStack repo for Red Hat Enterprise Linux $releasever
baseurl=https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest
enabled=1
gpgcheck=1
gpgkey=https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest/SALTSTACK-GPG-KEY.pub
       https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest/base/RPM-GPG-KEY-CentOS-7
EOF'

sudo sh -c "echo $STACK_HEAD_IP_ADDRESS salt stackhead >> /etc/hosts"

sudo yum install salt-minion -y

sudo su -c "cat << EOF > /etc/salt/grains
role:
  - $INSTANCE_ROLE
EOF"

sudo systemctl start salt-minion
