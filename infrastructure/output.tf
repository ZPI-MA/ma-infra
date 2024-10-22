output "rds_endpoint" {
  value       = module.rds_postgres.db_instance_endpoint
  description = "The connection endpoint for the RDS PostgreSQL instance"
}

output "rds_id" {
  value       =  module.rds_postgres.db_instance_id
  description = "The ID of the RDS PostgreSQL instance"
}