resource "aws_vpc_endpoint" "ssm" {
  vpc_id              = aws_vpc.three_tier_vpc.id
  service_name        = "com.amazonaws.us-east-1.ssm"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_app_subnet_a.id,
    aws_subnet.private_app_subnet_b.id
  ]

  security_group_ids = [
    aws_security_group.ssm_sg.id
  ]

  tags = {
    Name = "ssm-Endpoint"
  }
}

resource "aws_vpc_endpoint" "ssmmessages" {
  vpc_id              = aws_vpc.three_tier_vpc.id
  service_name        = "com.amazonaws.us-east-1.ssmmessages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_app_subnet_a.id,
    aws_subnet.private_app_subnet_b.id
  ]

  security_group_ids = [
    aws_security_group.ssm_sg.id
  ]

  tags = {
    Name = "ssmmessages-Endpoint"
  }
}

resource "aws_vpc_endpoint" "ec2messages" {
  vpc_id              = aws_vpc.three_tier_vpc.id
  service_name        = "com.amazonaws.us-east-1.ec2messages"
  vpc_endpoint_type   = "Interface"
  private_dns_enabled = true

  subnet_ids = [
    aws_subnet.private_app_subnet_a.id,
    aws_subnet.private_app_subnet_b.id
  ]

  security_group_ids = [
    aws_security_group.ssm_sg.id
  ]

  tags = {
    Name = "ec2messages-Endpoint"
  }
}
