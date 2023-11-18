module "goodreads_notification" {
    source = "../"

    resource_grp_name = var.resource_grp_name

    proj_name = var.proj_name

    region = var.region

    environment = var.environment
}