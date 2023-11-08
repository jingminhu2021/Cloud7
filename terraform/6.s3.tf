resource "aws_s3_bucket" "bucket" {
  bucket = "cloud7-dynamodb-bucket"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

# data "aws_iam_policy_document" "glue_allow_access" {
#   statement {
#     effect = "Allow"
#     resources = [
#       "${aws_s3_bucket.bucket.arn}",
#       "${aws_s3_bucket.bucket.arn}/*",
#     ]
#     actions = [
#       "s3:GetObject",
#       "s3:PutObject",
#       "s3:ListBucket",
#     ]
#     principals {
#       type        = "Service"
#       identifiers = ["glue.amazonaws.com"]
#     }
#   }
# }

# resource "aws_s3_bucket_policy" "glue_access" {
#   bucket = aws_s3_bucket.bucket.id
#   policy = data.aws_iam_policy_document.glue_allow_access.json
# }
