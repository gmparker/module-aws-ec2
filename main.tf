
/*
Post Network Configuration
Need to enable Public IP Address Delegation on one of the subnets
Need the subnet ID for that Public Subnet and make sure it's in the correct AZ

subnet-009325653702f45f8

Need to create a security group and provide ID

*/

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "us-west-2"
}

locals {
  sg_name = "sg-Kong-EA-${var.env_name}"
  ec2_ami = "ami-0d593311db5abb72b"
  ec2_instance_type = "t2.micro"
  ec2_az = "us-west-2a"

  ec2_sgs = ["sg-0c007ab49c8dd4dc9"] 
  ec2_subnet = "subnet-009325653702f45f8"

  ec2_keypair = "kong-ea-keypair"

  tags = {
    Name                     = "Kong-EA"
    product                  = "kong"
    component                = "kong"
    service_domain           = "kong"
    environment              = "dev"
    version                  = "1.0"
    location                 = "us-west-2"
    data_classification      = "public"
    resource_classification  = "public"
    criticality_tier         = "tier_4"
    map-migrated             = "d-server-02mjo92lxl8um6"
    aws-migration-project-id = "MPE19465"
    team                     = "enterprise architecture"
    organization             = "lytx"
    function                 = "kong"
    department               = "enterprise architecture"
    owner                    = "enterprise architecture"
  }
}

resource "aws_security_group" "Kong-EA" {
  name        = "Kong-EA-Sandbox-SG"
  description = "Kong-EA Security Group"
  vpc_id      = "vpc-08b1aac1c6a2de169"

  ingress {
    description = "Inbound traffic from within the security group"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    self        = true
  }

  tags = local.tags
}


resource "aws_instance" "Kong-EA" {
  ami                    = local.ec2_ami
  instance_type          = local.ec2_instance_type
  availability_zone      = local.ec2_az
  vpc_security_group_ids = ["sg-0c007ab49c8dd4dc9"]
  subnet_id              = "subnet-009325653702f45f8"
  key_name               = local.ec2_keypair

  user_data = file("apache_config.sh")

  associate_public_ip_address = true
  tags                        = local.tags
  volume_tags                 = local.tags
}


# create and attach EBS volume
resource "aws_ebs_volume" "data-vol" {
  availability_zone = local.ec2_az
  size              = 8
  tags              = local.tags
}

#
resource "aws_volume_attachment" "kong-data-volume" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.data-vol.id
  instance_id = aws_instance.Kong-EA.id
}


