variable "credentials_profile" {
  description = "Please provide the credentials profile's name. Default = default"
  type        = string
  default     = "default"
}

variable "ssh_public_key" {
    description = "Key used for SSH connections with EC2 instances"
    type        = string
}
