resource "aws_security_group" "nodejs" {
  name   = "NodejsSecurityGroup"
  vpc_id = aws_vpc.main.id # Replace with your VPC ID

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Update to restrict access (e.g., your IP)
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Update to restrict access if needed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_launch_template" "nodejs" {
  name          = "NodejsLaunchTemplate"
  image_id      = "ami-04b70fa74e45c3917" # Update with your desired Node.js AMI
  instance_type = "t2.micro"              # Update with desired instance type

  vpc_security_group_ids = [aws_security_group.nodejs.id]

  user_data = "IyBJbnN0YWxsIE5vZGUuanMgYW5kIHBhY2thZ2UgbWFuYWdlcgpjdXJsIC1zTCBodHRwczovL2RlYi5ub2Rlc291cmNlLmNvbS9zZXR1cF8xOC54IHwgc3VkbyAtRSBiYXNoIC0Kc3VkbyBhcHQtZ2V0IHVwZGF0ZSAmJiBzdWRvIGFwdC1nZXQgaW5zdGFsbCAteSBub2RlanMKCiMgQ2xvbmUgeW91ciBSZWFjdCBhcHAgcmVwb3NpdG9yeSBmcm9tIEdpdGh1YiAocmVwbGFjZSB3aXRoIHlvdXIgZGV0YWlscykKZ2l0IGNsb25lIGh0dHBzOi8vZ2l0aHViLmNvbS9PVWNoZW5uYS9OZXctUmVhY3QtZGphbmdvLUFwcC5naXQKCiMgTmF2aWdhdGUgdG8gdGhlIGFwcGxpY2F0aW9uIGRpcmVjdG9yeQpjZCBOZXctUmVhY3QtRGphbmdvLUFwcC9Db21wdXRleEZyb250ZW5kCgojIEluc3RhbGwgZGVwZW5kZW5jaWVzCm5wbSBpbnN0YWxsCgojIEJ1aWxkIHRoZSBSZWFjdCBhcHAKbnBtIHJ1biBidWlsZAoKIyBTdGFydCB5b3VyIE5vZGUuanMgc2VydmVyIChyZXBsYWNlIHdpdGggeW91ciBzdGFydCBjb21tYW5kKQpucG0gc3RhcnQK"
}

resource "aws_autoscaling_group" "nodejs" {
  name                = "NodejsAutoscalingGroup"
  vpc_zone_identifier = [aws_subnet.main.id] # Replace with your subnet ID

  launch_template {
    id = aws_launch_template.nodejs.id
  }

  min_size         = 2 # Minimum number of Node.js instances
  max_size         = 4 # Maximum number of Node.js instances
  desired_capacity = 2 # Initial number of Node.js instances

  # Link security group to VPC

}

data "aws_autoscaling_groups" "nodejs" {}

locals {
  autoscaling_group_names = length(data.aws_autoscaling_groups.nodejs.names) > 0 ? toset(data.aws_autoscaling_groups.nodejs.names) : []
}

data "aws_instances" "nodejs_instances" {
  for_each = local.autoscaling_group_names

  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [each.key]
  }
}

output "nodejs_instance_ips" {
  value       = [for instance in data.aws_instances.nodejs_instances : instance.private_ip]
  description = "Private IP addresses of the Node.js instances"
}

terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Ensure that the security group is associated with the VPC
resource "aws_security_group_attachment" "nodejs_attachment" {
  security_group_id = aws_security_group.nodejs.id
  vpc_id            = aws_vpc.main.id
}
