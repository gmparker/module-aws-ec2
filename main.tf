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


resource "aws_instance" "Kong-EA" {
  ami                    = "ami-0d593311db5abb72b"
  instance_type          = "t2.micro"
  availability_zone      = "us-west-2a"
  vpc_security_group_ids = ["sg-01d2a472f0fb70c24"]
  subnet_id              = "subnet-06e3840091064add2"
  key_name               = "kong-ea-keypair"

  user_data = file("apache_config.sh")

  associate_public_ip_address = true
  tags                        = local.tags
  volume_tags                 = local.tags
}


# create and attach EBS volume
resource "aws_ebs_volume" "data-vol" {
  availability_zone = "us-west-2a"
  size              = 8
  tags              = local.tags
}

#
resource "aws_volume_attachment" "kong-data-volume" {
  device_name = "/dev/sdc"
  volume_id   = aws_ebs_volume.data-vol.id
  instance_id = aws_instance.Kong-EA.id
}
