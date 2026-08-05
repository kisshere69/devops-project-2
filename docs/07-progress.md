# Project Progress

---

# Sprint 1 - Project Initialization

### Repository

- [x] GitHub repository
- [x] Initial project structure
- [x] README.md

### Local Environment

- [x] Git
- [x] AWS CLI
- [x] Terraform
- [x] Git

### AWS

- [x] IAM User
- [x] AWS credentials
- [x] Account verification

### Terraform

- [x] Terraform initialization
- [x] Provider configuration
- [x] Variables
- [x] Outputs

### Networking

- [x] VPC
- [x] Internet Gateway
- [x] Public Route Table
- [x] Public Route
- [x] Public Subnet A
- [x] Route Table Association

### Validation

- [x] terraform fmt
- [x] terraform validate
- [x] terraform plan
- [x] terraform apply
- [x] Infrastructure verified in AWS Console
- [x] terraform destroy tested

---

# Sprint 2 - Networking

- [x] Public Subnet B
- [x] Private Subnet A
- [x] Private Subnet B
- [x] NAT Gateway
- [x] Private Route Table
- [x] Route Table Associations

---

# Sprint 3 - Container Registry

- [x] Amazon ECR
- [x] Image Repository
- [x] Image Lifecycle Policy

---

# Sprint 4 - Kubernetes

## Amazon EKS

- [x] Amazon EKS Cluster
- [x] Managed Node Group
- [x] kubectl Configuration
- [x] Cluster Verification

---

# Sprint 5 - Containerized Application

## Flask Application

- [x] Flask Application
- [x] requirements.txt
- [x] Dockerfile
- [x] .dockerignore

## Docker

- [x] Local Docker Build
- [x] Local Docker Run
- [x] Push Image to Amazon ECR

---

# Sprint 6 - Kubernetes Workloads

- [x] Namespace
- [x] ConfigMap
- [x] Deployment
- [x] Service
- [x] Namespace-scoped RBAC
- [x] Kubernetes Secret created at runtime
- [ ] Ingress

## AWS Authorization for GitHub Actions

- [x] GitHub OIDC provider configuration
- [x] GitHub Actions IAM role creation
- [x] Least-privilege EKS IAM policy
- [x] EKS Access Entry configuration
- [x] Kubernetes group mapping
- [x] AWS authorization chain runtime verification
- [x] Kubernetes RBAC runtime verification

## GitHub Actions

- [x] `APP_SECRET` added to GitHub Secrets
- [x] Kubernetes Secret deployment workflow (`deploy-secret.yaml`) configured
- [x] OIDC authentication test
- [x] Kubernetes Secret runtime deployment
- [x] Application deployment workflow

## Runtime Validation

- [x] Apply Kubernetes manifests
- [x] Verify Pods are Running and Ready
- [x] Verify readiness and liveness probes
- [x] Verify Service EndpointSlices
- [x] Verify ConfigMap variables in the application
- [x] Verify Secret is available to the application
- [x] Verify namespace isolation with `kubectl auth can-i`

## Helm

- [ ] Helm Chart structure
- [ ] Kubernetes manifests converted to Helm templates
- [ ] Development values file
- [ ] Helm Release deployment

## Ingress

- [ ] AWS Load Balancer Controller IAM configuration
- [ ] AWS Load Balancer Controller installation with Helm
- [ ] Ingress manifest
- [ ] External access validation

---

# Sprint 7 - CI/CD

## GitHub Actions

- [ ] Terraform Format
- [ ] Terraform Validate
- [ ] Terraform Plan
- [ ] Docker Build
- [ ] Push Image to Amazon ECR
- [ ] Helm Upgrade
- [ ] Deployment Verification

---

# Sprint 8 - Observability

## Monitoring

- [ ] Metrics Server
- [ ] Prometheus
- [ ] Grafana

## Logging

- [ ] Centralized Logging

---

# Sprint 9 - Security

## Security

- [ ] IAM Roles for Service Accounts (IRSA)
- [ ] Network Policies
- [ ] Security Groups Review
- [ ] Secrets Management
- [ ] Image Security Review