resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "example" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_security_group" "nodejs" {
  name        = "NodejsSecurityGroup"
  description = "Security group for Node.js application"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["your_ip_address/32"] # Update with your IP
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["your_ip_address/32"] # Update with your IP
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Associate security group with the VPC
resource "aws_security_group_rule" "nodejs_vpc_association" {
  type              = "ingress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.nodejs.id
}

resource "aws_launch_template" "nodejs" {
  name          = "TerraformProject"
  image_id      = "ami-04b70fa74e45c3917" # Update with your desired Node.js AMI
  instance_type = "t2.micro"

  vpc_security_group_ids = [aws_security_group.nodejs.id]

  user_data = <<-EOF
  #!/bin/bash
  curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get update && sudo apt-get install -y nodejs
  git clone https://github.com/OUchenna/New-React-django-App.git
  cd New-React-django-App/ComputerXFrontend
  npm install
  npm run build
  npm start
  EOF
}

resource "aws_autoscaling_group" "nodejs" {
  name                = "NodejsAutoscalingGroup"
  vpc_zone_identifier = [aws_subnet.example.id]

  launch_template {
    id = aws_launch_template.nodejs.id
  }

  min_size         = 2
  max_size         = 4
  desired_capacity = 2
}

data "aws_autoscaling_group" "nodejs" {
  name = aws_autoscaling_group.nodejs.name
}

data "aws_instances" "nodejs_instances" {
  filter {
    name   = "tag:aws:autoscaling:groupName"
    values = [data.aws_autoscaling_group.nodejs.name]
  }
}

output "nodejs_instance_ips" {
  value       = [for instance in data.aws_instances.nodejs_instances.instances : instance.private_ip]
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
