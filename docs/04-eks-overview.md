# Amazon EKS Overview

## Objective

The EKS cluster will host the containerized Flask application that was built and published to Amazon ECR.

The platform was created with Terraform and includes:

- Amazon EKS control plane
- EKS Managed Node Group
- EC2 worker nodes
- IAM roles and policies
- Multi-AZ private networking
- Kubernetes system components
- Local `kubectl` access

---

## Architecture

```text
AWS Account
│
├── VPC: 10.0.0.0/16
│   │
│   ├── Public Subnet A: 10.0.1.0/24
│   │   └── Availability Zone: eu-central-1a
│   │
│   ├── Public Subnet B: 10.0.2.0/24
│   │   └── Availability Zone: eu-central-1b
│   │
│   ├── Private Subnet A: 10.0.11.0/24
│   │   └── Availability Zone: eu-central-1a
│   │
│   └── Private Subnet B: 10.0.12.0/24
│       └── Availability Zone: eu-central-1b
│
├── Amazon EKS Cluster: devops-project-2
│   │
│   ├── Control Plane
│   │   ├── AWS managed
│   │   ├── Kubernetes version: 1.36
│   │   ├── Public API endpoint: enabled
│   │   └── Private API endpoint: enabled
│   │
│   └── Managed Node Group: general
│       │
│       ├── Capacity type: ON_DEMAND
│       ├── Instance type: t3.small
│       ├── Desired nodes: 2
│       ├── Minimum nodes: 1
│       ├── Maximum nodes: 3
│       └── Root volume: 20 GiB
│
└── Amazon ECR
    └── Repository: flask-app
```

---

## Implemented AWS Resources

The Terraform EKS module creates the following resources:

```text
aws_eks_cluster
aws_eks_node_group

aws_iam_role.eks_cluster
aws_iam_role.eks_nodes

aws_iam_role_policy_attachment.eks_cluster_policy
aws_iam_role_policy_attachment.eks_worker_node_policy
aws_iam_role_policy_attachment.eks_ecr_pull_policy
aws_iam_role_policy_attachment.eks_cni_policy
```

Terraform state confirmed that all expected EKS, IAM, VPC, and ECR resources were successfully created.

---

## EKS Control Plane

The Amazon EKS control plane is fully managed by AWS.

Deployed configuration:

| Parameter | Value |
|---|---|
| Cluster name | `devops-project-2` |
| Status | `ACTIVE` |
| Kubernetes version | `1.36` |
| AWS Region | `eu-central-1` |
| VPC ID | `vpc-0dc053d1b39cf2ebc` |
| Public endpoint | Enabled |
| Private endpoint | Enabled |
| Egress mode | AWS managed |

The cluster uses the following private subnets:

```text
subnet-0f983ff76448de519
devops-project-2-dev-private-a
eu-central-1a
10.0.11.0/24
```

```text
subnet-0e29642c2918a9e24
devops-project-2-dev-private-b
eu-central-1b
10.0.12.0/24
```

The Kubernetes API endpoint created during validation was:

```text
https://E41ECB9D057CEA3F74B616F3C8365F72.gr7.eu-central-1.eks.amazonaws.com
```

The endpoint is generated dynamically and will change if the cluster is destroyed and recreated.

---

## EKS Cluster IAM Role

The EKS control plane uses a dedicated IAM role:

```text
devops-project-2-dev-eks-cluster-role
```

Trusted AWS service:

```text
eks.amazonaws.com
```

Attached policy:

```text
AmazonEKSClusterPolicy
```

Trust relationship:

```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
```

This role allows the EKS control plane to interact with required AWS resources.

---

## Managed Node Group

The cluster uses an Amazon EKS Managed Node Group.

| Parameter | Value |
|---|---|
| Node Group name | `general` |
| Status | `ACTIVE` |
| Capacity type | `ON_DEMAND` |
| Instance type | `t3.small` |
| Desired size | `2` |
| Minimum size | `1` |
| Maximum size | `3` |
| Disk size | `20 GiB` |
| Health issues | `0` |

The Node Group is attached to both private subnets, allowing AWS to distribute worker nodes across two Availability Zones.

---

## Worker Node IAM Role

The worker nodes use a separate IAM role:

```text
devops-project-2-dev-eks-node-role
```

Trusted AWS service:

```text
ec2.amazonaws.com
```

Attached policies:

```text
AmazonEKSWorkerNodePolicy
AmazonEC2ContainerRegistryPullOnly
AmazonEKS_CNI_Policy
```

Policy responsibilities:

- `AmazonEKSWorkerNodePolicy` allows worker nodes to connect to the EKS cluster.
- `AmazonEC2ContainerRegistryPullOnly` allows worker nodes to pull application images from Amazon ECR.
- `AmazonEKS_CNI_Policy` allows the Amazon VPC CNI plugin to manage network interfaces and private IP addresses.

---

## EC2 Worker Nodes

### Worker Node A

| Parameter | Value |
|---|---|
| Instance ID | `i-028f643025afb06bb` |
| Status | `Running` |
| Instance type | `t3.small` |
| Availability Zone | `eu-central-1a` |
| Subnet | `devops-project-2-dev-private-a` |
| Internal Kubernetes IP | `10.0.11.28` |
| Public IPv4 | None |
| IAM role | `devops-project-2-dev-eks-node-role` |

### Worker Node B

| Parameter | Value |
|---|---|
| Instance ID | `i-099e5657459673271` |
| Status | `Running` |
| Instance type | `t3.small` |
| Availability Zone | `eu-central-1b` |
| Subnet | `devops-project-2-dev-private-b` |
| Internal Kubernetes IP | `10.0.12.59` |
| Public IPv4 | None |
| IAM role | `devops-project-2-dev-eks-node-role` |

The absence of public IPv4 addresses confirms that the worker nodes were correctly deployed in private subnets.

---

## Kubernetes Nodes

The cluster was configured locally using:

```bash
aws eks update-kubeconfig \
  --region eu-central-1 \
  --name devops-project-2
```

Node verification command:

```bash
kubectl get nodes -o wide
```

Validated result:

```text
NAME                                          STATUS   VERSION
ip-10-0-11-28.eu-central-1.compute.internal   Ready    v1.36.2-eks-bca9cf6
ip-10-0-12-59.eu-central-1.compute.internal   Ready    v1.36.2-eks-bca9cf6
```

The nodes run:

```text
Amazon Linux 2023
containerd
kubelet
kube-proxy
```

---

## Kubernetes Pods

The following Kubernetes system Pods were validated in the `kube-system` namespace:

```
$ kubectl get nodes -o wide
NAME                                          STATUS   ROLES    AGE   VERSION               INTERNAL-IP   EXTERNAL-IP   OS-IMAGE                        KERNEL-VERSION                           CONTAINER-RUNTIME
ip-10-0-11-28.eu-central-1.compute.internal   Ready    <none>   47m   v1.36.2-eks-bca9cf6   10.0.11.28    <none>        Amazon Linux 2023.12.20260727   6.18.38-76.139.amzn2023.x86_64 (amd64)   containerd://2.2.5+unknown
ip-10-0-12-59.eu-central-1.compute.internal   Ready    <none>   47m   v1.36.2-eks-bca9cf6   10.0.12.59    <none>        Amazon Linux 2023.12.20260727   6.18.38-76.139.amzn2023.x86_64 (amd64)   containerd://2.2.5+unknown
```

All system Pods had `Ready` status and had 0 restarts during validation:

```
$ kubectl get pods -n kube-system -o wide
NAME                       READY   STATUS    RESTARTS   AGE   IP            NODE                                          NOMINATED NODE   READINESS GATES
aws-node-fl8p6             2/2     Running   0          48m   10.0.12.59    ip-10-0-12-59.eu-central-1.compute.internal   <none>           <none>
aws-node-gk5lf             2/2     Running   0          48m   10.0.11.28    ip-10-0-11-28.eu-central-1.compute.internal   <none>           <none>
coredns-7c78d44865-hd5h7   1/1     Running   0          50m   10.0.12.83    ip-10-0-12-59.eu-central-1.compute.internal   <none>           <none>
coredns-7c78d44865-k92pm   1/1     Running   0          50m   10.0.12.195   ip-10-0-12-59.eu-central-1.compute.internal   <none>           <none>
kube-proxy-k46d5           1/1     Running   0          48m   10.0.12.59    ip-10-0-12-59.eu-central-1.compute.internal   <none>           <none>
kube-proxy-rhkwr           1/1     Running   0          48m   10.0.11.28    ip-10-0-11-28.eu-central-1.compute.internal   <none>           <none>
```

## Networking

### Public Subnets

Public subnets use the following route:

```text
0.0.0.0/0 → Internet Gateway
```

They automatically assign public IPv4 addresses.

### Private Subnets

Private subnets use the following route:

```text
0.0.0.0/0 → NAT Gateway
```

They do not automatically assign public IPv4 addresses.

The NAT Gateway is deployed in Public Subnet A and provides outbound internet access for private worker nodes. This allows worker nodes to:

- pull container images;
- access AWS APIs;
- download required packages;
- remain inaccessible directly from the public internet.

---

### Amazon VPC CNI

The Amazon VPC CNI plugin runs as the `aws-node` DaemonSet. It assigns VPC-native private IP addresses to Kubernetes Pods.

During validation, the worker nodes contained multiple secondary private IPv4 addresses. This allows Pods to communicate using IP addresses from the VPC address space.

---

## Amazon ECR Integration

The ECR repository was successfully created:

| Parameter | Value |
|---|---|
| Repository | `flask-app` |
| URI | `215229808174.dkr.ecr.eu-central-1.amazonaws.com/flask-app` |
| Tag mutability | `MUTABLE` |
| Encryption | `AES-256` |
| Scan on push | Enabled |
| Lifecycle policy | Keep last 10 images |

Worker nodes have permission to pull images from this repository through:

```text
AmazonEC2ContainerRegistryPullOnly
```

---

## Cost Optimization

The development environment uses:

- one NAT Gateway;
- two `t3.small` worker nodes;
- one EKS control plane;
- On-Demand EC2 capacity.

One NAT Gateway is used as a development cost optimization.

A production Multi-AZ environment would normally use one NAT Gateway per Availability Zone to avoid a single point of failure and cross-AZ traffic.