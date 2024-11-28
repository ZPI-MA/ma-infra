# output "rds_endpoint" {
#   value       = module.rds_postgres.db_instance_endpoint
#   description = "The connection endpoint for the RDS PostgreSQL instance"
# }

output "first_public_ip" {
  value       = module.ec2.first_instance_public_ip
  description = "Public IP address of the first manager EC2 instance"
}

output "other_public_ip" {
  value       = module.ec2.other_instance_public_ip
  description = "Public IP address of other manager EC2 instances"
}
