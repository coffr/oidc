terraform {
  backend "s3" {
    bucket         = "pe-tf-state"
    key            = "ci-bot/terraform.tfstate"
    region         = "eu-west-2"
    encrypt        = true
    dynamodb_table = "pe-tf-state"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.52.0"
    }
    github = {
      source  = "integrations/github"
      version = "5.16.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile
  default_tags {
    tags = merge(var.tags, { User = var.user })
  }
}

provider "github" {
  token = var.token
  owner = var.owner
}

data "aws_iam_policy_document" "iam_policy_document" {
  statement {
    sid = "1"

    actions = [
      "ec2:DescribeImages",
      "iam:GetRole",
      "iam:ListAttachedRolePolicies",
      "iam:TagRole",
      "iam:CreateRole",
      "iam:PutRolePolicy",
      "iam:ListRolePolicies",
      "iam:GetOpenIDConnectProvider",
      "iam:TagOpenIDConnectProvider",
      "iam:GetRolePolicy",
      "iam:CreateOpenIDConnectProvider",
      "sts:GetCallerIdentity",
      "s3:GetObject",
      "dynamodb:PutItem"
    ]

    resources = [
      "*",
    ]
  }
}

resource "aws_iam_user" "iam_user" {
  name = "pe-tf-ci-bot"
}

resource "aws_iam_policy" "iam_policy" {
  name   = "pe-tf-ci-bot-iam-policy"
  policy = data.aws_iam_policy_document.iam_policy_document.json
}

resource "aws_iam_user_policy_attachment" "iam_user_policy_attachment" {
  user       = aws_iam_user.iam_user.name
  policy_arn = aws_iam_policy.iam_policy.arn
}

resource "aws_iam_access_key" "iam_access_key" {
  user = aws_iam_user.iam_user.name
}

resource "github_actions_organization_secret" "access_key" {
  secret_name     = "AWS_ACCESS_KEY_ID"
  visibility      = "all"
  plaintext_value = aws_iam_access_key.iam_access_key.id
}

resource "github_actions_organization_secret" "secret_key" {
  secret_name     = "AWS_SECRET_ACCESS_KEY"
  visibility      = "all"
  plaintext_value = aws_iam_access_key.iam_access_key.secret
}
