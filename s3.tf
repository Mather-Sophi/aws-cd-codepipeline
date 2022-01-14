resource "aws_s3_bucket" "artifact" {
  # S3 bucket cannot be longer than 63 characters and cannot end with dash
  bucket = trimsuffix(lower(substr("codepipeline-cd-${local.account_region}-${local.account_id}-${var.name}", 0, 63)), "-")
  acl    = "private"
  force_destroy = var.s3_bucket_force_destroy

  lifecycle_rule {
    enabled = true
    expiration {
      days = 90
    }
  }

  tags = var.tags
}

resource "aws_s3_bucket_public_access_block" "artifact" {
  count  = var.s3_block_public_access ? 1 : 0
  bucket = aws_s3_bucket.artifact.id

  block_public_acls   = true
  block_public_policy = true
  ignore_public_acls  = true
  restrict_public_buckets  = true
}