resource "aws_secretsmanager_secret" "rds_secret1" {

  name = "usernotes-rds-secret1"

  tags = {
    Name = "usernotes-rds-secret"
  }
}

resource "aws_secretsmanager_secret_version" "rds_secret_value" {

  secret_id = aws_secretsmanager_secret.rds_secret1.id

  secret_string = jsonencode({
    username = var.db_username
    password = var.db_password
    host     = aws_db_instance.usernotes.address
  })
}
