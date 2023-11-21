# 1. fill in the template file
# 2. generate a py file from the filled in template
# 3. zip up the py file
# 4. create the lambda, load the python code into it, and attach the specific handler function to be run as the primary lambda function


locals {
  resource_grp_name_underscore = replace(var.resource_grp_name, "-", "_")
  lambda_handler_function = "${local.resource_grp_name_underscore}_lambda" # name the lambda function
  source_file = "${path.module}/${local.lambda_handler_function}.py" # the py file created
  zip_file = "${path.module}/${local.lambda_handler_function}.zip" # the zip file created
}

# 1. fill in the template file
data "template_file" "lambda_template" {
  template = file("${path.module}/lambda_handler.py")
  vars = {
    lambda_handler_function = local.lambda_handler_function
    sns_topic_arn = aws_sns_topic.notification.arn
    s3_image_bucket_name = local.s3_bucket_name
  }
}

# 2. generate a py file from the filled in template
resource "local_file" "pycode" {
  content  = data.template_file.lambda_template.rendered
  filename = "${path.module}/${local.lambda_handler_function}.py"

  depends_on = [
    aws_sns_topic.notification
  ]
}

# 3. zip up the py file
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_file = local.source_file
  output_path = local.zip_file

  depends_on = [
    resource.local_file.pycode
  ]
}

locals {
  lambda_tag = "${var.resource_grp_name}-lambda"
}

# 4. create the lambda, load the python code into it, and attach the specific handler function to be run as the primary lambda function
resource "aws_lambda_function" "eventbridge_ses_link" {
  function_name = local.lambda_tag
  
  filename      = local.zip_file
  
  role          = aws_iam_role.lambda_iam_role.arn

  source_code_hash = data.archive_file.lambda_zip.output_base64sha256

  runtime = "python3.10"

  handler = "${local.lambda_handler_function}.${local.lambda_handler_function}"

  timeout = 180 # 3 mins timeout

  memory_size = 1024 # MB / 1 GB

  ephemeral_storage {
    size = 3072 # 3 GB
  }

  tags = {
    name    = local.lambda_tag,
    project = "${var.proj_name}"
  }
}


resource "aws_cloudwatch_log_group" "function_log_group" {
  name              = "/aws/lambda/${aws_lambda_function.eventbridge_ses_link.function_name}"
  retention_in_days = 0
  lifecycle {
    prevent_destroy = false
  }
}

output lambda_email_svc_arn {
  value = aws_lambda_function.eventbridge_ses_link.arn
}