aws_region   = "eu-central-1"
project_name = "devops-project-2"
environment  = "dev"

vpc_cidr = "10.0.0.0/16"

public_subnet_a_cidr = "10.0.1.0/24"
public_subnet_b_cidr = "10.0.2.0/24"

private_subnet_a_cidr = "10.0.11.0/24"
private_subnet_b_cidr = "10.0.12.0/24"

az_a = "eu-central-1a"
az_b = "eu-central-1b"

repository_name = "flask-app"

cluster_version = "1.36"

node_group_name     = "general"
node_instance_types = ["t3.small"]
node_capacity_type  = "ON_DEMAND"

node_desired_size = 2
node_min_size     = 1
node_max_size     = 3
node_disk_size    = 20

github_repository = "kisshere69/devops-project-2"