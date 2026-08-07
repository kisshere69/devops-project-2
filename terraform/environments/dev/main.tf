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

  node_group_name     = var.node_group_name
  node_instance_types = var.node_instance_types
  node_capacity_type  = var.node_capacity_type

  node_desired_size = var.node_desired_size
  node_min_size     = var.node_min_size
  node_max_size     = var.node_max_size
  node_disk_size    = var.node_disk_size

  project_name = var.project_name
  environment  = var.environment

  private_subnet_ids = module.vpc.private_subnet_ids
}

resource "aws_eks_access_entry" "terraform_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = "arn:aws:iam::215229808174:user/terraform-user"
  type          = "STANDARD"

  tags = {
    Name        = "${var.project_name}-${var.environment}-terraform-admin-access"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_eks_access_policy_association" "terraform_admin" {
  cluster_name  = module.eks.cluster_name
  principal_arn = aws_eks_access_entry.terraform_admin.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"

  access_scope {
    type = "cluster"
  }
}

module "github_oidc" {
  source = "../../modules/github-oidc"

  github_repository = var.github_repository
  github_branch     = var.github_branch

  eks_cluster_arn  = module.eks.cluster_arn
  eks_cluster_name = module.eks.cluster_name

  github_oidc_subject      = var.github_oidc_subject
  github_oidc_provider_arn = var.github_oidc_provider_arn

  project_name = var.project_name
  environment  = var.environment
}