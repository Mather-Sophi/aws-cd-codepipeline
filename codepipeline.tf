data "aws_iam_policy_document" "codepipeline_assume" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "codepipeline" {
  name               = "codepipeline-cd-${var.name}"
  assume_role_policy = data.aws_iam_policy_document.codepipeline_assume.json

  tags = var.tags
}

data "aws_iam_policy_document" "codepipeline_baseline" {
  statement {

    actions = [
      "s3:GetObject",
      "s3:GetObjectVersion"
    ]

    resources = [
      "${var.svcs_account_artifact_bucket_arn}/*"
    ]
  }

  statement {

    actions = [
      "s3:GetBucket*"
    ]

    resources = [
      var.svcs_account_artifact_bucket_arn
    ]
  }

  statement {

    actions = [
      "s3:GetObject",
      "s3:PutObject"      
    ]

    resources = [
      "${aws_s3_bucket.artifact.arn}/*"
    ]
  }

  statement {

    actions = [
      "kms:Decrypt"
    ]

    resources = [
      var.svcs_account_kms_cmk_arn_for_s3
    ]
  }
}

resource "aws_iam_role_policy" "codepipeline_baseline" {
  name   = "codepipeline-cd-baseline-${var.name}"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline_baseline.json
}

data "aws_iam_policy_document" "codepipeline_lambda" {
  count = var.deploy_type == "lambda" ? 1 : 0
  statement {
    actions   = ["lambda:InvokeFunction"]
    resources = ["arn:aws:lambda:${local.account_region}:${local.account_id}:function:${var.deploy_function_name}"]
  }
}

resource "aws_iam_role_policy" "codepipeline_lambda" {
  count = var.deploy_type == "lambda" ? 1 : 0
  name   = "codepipeline-cd-lambda-${var.name}"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline_lambda[0].json
}

data "aws_iam_policy_document" "codepipeline_ecs" {
  count = var.deploy_type == "ecs" ? 1 : 0
  statement {
    actions   = ["ecr:DescribeImages"]
    resources = [var.svcs_account_ecr_repository_arn]
  }

  statement {
    actions = [
      "ecs:DescribeServices",
      "ecs:DescribeTaskDefinition",
      "ecs:DescribeTasks",
      "ecs:ListTasks",
      "ecs:RegisterTaskDefinition"
    ]
    resources = ["*"]
  }

  statement {
    actions = ["ecs:UpdateService"]
    resources = [
      "arn:aws:ecs:${local.account_region}:${local.account_id}:service/${var.ecs_cluster_name}/${var.ecs_service_name}"
    ]
  }

  statement {
    actions   = ["iam:PassRole"]
    resources = ["arn:aws:iam::${local.account_id}:role/${local.task_execution_role}"]
  }
}

resource "aws_iam_role_policy" "codepipeline_ecs" {
  count = var.deploy_type == "ecs" ? 1 : 0
  name   = "codepipeline-cd-ecs-${var.name}"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline_ecs[0].json
}

data "aws_iam_policy_document" "codepipeline_sns" {
  count = var.require_manual_approval ? 1 : 0
  statement {
    actions   = ["sns:Publish"]
    resources = [var.approve_sns_arn]
  }
}

resource "aws_iam_role_policy" "codepipeline_sns" {
  count = var.require_manual_approval ? 1 : 0
  name   = "codepipeline-sns-${var.name}"
  role   = aws_iam_role.codepipeline.id
  policy = data.aws_iam_policy_document.codepipeline_sns[0].json
}

resource "aws_codepipeline" "pipeline" {
  name     = var.name
  role_arn = aws_iam_role.codepipeline.arn
  artifact_store {
    location = aws_s3_bucket.artifact.id
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "S3"
      version          = "1"
      output_artifacts = [local.codepipeline_artifact_name]

      configuration = {
        S3Bucket              = var.svcs_account_artifact_bucket_id
        S3ObjectKey           = var.svcs_account_artifact_object_name
        PollForSourceChanges = "true"
      }
    }
  }

  dynamic "stage" {
    for_each = var.require_manual_approval ? [1] : []
    content {
      name = "Approve"

      action {
        name            = "Approval"
        category        = "Approval"
        owner           = "AWS"
        provider        = "Manual"
        version         = "1"

        configuration = {
          NotificationArn   = var.approve_sns_arn
          CustomData = "Approve release in codepipeline ${var.name}. The account ID is ${local.account_id}."
          ExternalEntityLink = var.approve_url
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.deploy_type == "lambda" ? [1] : []
    content {
      name = "Deploy"

      action {
        name            = "Deploy"
        category        = "Invoke"
        owner           = "AWS"
        provider        = "Lambda"
        input_artifacts = [local.codepipeline_artifact_name]
        version         = "1"

        configuration = {
          FunctionName   = var.deploy_function_name
          UserParameters = "function_name=${var.lambda_function_name},alias=${var.lambda_function_alias}"
        }
      }
    }
  }

  dynamic "stage" {
    for_each = var.deploy_type == "ecs" ? [1]: []
    content {
      name = "Deploy"

      action {
        name            = "Deploy"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "ECS"
        input_artifacts = [local.codepipeline_artifact_name]
        version         = "1"

        configuration = {
          ClusterName = var.ecs_cluster_name
          ServiceName = var.ecs_service_name
          FileName    = var.ecs_artifact_filename
        }
      }
    }
  }

  tags = var.tags
}