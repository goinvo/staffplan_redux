terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Configure the AWS Provider
provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "staffplan_production" {
  bucket = "staffplan-production"

  tags = {
    Name = "staffplan-production"
  }
}

output "bucket_arn" {
  value = aws_s3_bucket.staffplan_production.arn
}

resource "aws_iam_user" "staffplan_bot" {
  name = "staffplan_bot"
  path = "/"
}
#
resource "aws_iam_policy" "staffplan_bot_policy" {
  name        = "staffplan_bot_policy"
  path        = "/"
  description = "S3 bucket policy for staffplan_bot"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject"
      ],
      "Resource": "${aws_s3_bucket.staffplan_production.arn}/*"
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = "s3_policy_attachment"
  users      = [aws_iam_user.staffplan_bot.name]
  policy_arn = aws_iam_policy.staffplan_bot_policy.arn
}