resource "aws_iam_role" "ssm_role" {
  name               = "${var.asg_name}-ssm-role"
  assume_role_policy = data.aws_iam_policy_document.ssm_assume_role_policy.json
}

data "aws_iam_policy_document" "ssm_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_instance_profile" "ssm_role" {
  name = "${var.asg_name}-ssm-instance-profile"
  role = aws_iam_role.ssm_role.name
}

resource "aws_iam_policy_attachment" "ssm_policy" {
  name       = "${var.asg_name}-ssm-policy-attachment"
  roles      = [aws_iam_role.ssm_role.name]
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy_attachment" "cw_agent_policy" {
  name       = "${var.asg_name}-cw-agent-policy-attachment"
  roles      = [aws_iam_role.ssm_role.name]
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["137112412989"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
}

resource "aws_security_group" "nginx" {
  name        = "${var.asg_name}-sg"
  description = "Allow HTTP from ALB"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Restrict to ALB SG in production
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_configuration" "this" {
  name_prefix          = var.asg_name
  image_id             = data.aws_ami.amazon_linux.id
  instance_type        = "t3.micro"
  user_data            = file("../../../scripts/install_nginx.sh")
  security_groups      = [aws_security_group.nginx.id]
  iam_instance_profile = aws_iam_instance_profile.ssm_role.name

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  desired_capacity      = 1
  max_size              = 3
  min_size              = 1
  vpc_zone_identifier   = var.private_subnet_ids
  launch_configuration  = aws_launch_configuration.this.id

  tag {
    key                 = "Name"
    value               = var.asg_name
    propagate_at_launch = true
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300
  force_delete              = true

  lifecycle {
    create_before_destroy = true
  }

  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
      instance_warmup        = 300
    }
    triggers = ["launch_configuration"]
  }
}

resource "aws_cloudwatch_log_group" "this" {
  name = "/var/log/messages"
}

resource "aws_cloudwatch_log_stream" "this" {
  name           = "messages"
  log_group_name = aws_cloudwatch_log_group.this.name
}

output "instance_ids" {
  value = aws_autoscaling_group.this.instances
}

output "load_balancer_dns" {
  value = var.lb_url
}