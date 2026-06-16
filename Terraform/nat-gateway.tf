resource "aws_eip" "nat_a_eip" {
  domain = "vpc"

  tags = {
    Name = "NAT-A-EIP"
  }
}

resource "aws_eip" "nat_b_eip" {
  domain = "vpc"

  tags = {
    Name = "NAT-B-EIP"
  }
}

resource "aws_nat_gateway" "nat_a" {
  allocation_id = aws_eip.nat_a_eip.id
  subnet_id     = aws_subnet.public_web_subnet_a.id

  tags = {
    Name = "NAT-A"
  }

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_nat_gateway" "nat_b" {
  allocation_id = aws_eip.nat_b_eip.id
  subnet_id     = aws_subnet.public_web_subnet_b.id

  tags = {
    Name = "NAT-B"
  }

  depends_on = [aws_internet_gateway.igw]
}
