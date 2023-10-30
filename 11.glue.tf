resource "aws_s3_object" "python_script" {
  bucket = aws_s3_bucket.bucket.id
  key    = "scripts/glue_script.py"
  source = "scripts/glue_script.py"
  etag   = filemd5("scripts/glue_script.py")
}

resource "aws_cloudwatch_log_group" "glue_log_group" {
  name              = "/aws-glue/jobs"
  retention_in_days = 7
}

resource "aws_glue_job" "db_to_s3" {
  name              = "db_to_s3"
  role_arn          = aws_iam_role.glue_role.arn
  glue_version      = "4.0"
  worker_type       = "G.1X"
  number_of_workers = 2
  execution_class   = "FLEX"

  command {
    python_version  = "3"
    script_location = "s3://${aws_s3_bucket.bucket.id}/scripts/glue_script.py"
  }

  default_arguments = {
    "--continuous-log-logGroup"          = aws_cloudwatch_log_group.glue_log_group.name
    "--enable-continuous-cloudwatch-log" = "true"
    "--enable-metrics"                   = ""
    "--enable-spark-ui"                  = "true"
    "--spark-event-logs-path"            = "s3://cloud7-dynamodb-bucket/sparkHistoryLogs/"
    "--enable-job-insights"              = "false"
    "--enable-glue-datacatalog"          = "true"
    "--job-language"                     = "python"
    "--TempDir"                          = "s3://cloud7-dynamodb-bucket/temporary/"
    "--enable-continuous-log-filter"     = "true"
    "--enable-auto-scaling"              = "true"
    "--job-bookmark-option"              = "job-bookmark-disable"
  }

}

resource "aws_glue_trigger" "glue_trigger" {
  name     = "glue_trigger"
  schedule = "cron(0 0 ? * 2#1 *)"
  type     = "SCHEDULED"
  actions {
    job_name = aws_glue_job.db_to_s3.name
  }
}

data "aws_iam_policy_document" "glue_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["glue.amazonaws.com", "s3.amazonaws.com", "dynamodb.amazonaws.com"]
    }
    effect = "Allow"
  }
}


resource "aws_iam_role" "glue_role" {
  name               = "glue_role"
  assume_role_policy = data.aws_iam_policy_document.glue_assume_role.json
}

data "aws_iam_policy_document" "glue_policy_doc" {
  statement {
    actions = [
      "glue:*",
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket",
      "dynamodb:ExportTableToPointInTime",
      "dynamodb:DescribeExport",
    ]
    resources = [
      "arn:aws:s3:::aws-glue-assets-708779265549-ap-southeast-1",
      "arn:aws:s3:::aws-glue-assets-708779265549-ap-southeast-1/*",
      "${aws_s3_bucket.bucket.arn}",
      "${aws_s3_bucket.bucket.arn}/*",
      "${aws_dynamodb_table.basic-dynamodb-table.arn}",
      "${aws_dynamodb_table.basic-dynamodb-table.arn}/export/*",
    ]
    effect = "Allow"
  }
}

data "aws_iam_policy_document" "glue_cloudwatch" {
  statement {
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "cloudwatch:GetMetricStatistics",
      "cloudwatch:ListMetrics",
      "cloudwatch:PutMetricData"
    ]
    resources = ["*"]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "glue_policy" {
  name   = "glue_policy"
  policy = data.aws_iam_policy_document.glue_policy_doc.json
}

resource "aws_iam_policy" "glue_policy_cw" {
  name   = "glue_policy_cw"
  policy = data.aws_iam_policy_document.glue_cloudwatch.json
}


resource "aws_iam_role_policy_attachment" "glue_policy_attach" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy.arn
}

resource "aws_iam_role_policy_attachment" "glue_policy_attach_cw" {
  role       = aws_iam_role.glue_role.name
  policy_arn = aws_iam_policy.glue_policy_cw.arn
}
