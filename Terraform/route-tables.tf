resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    Name = "Public-RT"
  }
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_a_assoc" {
  subnet_id      = aws_subnet.public_web_subnet_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b_assoc" {
  subnet_id      = aws_subnet.public_web_subnet_b.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table" "private_app_rt_a" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    Name = "Private-App-RT-A"
  }
}

resource "aws_route" "private_app_a_nat" {
  route_table_id         = aws_route_table.private_app_rt_a.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_a.id
}

resource "aws_route_table_association" "private_app_a_assoc" {
  subnet_id      = aws_subnet.private_app_subnet_a.id
  route_table_id = aws_route_table.private_app_rt_a.id
}

resource "aws_route_table" "private_app_rt_b" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    Name = "Private-App-RT-B"
  }
}

resource "aws_route" "private_app_b_nat" {
  route_table_id         = aws_route_table.private_app_rt_b.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_b.id
}

resource "aws_route_table_association" "private_app_b_assoc" {
  subnet_id      = aws_subnet.private_app_subnet_b.id
  route_table_id = aws_route_table.private_app_rt_b.id
}

resource "aws_route_table" "private_db_rt" {
  vpc_id = aws_vpc.three_tier_vpc.id

  tags = {
    Name = "Private-DB-RT"
  }
}

resource "aws_route_table_association" "private_db_a_assoc" {
  subnet_id      = aws_subnet.private_db_subnet_a.id
  route_table_id = aws_route_table.private_db_rt.id
}

resource "aws_route_table_association" "private_db_b_assoc" {
  subnet_id      = aws_subnet.private_db_subnet_b.id
  route_table_id = aws_route_table.private_db_rt.id
}
