resource "aws_instance_launch_template" "nodejs" {
  name = "NodejsLaunchTemplate"
  image_id = "ami-080e1f13689e07408" # Update with your desired Node.js AMI
  instance_type = "t2.micro" # Update with desired instance type

  # User data script to install Node.js, build your React app, and start the server
  user_data = <<EOF
  # Install Node.js and package manager
  curl -sL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt-get update && sudo apt-get install -y nodejs

  # Clone your React app repository from Github (replace with your details)
  git clone https://github.com/OUchenna/New-React_django-App.git

  # Navigate to the application directory
  cd New-React-Django-App/ComputexFrontend

  # Install dependencies
  npm install

  # Build the React app
  npm run build

  # Start your Node.js server (replace with your start command)
  npm start
  EOF

  security_groups = [sg-0d3da38f42bd62f99]
}

resource "aws_autoscaling_group" "nodejs" {
  name                  = "NodejsAutoscalingGroup"
  vpc_zone_identifier   = ["subnet-031386d14a0b64bfe"]
  launch_template       = aws_instance_launch_template.nodejs.id
  min_size              = 2  # Minimum number of Node.js instances
  max_size              = 4  # Maximum number of Node.js instances
  desired_capacity      = 2  # Initial number of Node.js instances

  # Configure scaling based on application metrics (replace with your needs)
  # health_check_type = "ELB"  # If using an ELB
  # target_tracking_configuration {
  #   predefined_metric_specification {
  #     predefined_metric_type = "CPUUtilization"
  #     target_value           = 70.0
  #   }
  # }
}

