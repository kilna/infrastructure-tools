#!/bin/bash

set -e -u -o pipefail -x

k8s_version=1.19.3         # https://github.com/kubernetes/kubernetes/releases
doctl_version=1.54.0       # https://github.com/digitalocean/doctl/releases
terraform_version=0.14.2   # https://github.com/hashicorp/terraform/releases
helm_version=3.4.2         # https://github.com/helm/helm/releases
awscli_version=1.18.193    # https://github.com/aws/aws-cli/releases
s3fs_version=1.85          # https://github.com/s3fs-fuse/s3fs-fuse/releases

mkdir -p /tmp/s3fs
cd /tmp/s3fs
curl -s -L https://github.com/s3fs-fuse/s3fs-fuse/archive/v${s3fs_version}.tar.gz \
  | tar -C /tmp/s3fs --strip-components=1 -x -v -z
./autogen.sh
./configure --prefix=/usr
make
make install
cd /
rm -rf /tmp/s3fs

pip3 install --upgrade yq

curl -s -L -o /usr/local/bin/kubectl https://storage.googleapis.com/kubernetes-release/release/v${k8s_version}/bin/linux/amd64/kubectl
chmod 755 /usr/local/bin/kubectl
kubectl version --client=true

curl -s -L https://github.com/digitalocean/doctl/releases/download/v${doctl_version}/doctl-${doctl_version}-linux-amd64.tar.gz \
  | tar -C /usr/local/bin -x -v -z
chmod 755 /usr/local/bin/doctl
chown root:root /usr/local/bin/doctl
doctl version

cd /usr/local/bin
curl -s -L -o tf.zip https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip
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
cd /
rm -rf /tmp/get_helm

pip3 install --upgrade awscli==${awscli_version}
aws --version

