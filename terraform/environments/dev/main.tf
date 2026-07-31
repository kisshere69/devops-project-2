data "aws_caller_identity" "current" {

}

module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr

  public_subnet_a_cidr = var.public_subnet_a_cidr
  az_a                 = var.az_a
}