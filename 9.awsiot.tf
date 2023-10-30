resource "random_id" "id" {
  byte_length = 8
}

resource "tls_private_key" "key" {
  algorithm   = "RSA"
	rsa_bits = 2048
}

resource "tls_self_signed_cert" "cert" {
  private_key_pem = tls_private_key.key.private_key_pem

  validity_period_hours = 240

  allowed_uses = [
  ]

	subject {
		organization = "test"
	}
}

resource "aws_iot_certificate" "cert" {
	certificate_pem = trimspace(tls_self_signed_cert.cert.cert_pem)
	active          = true
}

data "aws_arn" "thing" {
  arn = aws_iot_thing.thing.arn
}

resource "aws_iot_policy" "policy" {
  name = "thingpolicy_${random_id.id.hex}"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "iot:Connect",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${data.aws_arn.thing.region}:${data.aws_arn.thing.account}:client/$${iot:Connection.Thing.ThingName}"
      },
      {
        Action = [
          "iot:Publish",
          "iot:Receive",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${data.aws_arn.thing.region}:${data.aws_arn.thing.account}:topic/things/$${iot:Connection.Thing.ThingName}/*"
      },
      {
        Action = [
          "iot:Subscribe",
        ]
        Effect   = "Allow"
        Resource = "arn:aws:iot:${data.aws_arn.thing.region}:${data.aws_arn.thing.account}:topicfilter/things/$${iot:Connection.Thing.ThingName}/*"
      },
    ]
  })
}

resource "aws_iot_policy_attachment" "attachment" {
  policy = aws_iot_policy.policy.name
  target = aws_iot_certificate.cert.arn
}

resource "aws_iot_thing" "thing" {
  name = "thing_${random_id.id.hex}"
}

resource "aws_iot_thing_principal_attachment" "attachment" {
  principal = aws_iot_certificate.cert.arn
  thing     = aws_iot_thing.thing.name
}

data "http" "root_ca" {
  url = "https://www.amazontrust.com/repository/AmazonRootCA1.pem"
}

data "aws_iot_endpoint" "iot_endpoint" {
	endpoint_type = "iot:Data-ATS"
}

output "ca" {
	value = data.http.root_ca.response_body
}

output "iot_endpoint" {
	value = data.aws_iot_endpoint.iot_endpoint.endpoint_address
}

output "thing_name" {
	value = aws_iot_thing.thing.name
}

output "cert" {
	value = tls_self_signed_cert.cert.cert_pem
}

output "key" {
	value = tls_private_key.key.private_key_pem
	sensitive = true
}

# resource "aws_iot_topic_rule" "rule" {
#   name        = "DynamoDBRule"
#   description = "DynamoDB rule"
#   enabled     = true
#   sql         = "SELECT Oxygen, PulseRate, Temperature FROM 'things/+/test'"
#   sql_version = "2016-03-23"

#   dynamodb {
#     table_name = "iotdata"
#     hash_key_field = "timestamp"
#     hash_key_value = "$${timestamp()}"
#     hash_key_type = "NUMBER"
#     range_key_field = "thingId"
#     range_key_value = "$${cast(topic(2) AS STRING)}"
#     range_key_type = "STRING"
#     role_arn = aws_iam_role.role.arn
#     }
  
#   error_action {
#     cloudwatch_logs {
#       log_group_name = aws_cloudwatch_log_group.yada.name
#       role_arn = aws_iam_role.cloudwatchrole.arn
#     }
# }
# }

resource "aws_iot_topic_rule" "rule" {
  name        = "lambda"
  description = "lambda rule"
  enabled     = true
  sql         = "SELECT thingId, Oxygen, PulseRate, Temperature FROM 'things/+/test'"
  sql_version = "2016-03-23"

  lambda {
    function_arn = "arn:aws:lambda:ap-southeast-1:708779265549:function:covidtestfunc"
    }
  
#   error_action {
#     cloudwatch_logs {
#       log_group_name = aws_cloudwatch_log_group.yada.name
#       role_arn = aws_iam_role.cloudwatchrole.arn
#     }
# }
}

#For Cloudwatch Logs
# resource "aws_cloudwatch_log_group" "yada" {
#   name = "Yada"
# }

# resource "aws_iam_role" "cloudwatchrole" {
#   name               = "cloudwatchrole"
#   assume_role_policy = data.aws_iam_policy_document.cloudwatch_assume_role.json
# }

# data "aws_iam_policy_document" "cloudwatch_assume_role" {
#   statement {
#     effect = "Allow"

#     principals {
#       type        = "Service"
#       identifiers = ["iot.amazonaws.com"]
#     }

#     actions = ["sts:AssumeRole"]
#   }
# }

# data "aws_iam_policy_document" "iam_policy_for_cloudwatchlog" {
#   statement {
#     effect    = "Allow"
#     actions   = ["logs:PutLogEvents"]
#     resources = ["*"]
#   }
# }

# resource "aws_iam_role_policy" "iam_policy_for_cloudwatchlog" {
#   name   = "cloudwatchlogpolicy"
#   role   = aws_iam_role.cloudwatchrole.id
#   policy = data.aws_iam_policy_document.iam_policy_for_cloudwatchlog.json
# }

#For Lambda
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["iot.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "role" {
  name               = "myrole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

# data "aws_iam_policy_document" "iam_policy_for_dynamodb" {
#   statement {
#     effect    = "Allow"
#     actions   = ["dynamodb:*"]
#     resources = ["*"]
#   }
# }

data "aws_iam_policy_document" "iam_policy_for_lambda" {
  statement {
    effect    = "Allow"
    actions   = ["lambda:InvokeFunction"]
    resources = ["*"]
  }
}


# resource "aws_iam_role_policy" "iam_policy_for_dynamodb" {
#   name   = "mypolicy"
#   role   = aws_iam_role.role.id
#   policy = data.aws_iam_policy_document.iam_policy_for_dynamodb.json
# }

resource "aws_iam_role_policy" "iam_policy_for_lambda" {
  name   = "mypolicy"
  role   = aws_iam_role.role.id
  policy = data.aws_iam_policy_document.iam_policy_for_lambda.json
}