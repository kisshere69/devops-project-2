# VPC Overview

## Purpose

This document describes the network architecture used in the project.

The VPC is designed according to AWS best practices for Amazon EKS and provides:

- Multi-AZ deployment
- Public and Private subnets
- Internet access through Internet Gateway
- Outbound internet access for private workloads through NAT Gateway
- Foundation for future Amazon EKS deployment

---

# CIDR Layout

| Resource | CIDR | Availability Zone |
|----------|------|-------------------|
| VPC | 10.0.0.0/16 | eu-central-1 |
| Public Subnet A | 10.0.1.0/24 | eu-central-1a |
| Public Subnet B | 10.0.2.0/24 | eu-central-1b |
| Private Subnet A | 10.0.11.0/24 | eu-central-1a |
| Private Subnet B | 10.0.12.0/24 | eu-central-1b |

---

# Current Network Topology

```text
                           Internet
                               │
                        Internet Gateway
                               │
               +---------------+---------------+
               │                               │
        Public Subnet A                 Public Subnet B
               │
        NAT Gateway (EIP)
               │
        Private Route Table
               │
        +------+------+
        │             │
  Private A      Private B
```

---

# Traffic Flow

```text
Private EC2
      │
      ▼
Private Route Table
      │
0.0.0.0/0
      │
      ▼
NAT Gateway
      │
      ▼
Internet Gateway
      │
      ▼
Internet
```

---

# Routing

## Public Route Table

Destination

```
0.0.0.0/0 → Internet Gateway
```

Attached to:

- Public Subnet A
- Public Subnet B

---

## Private Route Table

Destination

```
0.0.0.0/0 → NAT Gateway
```

Attached to:

- Private Subnet A
- Private Subnet B

---

## Why a single NAT Gateway?

This project is intended for learning purposes. Therefore, using a single NAT Gateway reduces AWS costs, keeps the architecture simple, and is sufficient for a dev environment.

---