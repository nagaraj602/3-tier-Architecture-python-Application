resource "aws_launch_template" "three_tier_lt" {

  name = "3-tier-launch-template"

  image_id = var.ami_id

  instance_type = "t3.micro"

  vpc_security_group_ids = [
    aws_security_group.app_sg.id
  ]

  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_profile.name
  }

  tag_specifications {

    resource_type = "instance"

    tags = {
      Name = "Application EC2"
    }
  }
}
