resource "aws_s3_bucket" "artifact" {
  # S3 bucket cannot be longer than 63 characters and cannot end with dash
  bucket = trimsuffix(lower(substr("codepipeline-cd-${local.account_region}-${local.account_id}-${var.name}", 0, 63)), "-")
  acl    = "private"

  lifecycle_rule {
    enabled = true
    expiration {
      days = 90
    }
  }

  tags = var.tags
}