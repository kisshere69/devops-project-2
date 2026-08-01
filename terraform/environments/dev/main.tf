data "aws_caller_identity" "current" {

}

module "vpc" {
  source = "../../modules/vpc"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr

  public_subnet_a_cidr = var.public_subnet_a_cidr
  az_a                 = var.az_a

  public_subnet_b_cidr = var.public_subnet_b_cidr
  az_b                 = var.az_b

  private_subnet_a_cidr = var.private_subnet_a_cidr
  private_subnet_b_cidr = var.private_subnet_b_cidr
}

module "ecr" {
  source = "../../modules/ecr"

  project_name = var.project_name
  environment  = var.environment

  repository_name      = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  scan_on_push         = var.scan_on_push
}