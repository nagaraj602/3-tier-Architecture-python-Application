resource "aws_subnet" "public_web_subnet_a" {
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Web-subnet-A"
  }
}

resource "aws_subnet" "public_web_subnet_b" {
  vpc_id                  = aws_vpc.three_tier_vpc.id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name = "Public-Web-subnet-B"
  }
}

resource "aws_subnet" "private_app_subnet_a" {
  vpc_id            = aws_vpc.three_tier_vpc.id
  cidr_block        = "192.168.11.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private-App-subnet-A"
  }
}

resource "aws_subnet" "private_app_subnet_b" {
  vpc_id            = aws_vpc.three_tier_vpc.id
  cidr_block        = "192.168.12.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private-App-subnet-B"
  }
}

resource "aws_subnet" "private_db_subnet_a" {
  vpc_id            = aws_vpc.three_tier_vpc.id
  cidr_block        = "192.168.21.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "Private-Db-subnet-A"
  }
}

resource "aws_subnet" "private_db_subnet_b" {
  vpc_id            = aws_vpc.three_tier_vpc.id
  cidr_block        = "192.168.22.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "Private-Db-subnet-B"
  }
}
