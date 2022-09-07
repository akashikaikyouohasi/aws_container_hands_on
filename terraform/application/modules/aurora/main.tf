#####################
# Aurora
#####################
### IAM 拡張モニタリング ###
data "aws_iam_policy" "AmazonRDSEnhancedMonitoringRole" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonRDSEnhancedMonitoringRole"
}
# IAM Role
data "aws_iam_policy_document" "rds_monitoring_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["monitoring.rds.amazonaws.com"]
    }
  }
}
resource "aws_iam_role" "rds_monitoring" {
  name               = var.aurora.monitoring_iam_role
  assume_role_policy = data.aws_iam_policy_document.rds_monitoring_assume_role_policy.json
}
resource "aws_iam_policy_attachment" "rds_monitoring" {
  name       = var.aurora.monitoring_iam_role
  roles      = [aws_iam_role.rds_monitoring.name]
  policy_arn = data.aws_iam_policy.AmazonRDSEnhancedMonitoringRole.arn
}

### DBサブネットグループ ###
resource "aws_db_subnet_group" "db" {
  # サブネットグループ名
  name = var.aurora.db_subnet_group_name
  # 説明
  description = "DB subnet group for Aurora"
  # サブネット
  subnet_ids = var.aurora.subnet_ids
}

### クラスター###
resource "aws_rds_cluster" "db" {
  ### エンジンのオプション ###
  # エンジンのタイプ
  engine = var.aurora.engine
  # エンジンのバージョン
  engine_version = var.aurora.engine_version

  ### テンプレート ###
  engine_mode = "provisioned"

  ### 設定 ###
  # DBクラスター識別子
  cluster_identifier = var.aurora.cluster_identifier
  # マスターユーザー名
  master_username = var.aurora.master_username
  # マスターパスワード
  master_password = var.aurora.master_password

  ### 接続 ###
  # サブネットグループ
  db_subnet_group_name = aws_db_subnet_group.db.name
  # セキュリティグループ
  vpc_security_group_ids = var.aurora.vpc_security_group_ids
  # データベースポート
  port = 3306

  ### モニタリング ###


  ### 追加設定 ###
  # データベース名
  database_name = var.aurora.database_name
  # DBクラスターのパラメータグループ
  #db_cluster_parameter_group_name = 
  # DBパラメータグループ
  #db_instance_parameter_group_name = 
  # オプショングループ

  # バックアップ保持期間
  backup_retention_period = var.aurora.backup_retention_period
  # バックアップ開始時間・期間
  preferred_backup_window = "15:00-15:30"
  # スナップショットにタグをコピー
  copy_tags_to_snapshot = true
  # 暗号化
  storage_encrypted = true
  # AWS KMSキー
  kms_key_id = ""
  # バックトラック

  # ログのエクスポート
  enabled_cloudwatch_logs_exports = ["audit", "error", "slowquery"]
  # IAMロール

  # マイナーバージョン自動アップグレードの有

  # メンテナンスウィンドウ
  preferred_maintenance_window = "Sat:17:00-Sat:17:30"
  # 削除保護
  deletion_protection = true
  skip_final_snapshot = true
}

### インスタンス ###
resource "aws_rds_cluster_instance" "db" {
  for_each = var.aurora.instances

  identifier     = each.value.identifier
  instance_class = var.aurora.instance_class

  cluster_identifier = aws_rds_cluster.db.id
  engine             = aws_rds_cluster.db.engine
  engine_version     = aws_rds_cluster.db.engine_version

  # パブリックアクセス
  publicly_accessible = false
  # モニタリングロール
  monitoring_role_arn = aws_iam_role.rds_monitoring.arn
  # モニタリングの詳細度(秒)
  monitoring_interval = 60
  # フェイルオーバー優先順位
  promotion_tier = 1

  # マイナーバージョン自動アップグレード
  auto_minor_version_upgrade = true

  copy_tags_to_snapshot = aws_rds_cluster.db.copy_tags_to_snapshot

}