terraform {
  backend "s3" {
    bucket       = "devops-project-2-terraform-state-215229808174"
    key          = "dev/terraform.tfstate"
    region       = "eu-central-1"
    use_lockfile = true
    encrypt      = true
  }
}