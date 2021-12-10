# aws-cd-codepipeline
The AWS codepipeline for CD (i.e. deployment). Codepipeline is triggered by a lambda zip archive or an ECS imagedefinitions.json file upload to the S3 artifact bucket in the shared service account. The deploy stage then takes the input artifact and updates the lambda function code or ECS task definition in the current account.

Notes:
1. All code pipeline output artifacts are encrypted with the default S3 KMS key (alias aws/s3) in the same region.
2. For ECS and ECR deployment, set `container_image` in the ECS task definition module to the ECR repository URL imported from the shared service account.

## Usage
### Lambda
```hcl
 module "lambda_cd_pipeline" {
  source = "github.com/globeandmail/aws-cd-codepipeline?ref=1.0"

  name                              = "app-name"
  deploy_type                       = "lambda"
  svcs_account_artifact_bucket_arn  = "svcs-account-artifact-bucket-arn"
  svcs_account_artifact_bucket_id   = "svcs-account-artifact-bucket-id"
  svcs_account_artifact_object_name = "svcs-account-artifact-object-name"
  svcs_account_kms_cmk_arn_for_s3   = "svcs-account-kms-cmk-arn-for-s3"
  lambda_function_name              = "lambda-function-name"
  require_manual_approval           = true
  approve_sns_arn                   = "approve-sns-arn"
  tags                              = {
                                        Environment = var.environment
                                      }
}
```

### ECS
```hcl
module "ecs_cd_pipeline" {
  source = "github.com/globeandmail/aws-cd-codepipeline?ref=1.0"

  name                              = "app-name"
  deploy_type                       = "ecs"
  svcs_account_artifact_bucket_arn  = "svcs-account-artifact-bucket-arn"
  svcs_account_artifact_bucket_id   = "svcs-account-artifact-bucket-id"
  svcs_account_artifact_object_name = "svcs-account-artifact-object-name"
  svcs_account_kms_cmk_arn_for_s3   = "svcs-account-kms-cmk-arn-for-s3"
  ecs_cluster_name                  = "ecs-cluster-name"
  ecs_service_name                  = "ecs-service-name"
  task_execution_role               = "task-execution-role-name"
  svcs_account_ecr_repository_name  = "svcs-account-ecr-repository-name"
  svcs_account_ecr_repository_url   = "svcs-account-ecr-repository-url"
  svcs_account_ecr_repository_arn   = "svcs-account-ecr-repository-arn"
  require_manual_approval           = true
  approve_sns_arn                   = "approve-sns-arn"
  tags                              = {
                                        Environment = var.environment
                                      }
}
```

<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 0.12 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_approve_sns_arn"></a> [approve\_sns\_arn](#input\_approve\_sns\_arn) | (Optional) The ARN of the SNS topic in the approve stage.<br>                Required if var.require\_manual\_approval is true. | `string` | `null` | no |
| <a name="input_approve_url"></a> [approve\_url](#input\_approve\_url) | (Optional) The URL for review in the approve stage. It should begin with 'http://' or 'https://'. | `string` | `null` | no |
| <a name="input_deploy_function_name"></a> [deploy\_function\_name](#input\_deploy\_function\_name) | (Optional) The name of the Lambda function in the account that will update the function code. | `string` | `"CodepipelineDeploy"` | no |
| <a name="input_deploy_type"></a> [deploy\_type](#input\_deploy\_type) | (Required) Must be one of the following ( ecs, lambda ). | `string` | n/a | yes |
| <a name="input_ecs_artifact_filename"></a> [ecs\_artifact\_filename](#input\_ecs\_artifact\_filename) | (Optional) The name of the ECS deploy artifact. | `string` | `null` | no |
| <a name="input_ecs_cluster_name"></a> [ecs\_cluster\_name](#input\_ecs\_cluster\_name) | (Optional) The name of the ECS cluster. Required if var.deploy\_type is ecs. | `string` | `null` | no |
| <a name="input_ecs_service_name"></a> [ecs\_service\_name](#input\_ecs\_service\_name) | (Optional) The name of the ECS service. Required if var.deploy\_type is ecs. | `string` | `null` | no |
| <a name="input_lambda_function_alias"></a> [lambda\_function\_alias](#input\_lambda\_function\_alias) | (Optional) The name of the Lambda function alias that gets passed to the UserParameters data in the deploy stage. | `string` | `"live"` | no |
| <a name="input_lambda_function_name"></a> [lambda\_function\_name](#input\_lambda\_function\_name) | (Optional) The name of the lambda function to update. Required if var.deploy\_type is lambda. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | (Required) The name associated with the pipeline and assoicated resources. i.e.: app-name. | `string` | n/a | yes |
| <a name="input_require_manual_approval"></a> [require\_manual\_approval](#input\_require\_manual\_approval) | (Optional) Create the approval stage in the codepipeline. Defaults to false. | `bool` | `false` | no |
| <a name="input_s3_bucket_force_destroy"></a> [s3\_bucket\_force\_destroy](#input\_s3\_bucket\_force\_destroy) | (Optional) Delete all objects in S3 bucket upon bucket deletion. S3 objects are not recoverable.<br>                Defaults to true. | `bool` | `true` | no |
| <a name="input_svcs_account_artifact_bucket_arn"></a> [svcs\_account\_artifact\_bucket\_arn](#input\_svcs\_account\_artifact\_bucket\_arn) | (Optional) The ARN of the S3 bucket that stores the codebuild artifacts.<br>                The bucket is created in the shared service account.<br>                Required if var.deploy\_type is lambda or ecs. | `string` | `null` | no |
| <a name="input_svcs_account_artifact_bucket_id"></a> [svcs\_account\_artifact\_bucket\_id](#input\_svcs\_account\_artifact\_bucket\_id) | (Optional) The name of the S3 bucket that stores the codebuild artifacts.<br>                The bucket is created in the shared service account.<br>                Required if var.deploy\_type is lambda or ecs. | `string` | `null` | no |
| <a name="input_svcs_account_artifact_object_name"></a> [svcs\_account\_artifact\_object\_name](#input\_svcs\_account\_artifact\_object\_name) | (Optional) The key of the S3 object that triggers codepipeline.<br>                The object is created in the shared service account.<br>                Required if var.deploy\_type is lambda or ecs. | `string` | `null` | no |
| <a name="input_svcs_account_ecr_repository_arn"></a> [svcs\_account\_ecr\_repository\_arn](#input\_svcs\_account\_ecr\_repository\_arn) | (Optional) The ARN of the ECR repository.<br>                The repository is created in the shared service account.<br>                Required if var.deploy\_type is ecs. | `string` | `null` | no |
| <a name="input_svcs_account_ecr_repository_name"></a> [svcs\_account\_ecr\_repository\_name](#input\_svcs\_account\_ecr\_repository\_name) | (Optional) The name of the ECR repository.<br>                The repository is created in the shared service account.<br>                Required if var.deploy\_type is ecs. | `string` | `null` | no |
| <a name="input_svcs_account_ecr_repository_url"></a> [svcs\_account\_ecr\_repository\_url](#input\_svcs\_account\_ecr\_repository\_url) | (Optional) The URL of the ECR repository.<br>                The repository is created in the shared service account.<br>                Required if var.deploy\_type is ecs. | `string` | `null` | no |
| <a name="input_svcs_account_kms_cmk_arn_for_s3"></a> [svcs\_account\_kms\_cmk\_arn\_for\_s3](#input\_svcs\_account\_kms\_cmk\_arn\_for\_s3) | (Optional) The single-region AWS KMS customer managed key ARN for encrypting s3 artifacts.<br>                The key is created in the shared service account.<br>                Required if var.deploy\_type is lambda or ecs. | `string` | `null` | no |
| <a name="input_tags"></a> [tags](#input\_tags) | (Optional) A mapping of tags to assign to the resource. | `map` | `{}` | no |
| <a name="input_task_execution_role"></a> [task\_execution\_role](#input\_task\_execution\_role) | (Optional) The name of the ECS task execution role. Required if var.deploy\_type is ecs. | `string` | `"ecsTaskExecutionRole"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_artifact_bucket_arn"></a> [artifact\_bucket\_arn](#output\_artifact\_bucket\_arn) | n/a |
| <a name="output_artifact_bucket_id"></a> [artifact\_bucket\_id](#output\_artifact\_bucket\_id) | n/a |
| <a name="output_codepipeline_arn"></a> [codepipeline\_arn](#output\_codepipeline\_arn) | n/a |
| <a name="output_codepipeline_id"></a> [codepipeline\_id](#output\_codepipeline\_id) | n/a |
<!-- END_TF_DOCS -->