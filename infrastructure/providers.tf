provider "hcp" {
  client_id     = var.hcp_client_id
  client_secret = var.hcp_client_secret
}

provider "postgresql" {
  host            = aws_db_instance.postgres.address
  port            = 5432
  database        = var.db_name
  username        = var.user_name
  password        = var.user_password
  sslmode         = "require"
  connect_timeout = 15
}

provider "aws" {
  region     = "eu-central-1"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
