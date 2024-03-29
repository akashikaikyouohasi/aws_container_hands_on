## 実行手順
### dev
```
# cd common/dev/
# terraform init
# terraform apply
```
AWSのコンソール画面に行き、パラメータストアに格納しているデータベースのマスターパスワードを調整すること！！！
```
# cd ../../application/dev/
# terraform init
# terraform apply

# cd ../../billing/dev/
# terraform init
# terraform apply
```

## Terraform構成
共通となるリソースと、アプリケーションなどの個別のリソースに分けてTerraformを構成します。
リソースはmodule化します。

以下の順序通りの実施になります。

### 1.共通リソース(common)
NE、SG、IAM、ECRなど、アプリケーション以外の共通で使うもの

### 2.アプリケーション(application)
ECSクラスター・タスクなど、アプリケーションのもの

### 3.インタフェース型VPCエンドポイントなど、必要な時だけデプロイするもの(billing)
時間経過で金がかかるリソース用。
触るときだけデプロイして、終わったら削除！！！！

現状の対象
- Inteface型のVPCエンドポイント
  - ECR(dkr,api)
  - CloudWatch Logs
- ECSのサービス
- CodeDeploy：これ自体にお金はかからないが、ECS/ALBと依存関係があるため
- CodePipeline：CodeDeployに依存するため


### 注意点
Cloud9用に作成したIAMロールをアタッチする方法がわからなかったので、`sbcntr-cloud9-role`ロールは手動でアタッチしています。

Coud9の[AMTC無効化](https://dev.classmethod.jp/articles/execute-aws-cli-with-iam-role-on-cloud9/#toc-2)も手動でお願いします。


## commit時のお願い
`$ terraform fmt -recursive`してからコミットしましょう！
