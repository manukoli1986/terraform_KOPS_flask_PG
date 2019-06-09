

variable "AWS_ACCESS_KEY_ID" {
    default = "$(aws configure get aws_access_key_id)"
    }
variable "AWS_SECRET_ACCESS_KEY" {
    default = "$(aws configure get aws_secret_access_key)"
    }
variable "aws_region" {
    default = "ap-south-1"
    }

variable "key_name" {
    default = "deploy-user"
    }

variable "user" { 
    default = "ec2-user"
    }
