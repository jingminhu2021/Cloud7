# generate ACM cert for domain :
resource "aws_acm_certificate" "cert" {
  provider                  = aws.us-east-1
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
}

resource "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
}

# validate cert:
resource "aws_route53_record" "certvalidation" {
  for_each = {
    for d in aws_acm_certificate.cert.domain_validation_options : d.domain_name => {
      name   = d.resource_record_name
      record = d.resource_record_value
      type   = d.resource_record_type
    }
  }
  allow_overwrite = true
  name            = each.value.name
  records         = [each.value.record]
  ttl             = 60
  type            = each.value.type
  zone_id         = resource.aws_route53_zone.hosted_zone.zone_id
}
# resource "aws_acm_certificate_validation" "certvalidation" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for r in aws_route53_record.certvalidation : r.fqdn]
# }

# creating A record for domain:
resource "aws_route53_record" "websiteurl" {
  name    = var.domain_name
  zone_id = resource.aws_route53_zone.hosted_zone.zone_id
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cf_dist.domain_name
    zone_id                = aws_cloudfront_distribution.cf_dist.hosted_zone_id
    evaluate_target_health = true
  }
}

resource "aws_route53_health_check" "health_check" {
  fqdn               = aws_route53_record.websiteurl.fqdn
  port               = 443
  type               = "HTTPS"
  failure_threshold  = 3
  invert_healthcheck = false
  request_interval   = 30
  regions            = ["ap-southeast-1", "ap-southeast-2", "ap-northeast-1"] # minimum 3 item required
  tags = {
    Name = "health_check"
  }
}

resource "aws_kms_key" "route53_kms" {
  provider                 = aws.us-east-1
  description              = "KMS key for Route53"
  deletion_window_in_days  = 7
  key_usage                = "SIGN_VERIFY"
  customer_master_key_spec = "ECC_NIST_P256"
  policy = jsonencode({
    Statement = [
      {
        Action = [
          "kms:DescribeKey",
          "kms:GetPublicKey",
          "kms:Sign",
          "kms:Verify"
        ],
        Effect = "Allow",
        Principal = {
          Service = "dnssec-route53.amazonaws.com"
        }
        Resource = "*"
      },
      {
        Action = "kms:*",
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:root"
        }
        Resource = "*"
      }
    ]
    Version = "2012-10-17"
  })
}

data "aws_caller_identity" "current" {}

resource "aws_route53_key_signing_key" "kms_key_signing_key" {
  provider                   = aws.us-east-1
  hosted_zone_id             = aws_route53_zone.hosted_zone.zone_id
  key_management_service_arn = aws_kms_key.route53_kms.arn
  name                       = "route53_key"
}

resource "aws_route53_hosted_zone_dnssec" "hosted_zone_dnssec" {
  provider = aws.us-east-1
  depends_on = [
    aws_route53_key_signing_key.kms_key_signing_key
  ]
  hosted_zone_id = aws_route53_key_signing_key.kms_key_signing_key.hosted_zone_id
}
