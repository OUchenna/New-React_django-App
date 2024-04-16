# Define the web server instance
resource "aws_instance" "webserver" {
  # Configure your web server instance here
  # ... (AMI, instance type, security groups, etc.)
}

# Define the web server security group
resource "aws_security_group" "web" {
  name = "WebServerSecurityGroup"
  vpc_id = aws_vpc.main.id  # Reference the VPC by its ID attribute (.id)

  ingress {
    from_port = 22
    to_port   = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Update to restrict access (e.g., your IP)
  }

  ingress {
    from_port = 80
    to_port   = 80
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/24"] # Update to restrict access if needed
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/24"]
  }
}

# Define the database security group
resource "aws_security_group" "db" {
  name = "DatabaseSecurityGroup"
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 5432
    to_port   = 5432
    protocol = "tcp"
    cidr_blocks = [aws_instance.webserver.private_ip] # Allow access from web servers
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

