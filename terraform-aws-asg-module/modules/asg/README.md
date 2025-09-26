# AWS Autoscaling Group Module

This module provides a Terraform configuration for creating an AWS Autoscaling Group (ASG) with ephemeral EC2 instances. It is designed to run the latest version of Amazon Linux 2023 and includes features such as SSM Session Manager access, CloudWatch logging, and automatic instance replacement.

## Inputs

- `autoscaling_group_name`: The name of the Autoscaling Group.
- `load_balancer_url`: The URL of the Load Balancer.

## Requirements

- The module will launch EC2 instances running Amazon Linux 2023.
- Instances will be accessible via SSM Session Manager.
- Logs from `/var/log/messages` will be sent to CloudWatch Logs.
- Instances will be replaced every 30 days.
- Nginx will be installed and configured to listen on port 80.
- EC2 instances will be hosted in private subnets.

## Bonus Features

- An Application Load Balancer (ALB) will be created to listen for TLS over HTTP and route traffic to the EC2 instances running Nginx.

## Usage

To use this module, include it in your Terraform configuration and provide the required input variables. Refer to the examples provided in the `examples/basic` directory for a basic setup.