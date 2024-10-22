# Define the provider (here - AWS) and its version
terraform {
    required_providers {
      aws = {
        source  = "hashicorp/aws"
        version = "~> 4.16"
      }
      postgresql = {
        source = "cyrilgdn/postgresql"
        version = "1.23.0"
      }
    }
    required_version = ">= 1.2.0"
}

module "network" {
  source               = "./modules/network/"
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones   = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

module "rds_postgres" {
  source               = "./modules/rds_postgres/"
  private_subnet_ids = module.network.private_subnet_ids
  private_subnet_sg_id = module.network.private_sg_id
  postgres_identifier = "ma-rds-postgres"
  postgres_port = 5432
  db_name = "zpi"
  user_name = var.user_name
  user_password = var.user_password
}
