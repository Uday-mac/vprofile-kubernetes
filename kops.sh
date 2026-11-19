#!/bin/bash
apt-get update
apt-get install unzip -y

#installing aws cli 
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install

#Installing kops and kubectl
curl -Lo kops https://github.com/kubernetes/kops/releases/download/$(curl -s https://api.github.com/repos/kubernetes/kops/releases/latest | grep tag_name | cut -d '"' -f 4)/kops-linux-amd64
chmod +x kops
sudo mv kops /usr/local/bin/kops

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/kubectl

#Creating ssh-keys
ssh-keygen -t rsa -b 4096 -f ~/.ssh/kop

#Create cluster with kops 
kops create cluster \
    --name=kops.learndevcloud.shop \
    --state=s3://kopscluster2191 \
    --zones=us-east-1a,us-east-1b \
    --node-count=2 \
    --node-size=c7i-flex.large \
    --node-volume-size=20 \
    --control-plane-size=c7i-flex.large \
    --control-plane-volume-size=20 \
    --dns-zone=kops.learndevcloud.shop \
    --ssh-public-key=~/.ssh/kop.pub

#update cluster
kops update cluster --name=kops.learndevcloud.shop --state=s3://kopscluster2191 --admin --yes

#validate cluster
kops validate cluster --name=kops.learndevcloud.shop --state=s3://kopscluster2191

#delete cluster 
kops delete cluster --name=kops.learndevcloud.shop --state=s3://kopscluster2191

#installing ingress nginx controller
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-0.32.0/deploy/static/provider/aws/deploy.yaml