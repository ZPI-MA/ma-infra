variable "gitlab_ssh_public" {
  type = string
}

variable "ec2_ssh_private" {
  type = string
}

variable "secrets_ini" {
  type = string
}

variable "public_subnet_id" {
  type        = string
  description = "ID of the Music Assistant public subnet"
}

variable "public_sg_id" {
  type        = string
  description = "ID of the Music Assistant public subnet security group"
}
