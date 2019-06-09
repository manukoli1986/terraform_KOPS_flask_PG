provider "aws" {
    shared_credentials_file = "/root/.aws/credentials"
#    access_key = "${var.AWS_ACCESS_KEY_ID}"
#    secret_key = "${var.AWS_SECRET_ACCESS_KEY}"
    region     = "${var.aws_region}"
}

resource "aws_instance" "prometheus-stack" {
  ami = "ami-00e782930f1c3dbc7"
  instance_type = "t2.micro"
  key_name = "${var.key_name}"
  security_groups = ["All_traffic"]
  tags = {
    Name= "prometheus-stack"
  }
}

resource "null_resource" "prometheus-stack" {
  triggers = {
    public_ip = "${aws_instance.prometheus-stack.public_ip}"
  }
  connection {
    type     = "ssh"
    host     = "${aws_instance.prometheus-stack.public_ip}"
    user     = "${var.user}"
    password = ""
    private_key = "${file("/tmp/deploy-user.pem")}"
  }
  provisioner "remote-exec" {
    inline = [
        "sudo amazon-linux-extras install ansible2 -y",
#        "sudo amazon-linux-extras install docker -y",
    ]
  }

  provisioner "file" {
    source      = "../ansible/ansible-deployment.yml"
    destination = "/tmp/ansible-deployment.yml"
  }
  provisioner "file" {
    source      = "../prometheus-docker"
    destination = "/tmp"
  } 
  
  provisioner "remote-exec" {
    inline = [
      "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --connection=local  /tmp/ansible-deployment.yml",
    ]
  }
  
}




resource "aws_security_group" "All_traffic" {
  name        = "All_traffic"
  description = "Allow all inbound traffic"
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # add your IP address here
  }
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # add your IP address here
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # add your IP address here
  }
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # add your IP address here
  }
  ingress {
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # add your IP address here
  }
  ingress {
    from_port   = 9093
    to_port     = 9093
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # add your IP address here
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

