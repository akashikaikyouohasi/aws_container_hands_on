# Terraform構成
共通となるリソースと、アプリケーションなどの個別のリソースに分けてTerraformを構成します。
リソースはmodule化します。

## 1.共通リソース(common)
NE、SG、IAM、ECRなど、アプリケーションで共通で使うもの

## 2.アプリケーション(application)
ECSクラスター・タスクなど、関係するもの

## 3.インタフェース型VPCエンドポイントなど、必要な時だけデプロイするもの(billing)
時間で金がかかるリソース用。
触るときだけデプロイして、終わったら削除！！！！
現状の対象
- Inteface型のVPCエンドポイント
  - ECR(dkr,api)
  - CloudWatch Logs


## 注意点
Cloud9用に作成したIAMロールをアタッチする方法がわからなかったので、`sbcntr-cloud9-role`ロールは手動でアタッチしています。

Coud9の[AMTC無効化](https://dev.classmethod.jp/articles/execute-aws-cli-with-iam-role-on-cloud9/#toc-2)も手動でお願いします。


## commit
`$ terraform fmt -recursive`してからコミットしましょう！