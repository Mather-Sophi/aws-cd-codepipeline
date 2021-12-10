output "codepipeline_id" {
  value = aws_codepipeline.pipeline.id
}

output "codepipeline_arn" {
  value = aws_codepipeline.pipeline.arn
}

output "artifact_bucket_id" {
  value = aws_s3_bucket.artifact.id
}

output "artifact_bucket_arn" {
  value = aws_s3_bucket.artifact.arn
}