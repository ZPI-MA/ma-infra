# Define the provider (here - AWS) and its version
terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 4.16"
        }
    }
    required_version = ">= 1.2.0"
}

# Define the region in which AWS resources will 'physically' be created,
# optionally add a profile name (from the file .aws/credentials)
provider "aws" {
  region = "eu-central-1"
  # profile = var.credentials_profile
}

# Create the instance using some specific AMI, type t2.micro is perfectly fine for our needs
# Attach the subnet, security group, (optionally ssh key name)
# User data contains the script that will initially install docker and docker-compose on our instance
resource "aws_instance" "zpi_ec2" {
  ami                    = "ami-0e04bcbe83a83792e"
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.ec2_subnet.id
  vpc_security_group_ids = [aws_security_group.ec2_sec_group.id]
  key_name               = "ec2-ssh"

  tags = {
    Name = "zpi_ec2"
  }

  # user_data = <<-EOF
  #   #!/bin/bash
  #   ${var.ssh_public_key} >> ~/.ssh/known_hosts
  #   EOF
}

# Create Virtual Private Cloud and enable DNS and hostnames services inside it
resource "aws_vpc" "ec2_vpc" {
  cidr_block           = "10.0.0.0/24"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "ec2_vpc"
  }
}

# Attach an Internet gateway to make the instance visible from outside
resource "aws_internet_gateway" "ec2_gateway" {
  vpc_id = aws_vpc.ec2_vpc.id
  tags = {
    Name = "ec2_gateway"
  }
}

# Create a public subnet inside the instance
resource "aws_subnet" "ec2_subnet" {
  vpc_id                  = aws_vpc.ec2_vpc.id
  cidr_block              = "10.0.0.0/26"
  map_public_ip_on_launch = true 
  tags = {
    Name = "ec2_subnet"
  }
}

# Create a routing table, attach it to the instance's VPC and add a default route through the gateway
resource "aws_route_table" "ec2_rt" { 
  vpc_id = aws_vpc.ec2_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.ec2_gateway.id
  }

  tags = {
    Name = "ec2_rt"
  }
}

# Associate the routing table to the subnet to apply routing rules to that subnet
resource "aws_route_table_association" "ec2_rt_assoc" {
  subnet_id      = aws_subnet.ec2_subnet.id
  route_table_id = aws_route_table.ec2_rt.id
}

# Create a security group defining incoming and outcoming rules for the network
# That way we define and enable only the necessary ports for our application
# This security group is then attached to the VPC
resource "aws_security_group" "ec2_sec_group" {
  name        = "ec2_sec_group"
  vpc_id      = aws_vpc.ec2_vpc.id
  description = "Security group for accessing application and ec2 via SSH"

  # HTTP rule
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTPS rule
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  }

  # backend rule - port 8080
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  }

  # frontend rule - port 3000
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ssh - enable ssh connection
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # enable whole outcoming traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ec2_sec_group"
  }
}