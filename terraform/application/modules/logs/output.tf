output "s3_bucket" {
  value = aws_s3_bucket.logs
}
output "logs_group" {
  value = aws_cloudwatch_log_group.logs
}