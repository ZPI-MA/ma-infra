variable "aws_access_key" {
  type      = string
  sensitive = true
}

variable "aws_secret_key" {
  type      = string
  sensitive = true
}

variable "gitlab_ssh_public" {
  type      = string
  sensitive = true
}

variable "ec2_ssh_private" {
  type      = string
  sensitive = true
}

variable "secrets_spotify_client_id" {
  type      = string
  sensitive = true
}

variable "secrets_spotify_client_secret" {
  type      = string
  sensitive = true
}

variable "secrets_database_user" {
  type      = string
  sensitive = true
}

variable "secrets_database_password" {
  type      = string
  sensitive = true
}    

variable "secrets_gitlab_access_token" {
  type = string
  sensitive = true
}

variable "public_subnet_id" {
  type        = string
  description = "ID of the Music Assistant public subnet"
}

variable "public_sg_id" {
  type        = string
  description = "ID of the Music Assistant public subnet security group"
}
