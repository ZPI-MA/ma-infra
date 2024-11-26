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

# RDS PostgreSQL Instance using a pre-existing security group by ID
resource "aws_db_instance" "postgresql" {
  allocated_storage      = 20
  engine                 = "postgres"
  engine_version         = "16.3"
  instance_class         = "db.t3.micro"
  db_name                = "mydatabase"
  username               = var.db_username
  password               = var.db_password
  parameter_group_name   = "default.postgres16"
  skip_final_snapshot    = true
  publicly_accessible    = true
  storage_type           = "gp2"
  vpc_security_group_ids = ["sgr-0b5bb71d0823f6b74"]

  backup_retention_period = 7
  maintenance_window      = "Mon:00:00-Mon:03:00"

  tags = {
    Name = "postgresql"
  }
}

