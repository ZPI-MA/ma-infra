output "db_instance_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "The connection endpoint for the RDS PostgreSQL instance"
}

output "db_instance_address" {
  value       = aws_db_instance.postgres.address
  description = "The address of the RDS PostgreSQL instance"
}
