resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-west-2a"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_launch_configuration" "app" {
  name          = var.asg_name
  image_id     = data.aws_ami.amazon_linux.id
  instance_type = "t2.micro"
  user_data     = file("../../../scripts/install_nginx.sh")

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "app" {
  desired_capacity     = 1
  max_size             = 3
  min_size             = 1
  vpc_zone_identifier = [aws_subnet.private.id]
  launch_configuration = aws_launch_configuration.app.id

  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }

  health_check_type          = "EC2"
  health_check_grace_period  = 300
  force_delete                  = true
}

resource "aws_cloudwatch_log_group" "messages" {
  name = "/var/log/messages"
}

resource "aws_ssm_document" "session_manager" {
  name          = "SessionManagerDocument"
  document_type = "Session"
  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Session Manager Document"
    mainSteps = [
      {
        action = "aws:runCommand"
        name   = "runShellScript"
        inputs = {
          DocumentName = "AWS-RunShellScript"
          Parameters = {
            commands = ["echo 'Hello World'"]
          }
        }
      }
    ]
  })
}

resource "aws_autoscaling_policy" "replace_instance" {
  name                   = "replace-instance"
  scaling_adjustment      = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.app.name
}

resource "aws_lb" "app" {
  name               = "${var.asg_name}-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id]
  subnets            = [aws_subnet.private.id]

  enable_deletion_protection = false
}

resource "aws_lb_listener" "https" {
  load_balancer_arn = aws_lb.app.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.app.arn
  }
}

resource "aws_lb_target_group" "app" {
  name     = "${var.asg_name}-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_security_group" "lb_sg" {
  name        = "${var.asg_name}-lb-sg"
  description = "Allow HTTPS inbound"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "instance_ids" {
  value = aws_autoscaling_group.app.instance_ids
}

output "load_balancer_dns" {
  value = aws_lb.app.dns_name
}