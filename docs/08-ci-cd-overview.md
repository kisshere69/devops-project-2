# CI/CD Overview

## CI Overview

The project uses GitHub Actions for CI/CD.

The current pipeline validates Terraform, Helm, and Docker changes before they are merged into the `main` branch.

The pipeline currently contains four jobs:

```text
Terraform Checks
Helm Checks
Docker Checks
Terraform Plan
```

These jobs run independently and can execute in parallel.

---

## Terraform Checks

Terraform configuration is validated using:

```bash
terraform fmt -check -recursive terraform
terraform init -backend=false
terraform validate
```

This job checks formatting, syntax, providers, modules, and Terraform configuration consistency.

The backend is disabled because this job does not need access to AWS or the remote Terraform state.

---

## Helm Checks

The Helm chart is validated using:

```bash
helm lint
helm template
```

The development configuration is loaded from `helm/values-dev.yaml`. This verifies that the chart is valid and Kubernetes manifests can be rendered successfully.

---

## Docker Checks

The Docker job builds the Flask application image.

Its purpose is to verify that the Dockerfile is valid, dependencies can be installed, and application image can be built successfully.

---

## Terraform Plan

The Terraform Plan job connects to AWS and generates a real infrastructure plan.

It uses:

```bash
terraform plan \
  -input=false \
  -lock-timeout=60s \
  -no-color \
  -var-file=terraform.ci.tfvars
```

CI-specific non-sensitive Terraform variables are stored in `terraform/environments/dev/terraform.ci.tfvars`.

The job reads the remote Terraform state from S3.

---

## AWS Authentication

GitHub Actions authenticates to AWS using OIDC. No long-lived AWS access keys are stored in GitHub.

Authentication flow:

```text
GitHub Actions
    |
    v
GitHub OIDC
    |
    v
AWS STS
    |
    v
Terraform Plan IAM Role
    |
    v
Temporary AWS Credentials
```

The Terraform Plan IAM role is `devops-project-2-shared-terraform-plan-role`.

The role has read permissions for AWS infrastructure and access to the Terraform state backend (S3 bucket).

Terraform state locking requires limited write access to the S3 lock file.

---

## Persistent CI Infrastructure

CI authentication infrastructure is managed separately in `terraform/bootstrap/`. It contains:

```text
GitHub OIDC Provider
Terraform Plan IAM Role
Terraform Plan IAM Policy
```

This allows the development infrastructure to be destroyed without breaking the CI pipeline.

---