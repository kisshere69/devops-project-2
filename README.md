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
│
├── terraform/
│   ├── backend/
│   ├── environments/
│   │   └── dev/
│   └── modules/
│
├── kubernetes/
│
├── helm/
│   └── flask-app/
│
├── app/
│
├── docs/
│
├── scripts/
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