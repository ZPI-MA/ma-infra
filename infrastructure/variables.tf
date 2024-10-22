variable "gitlab_ssh_public" {
  type = string
}

variable "ec2_ssh_private" {
  type = string
}

variable "secrets_ini" {
  type = string
}

variable "db_user_name" {
  type        = string
  sensitive   = true
}

variable "db_user_password" {
  type        = string
  sensitive   = true
}
