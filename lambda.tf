# 1. fill in the template file
# 2. generate a py file from the filled in template
# 3. zip up the py file
# 4. create the lambda, load the python code into it, and attach the specific handler function to be run as the primary lambda function


locals {
  lambda_handler_function = "${var.resource_grp_name}_lambda" # name the lambda function
  source_file = "${path.module}/${local.lambda_handler_function}.py" # the py file created
  zip_file = "${path.module}/${local.lambda_handler_function}.zip" # the zip file created
}

# 1. fill in the template file
data "template_file" "lambda_template" {
  template = file("${path.module}/lambda_handler.py")
  vars = {
    lambda_handler_function = local.lambda_handler_function
    sns_topic_arn = aws_sns_topic.notification.arn
  }
}

# 2. generate a py file from the filled in template
resource "local_file" "pycode" {
  content  = data.template_file.lambda_template.rendered
  filename = "${path.module}/${local.lambda_handler_function}.py"

  depends_on = [
    aws_sns_topic.lambda_hello_world
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

  tags = {
    name    = local.lambda_tag,
    project = "${var.proj_name}"
  }
}
