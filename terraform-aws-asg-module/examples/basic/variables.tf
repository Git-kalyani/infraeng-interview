variable "asg_name" {
  description = "Name for the Auto Scaling Group and related resources"
  type        = string
}

variable "certificate_arn" {
  description = "ARN of the ACM certificate for the ALB"
  type        = string
}