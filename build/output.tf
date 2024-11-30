output "first_public_ip" {
  value       = module.ec2.first_instance_public_ip
  description = "Public IP address of the first manager EC2 instance"
}

output "other_public_ip" {
  value       = module.ec2.other_instances_public_ips
  description = "Public IP address of other manager EC2 instances"
}

output "rds_endpoint" {
  value       = var.is_prod ? module.rds[0].db_instance_endpoint : null
  description = "The connection endpoint for the RDS PostgreSQL instance"
}
