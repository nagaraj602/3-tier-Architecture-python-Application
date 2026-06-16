resource "aws_lb_target_group" "three_tier_tg" {

  name = "3-tier-target-group"

  port     = 9051
  protocol = "HTTP"

  target_type = "instance"

  vpc_id = aws_vpc.three_tier_vpc.id

  health_check {

    path = "/"

    protocol = "HTTP"

    matcher = "200"

    interval = 30

    healthy_threshold = 3

    unhealthy_threshold = 3
  }
}
