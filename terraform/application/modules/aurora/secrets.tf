#####################
# Secret Manager
####################
# キーと値のペア
locals {
    db_secret = {
        username = var.aurora.secretmanager.username
        password = var.aurora.secretmanager.password
        engine = "mysql"
        host = aws_rds_cluster.db.endpoint
        port = "3306"
        dbname = var.aurora.database_name
        dbClusterIdentifier = var.aurora.cluster_identifier
    }
}

# シークレット
resource "aws_secretsmanager_secret" "db" {
  # シークレットの名前
  name = var.aurora.secretmanager.name

  description = "${var.aurora.cluster_identifier}アクセスのシークレット"

  # 暗号化キー
  #kms_key_id = "aws/secretmanager"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id

  # 認証情報
  secret_string = jsonencode(local.db_secret)
}

