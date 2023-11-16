# resource "aws_scheduler_schedule" "example" {
#   name       = "${var.resource_grp_name}-eventbridge-schedule"
#   group_name = "default"

#   flexible_time_window {
#     mode = "OFF"
#   }

#   schedule_expression = "cron(47 3 16 11 ? 2023)"

#   target {
#     arn      = aws_lambda_function.eventbridge_ses_link.arn
#     role_arn = aws_iam_role.eventbridge_iam_role.arn

#     # input = jsonencode({
#     #   body = var.body
#     # })
#   }
# }

# variable "body" {
#   default = {
#     body = {
#       name = "cheemeng"
#       surname   = "low"
#     }
#   }
# }
