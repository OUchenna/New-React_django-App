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

  user_data = <<-EOF
    # Install Node.js and package manager
    curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
    sudo apt-get update && sudo apt-get install -y nodejs

    # Clone your React app repository from Github (replace with your details)
    git clone https://github.com/OUchenna/New-React-django-App.git

    # Navigate to the application directory
    cd New-React-Django-App/ComputexFrontend

    # Install dependencies
    npm install

    # Build the React app
    npm run build

    # Start your Node.js server (replace with your start command)
    npm start
  EOF
}

resource "aws_autoscaling_group" "nodejs" {
  name                = "NodejsAutoscalingGroup"
  vpc_zone_identifier = ["subnet-031386d14a0b64bfe"]

  launch_template {
    id = aws_launch_template.nodejs.id
  }

  min_size         = 2 # Minimum number of Node.js instances
  max_size         = 4 # Maximum number of Node.js instances
  desired_capacity = 2 # Initial number of Node.js instances
}

data "aws_autoscaling_groups" "nodejs" {}

data "aws_instances" "nodejs_instances" {
  for_each = data.aws_autoscaling_groups.nodejs.names

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

# Your AWS resources (e.g., aws_security_group, aws_launch_template, aws_autoscaling_group, etc.)

