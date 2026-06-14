resource "aws_autoscaling_group" "three_tier_asg" {

  name = "3-tier-ASG"

  min_size = 2

  max_size = 4

  desired_capacity = 2

  vpc_zone_identifier = [
    aws_subnet.private_app_subnet_a.id,
    aws_subnet.private_app_subnet_b.id
  ]

  target_group_arns = [
    aws_lb_target_group.three_tier_tg.arn
  ]

  health_check_type = "ELB"

  health_check_grace_period = 300

  launch_template {

    id = aws_launch_template.three_tier_lt.id

    version = "$Latest"
  }

  tag {
    key                 = "Name"
    value               = "Application EC2"
    propagate_at_launch = true
  }
}


resource "aws_autoscaling_policy" "target_tracking" {

  name                   = "Target Tracking Policy"
  autoscaling_group_name = aws_autoscaling_group.three_tier_asg.name

  policy_type = "TargetTrackingScaling"

  target_tracking_configuration {

    predefined_metric_specification {

      predefined_metric_type = "ALBRequestCountPerTarget"

      resource_label = "${aws_lb.three_tier_alb.arn_suffix}/${aws_lb_target_group.three_tier_tg.arn_suffix}"
    }

    target_value = 60
  }
}
