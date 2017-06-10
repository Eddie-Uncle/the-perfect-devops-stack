# The Perfect DevOps Stack 
### (work in progress, stay tuned)

### Tools used
+ Terraform (Cloud provisioner)
+ Saltstack (Configuration management system)
+ Docker (Application runtime) 
+ Consul (Service discovery)
+ Nomad (Containers/Cluster scheduler)

### Infrastructure components
+ stackhead (hosts terraform, consul server, nomad server and docker registry)
+ app (docker engine servers)
+ web (nginx as reserve proxy of the app containers)

## Preparing the enviroment
First we need to prepare our first instance(stack head) that will serve as our server for terraform, saltstack, nomad and consul.

All of the environment in this project was done using the AMI ami-0ca23e1b (CentOS 7.2 minimal).

1) Cloning the repository
````
# mkdir /opt/devops && cd /opt/devops
````

````
# git clone https://github.com/iarlyy/the-perfect-devops-stack && cd the-perfect-devops-stack
````

2) Initializing the stackhead server
````
# sh scripts/install-stackhead.sh
````

3) Reboot the server


4) Generate a key pair and save it to /opt/devops/the-perfect-devops-stack/files/aws.pem
````
# mkdir /opt/devops/the-perfect-devops-stack/files
````

AWS Console -> EC2 -> Key Pairs -> Create new Key Pair


4) Generate a new access keys and set the values accordingly on /opt/devops/the-perfect-devops-stack/terraform/terraform.tfvars
````
stack_head_ip_address = "172.X.Y.Z"

aws_access_key = "JGZTECMCNA..."
aws_secret_key = "K0Vk6STRNu..."
````

How to generate access keys: http://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html

5) Add the stackhead IP address to both consul and nomad salt pillars

````
# vi salt/pillars/consul/init.sls
stackhead_ip_address: '172.X.Y.Z'
````

````
# vi salt/pillars/nomad/init.sls
stackhead_ip_address: '172.X.Y.Z'
````

6) Apply the salt profile to the stackhead server
````
# salt -G 'role:stackhead' state.highstate
````

7) Terraform apply
````
# cd /opt/devops/the-perfect-devops-stack/terraform
````

````
# terraform apply
````

8) Ping if the instance is already connected to saltstack
````
# salt '*' test.ping
````

9) Assign role to all newly created instances and restart salt-minion
````
# salt -G 'role:app' file.write /etc/salt/grains "role:
  - app
  - consul
  - nomad
  - docker
  - registrator
"
````

````
# salt -G 'role:app' service.restart salt-minion
````
The command above will timeout, to test if the minion is up again run a test.ping

````
salt -G 'role:app' test.ping
````

10) Push the installation of the application servers
````
# salt -G 'role:app' state.highstate
````

11) Build a sample php-fpm docker image
````
# cd ../docker/phpfpm
````

````
# docker build -t phpfpm:0.1 .
````

````
# docker tag phpfpm:0.1 stackhead:5000/phpfpm:0.1
````

````
# docker push stackhead:5000/phpfpm:0.1
````

12) Run nomad job
````
# cd ../../nomad
````

````
# nomad run wp.nomad
````

13) Assign role to the web instance instance and restart salt-minion
````
# salt -G 'role:web' file.write /etc/salt/grains "role:
  - web
  - consul
  - consul-template
"
````

````
# salt -G 'role:web' service.restart salt-minion
````

14) Push the installation of the web server
````
# salt -G 'role:web' state.highstate
````

## Helpful commands 
* Remove inactive salt minions
````
# salt-run manage.down removekeys=True
````
