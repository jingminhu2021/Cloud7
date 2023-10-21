# resource "aws_route53_zone" "primary" {
#   name = var.domain_name
# }

# resource "aws_acm_certificate" "cert" {
#   domain_name       = var.domain_name
#   validation_method = "DNS"

#   lifecycle {
#     create_before_destroy = true
#   }
# }

# resource "aws_route53_record" "record" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_name
#   type    = tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_type
#   records = [tolist(aws_acm_certificate.cert.domain_validation_options)[0].resource_record_value]
#   ttl     = var.ttl
# }

# resource "aws_acm_certificate_validation" "certificate_validation" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [aws_route53_record.record.fqdn]
# }

# resource "aws_route53_record" "caa_record" {
#   zone_id = aws_route53_zone.primary.zone_id
#   name    = var.domain_name
#   type    = "CAA"
#   records = [
#     "0 issue \"amazon.com\"",
#     "0 issuewild \"amazon.com\""
#   ]
#   ttl = var.ttl
# }



# generate ACM cert for domain :
resource "aws_acm_certificate" "cert" {
  domain_name               = var.domain_name
  subject_alternative_names = ["*.${var.domain_name}"]
  validation_method         = "DNS"
  tags                      = var.tags
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
  zone_id         = data.aws_route53_zone.hosted_zone.zone_id
}
resource "aws_acm_certificate_validation" "certvalidation" {
  certificate_arn         = aws_acm_certificate.cert.arn
  validation_record_fqdns = [for r in aws_route53_record.certvalidation : r.fqdn]
}
# creating A record for domain:
resource "aws_route53_record" "websiteurl" {
  name    = var.domain_name
  zone_id = data.aws_route53_zone.hosted_zone.zone_id
  type    = "A"
  alias {
    name                   = aws_cloudfront_distribution.cf_dist.domain_name
    zone_id                = aws_cloudfront_distribution.cf_dist.hosted_zone_id
    evaluate_target_health = true
  }
}

# data source to fetch hosted zone info from domain name:
data "aws_route53_zone" "hosted_zone" {
  name = var.domain_name
  # zone_id = "Z02386973F7B60PPWX7U2"
}
