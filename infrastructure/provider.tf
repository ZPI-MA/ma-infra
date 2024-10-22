# PROVIDERS - AWS and Postgres
provider "aws" {
  region  = "eu-central-1"
  profile = "admin"
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
