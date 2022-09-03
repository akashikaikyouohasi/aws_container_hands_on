output "intenal_alb" {
  value = aws_lb.intenal_alb
}
output "intenal_alb_target_group" {
  value = { for value in aws_lb_target_group.intenal_alb : value.name => value }
}

output "intenal_alb_listener_blue" {
  value = aws_lb_listener.intenal_alb["internal_alb"]
}
output "intenal_alb_listener_green" {
  value = aws_lb_listener.intenal_alb_green
}
