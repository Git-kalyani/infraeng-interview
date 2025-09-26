# Basic Example of AWS Autoscaling Group Module

This README provides instructions on how to use the AWS Autoscaling Group module in a basic setup.

## Prerequisites

- Ensure you have Terraform installed on your machine.
- AWS credentials configured for Terraform to access your AWS account.

## Usage

1. Clone the repository:

   git clone <repository-url>

2. Navigate to the example directory:

   cd terraform-aws-asg-module/examples/basic

3. Initialize Terraform:

   terraform init

4. Review the configuration:

   terraform plan

5. Apply the configuration:

   terraform apply

## Resources Created

This example will create the following resources:

- An AWS Autoscaling Group with the specified configuration.
- EC2 instances running the latest version of Amazon Linux 2023.
- An Application Load Balancer that listens on TLS over HTTP and routes traffic to the EC2 instances running Nginx.

## Cleanup

To remove the resources created by this example, run:

terraform destroy

This will delete all resources created by the Terraform configuration.