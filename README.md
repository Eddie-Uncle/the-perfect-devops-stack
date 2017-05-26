# Perfect DevOps stack (hashicorp tools[terraform, nomad, consul] + saltstack + docker)

### [WORK IN PROGRESS, STAY TUNED]

## Preparing the STACK HEAD server

Create a new instance(Centos 7.2 - ami-0ca23e1b) that will serve as our stack head for terraform, saltstack, nomad and consul

1) Set a hostname to the cluster head
````
# echo 'stackhead.local' > /etc/hostname

# hostname $(cat /etc/hostname)

# STACK_HEAD_IP=$(ip -4 addr show dev eth0|grep inet | cut -d" " -f6|sed s/\\/.*//g)

# echo "$STACK_HEAD_IP $HOSTNAME" >> /etc/hosts
````

2) Clone the git repository
````
# mkdir /opt/devops
# cd /opt/devops
# git clone https://git@github.com/iarlyy/hashicorpstack-aws-saltstack-docker
# cd hashicorpstack-aws-saltstack-docker
````

3) Generate a key pair and save it to /opt/devops/hashicorpstack-aws-saltstack-docker/files/aws.pem
````
# mkdir /opt/devops/hashicorpstack-aws-saltstack-docker/files

AWS Console -> EC2 -> Key Pairs -> Create new Key Pair

````

4) Generate a new access keys and set the values accordingly on the file /opt/devops/hashicorpstack-aws-saltstack-docker/terraform/terraform.tfvars
````
http://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html
````

5) Install Saltstack
````
# rpm -Uvh https://dl.fedoraproject.org/pub/epel/epel-release-latest-7.noarch.rpm
# cat << EOF > /etc/yum.repos.d/saltstack.repo
[saltstack-repo]
name=SaltStack repo for Red Hat Enterprise Linux $releasever
baseurl=https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest
enabled=1
gpgcheck=1
gpgkey=https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest/SALTSTACK-GPG-KEY.pub
       https://repo.saltstack.com/yum/redhat/\$releasever/\$basearch/latest/base/RPM-GPG-KEY-CentOS-7
EOF
# yum install salt-master salt-minion -y

# sed -i s/'#auto_accept: False'/'auto_accept: True'/g /etc/salt/master

# echo -e "file_roots:\n    base:\n      - /opt/devops/hashicorpstack-aws-saltstack-docker/salt/states" >> /etc/salt/master

# echo -e "pillar_roots:\n    base:\n      - /opt/devops/hashicorpstack-aws-saltstack-docker/salt/pillars" >> /etc/salt/master

# sed -i s/"#master: salt"/"master: $HOSTNAME"/g /etc/salt/minion

# systemctl start salt-master salt-minion

# systemctl enable salt-master salt-minion

````

6) Add role to the STACK_HEAD and restart the salt-minion
````
# cat << EOF > /etc/salt/grains
role:
  - stackhead
EOF
# systemctl restart salt-minion
````

7) Install hashicorp tools (consul, consul-template, nomad and terraform)
````
# salt -G 'role:stackhead' state.highstate
````

8) Terraform apply
````
# cd /opt/devops/hashicorpstack-aws-saltstack-docker/terraform

# terraform apply
````

9) Ping if the instance is already connected to saltstack
````
# salt '*' test.ping
````

10) Assign role to all newly created instances and restart salt-minion
````
# salt -C '* not G@role:stackhead' file.write /etc/salt/grains "role:
  - consul
  - consul-template
  - nomad
"
# salt -C '* not G@role:stackhead' service.restart salt-minion
The command above will timeout, to test if the minion is up again run a test.ping (salt -C '* not G@role:stackhead' test.ping)
````

11) Enforce the installation of hashicorp tools on the minions
````
# salt -C '* not G@role:stackhead' state.highstate
````

12) [work in progress...]

## Helpful commands 
* Remove inactive salt minions
````
# salt-run manage.down removekeys=True
````
