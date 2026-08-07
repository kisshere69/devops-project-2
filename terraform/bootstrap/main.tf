terraform {
  required_version = ">= 1.15.8"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.3.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
      Purpose     = "CI-CD-Bootstrap"
    }
  }
}

data "tls_certificate" "github" {
  url = "https://token.actions.githubusercontent.com"
}

resource "aws_iam_openid_connect_provider" "github" {
  url = "https://token.actions.githubusercontent.com"

  client_id_list = [
    "sts.amazonaws.com"
  ]

  thumbprint_list = [
    data.tls_certificate.github.certificates[0].sha1_fingerprint
  ]

  tags = {
    Name = "${var.project_name}-${var.environment}-github-oidc"
  }
}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    sid     = "GitHubActionsOIDC"
    effect  = "Allow"
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type = "Federated"

      identifiers = [
        aws_iam_openid_connect_provider.github.arn
      ]
    }

    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"

      values = [
        "sts.amazonaws.com"
      ]
    }

    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"

      values = var.github_oidc_subjects
    }
  }
}

resource "aws_iam_role" "terraform_plan" {
  name = "${var.project_name}-${var.environment}-terraform-plan-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  description = "IAM role assumed by GitHub Actions to run Terraform plans"

  tags = {
    Name = "${var.project_name}-${var.environment}-terraform-plan-role"
  }
}

data "aws_iam_policy_document" "terraform_plan_permissions" {

  statement {
    sid    = "ReadTerraformStateBucket"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      "arn:aws:s3:::${var.terraform_state_bucket}"
    ]
  }

  statement {
    sid    = "ReadTerraformState"
    effect = "Allow"

    actions = [
      "s3:GetObject"
    ]

    resources = [
      "arn:aws:s3:::${var.terraform_state_bucket}/dev/terraform.tfstate"
    ]
  }

  statement {
    sid    = "ManageTerraformStateLock"
    effect = "Allow"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject"
    ]

    resources = [
      "arn:aws:s3:::${var.terraform_state_bucket}/dev/terraform.tfstate.tflock"
    ]
  }

  statement {
    sid = "ReadInfrastructure"

    effect = "Allow"

    actions = [
      "ec2:Describe*",

      "eks:Describe*",
      "eks:List*",

      "ecr:Describe*",
      "ecr:List*",
      "ecr:Get*",

      "iam:Get*",
      "iam:List*",

      "sts:GetCallerIdentity"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "terraform_plan" {
  name = "${var.project_name}-${var.environment}-terraform-plan-policy"

  description = "Read-only AWS permissions for Terraform plans"

  policy = data.aws_iam_policy_document.terraform_plan_permissions.json

  tags = {
    Name = "${var.project_name}-${var.environment}-terraform-plan-policy"
  }
}

resource "aws_iam_role_policy_attachment" "terraform_plan" {
  role       = aws_iam_role.terraform_plan.name
  policy_arn = aws_iam_policy.terraform_plan.arn
}