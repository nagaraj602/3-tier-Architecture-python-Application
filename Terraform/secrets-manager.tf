resource "aws_secretsmanager_secret" "rds_secret" {

  name = "usernotes-rds-secret"

  tags = {
    Name = "usernotes-rds-secret"
  }
}

resource "aws_secretsmanager_secret_version" "rds_secret_value" {

  secret_id = aws_secretsmanager_secret.rds_secret.id

  secret_string = jsonencode({
    username = "admin"
    password = random_password.db_password.result
    host     = aws_db_instance.usernotes.address
  })
}
