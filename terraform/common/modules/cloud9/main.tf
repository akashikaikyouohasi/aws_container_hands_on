resource "aws_cloud9_environment_ec2" "main" {
    name = var.cloud9.name
    description = var.cloud9.description

    connection_type = var.cloud9.connection_type
    instance_type = var.cloud9.instance_type
    image_id = "amazonlinux-2-x86_64"

    automatic_stop_time_minutes = 30
    subnet_id = var.public_subnets[var.cloud9.subnet_id]

    # Terraform実行ユーザーとコンソールユーザーが異なるため設定
    owner_arn = var.cloud9.owner_arn
}

# セキュリティグループ割り当て
resource "aws_network_interface_sg_attachment" "sg" {
  security_group_id = var.sg[var.cloud9.security_group]
  network_interface_id = data.aws_instance.cloud9_instance.network_interface_id
}

# Cloud9のインスタンスの情報を取得
data "aws_instance" "cloud9_instance" {
    filter {
        name = "tag:aws:cloud9:environment"
        values = [aws_cloud9_environment_ec2.main.id]
    }
}

output "cloud9_values" {
    value = data.aws_instance.cloud9_instance
}