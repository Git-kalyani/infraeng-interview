output "instance_ids" {
  value = aws_autoscaling_group.asg.instances
}

output "load_balancer_dns" {
  value = aws_lb.example.dns_name
}