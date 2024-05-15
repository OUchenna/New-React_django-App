resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "Main VPC"
  }
}


resource "aws_security_group" "nodejs" {
  name   = "NodejsSecurityGroup"
  vpc_id = aws_vpc.main.id

  # ... (rest of the security group configuration)
}
