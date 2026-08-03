# Amazon EKS Overview

## Objective

The EKS cluster will host the containerized Flask application that was built and published to Amazon ECR.

---

## Architecture

```text
AWS Account
│
├── VPC
│   ├── Public Subnet A
│   ├── Public Subnet B
│   ├── Private Subnet A
│   └── Private Subnet B
│
├── EKS Cluster
│   │
│   ├── Control Plane (AWS Managed)
│   │
│   └── Managed Node Group
│           │
│           ├── EC2
│           ├── kubelet
│           └── kube-proxy
│
└── Amazon ECR
        │
        └── Flask Image
```

---

## IAM Design

The EKS Control Plane requires an IAM Role to interact with AWS services. The Role is assumed by EKS Control Plane.

Terraform creates:

- IAM Role
- AmazonEKSClusterPolicy attachment

---

## Networking

The EKS cluster is deployed into the existing VPC, exactly in private subnets A/B.

Public API endpoint remains enabled to simplify cluster administration from the local workstation during development.

---

## Next Steps

The following components will be implemented next:

- Managed Node Group
- kubectl configuration
- Cluster verification
- Helm installation
- Kubernetes workloads