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

module "eks" {
  source = "../../modules/eks"

  cluster_name    = var.project_name
  cluster_version = var.cluster_version

  node_group_name    = var.node_group_name
  node_instance_types = var.node_instance_types
  node_capacity_type = var.node_capacity_type

  node_desired_size = var.node_desired_size
  node_min_size     = var.node_min_size
  node_max_size     = var.node_max_size
  node_disk_size    = var.node_disk_size

  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids = module.vpc.private_subnet_ids
}