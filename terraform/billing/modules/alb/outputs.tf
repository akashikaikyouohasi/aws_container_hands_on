output "intenal_alb" {
  value = aws_lb.intenal_alb
}
output "intenal_alb_target_group" {
  value = { for value in aws_lb_target_group.intenal_alb : value.name => value }
}