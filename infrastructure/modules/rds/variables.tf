variable "private_subnet_ids" {
  type        = list(string)
  description = "List of IDs of the Music Assistant private subnets"
}

variable "private_subnet_sg_id" {
  type        = string
  description = "ID of the Music Assistant private subnet security group"
}

variable "postgres_identifier" {
  description = "Identifier - can be the same as the database name."
  type        = string
}

variable "postgres_port" {
  description = "Port for PostgreSQL. Default = 5432."
  type        = string
  default     = "5432"
}

variable "db_name" {
  type = string
}

variable "user_name" {
  type        = string
  sensitive   = true
}

variable "user_password" {
  type        = string
  sensitive   = true
}
