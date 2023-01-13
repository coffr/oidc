terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.49.0"
    }
    http = {
      source  = "hashicorp/http"
      version = "3.2.1"
    }
    tls = {
      source  = "hashicorp/tls"
      version = "4.0.4"
    }
  }
}

provider "aws" {
  region = var.aws_region
  default_tags {
    tags = merge(var.tags, { User = var.user })
  }
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
      variable = "token.actions.githubusercontent.com:aut"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values   = ["repo:coffr/creds:*"]
    }
  }
}

data "aws_iam_policy_document" "creds_policy" {
  statement {
    sid = "1"

    actions = [
      "logs:PutLogEvents"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_role" "github_actions_role" {
  name               = "github_actions_role"
  assume_role_policy = data.aws_iam_policy_document.assume_policy.json
  inline_policy {
    name   = "creds"
    policy = data.aws_iam_policy_document.creds_policy.json
  }
}
