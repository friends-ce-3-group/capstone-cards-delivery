resource "aws_sns_topic" "notification" {
  name = "${var.resource_grp_name}-sns"
}

resource "aws_sns_topic_subscription" "notification" {
  topic_arn = aws_sns_topic.notification.arn
  protocol  = "email"
  endpoint  = "gooodgreets@gmail.com"
}