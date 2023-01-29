#####################
# CodePipeline
# 参考：https://docs.aws.amazon.com/ja_jp/codepipeline/latest/userguide/action-reference.html
#####################
resource "aws_codepipeline" "code_pipeline_backend" {
  ### パイプラインの設定 ###
  # 名前
  name = var.codepipeline_backend.pipeline_name
  # ロール名
  role_arn = aws_iam_role.code_pipeline.arn
  # アーティファクトストア
  artifact_store {
    # ロケーション
    location = aws_s3_bucket.codepipeline_bucket.bucket
    type     = "S3"

    # 暗号化キー
    #encryption_key {
    #    type = "KMS"
    #    id = ""
    #}
  }

  ### ソース ###
  stage {
    name = "Source"
    action {
      name      = "Source"
      category  = "Source"
      owner     = "AWS"
      run_order = 1
      # ソースプロバイダー
      provider = "CodeCommit"
      version  = 1

      configuration = {
        # リポジトリ名
        RepositoryName = var.codepipeline_backend.source.reposiroty_name
        # ブランチ名
        BranchName = "main"
        # 検出オプション
        PollForSourceChanges = "false"
        # 出力アーティファクト形式
        OutputArtifactFormat = "CODE_ZIP"
      }

      output_artifacts = ["SourceArtifact"]
    }
  }

  ### ビルド ###
  stage {
    name = "Build"
    action {
      name      = "Build"
      category  = "Build"
      owner     = "AWS"
      run_order = 2
      # Buildプロバイダー
      provider = "CodeBuild"
      version  = "1"
      configuration = {
        # プロジェクト名
        ProjectName = var.codepipeline_backend.codebuild.project_name
        # 環境変数
        #EnvironmentVariables = '[{"name":"TEST_VARIABLE","value":"TEST_VALUE","type":"PLAINTEXT"},{"name":"ParamStoreTest","value":"PARAMETER_NAME","type":"PARAMETER_STORE"}]'
        # ビルドタイプ
        BatchEnabled = "false"
      }

      input_artifacts  = ["SourceArtifact"]
      output_artifacts = ["BuildArtifact"]
    }
  }

  ### Deploy ###
  stage {
    name = "Deploy"
    action {
      name      = "Deploy"
      category  = "Deploy"
      owner     = "AWS"
      run_order = 3
      # Deployプロバイダー
      provider = "CodeDeployToECS"
      version  = 1

      configuration = {
        # AWS CodeDeployアプリケーション名
        ApplicationName = var.codepipeline_backend.codedeploy.application_name
        # AWS CodeDeployデプロイメントグループ
        DeploymentGroupName = var.codepipeline_backend.codedeploy.deploy_group_name
        # ECSタスク定義
        TaskDefinitionTemplateArtifact = "SourceArtifact"
        #TaskDefinitionTemplatePath = "taskdef.json"
        # CodeDeploy AppSpecファイル
        AppSpecTemplateArtifact = "SourceArtifact"
        #AppSpecTemplatePath = "appspec.yaml"
        # 入力アーティファクトを持つイメージの詳細
        Image1ArtifactName = "BuildArtifact"
        # タスク定義のプレースホルダー文字
        Image1ContainerName = "IMAGE1_NAME"

      }

      input_artifacts = ["SourceArtifact", "BuildArtifact"]
    }
  }
}

resource "aws_s3_bucket" "codepipeline_bucket" {
  # S3 bucket for codepipeline
  bucket = "${var.codepipeline_backend.pipeline_name}-bucket"
}

#####################
# CodePipeline用のIAM
#####################
data "aws_iam_policy_document" "code_pipeline" {
  statement {
    effect = "Allow"
    actions = [
      "iam:PassRole"
    ]
    resources = [
      "*"
    ]
    condition {
      test     = "StringEqualsIfExists"
      variable = "iam:PassedToService"
      values = [
        "cloudformation.amazonaws.com",
        "ec2.amazonaws.com",
        "ecs-tasks.amazonaws.com"
      ]
    }
  }

  statement {
    effect = "Allow"
    actions = [
      "codecommit:CancelUploadArchive",
      "codecommit:GetBranch",
      "codecommit:GetCommit",
      "codecommit:GetRepository",
      "codecommit:GetUploadArchiveStatus",
      "codecommit:UploadArchive"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "codedeploy:CreateDeployment",
      "codedeploy:GetApplication",
      "codedeploy:GetApplicationRevision",
      "codedeploy:GetDeployment",
      "codedeploy:GetDeploymentConfig",
      "codedeploy:RegisterApplicationRevision"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "ec2:*",
      "elasticloadbalancing:*",
      "autoscaling:*",
      "cloudwatch:*",
      "s3:*",
      "sns:*",
      "cloudformation:*",
      "rds:*",
      "sqs:*",
      "ecs:*"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "lambda:InvokeFunction",
      "lambda:ListFunctions"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "cloudformation:CreateStack",
      "cloudformation:DeleteStack",
      "cloudformation:DescribeStacks",
      "cloudformation:UpdateStack",
      "cloudformation:CreateChangeSet",
      "cloudformation:DeleteChangeSet",
      "cloudformation:DescribeChangeSet",
      "cloudformation:ExecuteChangeSet",
      "cloudformation:SetStackPolicy",
      "cloudformation:ValidateTemplate"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "codebuild:BatchGetBuilds",
      "codebuild:StartBuild",
      "codebuild:BatchGetBuildBatches",
      "codebuild:StartBuildBatch"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "devicefarm:ListProjects",
      "devicefarm:ListDevicePools",
      "devicefarm:GetRun",
      "devicefarm:GetUpload",
      "devicefarm:CreateUpload",
      "devicefarm:ScheduleRun"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "servicecatalog:ListProvisioningArtifacts",
      "servicecatalog:CreateProvisioningArtifact",
      "servicecatalog:DescribeProvisioningArtifact",
      "servicecatalog:DeleteProvisioningArtifact",
      "servicecatalog:UpdateProduct"
    ]
    resources = [
      "*"
    ]
  }
  statement {
    effect = "Allow"
    actions = [
      "cloudformation:ValidateTemplate",
      "ecr:DescribeImages",
      "states:DescribeExecution",
      "states:DescribeStateMachine",
      "states:StartExecution",
      "appconfig:StartDeployment",
      "appconfig:StopDeployment",
      "appconfig:GetDeployment"
    ]
    resources = [
      "*"
    ]
  }
}
resource "aws_iam_policy" "code_pipeline" {
  name   = "CodePipelineServiceRolePolicy"
  policy = data.aws_iam_policy_document.code_pipeline.json
}

# IAM Role
data "aws_iam_policy_document" "code_pipeline_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["codepipeline.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "code_pipeline" {
  name               = "CodePipelineServiceRole"
  assume_role_policy = data.aws_iam_policy_document.code_pipeline_assume_role_policy.json
}
resource "aws_iam_policy_attachment" "code_pipeline" {
  name       = "codepipeline_attachment"
  roles      = [aws_iam_role.code_pipeline.name]
  policy_arn = aws_iam_policy.code_pipeline.arn
}