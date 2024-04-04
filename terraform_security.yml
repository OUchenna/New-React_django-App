resource "aws_security_group" "web" {
  name = "WebServerSecurityGroup"
  vpc_id = vpc-0b82f3e5aa0c4a472

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
