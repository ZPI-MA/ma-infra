variable "hcp_client_id" {
  type      = string
  sensitive = true
}

variable "hcp_client_secret" {
  type      = string
  sensitive = true
}

variable "is_prod" {
  type      = bool
  default   = false
}
