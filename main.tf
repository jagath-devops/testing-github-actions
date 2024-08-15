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
