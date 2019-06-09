# Project Details
> This is a project to build webapp using python flask framework and deploy it on Kubernetes cluster using KOPS. I am using AWS cloud as a target infra. This project uses Prometheus to collect metrcis from flask webapp and represent visualization on Grafana platfrom. The entire project is intended to be a container based system which is provisioned on EKS using KOPS.

### NOTE: 
I have used subdomain "kubernetes.automatedesire.com" to create kubernetes cluster using kops with below command and configured it with ROUTE53 DNS service, make sure you have dedicated domain name which you can bind to your KOPS cluster. 

### Prerequisites
You should have aws account with  the following resource created:
* AWS access/secret keys
* VPC and subnet
* Key pair 

Assign value :
+ AWS Access/Secret key : Use to access you AWS resource
+ key-pair :  will use by ansible for remote login


Below are the specs used in this project:
* DockerImage: Creating using Dockerfile
* Configuration Management: Ansible
* IAAS : Terraform
* Cloud provider : AWS
* KOPS : To setup Kubernetes Cluster
* Prometheus : For data storing in time-series format
* Docker : To run containers 
* Grafana : Visualization

### This project consist of two steps:
1. Create flask-webapp and deployed it on AWS kubernetes cluster using KOPS.

> To create kubernetes cluster using KOPS where master and worker nodes configuration will be "t2.micro" with 1 node each in "ap-south-1a" zone. Also using s3 bucket for storing KOPS state. 
```
kops create cluster --name=kubernetes.automatedesire.com --state=s3://kops-state-1111 --zones=ap-south-1a --node-count=1 --node-size=t2.micro --master-size=t2.micro  --dns-zone=kubernetes.automatedesire.com
```


> To delete kubernetes cluster using KOPS
```
kops delete cluster --name=kubernetes.automatedesire.com --state=s3://kops-state-1111  --yes
```

a. Wait for few minutes till master and worker nodes do not get provisioned then check node status with below command. 
```kubectl get nodes
NAME                                           STATUS   ROLES    AGE   VERSION
ip-172-20-32-255.ap-south-1.compute.internal   Ready    master   85s   v1.12.8
ip-172-20-44-6.ap-south-1.compute.internal     Ready    node     6s    v1.12.8
```

b. Then go to simple_python_app_on_kubernetes directory to launch flask webapp on kubernetes and also check app is exposed with as load-balancer

```kubectl create -f flask-webapp-deployment.yaml  -f flask-webapp-deployment-service.yaml && kubectl get svc
deployment.apps/flask-app-deployment created
service/flask-app-svc created
NAME            TYPE           CLUSTER-IP    EXTERNAL-IP                                                                PORT(S)        AGE
flask-app-svc   LoadBalancer   100.71.54.9   a1cbbf2db8abb11e9928e02f2574db19-1407757864.ap-south-1.elb.amazonaws.com   80:31547/TCP   15s
kubernetes      ClusterIP      100.64.0.1    <none>                                                                     443/TCP        3m6s
```

c. We can access flask app using "External-IP" on browser but no one can remember this unique name given by ELB, so to overcome this we can create "A" record with choosing target as ELB id.
i.e.  For my case I am using random one "messagebird.automatedesire.com."
![alt text](https://github.com/manukoli1986/terraform_KOPS_flask_PG/blob/master/image/home.png)

d. This Webapp show Homer Simpson picture by accessing /homersimpson & the time in the moment og requestin Covilha City (Portugal) when accessing /covilha.
![alt text](https://github.com/manukoli1986/terraform_KOPS_flask_PG/blob/master/image/homersimpson.png)
![alt text](https://github.com/manukoli1986/terraform_KOPS_flask_PG/blob/master/image/covilha.png)
![alt text](https://github.com/manukoli1986/terraform_KOPS_flask_PG/blob/master/image/covilha1.png)

e. Below are the modules used for app to working fine.
```
Used below modules:
Flask - It began as a simple wrapper around Werkzeug and Jinja and has become one of the most popular Python web application frameworks.
pytz - pytz brings the Olson tz database into Python. This library allows accurate and cross platform timezone calculations using Python 2.4 or higher.
prometheus_flask_exporter - This library provides HTTP request metrics to export into Prometheus. It can also track method invocations using convenient functions.
```

2. Deploying prometheus and grafana on EC2 using terraform code which uses configration management tool (ansible)

a. Rather than setting up prometheus and grafana on EC2, I have used them in container-based and running via docker-compose.yml. Make sure you provisioned your EC2 with all required packages. ( docker/python-pip/docker-compse ). 

b. Go to "prometheus-docker" directory and you will see docker-compsose file with manual configration of dashboard, datasource and prometheus target entry.

c. Terraform which famously known for IAAC. I have used it to deploy EC2 with all required package to run prometheus and grafana using ansible-playbook. It will copy prometheus-docker and ansible directory inside EC2 while provisioning it. 

> Note: Make sure you have configured your environment with AWS access and secret key and .pem file to login into created EC2 

*Please follow below command. 
#Go to "aws directory to run terrafrom code."
```
$terraform init -- The terraform init command is used to initialize a working directory containing Terraform configuration files.

$terrafrom plan -- The terrafrom plan will pre-determined set of actions generated by a terraform plan execution plan

$terrafrom apply -- The terraform apply command is used to apply the changes required to reach the desired state of the configuration.

$terrafrom delete -- The terraform destroy command is used to destroy the Terraform-managed infrastructure
```
```
$terrafrom init
Initializing the backend...

Initializing provider plugins...
- Checking for available provider plugins...
- Downloading plugin for provider "null" (terraform-providers/null) 2.1.2...
- Downloading plugin for provider "aws" (terraform-providers/aws) 2.14.0...

The following providers do not have any version constraints in configuration,
so the latest version was installed.

To prevent automatic upgrades to new major versions that may contain breaking
changes, it is recommended to add version = "..." constraints to the
corresponding provider blocks in configuration, with the constraint strings
suggested below.

* provider.aws: version = "~> 2.14"
* provider.null: version = "~> 2.1"

Terraform has been successfully initialized!

You may now begin working with Terraform. Try running "terraform plan" to see
any changes that are required for your infrastructure. All Terraform commands
should now work.

If you ever set or change modules or backend configuration for Terraform,
rerun this command to reinitialize your working directory. If you forget, other
commands will detect it and remind you to do so if necessary.
```

```
$terrafrom plan
Refreshing Terraform state in-memory prior to plan...
The refreshed state will be used to calculate this plan, but will not be
persisted to local or remote state storage.


------------------------------------------------------------------------

An execution plan has been generated and is shown below.
Resource actions are indicated with the following symbols:
  + create

Terraform will perform the following actions:

  # aws_instance.prometheus-stack will be created
  + resource "aws_instance" "prometheus-stack" {
      + ami                          = "ami-00e782930f1c3dbc7"
      + arn                          = (known after apply)
      + associate_public_ip_address  = (known after apply)
      + availability_zone            = (known after apply)
      + cpu_core_count               = (known after apply)
      + cpu_threads_per_core         = (known after apply)
      + get_password_data            = false
      + host_id                      = (known after apply)
      + id                           = (known after apply)
      + instance_state               = (known after apply)
      + instance_type                = "t2.micro"
      + ipv6_address_count           = (known after apply)
      + ipv6_addresses               = (known after apply)
      + key_name                     = "deploy-user"
      + network_interface_id         = (known after apply)
      + password_data                = (known after apply)
      + placement_group              = (known after apply)
      + primary_network_interface_id = (known after apply)
      + private_dns                  = (known after apply)
      + private_ip                   = (known after apply)
      + public_dns                   = (known after apply)
      + public_ip                    = (known after apply)
      + security_groups              = [
          + "All_traffic",
        ]
      + source_dest_check            = true
      + subnet_id                    = (known after apply)
      + tags                         = {
          + "Name" = "prometheus-stack"
        }
      + tenancy                      = (known after apply)
      + volume_tags                  = (known after apply)
      + vpc_security_group_ids       = (known after apply)

      + ebs_block_device {
          + delete_on_termination = (known after apply)
          + device_name           = (known after apply)
          + encrypted             = (known after apply)
          + iops                  = (known after apply)
          + snapshot_id           = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }

      + ephemeral_block_device {
          + device_name  = (known after apply)
          + no_device    = (known after apply)
          + virtual_name = (known after apply)
        }

      + network_interface {
          + delete_on_termination = (known after apply)
          + device_index          = (known after apply)
          + network_interface_id  = (known after apply)
        }

      + root_block_device {
          + delete_on_termination = (known after apply)
          + iops                  = (known after apply)
          + volume_id             = (known after apply)
          + volume_size           = (known after apply)
          + volume_type           = (known after apply)
        }
    }

  # aws_security_group.All_traffic will be created
  + resource "aws_security_group" "All_traffic" {
      + arn                    = (known after apply)
      + description            = "Allow all inbound traffic"
      + egress                 = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 0
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "-1"
              + security_groups  = []
              + self             = false
              + to_port          = 0
            },
        ]
      + id                     = (known after apply)
      + ingress                = [
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 22
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 22
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 3000
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 3000
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 8080
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 8080
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 80
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 80
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 9090
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 9090
            },
          + {
              + cidr_blocks      = [
                  + "0.0.0.0/0",
                ]
              + description      = ""
              + from_port        = 9093
              + ipv6_cidr_blocks = []
              + prefix_list_ids  = []
              + protocol         = "tcp"
              + security_groups  = []
              + self             = false
              + to_port          = 9093
            },
        ]
      + name                   = "All_traffic"
      + owner_id               = (known after apply)
      + revoke_rules_on_delete = false
      + vpc_id                 = (known after apply)
    }

  # null_resource.prometheus-stack will be created
  + resource "null_resource" "prometheus-stack" {
      + id       = (known after apply)
      + triggers = (known after apply)
    }

Plan: 3 to add, 0 to change, 0 to destroy.

------------------------------------------------------------------------

Note: You didn't specify an "-out" parameter to save this plan, so Terraform
can't guarantee that exactly these actions will be performed if
"terraform apply" is subsequently run.

```

```
$terrafrom apply

below is the final output of public IP.


Apply complete! Resources: 3 added, 0 changed, 0 destroyed.

Outputs:

ec2_global_ips = [
  [
    "13.233.230.108",
  ],
]
```

d. Now you can access above created EC2 with provided IP using ec2-user.

```
# ssh -i /tmp/deploy-user.pem ec2-user@13.233.230.108
The authenticity of host '13.233.230.108 (13.233.230.108)' can't be established.
ECDSA key fingerprint is 19:1f:42:79:94:4d:27:e2:3d:93:59:e7:ac:84:84:1d.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added '13.233.230.108' (ECDSA) to the list of known hosts.
Last login: Sun Jun  9 14:14:08 2019 from 112.196.159.155

       __|  __|_  )
       _|  (     /   Amazon Linux 2 AMI
      ___|\___|___|

https://aws.amazon.com/amazon-linux-2/
5 package(s) needed for security, out of 7 available
Run "sudo yum update" to apply all updates.
[ec2-user@ip-172-31-26-126 ~]$
```

e. Now your prometheus and grafana has been installed and running on default ports. 
prometheus - 13.233.230.108:9090
grafana - 13.233.230.108:3000 (Enabled anonymous account to view dashbaord)

![alt text](https://github.com/manukoli1986/terraform_KOPS_flask_PG/blob/master/image/prometheus.png)
![alt text](https://github.com/manukoli1986/terraform_KOPS_flask_PG/blob/master/image/grafana.png)
