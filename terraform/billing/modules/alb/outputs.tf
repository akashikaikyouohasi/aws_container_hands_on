output "internal_alb" {
  value = aws_lb.internal_alb
}
output "internal_alb_target_group" {
  value = { for value in aws_lb_target_group.internal_alb : value.name => value }
}

output "internal_alb_listener_blue" {
  value = aws_lb_listener.internal_alb["internal_alb"]
}
output "internal_alb_listener_green" {
  value = aws_lb_listener.internal_alb_green
}



output "frontend_alb" {
  value = aws_lb.frontend_alb
}
output "frontend_alb_target_group" {
  value = { for value in aws_lb_target_group.frontend_alb : value.name => value }
}

output "frontend_alb_listener_blue" {
  value = aws_lb_listener.frontend_alb["frontend_alb"]
}
output "frontend_alb_listener_green" {
  value = aws_lb_listener.frontend_alb_green
}