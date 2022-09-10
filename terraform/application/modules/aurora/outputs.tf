output "cluster" {
  value = aws_rds_cluster.db
}
output "instance" {
  value = aws_rds_cluster_instance.db
}
output "secretsmanager_secret_db" {
  value = aws_secretsmanager_secret.db.arn
}