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
  fqdn              = aws_route53_record.websiteurl.fqdn
  port              = 443
  type              = "HTTPS"
  failure_threshold = 3
  regions           = ["ap-southeast-1", "ap-southeast-2", "ap-northeast-1"] # minimum 3 item required
  tags = {
    Name = "health_check"
  }
}
