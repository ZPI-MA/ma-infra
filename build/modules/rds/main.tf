resource "aws_db_subnet_group" "ma_private_subnet" {
  name       = "ma-private-subnet-group"
  subnet_ids = var.private_subnet_ids

  tags = {
    Name = "Music Assistant private subnet"
  }
}

resource "aws_db_instance" "postgres" {
  allocated_storage         = 20
  storage_type              = "gp2"  # Default one, from docs: "gp2" (general purpose SSD)
  engine                    = "postgres"
  engine_version            = "16.4"
  instance_class            = "db.t4g.small"
  identifier                = var.postgres_identifier
  db_name                   = var.db_name
  username                  = var.user_name  # Username of master db user
  password                  = var.user_password  # Password of master db user
  publicly_accessible       = false
  parameter_group_name      = "default.postgres16"  # Parameter group to control database settings
  vpc_security_group_ids    = [var.private_subnet_sg_id]
  db_subnet_group_name      = aws_db_subnet_group.ma_private_subnet.name
  skip_final_snapshot       = true

  # Backup and Maintenance
  backup_retention_period   = 14  # 14 days
  maintenance_window        = "Mon:00:00-Mon:03:00"  # The window to perform maintenance in

  tags = {
    Name = "Music Assistant RDS PostgreSQL Database"
  }
}
