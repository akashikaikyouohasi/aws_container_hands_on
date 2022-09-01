##################
# CodeDeploy
##################

module "codedeploy" {
  source = "../modules/codedeploy"

  iam = local.iam
}