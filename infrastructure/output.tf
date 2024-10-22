output "rds_endpoint" {
  value       = module.rds_postgres.db_instance_endpoint
  description = "The connection endpoint for the RDS PostgreSQL instance"
}

output "ec2_public_ip" {
  value       = module.ec2.instance_public_ip
  description = "Public IP address of the EC2 instance"
}
