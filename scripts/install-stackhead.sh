#!/bin/bash

STACKHEAD_HOSTNAME="stackhead"
STACKHEAD_IPADDR=`ip -4 addr show dev eth0|grep inet | cut -d" " -f6|sed s/\\/.*//g`
GIT_REPO="https://git@github.com/iarlyy/hashicorpstack-aws-saltstack-docker"
WORKDIR="/opt/devops"

# Setting up yum repositories
rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm

cat << EOF > /etc/yum.repos.d/saltstack.repo
[saltstack-repo]
name=SaltStack repo for Red Hat Enterprise Linux $releasever
baseurl=https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest
enabled=1
gpgcheck=1
gpgkey=https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest/SALTSTACK-GPG-KEY.pub
       https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest/base/RPM-GPG-KEY-CentOS-7
EOF

# Setting up a hostname

echo "$STACKHEAD_HOSTNAME" > /etc/hostname

hostname $(cat /etc/hostname)

echo "$STACKHEAD_IPADDR $STACKHEAD_HOSTNAME" >> /etc/hosts

# Setting up working directory
mkdir $WORKDIR

# Installing packages
yum -y install salt salt-minion git

# Cloning repo
cd $WORKDIR
git clone $GIT_REPO

# Setting up saltmaster
sed -i s/'#auto_accept: False'/'auto_accept: True'/g /etc/salt/master

cat << EOF >> /etc/salt/master
file_roots:
    base:
        - $WORKDIR/$GIT_REPO/salt/states
EOF
 
cat << EOF >> /etc/salt/master
pillar_roots:
    base:
        - $WORKDIR/$GIT_REPO/salt/pillars
EOF
 
cat << EOF > /etc/salt/grains
role:
  - stackhead
EOF

sed -i s/"#master: salt"/"master: $STACKHEAD_HOSTNAME"/g /etc/salt/minion
 
systemctl enable salt-minion salt-master

echo 'Done!'
