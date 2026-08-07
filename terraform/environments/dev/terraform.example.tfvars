aws_region   = "value"
project_name = "value"
environment  = "value"
vpc_cidr     = "1.2.3.4/67"

public_subnet_a_cidr = "3.2.1.0/69"
az_a                 = "value"

public_subnet_b_cidr = "2.3.1.0/69"
az_b                 = "value"

private_subnet_a_cidr = "value"
private_subnet_b_cidr = "value"

repository_name      = "value"
image_tag_mutability = "MUTABLE"
scan_on_push         = true

cluster_version = "1.36"

node_group_name     = "value"
node_instance_types = ["t3.small"]
node_capacity_type  = "ON_DEMAND"

node_desired_size = 2
node_min_size     = 1
node_max_size     = 3

node_disk_size = 20

github_repository = "owner/repository"
github_branch     = "main"

github_oidc_provider_arn = "value"
github_oidc_subject      = "value"