locals {
  domain_name = var.domain_name
}

# generate ACM cert for domain :
# resource "aws_acm_certificate" "cert" {
#   domain_name               = local.domain_name
#   subject_alternative_names = ["*.${local.domain_name}"]
#   validation_method         = "DNS"
#   tags                      = var.tags
# }
# # validate cert:
# resource "aws_route53_record" "certvalidation" {
#   for_each = {
#     for d in aws_acm_certificate.cert.domain_validation_options : d.domain_name => {
#       name   = d.resource_record_name
#       record = d.resource_record_value
#       type   = d.resource_record_type
#     }
#   }
#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = aws_cloudfront_distribution.cf_dist.hosted_zone_id
# }
# resource "aws_acm_certificate_validation" "certvalidation" {
#   certificate_arn         = aws_acm_certificate.cert.arn
#   validation_record_fqdns = [for r in aws_route53_record.certvalidation : r.fqdn]
# }
# creating A record for domain:
# resource "aws_route53_record" "websiteurl" {
#   name    = local.domain_name
#   zone_id = aws_cloudfront_distribution.cf_dist.hosted_zone_id
#   type    = "A"
#   alias {
#     name                   = aws_cloudfront_distribution.cf_dist.domain_name
#     zone_id                = aws_cloudfront_distribution.cf_dist.hosted_zone_id
#     evaluate_target_health = false
#   }
# }

# resource "aws_iam_policy" "route53_policy" {
#   name        = "route53_policy"
#   description = "IAM polciy for Route 53"
#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Allow"
#         Action = [
#           "route53:ChangeResourceRecordSets",
#           "route53:GetChange",
#           "route53:ListResourceRecordSets"
#         ],
#         Resource = [
#           "arn:aws:route53:::hostedzone/${aws_cloudfront_distribution.cf_dist.hosted_zone_id}"
#         ]
#       }
#     ]
#   })
# }

# resource "aws_iam_user_policy_attachment" "route53_policy_attachment" {
#   user       = "cloudteam7"
#   policy_arn = aws_iam_policy.route53_policy.arn
# }
