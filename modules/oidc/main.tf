terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.12.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.4.0"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
    github = {
      source  = "integrations/github"
      version = "5.33.0"
    }
  }
}

data "aws_secretsmanager_secret_version" "github_creds" {
  secret_id = "github"
}

locals {
  github = jsondecode(
    data.aws_secretsmanager_secret_version.github_creds.secret_string
  )
}

provider "github" {
  token = local.github.token
  owner = var.owner
}

data "http" "github_actions_openid_configuration" {
  url = "https://token.actions.githubusercontent.com/.well-known/openid-configuration"
}

data "tls_certificate" "github_actions" {
  url = jsondecode(data.http.github_actions_openid_configuration.response_body).jwks_uri
}

resource "aws_iam_openid_connect_provider" "github_actions" {
  url             = "https://token.actions.githubusercontent.com"
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.github_actions.certificates[0].sha1_fingerprint]
}

data "aws_iam_policy_document" "assume_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github_actions.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:platform-engineering-org/*"]
    }
  }
}

data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    sid = "1"

    actions = [
      "logs:*",
      "s3:*",
      "dynamodb:*",
      "sts:*",
      "ec2:*",
      "vpc:*",
      "iam:*"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "gha_oidc_assume_role" {
  name               = "pe-tf-github_actions"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
  inline_policy {
    name   = "creds"
    policy = data.aws_iam_policy_document.iam_policy_document.json
  }
}

resource "github_actions_organization_secret" "role" {
  secret_name     = "ROLE"
  visibility      = "all"
  plaintext_value = aws_iam_role.gha_oidc_assume_role.arn
}
