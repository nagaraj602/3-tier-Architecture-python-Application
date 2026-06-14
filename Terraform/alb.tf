resource "aws_lb" "three_tier_alb" {

  name = "3-tier-alb"

  internal = false

  load_balancer_type = "application"

  security_groups = [
    aws_security_group.alb_sg.id
  ]

  subnets = [
    aws_subnet.public_web_subnet_a.id,
    aws_subnet.public_web_subnet_b.id
  ]
}

resource "aws_lb_listener" "http_listener" {

  load_balancer_arn = aws_lb.three_tier_alb.arn

  port = 80

  protocol = "HTTP"

  default_action {

    type = "forward"

    target_group_arn = aws_lb_target_group.three_tier_tg.arn
  }
}
