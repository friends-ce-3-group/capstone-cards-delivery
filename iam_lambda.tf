# Create a new IAM role using:                      resource "aws_iam_role"
# Create policy documents as necessary using:       data "aws_iam_policy_document"

# Create policies using:                            resource "aws_iam_policy"
# where each policy is required to come with a policy document json attached to it using the "policy" parameter

# Attach policies to IAM role using:                resource "aws_iam_role_policy_attachment"

# IAM policy document json ----part of----> IAM policy ----attach to----> IAM role


# A1. generate the policy doc to allow SNS publishing
# A2. create a new policy and attach the SNS publishing policy doc json to it
# A3. attach the new policy to the IAM role

# B1. generate the policy doc to allow logging from lambda
# B2. create a new policy and attach the lambda logging policy doc json to it
# B3. attach the new policy to the IAM role

locals {
  lambda_iam_role = "${var.resource_grp_name}-lambda-role"
  lambda_iam_logging_policy = "${var.resource_grp_name}-lambda-logging-policy"
  lambda_iam_s3_get_policy = "${var.resource_grp_name}-lambda-s3-get-policy"
  sns_iam_policy = "${var.resource_grp_name}-sns-policy"
}

# generate a generic trust relationship policy document for lambdas
data "aws_iam_policy_document" "lambda" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

# the iam role for the lambda function
resource "aws_iam_role" "lambda_iam_role" {
  name = local.lambda_iam_role

  # a trust relationship policy document is needed to give a target service (in this case Lambda), 
  # the permissions to take on this newly created role, and thereby gain the permissions associated with the role
  assume_role_policy = data.aws_iam_policy_document.lambda.json

  tags = {
    name = local.lambda_iam_role
    proj_name = var.proj_name
  }
}

# Set up permissions for publishing to SNS
# -----------------------------------------------------------------

# A1. generate the policy doc to allow SNS publishing
data "aws_iam_policy_document" "sns_topic_policy_doc" {
  statement {
    actions   = ["sns:Publish"]
    resources = [aws_sns_topic.notification.arn]
    effect    = "Allow"
  }
}

# A2. create a new policy and attach the SNS publishing policy doc json to it
resource "aws_iam_policy" "sns_topic_policy" {
  name   = local.sns_iam_policy
  policy = data.aws_iam_policy_document.sns_topic_policy_doc.json

  tags = {
    name = local.sns_iam_policy
    proj_name = var.proj_name
  }
}

# A3. attach the new policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_sns_topic" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.sns_topic_policy.arn
}


# Set up permissions for CloudWatch logging
# -----------------------------------------------------------------

#
# Approach 1:: Use data to find a predefined policy AWSLambdaBasicExecutionRole
#

# # search for the basic lambda policy and get its arn
# data "aws_iam_policy" "lambda_basic_policy" {
#   name = "AWSLambdaBasicExecutionRole"
# }

# # attach the AWSLambdaBasicExecutionRole policy to the new IAM role using the former's arn
# resource "aws_iam_role_policy_attachment" "attach_lambda_basic_policy" {
#   role       = aws_iam_role.lambda_iam_role.name
#   policy_arn = data.aws_iam_policy.lambda_basic_policy.arn # this policy already exists so we don't need to generate it
# }

#
# Approach 2:: Specify a new policy
#

# B1. generate the policy doc to allow logging from lambda
data "aws_iam_policy_document" "lambda_logging_policy_doc" {
  statement {
    actions   = [
          # "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
    resources = [ "arn:aws:logs:*:*:*" ]
    effect    = "Allow"
  }
}

# B2. create a new policy and attach the lambda logging policy doc json to it
resource "aws_iam_policy" "lambda_logging_policy" {
  name   = local.lambda_iam_logging_policy
  policy = data.aws_iam_policy_document.lambda_logging_policy_doc.json

  tags = {
    name = local.lambda_iam_logging_policy
    proj_name = var.proj_name
  }
}

# B3. attach the new policy to the IAM role
resource "aws_iam_role_policy_attachment" "attach_lambda_logging_policy" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_logging_policy.arn
}

# Set up permissions to reach S3 bucket
#------------------------------------------------------------------------------

locals {
  s3_bucket_name = split(".", "${S3_BUCKET_IMAGES_URL}")[0]
}

data "aws_iam_policy_document" "lambda_s3_get_policy_doc" {
  statement {
    actions   = [
          "s3:GetObject"
        ]
    resources = [ "arn:aws:s3:::${local.s3_bucket_name}/*" ]
    effect    = "Allow"
  }
}

resource "aws_iam_policy" "lambda_s3_get_policy" {
  name   = local.lambda_iam_s3_get_policy
  policy = data.aws_iam_policy_document.lambda_s3_get_policy_doc.json

  tags = {
    name = local.lambda_iam_s3_get_policy
    proj_name = var.proj_name
  }
}


resource "aws_iam_role_policy_attachment" "attach_s3_get_policy" {
  role       = aws_iam_role.lambda_iam_role.name
  policy_arn = aws_iam_policy.lambda_s3_get_policy.arn
}
