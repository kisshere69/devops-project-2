# DevOps Project 2

## Overview

Production-like DevOps project deployed in AWS Cloud.

The goal of this project is to practice building modern Cloud infrastructure using Infrastructure as Code (IaC), Kubernetes, Docker, and CI/CD.

## Project Structure

```text
devops-project-2/
│
├── .github/
│   └── workflows/
│       └── ci-cd.yaml
│       └── deploy-app.yaml
│       └── deploy-secret.yaml
│
├── terraform/
│   ├── backend/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   │
│   ├── bootstrap/
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── terraform.tfvars.example
│   │
│   ├── environments/
│   │   └── dev/
│   │       ├── main.tf
│   │       ├── providers.tf
│   │       ├── variables.tf
│   │       ├── outputs.tf
│   │       ├── backend.tf
│   │       ├── terraform.ci.tfvars
│   │       └── terraform.example.tfvars
│   │
│   └── modules/
│       ├── vpc/
│       ├── ecr/
│       ├── eks/
│       ├── monitoring/
│       └── github-oidc/
│
├── k8s/
│   ├── Namespace.yaml
│   ├── ConfigMap.yaml
│   ├── Deployment.yaml
│   ├── Service.yaml
│   └── RBAC.yaml
│
├── helm/
│   ├── Chart.yaml
│   ├── values.yaml
│   ├── values-dev.yaml
│   └── templates/
│       ├── _helpers.tpl
│       ├── configmap.yaml
│       ├── deployment.yaml
│       └── service.yaml
│
├── app/
│   ├── app.py
│   ├── requirements.txt
│   └── Dockerfile
│
├── docs/
│   
├── .gitignore
├── LICENSE
└── README.md
```


## Technologies used

- AWS
- Terraform
- Amazon EKS
- Docker
- Kubernetes
- Helm
- Python
- Flask
- GitHub Actions

## Architecture

```text
                    GitHub
                       │
                       ▼
               GitHub Actions
                       │
          ┌────────────┴────────────┐
          ▼                         ▼
    Terraform                 Docker Build
          │                         │
          ▼                         ▼
        AWS ECR               Docker Image
          │
          ▼
        Amazon EKS
          │
          ▼
     Kubernetes Cluster
          │
     ┌────┴────┐
     ▼         ▼
 Flask API   Helm Chart
          │
          ▼
 Application Load Balancer
          │
          ▼
        Internet
```


## Project Goals

- Deploy Kubernetes cluster
- Automate infrastructure provisioning
- Build CI/CD pipelines
- Deploy applications using Helm
- Implement monitoring and observability

## Status

Project in progress
