#!/usr/bin/bash
#################
# middleware
#################
npm install --global nvm
nvm alias default v16.17.0
node -v # 16.17.0
npm install --global yarn
yarn -v # 1.22.19

#################
# Application
#################
# for Frontend
git clone https://github.com/uma-arai/sbcntr-frontend.git
cd /home/ec2-user/environment/sbcntr-frontend/
yarn install --pure-lockfile --production # --pure-lockfileでlockファイルを生成しない。productionはproduction用インストールで、devDependenciesがインスコされない。

npx blitz -v # blitz: 0.33.1 (local)

# for Backend
git clone https://github.com/uma-arai/sbcntr-backend.git
cd /home/ec2-user/environment/sbcntr-backend/


# EBS extended
cd /home/ec2-user/environment/
curl https://raw.githubusercontent.com/uma-arai/sbcntr-resources/main/cloud9/resize.sh > resize.sh
chmod 755 resize.sh
sh resize.sh 30
df -h / # 30GB!

# Docker for backehd
# https://docs.aws.amazon.com/ja_jp/AmazonECR/latest/userguide/getting-started-cli.html#cli-push-image
cd /home/ec2-user/environment/sbcntr-backend/
docker image build -t sbcntr-backend:v1 .
docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)

# docker tag [タグを付けるイメージ] [タグ名]
docker image tag sbcntr-backend:v1 ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1
docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}" | grep amazon

# ecr login
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com
# Push image 
docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1

docker image rm -f $(docker image ls --quiet)
docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}"

docker image pull ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1

# test
docker container run --detach --publish 8080:80 ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-backend:v1
docker container ls --format "table {{.ID}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
date; curl http://localhost:8080/v1/helloworld ;date 

### Dcoker for frontend ###
# DB接続なし
cd /home/ec2-user/environment/sbcntr-frontend/
docker image build -t sbcntr-frontend:v1 .
docker image tag sbcntr-frontend:v1 ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend:v1

aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend:v1


aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend:v1
docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend:v1

# DB接続あり
cd /home/ec2-user/environment/sbcntr-frontend/
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
docker image build -t sbcntr-frontend .

docker image tag sbcntr-frontend:latest ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend:dbv1
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin https://${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend
docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-frontend:dbv1


### Docker for base ###
docker image pull golang:1.16.8-alpine3.13
docker image ls --format "table {{.ID}}\t{{.Repository}}\t{{.Tag}}\t{{.Size}}"

AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base
docker image tag golang:1.16.8-alpine3.13 ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:golang1.16.8-alpine3.13
docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:golang1.16.8-alpine3.13

$ sed -i -e "s/golang:1.16.8-alpine3.13/206863353204.dkr.ecr.ap-northeast-1.amazonaws.com\/sbcntr-base:golang1.16.8-alpine3.13/g" Dockerfile  
$ git add Dockerfile
$ git commit -m 'ci: change Dockerfile'
$ git push

### Firelens ###
cd /home/ec2-user/environment
mkdir base-logrouter 
cd base-logrouter 
touch fluent-bit-custom.conf myparsers.conf stream_processor.conf Dockerfile

cd /home/ec2-user/environment/base-logrouter 
AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query 'Account' --output text)
docker image build -t sbcntr-log-router .
aws ecr get-login-password --region ap-northeast-1 | docker login --username AWS --password-stdin ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base
docker image tag sbcntr-log-router:latest ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:log-router
docker image push ${AWS_ACCOUNT_ID}.dkr.ecr.ap-northeast-1.amazonaws.com/sbcntr-base:log-router