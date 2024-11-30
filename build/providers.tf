provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}

provider "postgresql" {
  host            = module.rds[0].db_instance_address
  port            = 5432
  database        = data.hcp_vault_secrets_app.postgres.secrets["db_name"]
  username        = data.hcp_vault_secrets_app.postgres.secrets["user_name"]
  password        = data.hcp_vault_secrets_app.postgres.secrets["user_password"]
  sslmode         = "require"
  connect_timeout = 15
}

provider "aws" {
  region     = "eu-central-1"
  access_key = data.hcp_vault_secrets_app.aws.secrets["access_key"]
  secret_key = data.hcp_vault_secrets_app.aws.secrets["secret_key"]
}
