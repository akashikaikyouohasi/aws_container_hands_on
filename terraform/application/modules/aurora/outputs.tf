output "cluster" {
  value = aws_rds_cluster.db
}
output "instance" {
  value = aws_rds_cluster_instance.db
}