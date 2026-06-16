output "alb_url" {
  value = "http://${aws_lb.three_tier_alb.dns_name}"
}

output "cloudfront_url" {
  value = "https://${aws_cloudfront_distribution.three_tier_cf.domain_name}"
}

output "rds_endpoint" {
  value = aws_db_instance.usernotes.address
}

output "secret_name" {
  value = aws_secretsmanager_secret.rds_secret1.name
}