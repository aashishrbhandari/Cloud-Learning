/*
  
  Why I wrote the block: terraform {} & provider "aws" {}
  Ref: https://stackoverflow.com/questions/68216074/do-terraform-modules-need-required-providers
  
  In Simple Words: With Latest Version of Terraform, It is intelligent enough to identify that we are working with aws the moment we added the block `resource "aws_vpc"`
  Note: Provider is IMP, Since you will have to mention the region where you want to create the VPC, it will set by default to us-east-1.
*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
    }
  }
}
   
provider "aws" {
  region = "us-east-1"
}

resource "aws_vpc" "Trail-Dev-VPC" {
  cidr_block = "10.30.0.0/16"
  tags = {
    Name = "Trail-Dev-VPC"
  }
}
