output "ec2_public_ip" {
  value       = module.ec2.instance_public_ip
  description = "Public IP address of the EC2 instance"
}

output "rds_endpoint" {
  value       = var.is_prod ? module.rds[0].db_instance_endpoint : null
  description = "The connection endpoint for the RDS PostgreSQL instance"
}
