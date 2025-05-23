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

resource "aws_s3_bucket" "staffplan_redux_production" {
  bucket = "staffplan-redux-production"

  tags = {
    Name = "staffplan-redux-production"
  }
}

output "bucket_arn" {
  value = aws_s3_bucket.staffplan_redux_production.arn
}

resource "aws_iam_user" "staffplan_redux_bot" {
  name = "staffplan_redux_bot"
  path = "/"
}
#
resource "aws_iam_policy" "staffplan_redux_bot_policy" {
  name        = "staffplan_redux_bot_policy"
  path        = "/"
  description = "S3 bucket policy for staffplan_redux_bot"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
        ]
        Resource = "${aws_s3_bucket.staffplan_redux_production.arn}/*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:ListBucket",
          "s3:ListBucketMultipartUploads",
        ]
        Resource = "${aws_s3_bucket.staffplan_redux_production.arn}"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "s3_policy_attachment" {
  name       = "s3_policy_attachment"
  users      = [aws_iam_user.staffplan_redux_bot.name]
  policy_arn = aws_iam_policy.staffplan_redux_bot_policy.arn
}
