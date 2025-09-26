variable "asg_name" {
  description = "Name for the Auto Scaling Group and related resources"
  type        = string
}

variable "lb_url" {
  description = "Load balancer URL or DNS name"
  type        = string
}

variable "private_subnet_ids" {
  description = "List of private subnet IDs for the Auto Scaling Group"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID for security group and resources"
  type        = string
}