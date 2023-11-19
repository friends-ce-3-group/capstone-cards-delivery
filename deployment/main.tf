module "goodreads_notification" {
  source = "../"

  resource_grp_name = var.resource_grp_name

  proj_name = var.proj_name

  region = var.region

}

resource "local_file" "lambda_email_svc_arn" {
  content = <<-EOT
    LAMBDAARN=${module.goodreads_notification.lambda_email_svc_arn}
    EVENTBRIDGETRIGGERLAMBDAROLEARN=${module.goodreads_notification.eventbrige_trigger_lambda_arn}
    EOT

  filename = "${path.module}/outputs.dat"
}
