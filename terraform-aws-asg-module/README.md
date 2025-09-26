# AWS Autoscaling Group Module

This module provides a Terraform configuration for creating an AWS Autoscaling Group (ASG) that runs ephemeral EC2 instances. It is designed to be flexible and reusable, allowing users to easily integrate it into their infrastructure.

## Inputs

The module requires the following input variables:

- `autoscaling_group_name`: The name of the Autoscaling Group.
- `load_balancer_url`: The URL of the Load Balancer that will route traffic to the EC2 instances.

## Requirements

The module is designed to meet the following requirements:

1. Launch EC2 instances running the latest version of Amazon Linux 2023.
2. Ensure EC2 instances are accessible via SSM Session Manager.
3. Send `/var/log/messages` from the EC2 instances to CloudWatch Logs.
4. Automatically replace instances in the Autoscaling Group every 30 days.
5. Install and configure Nginx to listen on port 80.
6. Host EC2 instances in private subnets.

## Bonus Features

- Create an Application Load Balancer that listens for TLS over HTTP and routes traffic to the EC2 instances running Nginx.

## Usage

To use this module, include it in your Terraform configuration and provide the required input variables. Refer to the examples provided in the `examples` directory for guidance on how to implement this module in your projects.