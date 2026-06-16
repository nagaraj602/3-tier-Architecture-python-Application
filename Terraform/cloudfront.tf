resource "aws_cloudfront_distribution" "three_tier_cf" {

  enabled = true

  comment = "3-tier-Cloudfront"

  origin {

    domain_name = aws_lb.three_tier_alb.dns_name

    origin_id = "alb-origin"

    custom_origin_config {

      http_port = 80

      https_port = 443

      origin_protocol_policy = "http-only"

      origin_ssl_protocols = ["TLSv1.2"]
    }
  }

  default_cache_behavior {

    target_origin_id = "alb-origin"

    viewer_protocol_policy = "allow-all"

    allowed_methods = [
      "GET",
      "HEAD",
      "OPTIONS",
      "PUT",
      "POST",
      "PATCH",
      "DELETE"
    ]

    cached_methods = [
      "GET",
      "HEAD"
    ]

    forwarded_values {

      query_string = true

      cookies {
        forward = "all"
      }
    }
  }

  restrictions {

    geo_restriction {

      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  web_acl_id = aws_wafv2_web_acl.three_tier_waf.arn

  depends_on = [
    aws_lb.three_tier_alb
  ]
}
