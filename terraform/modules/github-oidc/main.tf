data "aws_caller_identity" "current" {

}

data "aws_iam_policy_document" "github_actions_assume_role" {
  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRoleWithWebIdentity"
    ]

    principals {
      type = "Federated"

      identifiers = [
        var.github_oidc_provider_arn
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
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:sub"

      values = [
        var.github_oidc_subject
      ]
    }
  }
}

data "aws_iam_policy_document" "ecr_push" {
  statement {
    sid    = "GetECRAuthorizationToken"
    effect = "Allow"

    actions = [
      "ecr:GetAuthorizationToken"
    ]

    resources = ["*"]
  }

  statement {
    sid    = "PushImageToECR"
    effect = "Allow"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage"
    ]

    resources = [
      "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/${var.repository_name}"
    ]
  }
}

resource "aws_iam_role" "github_actions" {
  name = "${var.project_name}-${var.environment}-github-actions-role"

  assume_role_policy = data.aws_iam_policy_document.github_actions_assume_role.json

  tags = {
    Name        = "${var.project_name}-${var.environment}-github-actions-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

data "aws_iam_policy_document" "eks_access" {
  statement {
    sid    = "DescribeEKSCluster"
    effect = "Allow"

    actions = [
      "eks:DescribeCluster"
    ]

    resources = [
      var.eks_cluster_arn
    ]
  }
}

resource "aws_iam_policy" "eks_access" {
  name = "${var.project_name}-${var.environment}-github-actions-eks-policy"

  policy = data.aws_iam_policy_document.eks_access.json

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_policy" "ecr_push" {
  name        = "${var.project_name}-${var.environment}-ecr-push-policy"
  description = "Allows GitHub Actions to push Docker images to Amazon ECR"
  policy      = data.aws_iam_policy_document.ecr_push.json

  tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}


resource "aws_iam_role_policy_attachment" "eks_access" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.eks_access.arn
}

resource "aws_iam_role_policy_attachment" "ecr_push" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.ecr_push.arn
}

resource "aws_eks_access_entry" "github_actions" {
  cluster_name  = var.eks_cluster_name
  principal_arn = aws_iam_role.github_actions.arn
  type          = "STANDARD"

  kubernetes_groups = [
    "github-actions-deployers"
  ]

  tags = {
    Name        = "${var.project_name}-${var.environment}-github-actions-access"
    Project     = var.project_name
    Environment = var.environment
  }
}