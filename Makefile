AWS_REGION ?= us-west-2
$(eval AWS_ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text))
$(eval REG=$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com)

eksctl-create:
	eksctl create cluster -f k8s/cluster.yaml

eksctl-delete:
	eksctl delete cluster -f k8s/cluster.yaml

ecr-login:
	$(eval AWS_ACCOUNT_ID=$(shell aws sts get-caller-identity --query Account --output text))
	aws ecr get-login-password --region ${AWS_REGION} | docker login --password-stdin --username AWS "$(AWS_ACCOUNT_ID).dkr.ecr.$(AWS_REGION).amazonaws.com"

arm-ami:
	aws ssm get-parameter --name /aws/service/eks/optimized-ami/1.21/amazon-linux-2-arm64/recommended/image_id --region us-west-2 --query "Parameter.Value" --output text

# App1
app1: app1-build app1-arm-build

app1-build: ecr-login
	cd app1 && docker build -t python-amd64 .
	docker tag python-amd64 $(REG)/reinvent/app1:amd64
	docker push $(REG)/reinvent/app1:amd64

app1-arm-build: ecr-login
	cd app1 && docker build -f Dockerfile-arm -t python-arm64 .
	docker tag python-arm64 $(REG)/reinvent/app1:arm64
	docker push $(REG)/reinvent/app1:arm64

# App2
app2: app2-build app2-arm-build

app2-build: ecr-login
	cd app2 && docker build -t node-amd64 .
	docker tag node-amd64 $(REG)/reinvent/app2:amd64
	docker push $(REG)/reinvent/app2:amd64

app2-arm-build: ecr-login
	cd app2 && docker build -f Dockerfile-arm -t node-arm64 .
	docker tag node-arm64 $(REG)/reinvent/app2:arm64
	docker push $(REG)/reinvent/app2:arm64

# App3
app3: app3-build app3-arm-build

app3-build: ecr-login
	cd app3 && docker build -t go-86 .
	docker tag go-86 $(REG)/reinvent/app3:x86
	docker push $(REG)/reinvent/app3:x86

app3-arm-build: ecr-login
	cd app3 && docker build -f Dockerfile-arm -t go-arm64 .
	docker tag go-arm64 $(REG)/reinvent/app3:arm64
	docker push $(REG)/reinvent/app3:arm64

kubectl-86:
	kubectl apply -f manifests-x86/

kubectl-arm:
	kubectl apply -f manifests-arm64/

port-forward:
	kubectl port-forward deploy/hello-eks-a 8000:80
	kubectl port-forward deployment/go-arm64 8080:8080
	kubectl port-forward deployment/go-x86 8080:8080
	kubectl port-forward deployment/node-amd64 8081:8081
	kubectl port-forward deployment/node-arm64 8081:8081
	kubectl port-forward deployment/python-amd64 5000:5000
	kubectl port-forward deployment/python-arm64 5000:5000


port-forward-arm:
	kubectl port-forward deploy/hello-arm64 8000:80

#aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.${AWS_REGION}.amazonaws.com
