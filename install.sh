#!/bin/bash

set -e -u -o pipefail -x

k8s_version=1.16.4
doctl_version=1.36.0
terraform_version=0.12.8
helm_version=3.0.2
awscli_version=1.16.308

pip3 install --upgrade yq

curl -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${k8s_version}/bin/linux/amd64/kubectl
chmod 755 /usr/local/bin/kubectl
kubectl version --client=true

curl -L https://github.com/digitalocean/doctl/releases/download/v${doctl_version}/doctl-${doctl_version}-linux-amd64.tar.gz \
  | tar -C /usr/local/bin -x -v -z
chmod 755 /usr/local/bin/doctl
chown root:root /usr/local/bin/doctl
doctl version

cd /usr/local/bin
curl -L -o tf.zip https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip
unzip tf.zip terraform
rm tf.zip
chmod 755 /usr/local/bin/terraform
ls -la
cd /workspace
terraform version

curl -s -L -o /tmp/get_helm https://raw.githubusercontent.com/helm/helm/master/scripts/get
HELM_INSTALL_DIR=/usr/local/bin USE_SUDO=false bash /tmp/get_helm -v v${helm_version}
rm /tmp/get_helm
helm version --client

pip3 install --upgrade awscli==${awscli_version}
aws --version

