resource "aws_db_subnet_group" "database_subnet_group" {

  name        = "database-subnet-group"
  description = "3tier-database-subnet-group"

  subnet_ids = [
    aws_subnet.private_db_subnet_a.id,
    aws_subnet.private_db_subnet_b.id
  ]

  tags = {
    Name = "database-subnet-group"
  }
}


resource "aws_db_instance" "usernotes" {

  identifier = "usernotes"

  engine         = "mysql"
  engine_version = "8.4"

  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp3"

  username = var.db_username
  password = var.db_password

  db_subnet_group_name = aws_db_subnet_group.database_subnet_group.name

  vpc_security_group_ids = [
    aws_security_group.db_sg.id
  ]

  publicly_accessible = false

  multi_az = false

  skip_final_snapshot = true

  availability_zone = "us-east-1a"

  tags = {
    Name = "usernotes"
  }
}
