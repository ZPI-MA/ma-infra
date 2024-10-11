variable "credentials_profile" {
  description = "Please provide the credentials profile's name. Default = default"
  type        = string
  default     = "default"
}

variable "gitlab_ssh_public" {
  type = string
}

variable "ec2_ssh_private" {
  type = string
}

variable "secrets_ini" {
  type = string
}