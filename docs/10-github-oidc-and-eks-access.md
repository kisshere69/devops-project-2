# GitHub OIDC and Amazon EKS Access

## Objective

This document describes how GitHub Actions authenticates to AWS and receives authorization to work with the Amazon EKS cluster without storing long-lived AWS access keys in GitHub.

---

## Access Architecture

```text
GitHub Actions workflow
        │
        │ requests an OIDC token
        ▼
GitHub OIDC Provider
        │
        │ presents the signed token
        ▼
AWS STS
        │
        │ validates repository, branch, and audience
        ▼
GitHub Actions IAM Role
        │
        │ receives temporary AWS credentials
        ▼
Amazon EKS
        │
        │ identifies the IAM role through an Access Entry
        ▼
Kubernetes group: github-actions-deployers
        │
        │ is bound by RoleBinding
        ▼
Kubernetes Role: flask-app-deployer
        │
        ▼
Namespace-scoped access to flask-app
```

---

## Why OIDC Is Used

GitHub Actions requests a short-lived OIDC identity token. AWS validates the token and issues temporary credentials through AWS STS.

Benefits:

- no long-lived AWS access keys in GitHub;
- no manual credential rotation;
- credentials exist only for the workflow session;
- access is restricted to one repository and one branch;
- IAM permissions can be limited to the exact AWS resources required.

---

## GitHub OIDC Provider

Terraform registers the GitHub Actions token service as an AWS IAM OIDC provider `https://token.actions.githubusercontent.com`.

The configured audience is `sts.amazonaws.com`.

The OIDC provider allows AWS to validate identity tokens issued by GitHub Actions. However, it doesn't grant AWS permissions by itself.

---

## GitHub Actions IAM Role

The dedicated IAM role is `devops-project-2-dev-github-actions-role`.

The role is assumed through `sts:AssumeRoleWithWebIdentity`.

---

## Trust Policy

The IAM role trust policy answers the following question: "Who is allowed to assume this role?"

The trust policy validates two GitHub OIDC token claims.

### Audience

Required audience is `token.actions.githubusercontent.com:aud = sts.amazonaws.com`. This confirms that the token was issued for AWS STS.

### Subject

Required subject:

```text
token.actions.githubusercontent.com:sub =
repo:kisshere69/devops-project-2:ref:refs/heads/main
```

This restricts role assumption to:

| Parameter | Allowed value |
|---|---|
| GitHub repository | `kisshere69/devops-project-2` |
| Git branch | `main` |

A workflow from another repository or branch must not be able to assume the role.

---

## IAM Permissions Policy

The role permissions policy answers a different question: "What can the role do after it has been assumed?"

The current policy allows `eks:DescribeCluster`

The permission is restricted to the ARN of the project EKS cluster, and allows GitHub Actions to run:

```bash
aws eks update-kubeconfig   --region eu-central-1   --name devops-project-2
```

The command retrieves the EKS API endpoint and certificate authority data and configures a temporary kubeconfig on the GitHub Actions runner.

The IAM policy does not grant permissions to create Kubernetes Deployments, Services, ConfigMaps, or Secrets. Kubernetes authorization is managed separately through EKS Access Entry and Kubernetes RBAC.

---

## EKS Authentication Mode

The EKS cluster is configured with:

```hcl
access_config {
  authentication_mode = "API_AND_CONFIG_MAP"
}
```

This enables:

- the EKS Access Entry API;
- compatibility with the existing `aws-auth` ConfigMap mechanism.

The mode allows the project to introduce Access Entries without removing compatibility required by existing cluster components.

---

## EKS Access Entry

Terraform creates an EKS Access Entry for the GitHub Actions IAM role:

```text
Cluster: devops-project-2
Principal: devops-project-2-dev-github-actions-role
Type: STANDARD
Kubernetes group: github-actions-deployers
```

The Access Entry connects an AWS IAM identity to a Kubernetes identity. It does not define the Kubernetes permissions by itself.

---

## Kubernetes RBAC

The Kubernetes RBAC configuration is stored in `k8s/base/rbac.yaml`.

It contains:

```text
Role: flask-app-deployer
RoleBinding: flask-app-deployer
Namespace: flask-app
```

The RoleBinding maps the group `github-actions-deployers` to the Role `flask-app-deployer`

The complete authorization path is:

```text
GitHub Actions IAM role
→ EKS Access Entry
→ github-actions-deployers
→ RoleBinding
→ flask-app-deployer Role
```

---

## Allowed Kubernetes Operations

The Role is namespace-scoped and allows the workflow to manage application resources only in `flask-app`. This follows the principle of least privilege.

Allowed resources and actions:

| API group | Resources | Verbs |
|---|---|---|
| Core API | `configmaps`, `secrets`, `services` | `get`, `list`, `watch`, `create`, `update`, `patch` |
| `apps` | `deployments`, `replicasets` | `get`, `list`, `watch`, `create`, `update`, `patch` |
| Core API | `pods`, `pods/log` | `get`, `list`, `watch` |

---

## Authentication and Authorization

The access chain has two separate layers.

### AWS Authentication

```text
GitHub OIDC token
→ AWS STS
→ GitHub Actions IAM role
```

This layer proves the AWS identity of the workflow.

### Kubernetes Authorization

```text
IAM role
→ EKS Access Entry
→ Kubernetes group
→ RoleBinding
→ Role
```

This layer determines what the authenticated identity can do inside Kubernetes.

---

## GitHub Secret Runtime Deployment

The application secret is stored in GitHub as `APP_SECRET`. The planned GitHub Actions workflow creates or updates the Kubernetes Secret (`flask-app-secret`).

The intended runtime command is:

```bash
kubectl create secret generic flask-app-secret   --namespace flask-app   --from-literal=APP_SECRET="$APP_SECRET"   --dry-run=client   --output=yaml |
kubectl apply -f -
```

The generated Secret manifest is passed directly through standard input and is not committed to the repository.

---

## Security Summary

The current design provides the following security boundaries:

```text
Repository boundary:
kisshere69/devops-project-2

Branch boundary:
main

AWS resource boundary:
devops-project-2 EKS cluster

Kubernetes namespace boundary:
flask-app

Credential lifetime:
temporary AWS STS session

Secret storage:
GitHub Secrets

Cluster permissions:
namespace-scoped Kubernetes RBAC
```

This design avoids long-lived AWS credentials and separates AWS authentication from Kubernetes authorization.