locals {
  sns_tag = "${var.resource_grp_name}-sns"
}

resource "aws_sns_topic" "notification" {
  name = local.sns_tag

  tags = {
    name = local.sns_tag
    proj_name = var.proj_name
  }
}

resource "aws_sns_topic_subscription" "notification" {
  topic_arn = aws_sns_topic.notification.arn
  protocol  = "email"
  endpoint  = "gooodgreets@gmail.com"
}