output "db_instance_endpoint" {
  value       = aws_db_instance.postgres.endpoint
  description = "The connection endpoint for the RDS PostgreSQL instance"
}

output "db_instance_id" {
  value       = aws_db_instance.postgres.id
  description = "The ID of the RDS PostgreSQL instance"
}
