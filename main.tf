variable "vpc_cidr" {
  type = string
  default = "40.0.0.0/16"
}

terraform {
  required_providers {
	aws = {
  	source  = "hashicorp/aws"
	}
  }

}

data "aws_availability_zones" "available" {}

locals {
  region 	= "us-east-1"
  azs    	= slice(data.aws_availability_zones.available.names, 0, 3)

}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
 
  version = "~> 5.0"

  cidr = var.vpc_cidr
  azs          	= local.azs
  private_subnets  = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 4, k)]

  public_subnets   = [for k, v in local.azs : cidrsubnet(var.vpc_cidr, 8, k + 48)]
  enable_nat_gateway   = true
  enable_dns_support   = true
  enable_dns_hostnames = true
  single_nat_gateway   = true

 }



output "vpc_id" {
  description = "The ID of the VPC"
  value   	= module.vpc.vpc_id
}


output "public_subnets" {
  description = "List of IDs of public subnets"
  value   	= module.vpc.public_subnets[*]
}


data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
	name   = "name"
	values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
	name   = "virtualization-type"
	values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "web1" {
  ami       	= data.aws_ami.ubuntu.id
  instance_type = "t3.micro"

  tags = {
	Name = "HelloWorld"
  }
}




resource "aws_instance" "server" {
  ami       	= data.aws_ami.ubuntu.id
  instance_type = "t2.micro"
  count = 3
}
