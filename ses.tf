# Provides an SES email identity resource
resource "aws_ses_email_identity" "gooodgreets" {
  email = "gooodgreets@gmail.com"
}

# Provides an IAM access key. This is a set of credentials that allow API requests to be made as an IAM user.
resource "aws_iam_user" "ses_user" {
  name = "${var.resource_grp_name}-ses-identity"

  tags = {
    name = "${var.resource_grp_name}-ses-identity"
    proj_name = var.proj_name
  }
}

# Provides an IAM access key. This is a set of credentials that allow API requests to be made as an IAM user.
resource "aws_iam_access_key" "access_key" {
  user = aws_iam_user.ses_user.name
}


data "aws_iam_policy_document" "ses_policy_document" {
  statement {
    actions   = [
      "ses:SendEmail", 
      "ses:SendRawEmail"
      ]
    resources = [aws_ses_email_identity.gooodgreets.arn]
  }
}


resource "aws_iam_policy" "ses_policy" {
  name   = "${var.resource_grp_name}-ses-policy"
  policy = data.aws_iam_policy_document.ses_policy_document.json

  tags = {
    name = "${var.resource_grp_name}-ses-policy"
    proj_name = var.proj_name
  }
}

# Attaches a Managed IAM Policy to an IAM user
resource "aws_iam_user_policy_attachment" "ses_user_policy_attach" {
  user       = aws_iam_user.ses_user.name
  policy_arn = aws_iam_policy.ses_policy.arn
}


# IAM user credentials output
output "smtp_username" {
  value = aws_iam_access_key.access_key.id
}

output "smtp_password" {
  value     = aws_iam_access_key.access_key.ses_smtp_password_v4
  sensitive = true
}