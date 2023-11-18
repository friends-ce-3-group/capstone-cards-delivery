# generate a generic trust relationship policy document for event bridge
data "aws_iam_policy_document" "eventbridge" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["scheduler.amazonaws.com"]
    }
  }
}

locals {
  eventbridge_iam_role = "${var.resource_grp_name}-eventbridge-role"
  eventbridge_iam_policy = "${var.resource_grp_name}-eventbridge-policy"
}

# the iam role for the lambda function
resource "aws_iam_role" "eventbridge_iam_role" {
  name = local.eventbridge_iam_role

  # a trust relationship policy document is needed to give a target service (in this case Lambda), 
  # the permissions to take on this newly created role, and thereby gain the permissions associated with the role
  assume_role_policy = data.aws_iam_policy_document.eventbridge.json

  tags = {
    name = local.eventbridge_iam_role
    proj_name = var.proj_name
  }
}


data "aws_iam_policy_document" "eventbridge_lambda_trigger" {
  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = [aws_lambda_function.eventbridge_ses_link.arn]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "eventbridge_iam_policy" {
  name   = local.eventbridge_iam_policy
  policy = data.aws_iam_policy_document.eventbridge_lambda_trigger.json

  tags = {
    name = local.eventbridge_iam_policy
    proj_name = var.proj_name
  }
}

resource "aws_iam_role_policy_attachment" "eventbridge_lambda" {
  role       = aws_iam_role.eventbridge_iam_role.name
  policy_arn = aws_iam_policy.eventbridge_iam_policy.arn
}

output "eventbrige_trigger_lambda_arn" {
  value = aws_iam_role.eventbridge_iam_role.arn
}