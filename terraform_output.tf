output "nodejs_instance_ips" {
  value = aws_instance.vites.*.private_ip
}


output "postgres_endpoint" {
  value = aws_rds_cluster.postgres.endpoint
}
