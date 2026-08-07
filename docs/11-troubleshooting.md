## Troubleshooting: GitHub OIDC subject mismatch

### Problem summary

During the first runtime validation of the GitHub Actions authentication chain, the `Deploy Kubernetes Secret` workflow failed at the AWS credentials configuration step.

The failed step used:

```yaml
- name: Configure AWS credentials
  uses: aws-actions/configure-aws-credentials@v4
```

The workflow returned:

```text
Error: Could not assume role with OIDC:
Not authorized to perform sts:AssumeRoleWithWebIdentity
```

The error occurred before GitHub Actions reached the EKS cluster or executed any `kubectl` commands.

### Initial Terraform configuration

The GitHub OIDC Terraform module originally constructed the expected `sub` claim from the repository name and branch.

Initial condition:

```hcl
condition {
  test     = "StringEquals"
  variable = "token.actions.githubusercontent.com:sub"

  values = [
    "repo:${var.github_repository}:ref:refs/heads/${var.github_branch}"
  ]
}
```

The module received values similar to:

```hcl
github_repository = "kisshere69/devops-project-2"
github_branch     = "main"
```

As a result, Terraform generated the following IAM trust condition:

```text
repo:kisshere69/devops-project-2:ref:refs/heads/main
```

The IAM Role trust policy also correctly required the AWS STS audience:

```hcl
condition {
  test     = "StringEquals"
  variable = "token.actions.githubusercontent.com:aud"

  values = [
    "sts.amazonaws.com"
  ]
}
```

### Initial checks

The following components were verified before changing the configuration:

- the workflow was started from the `main` branch;
- the workflow had the required permission:

```yaml
permissions:
  id-token: write
  contents: read
```

- the IAM Role trusted the correct GitHub OIDC provider;
- the trust policy allowed `sts:AssumeRoleWithWebIdentity`;
- the audience condition was `sts.amazonaws.com`;
- the repository did not use a GitHub Environment in this workflow;
- the OIDC provider existed in the correct AWS account.

The IAM trust policy expected:

```text
repo:kisshere69/devops-project-2:ref:refs/heads/main
```

However, AWS STS continued to reject the token.

### OIDC claim diagnostics

A temporary diagnostic step was added before the AWS credentials configuration step. Its purpose was to request a GitHub OIDC token and print only selected identity claims without exposing the complete JWT.

The relevant claims were:

```json
{
  "aud": "sts.amazonaws.com",
  "sub": "repo:kisshere69@155293675/devops-project-2@1315877380:ref:refs/heads/main",
  "repository": "kisshere69/devops-project-2",
  "repository_owner": "kisshere69",
  "ref": "refs/heads/main",
  "ref_type": "branch",
  "event_name": "workflow_dispatch",
  "workflow": "Deploy Kubernetes Secret",
  "job_workflow_ref": "kisshere69/devops-project-2/.github/workflows/deploy-secret.yaml@refs/heads/main"
}
```

The mismatch was located in the `sub` claim.

### Root cause

The IAM Role trust policy expected:

```text
repo:kisshere69/devops-project-2:ref:refs/heads/main
```

The actual GitHub OIDC token contained:

```text
repo:kisshere69@155293675/devops-project-2@1315877380:ref:refs/heads/main
```

The actual subject included immutable numeric identifiers:

```text
GitHub owner:
kisshere69@155293675

GitHub repository:
devops-project-2@1315877380
```

Because the IAM trust policy used `StringEquals`, the expected value had to match the actual `sub` claim exactly.

The difference between these two values caused AWS STS to reject: `sts:AssumeRoleWithWebIdentity`/

### Terraform module change

The module was updated so that it no longer constructed the OIDC subject internally from only the repository name and branch.

Instead, the exact subject became an explicit module input. Added variable:

```hcl
variable "github_oidc_subject" {
  description = "Exact GitHub OIDC subject allowed to assume the IAM role"
  type        = string
}
```

In file `terraform/modules/github-oidc/main.tf`, a previous configuration was:

```hcl
condition {
  test     = "StringEquals"
  variable = "token.actions.githubusercontent.com:sub"

  values = [
    "repo:${var.github_repository}:ref:refs/heads/${var.github_branch}"
  ]
}
```

The updated configuration now looks like this:

```hcl
condition {
  test     = "StringEquals"
  variable = "token.actions.githubusercontent.com:sub"

  values = [
    var.github_oidc_subject
  ]
}
```

### Environment configuration

The exact immutable subject was passed from the development environment. This makes the trust boundary explicit at the environment level.

File:

```text
terraform/environments/dev/main.tf
```

Configuration:

```hcl
github_oidc_subject = "repo:kisshere69@155293675/devops-project-2@1315877380:ref:refs/heads/main"
```

### Terraform validation

After changing the module, the Terraform configuration was checked with:

```bash
terraform fmt -recursive
terraform validate
terraform plan
```

The expected plan contained only an in-place IAM Role trust policy update:

```text
Plan: 0 to add, 1 to change, 0 to destroy
```

Eventually, the IAM Role trust policy was updated to expect the exact immutable GitHub OIDC subject.

### Runtime validation

The `Deploy Kubernetes Secret` workflow was started again from the `main` branch.

The AWS credentials step completed successfully and reported an assumed Role session:

```text
Authenticated as assumedRoleId
AROATEHFSHYXCDS7UXAMU:github-actions-deploy-secret
```

### Temporary diagnostics cleanup

The OIDC claim inspection step was used only to identify the mismatch.

After successful runtime validation, the temporary diagnostic step was removed from `.github/workflows/deploy-secret.yaml`.


## Troubleshooting: GitHub Actions job skip

### Problem summary

The `Deploy Flask Application` workflow started successfully, but the deployment job was marked as `Skipped`.

### Initial configuration

The job contained the following condition:

```yaml
if: github.ref == 'main'
```

### Root cause

Since GitHub Actions does not store the branch name in `github.ref` as only `main`, the full reference should be `refs/heads/main`.

### Resolution

The job condition was updated to use the full branch reference:

```yaml
if: github.ref == 'refs/heads/main'
```

### Validation

The workflow was started again from the `main` branch.

The job was no longer skipped and proceeded to execute the deployment steps.

## Troubleshooting: Missing RBAC access to EndpointSlices

### Problem summary

The application deployment workflow included a verification step for Kubernetes Service EndpointSlices:

```bash
kubectl get endpointslices \
  --namespace "$KUBERNETES_NAMESPACE" \
  --selector kubernetes.io/service-name="$SERVICE_NAME"
```

The GitHub Actions Kubernetes Role did not include permission to read this resource.

### Root cause

`EndpointSlice` is not part of the core Kubernetes API group. Instead, it belongs to `discovery.k8s.io`.

The existing Role allowed access to Deployments, Services, Pods, ConfigMaps, and Secrets, but did not include `endpointslices`. As a result, the workflow  failed with a Kubernetes authorization error `Forbidden`.


### Resolution

A read-only rule was added to `k8s/base/rbac.yaml`. A slice of config:

```yaml
- apiGroups:
    - discovery.k8s.io
  resources:
    - endpointslices
  verbs:
    - get
    - list
    - watch
```

### Validation

The updated Role was applied:

```bash
kubectl apply -f k8s/base/rbac.yaml
```

The get action was verified with:

```bash
kubectl auth can-i get endpointslices.discovery.k8s.io \
  --namespace flask-app \
  --as=github-actions-validation \
  --as-group=github-actions-deployers
```

Result `yes`.

Delete access was tested with:

```bash
kubectl auth can-i delete endpointslices.discovery.k8s.io \
  --namespace flask-app \
  --as=github-actions-validation \
  --as-group=github-actions-deployers
```

Result `no`.

## Troubleshooting: Kubernetes admin access was missing

### Problem summary

Although, the local `terraform-user` identity could authenticate to AWS and manage the EKS infrastructure through Terraform, `kubectl` commands against the EKS cluster were denied.

### Root cause

The IAM user existed in AWS, but it was not registered as an EKS access principal and therefore had no Kubernetes permissions inside the cluster.

### Resolution

An EKS Access Entry was created for `arn:aws:iam::215229808174:user/terraform-user`.

The `AmazonEKSClusterAdminPolicy` EKS access policy was associated with cluster scope. This allowed the local Terraform identity to perform administrative Kubernetes operations required for bootstrap and validation.

### Validation

The kubeconfig was updated:

```bash
aws eks update-kubeconfig \
  --name devops-project-2 \
  --region eu-central-1
```

Cluster access was then verified:

```bash
kubectl get nodes
```

The worker nodes were returned successfully in `Ready` state.

Additional validation included:

```bash
kubectl get pods --namespace kube-system
kubectl get namespaces
```

## Troubleshooting: Terraform Plan failed because CI variables are missing

### Problem summary

The `Terraform Plan` GitHub Actions job failed with errors such as:

```text
Error: No value for required variable

The root module input variable "aws_region" is not set
The root module input variable "project_name" is not set
```

The same Terraform configuration worked locally.

### Root cause

Local Terraform runs used values stored in `terraform/environments/dev/terraform.tfvars`.

This file is excluded from Git and therefore does not exist on the GitHub Actions runner.

The CI pipeline had no values for the required Terraform variables.

### Resolution

A separate CI variables file was created `terraform/environments/dev/terraform.ci.tfvars`.

The Terraform Plan command was updated to explicitly use it:

```bash
terraform plan \
  -input=false \
  -lock-timeout=60s \
  -no-color \
  -var-file=terraform.ci.tfvars
```

P.S. The file contains only non-sensitive infrastructure configuration.

### Validation

The same `terraform plan...` command was tested locally first.

Result:

```text
Plan: 32 to add, 0 to change, 0 to destroy.
```

Then, the `Terraform Plan` job was executed in GitHub Actions successfully.

---

## Troubleshooting: Syntax error. Terraform variables used as literal provider tag values.

### Problem summary

Terraform AWS provider tags were configured as:

```hcl
Project     = "var.project_name"
Environment = "var.environment"
```

This caused Terraform to treat the variable references as literal strings.

### Root cause

Terraform variable references were incorrectly placed inside quotation marks.

### Resolution

The provider configuration was corrected to reference the variables directly:

```hcl
provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}
```

### Validation

Terraform configuration was formatted and validated:

```bash
terraform fmt
terraform validate
```

Terraform Plan then completed successfully using the corrected provider configuration.