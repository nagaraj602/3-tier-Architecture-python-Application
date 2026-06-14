resource "aws_security_group" "alb_sg" {
  name        = "ALB-SG"
  description = "ALB-SG"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ALB-SG"
  }
}

resource "aws_security_group" "app_sg" {
  name        = "APP-SG"
  description = "APP-SG"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    description     = "Flask App"
    from_port       = 9051
    to_port         = 9051
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "APP-SG"
  }
}

resource "aws_security_group" "db_sg" {
  name        = "DB-SG"
  description = "DB-SG"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    description     = "MySQL"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "DB-SG"
  }
}

resource "aws_security_group" "ssm_sg" {
  name        = "SSM-SG"
  description = "SSM-SG"
  vpc_id      = aws_vpc.three_tier_vpc.id

  ingress {
    description     = "HTTPS from APP-SG"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.app_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "SSM-SG"
  }
}
