# Amazon Elastic Container Registry (ECR)

## Purpose

Amazon Elastic Container Registry (ECR) is used as the private container registry for this project.

---

# Architecture

```text
Developer
     │
docker build
     │
docker push
     │
Amazon ECR
     │
Amazon EKS
```

---

# Repository Configuration

Repository name:

```text
flask-app
```

The repository is designed to store Docker images for the Flask application used throughout the project.

---

# Image Tag Mutability

Current configuration:

```text
MUTABLE
```

Reason:

The project is currently in the development phase. Allowing mutable tags simplifies testing because images such as `latest` can be pushed multiple times.

---

# Image Scanning

Image scanning is enabled.

```text
scan_on_push = true
```

Every image pushed to the repository is automatically scanned for vulnerabilities by Amazon ECR. This helps identify security issues before deployment.

---

# Encryption

Encryption type:

```text
AES256
```

The default AWS-managed encryption is sufficient for this project.

---

# Lifecycle Policy

The repository automatically removes old images.

Current policy:

- Keep the latest 10 images.
- Delete older images automatically.

Benefits:

- Reduce storage usage.
- Keep the repository clean.
- Prevent unnecessary AWS costs.

---

# Outputs

The module exports:

- Repository Name
- Repository ARN
- Repository URL

These outputs will be used later by:

- GitHub Actions
- Docker
- Amazon EKS

---

# Design Decisions

## One Repository per Application

Each application should have its own ECR repository.

Advantages:

- simpler access control;
- independent lifecycle policies;
- easier CI/CD integration;
- cleaner repository organization.

---

## Why Amazon ECR?

Amazon ECR was selected because it:

- integrates natively with Amazon EKS;
- integrates with AWS IAM;
- supports vulnerability scanning;
- supports lifecycle policies;
- requires no additional infrastructure;
- is fully managed by AWS.

---