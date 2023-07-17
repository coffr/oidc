terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.8.0"
    }
  }
}

data "aws_caller_identity" "current" {}

data "aws_iam_role" "AWSServiceRoleForCloudTrail" {
  name = "AWSServiceRoleForCloudTrail"
}

resource "aws_cloudtrail" "cloudtrail" {
  name                       = "pe-tf-audit"
  s3_bucket_name             = aws_s3_bucket.s3_bucket.id
  is_multi_region_trail      = true
  cloud_watch_logs_group_arn = "${aws_cloudwatch_log_group.cloudwatch_log_group.arn}:*"
  cloud_watch_logs_role_arn  = data.aws_iam_role.AWSServiceRoleForCloudTrail.arn

  event_selector {
    read_write_type           = "All"
    include_management_events = true

    data_resource {
      type   = "AWS::S3::Object"
      values = ["arn:aws:s3"]
    }
  }
}

resource "aws_s3_bucket" "s3_bucket" {
  bucket        = "pe-tf-audit"
  force_destroy = true
}

resource "aws_s3_bucket_policy" "s3_bucket_policy" {
  bucket = aws_s3_bucket.s3_bucket.id
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "${aws_s3_bucket.s3_bucket.arn}"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "${aws_s3_bucket.s3_bucket.arn}/AWSLogs/${data.aws_caller_identity.current.account_id}/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_cloudwatch_log_group" "cloudwatch_log_group" {
  name              = "pe-tf-audit"
  retention_in_days = 30
}

resource "aws_cloudwatch_log_metric_filter" "cloudwatch_log_metric_filter" {
  name           = "APICallsWithAccessKeys"
  pattern        = "{ $.userIdentity.type = \"IAMUser\" }"
  log_group_name = aws_cloudwatch_log_group.cloudwatch_log_group.name
  metric_transformation {
    name          = "COUNT(Calls with Access Keys)"
    namespace     = "PE/Audit"
    value         = "1"
    default_value = "0"
    unit          = "Count"
  }
}

resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "pe-tf-audit"

  dashboard_body = <<EOF
{
  "widgets": [
    {
      "type": "metric",
      "x": 0,
      "y": 0,
      "width": 6,
      "height": 6,
      "properties": {
        "view": "timeSeries",
        "stacked": false,
        "metrics": [
          [ "PE/Audit", "COUNT(Calls with Access Keys)" ]
        ],
        "region": "eu-west-2",
        "stat": "SampleCount"
      }
    }
  ]
}
EOF
}
