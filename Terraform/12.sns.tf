resource "aws_sns_topic" "user_alert" {
  name              = "user-alerts-topic"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic" "admin_alert" {
  name              = "admin-alerts-topic"
  kms_master_key_id = "alias/aws/sns"
}

resource "aws_sns_topic_subscription" "user_alert_subscription" {
  topic_arn = aws_sns_topic.user_alert.arn
  protocol  = "email"
  endpoint  = "junyang.ong.2021@scis.smu.edu.sg"

  depends_on = [
    aws_sns_topic.user_alert
  ]
}

resource "aws_sns_topic_subscription" "admin_alert_subscription" {
  topic_arn = aws_sns_topic.admin_alert.arn
  protocol  = "email"
  endpoint  = "junyang.ong.2021@scis.smu.edu.sg"

  depends_on = [
    aws_sns_topic.admin_alert
  ]
}

resource "aws_sns_topic_subscription" "user_alert_subscription_2" {
  topic_arn = aws_sns_topic.user_alert.arn
  protocol  = "email"
  endpoint  = "yingfu.lim.2022@msc.smu.edu.sg"

  depends_on = [
    aws_sns_topic.user_alert
  ]
}

resource "aws_sns_topic_subscription" "admin_alert_subscription_2" {
  topic_arn = aws_sns_topic.admin_alert.arn
  protocol  = "email"
  endpoint  = "yingfu.lim.2022@msc.smu.edu.sg"

  depends_on = [
    aws_sns_topic.admin_alert
  ]
}

resource "aws_sns_topic_subscription" "admin_alert_grafana" {
  topic_arn = aws_sns_topic.user_alert.arn
  protocol  = "https"
  endpoint  = "https://oncall-prod-us-central-0.grafana.net/oncall/integrations/v1/amazon_sns/Dp243BbBx6jXeQxjlXUW4ReTh/"

  depends_on = [
    aws_sns_topic.admin_alert
  ]
}
