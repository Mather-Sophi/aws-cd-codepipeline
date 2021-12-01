variable "name" {
  type        = string
  description = "(Required) The name associated with the pipeline and assoicated resources. i.e.: app-name."
}

variable "deploy_type" {
  type        = string
  description = "(Required) Must be one of the following ( ecs, lambda )."
}

variable "tags" {
  type        = map
  description = "(Optional) A mapping of tags to assign to the resource."
  default     = {}
}

variable "svcs_account_artifact_bucket_arn" {
  type        = string
  description = <<EOT
                (Optional) The ARN of the S3 bucket that stores the codebuild artifacts.
                The bucket is created in the shared service account.
                Required if var.deploy_type is lambda or ecs.
                EOT
  default     = null
}

variable "svcs_account_artifact_bucket_id" {
  type        = string
  description = <<EOT
                (Optional) The name of the S3 bucket that stores the codebuild artifacts.
                The bucket is created in the shared service account.
                Required if var.deploy_type is lambda or ecs.
                EOT
  default     = null
}

variable "svcs_account_artifact_object_name" {
  type        = string
  description = <<EOT
                (Optional) The key of the S3 object that triggers codepipeline.
                The object is created in the shared service account.
                Required if var.deploy_type is lambda or ecs.
                EOT
  default     = null
}

variable "svcs_account_kms_cmk_arn_for_s3" {
  type        = string
  description = <<EOT
                (Optional) The single-region AWS KMS customer managed key ARN for encrypting s3 artifacts.
                The key is created in the shared service account.
                Required if var.deploy_type is lambda or ecs.
                EOT
  default     = null
}

variable "lambda_function_name" {
  type        = string
  description = "(Optional) The name of the lambda function to update. Required if var.deploy_type is lambda."
  default     = null
}

variable "lambda_function_alias" {
  type        = string
  description = <<EOT
                (Optional) The name of the Lambda function alias that gets passed to the UserParameters data in the deploy stage.
                EOT
  default     = "live"
}

variable "deploy_function_name" {
  type        = string
  description = "(Optional) The name of the Lambda function in the account that will update the function code."
  default     = "CodepipelineDeploy"
}

variable "ecs_cluster_name" {
  type        = string
  description = "(Optional) The name of the ECS cluster. Required if var.deploy_type is ecs."
  default     = null
}

variable "ecs_service_name" {
  type        = string
  description = "(Optional) The name of the ECS service. Required if var.deploy_type is ecs."
  default     = null
}

variable "ecs_artifact_filename" {
  type        = string
  description = "(Optional) The name of the ECS deploy artifact."
  default     = null
}

variable "task_execution_role" {
  type        = string
  description = "(Optional) The name of the ECS task execution role. Required if var.deploy_type is ecs."
  default     = "ecsTaskExecutionRole"
}

variable "svcs_account_ecr_repository_name" {
  type        = string
  description = <<EOT
                (Optional) The name of the ECR repository.
                The repository is created in the shared service account.
                Required if var.deploy_type is ecs.
                EOT
  default     = null
}

variable "svcs_account_ecr_repository_url" {
  type        = string
  description = <<EOT
                (Optional) The URL of the ECR repository.
                The repository is created in the shared service account.
                Required if var.deploy_type is ecs.
                EOT
  default     = null
}

variable "svcs_account_ecr_repository_arn" {
  type        = string
  description = <<EOT
                (Optional) The ARN of the ECR repository.
                The repository is created in the shared service account.
                Required if var.deploy_type is ecs.                
                EOT
  default     = null
}