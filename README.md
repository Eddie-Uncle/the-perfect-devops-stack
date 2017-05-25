# Perfect DevOps stack (hashicorp too[terraform, nomad, consul] + saltstack + docker)

## Preparing the cluster head

Create a new instance(Centos 7.2 - ami-0ca23e1b) that will serve as our cluster head for terraform, saltstack, nomad and consul

1) Set a hostname to the cluster head
````
# echo 'clusterhead.local' > /etc/hostname

# hostname $(cat /etc/hostname)

# CLUSTER_HEAD_IP=$(ip -4 addr show dev eth0|grep inet | cut -d" " -f6|sed s/\\/.*//g)
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

# systemct start salt-master salt-minion

# systemct enable salt-master salt-minion

````

6) [work in progress]

## Helpful commands 
* Remove inactive salt minions
````
# salt-run manage.down removekeys=True
````
