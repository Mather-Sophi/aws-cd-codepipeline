data "aws_region" "current" {}
data "aws_caller_identity" "current" {}

locals {
  account_region  = data.aws_region.current.name
  account_id      = data.aws_caller_identity.current.account_id

  task_execution_role = var.task_execution_role == "ecsTaskExecutionRole" ? "ecsTaskExecutionRole" : var.task_execution_role
  codepipeline_artifact_name = var.deploy_type == "lambda" ? "function_zip" : "imagedefinitions_file"
}