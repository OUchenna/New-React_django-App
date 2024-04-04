resource "aws_rds_cluster" "postgres" {
  cluster_identifier = "my-postgres-cluster"
  db_name           = "my-app-db"
  master_username   = "postgres"
  master_password   = "your_strong_password"
  database_cluster_parameter_group_name = "default"
  engine            = "postgres"
  engine_version    = "14.0"
  allocated_storage = 20
  instance_class    = "db.t2.micro" # Update with desired instance type
  vpc_security_group_ids = [aws_security_group.db.id]
}
