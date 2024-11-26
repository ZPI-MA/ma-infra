# Define the provider (here - AWS) and its version
terraform {
    required_providers {
      hcp = {
        source  = "hashicorp/hcp"
        version = "~> 0.91.0"
      }
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

data "hcp_vault_secrets_app" "aws" {
  app_name = "aws"
}

data "hcp_vault_secrets_app" "duckdns" {
  app_name = "duckdns"
}

data "hcp_vault_secrets_app" "postgres" {
  app_name = "postgres"
}

data "hcp_vault_secrets_app" "spotify" {
  app_name = "spotify-api"
}

data "hcp_vault_secrets_app" "ssh" {
  app_name = "ssh"
}

data "hcp_vault_secrets_app" "gitlab" {
  app_name = "gitlab-container-registry"
}

module "network" {
  source               = "./modules/network/"

  aws_access_key       = data.hcp_vault_secrets_app.aws.secrets["access_key"]
  aws_secret_key       = data.hcp_vault_secrets_app.aws.secrets["secret_key"]

  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"]
  availability_zones   = ["eu-central-1a", "eu-central-1b", "eu-central-1c"]
}

module "ec2" {
  source                        = "./modules/ec2/"

  # AWS credentials
  aws_access_key                = data.hcp_vault_secrets_app.aws.secrets["access_key"]
  aws_secret_key                = data.hcp_vault_secrets_app.aws.secrets["secret_key"]

  # SSH keys
  gitlab_ssh_public             = data.hcp_vault_secrets_app.ssh.secrets["gitlab_ssh_public"]
  ec2_ssh_private               = data.hcp_vault_secrets_app.ssh.secrets["ec2_ssh_private"]

  # Secrets that will be passed to docker secret create command
  secrets_spotify_client_id     = data.hcp_vault_secrets_app.spotify.secrets["client_id"]
  secrets_spotify_client_secret = data.hcp_vault_secrets_app.spotify.secrets["client_secret"]
  secrets_database_user         = data.hcp_vault_secrets_app.postgres.secrets["user_name"]
  secrets_database_password     = data.hcp_vault_secrets_app.postgres.secrets["user_password"]
  secrets_gitlab_access_token   = data.hcp_vault_secrets_app.gitlab.secrets["access_token"]

  # Network config
  public_subnet_id              = module.network.public_subnet_id
  public_sg_id                  = module.network.public_sg_id
}

# module "rds_postgres" {
#   source               = "./modules/rds_postgres/"
#   private_subnet_ids   = module.network.private_subnet_ids
#   private_subnet_sg_id = module.network.private_sg_id
#   postgres_identifier  = "ma-rds-postgres"
#   postgres_port        = 5432
#   db_name              = "zpi"
#   user_name            = var.db_user_name
#   user_password        = var.db_user_password
# }
