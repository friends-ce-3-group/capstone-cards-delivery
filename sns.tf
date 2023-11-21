locals {
  sns_tag = "${var.resource_grp_name}-ses-status"
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

resource "aws_ses_configuration_set" "example_config_set" {
  name = "${var.resource_grp_name}-ses-status"
}

resource "aws_ses_event_destination" "example_event_destination" {
  name               = "${var.resource_grp_name}-ses-destination"
  matching_types    = ["send", "reject", "bounce", "complaint", "delivery"]
  configuration_set_name = aws_ses_configuration_set.example_config_set.name
  
  sns_destination {
    topic_arn = aws_sns_topic.notification.arn
  }
}