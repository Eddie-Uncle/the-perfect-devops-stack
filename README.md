# The Perfect DevOps Stack 

### Description
Guide to implement automated deployment/delivering of PHP application using cutting edge tools

### Tools used
+ Terraform (Cloud provisioner - GCE coming soon)
+ Saltstack (Configuration management system)
+ Docker (Application runtime)
+ Consul (Service discovery)
+ Nomad (Containers/Cluster scheduler)

### Infrastructure components
+ stackhead (hosts terraform, consul server, nomad server and docker registry)
+ app (docker engine servers)
+ web (nginx as reserve proxy of the app containers)

## Preparing the enviroment
First we need to prepare our first instance(a.k.a. stack head) that will serve as our server for terraform, saltstack, nomad and consul.

All of the environment in this project was done using the AMI ami-0ca23e1b (CentOS 7.2 minimal).

1) Cloning the repository
````
mkdir /opt/devops && cd /opt/devops
````

````
git clone https://github.com/iarlyy/the-perfect-devops-stack && cd the-perfect-devops-stack
````

2) Initializing the stackhead server
````
sh scripts/install-stackhead.sh
````

3) Reboot the server


4) Save your AWS Key Pair as /opt/devops/the-perfect-devops-stack-files/aws.pem
````
How to generate Key Pair: AWS Console -> EC2 -> Key Pairs -> Create new Key Pair
````

4) Generate a new access keys and adjust the variables values

vi /opt/devops/the-perfect-devops-stack/terraform/terraform.tfvars
````
stack_head_ip_address = "172.X.Y.Z"

aws_access_key = "JGZTECMCNA..."
aws_secret_key = "K0Vk6STRNu..."
````

How to generate access keys: http://docs.aws.amazon.com/general/latest/gr/managing-aws-access-keys.html

5) Ajust the stackhead IP address to both consul and nomad salt pillars

vi salt/pillars/consul/init.sls
````
stackhead_ip_address: '172.X.Y.Z'
````

vi salt/pillars/nomad/init.sls
````
stackhead_ip_address: '172.X.Y.Z'
````

6) Apply the salt profile to the stackhead server
````
salt -G 'role:stackhead' state.highstate
````

## Provisioning the applications

1) Cloud instances provisioning
````
cd /opt/devops/the-perfect-devops-stack/terraform
````

````
terraform apply
````

2) Check if the instances are connected to saltstack
````
salt '*' test.ping
````

3) Assign role to all newly created instances and restart salt-minion
````
salt -G 'role:app' file.write /etc/salt/grains "role:
  - app
  - consul
  - nomad
  - docker
  - registrator
"
````

````
salt -G 'role:app' service.restart salt-minion
````
The command above will timeout, to test if the minion is up again run a test.ping

````
salt -G 'role:app' test.ping
````

4) Push the installation of the application servers
````
salt -G 'role:app' state.highstate
````

5) Build a sample php-fpm docker image
````
cd ../docker/phpfpm
````

````
docker build -t phpfpm:0.1 .
````

````
docker tag phpfpm:0.1 stackhead:5000/phpfpm:0.1
````

````
docker push stackhead:5000/phpfpm:0.1
````

6) Run nomad job
````
cd ../../nomad
````

````
nomad run wp.nomad
````

7) Assign role to the web instance instance and restart salt-minion
````
salt -G 'role:web' file.write /etc/salt/grains "role:
  - web
  - consul
  - consul-template
"
````

````
salt -G 'role:web' service.restart salt-minion
````

8) Push the installation of the web server
````
salt -G 'role:web' state.highstate
````

At this point you should have a nginx server returning its default blank page and two containers running in each app* instance. Go ahead and add the vhosts to the /etc/nginx/conf.d/(will be automated in the future), there's an example of a wordpress vhost on the "extras" directory of this repository.

## Scaling up/down

1) Terraform

* File: terraform/ec2-instances.tf

Change the "count" value of the instances (default: 1). Repeat the steps 3-4 every time a new app instaces are deployed and steps 7-8 every time a new web instance is deployed.

2) Docker containers

* File: nomad/wp.nomad

Change the "count" value of the desired group you want to deploy more containers and run nomad again (step 6). Nomad and Consul-template will take care of the rest.

3) What else should i add here?...

## TODO
* Create nginx vhosts formula
* Add RDS resource to AWS tf template
* Add Elastic IP/Route53 resources to add/del IPs to domain
* Create GCE tf template

## Something wrong?
* SELinux blocking incoming traffic to the containers (salt '*' cmd.run 'setenforce 0')
* IP forward disabled (sysctl -w net.ipv4.ip_forward=1)

## Helpful commands 
* Remove inactive salt minions
````
salt-run manage.down removekeys=True
````
