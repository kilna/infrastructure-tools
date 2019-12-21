FROM alpine:latest

ENV PATH="/workspace/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

ARG OPS_UID=1000
ARG OPS_GID=1000

COPY entrypoint.sh /

RUN set -e -u -o pipefail -x; \
    apk --no-cache update; \
    apk --no-cache upgrade; \
    apk --no-cache add --no-scripts \
      ca-certificates jq python3 curl unzip tree git openssl bash rsync; \
    update-ca-certificates; \
    pip3 install --upgrade pip yq; \
    adduser -H -D -h /workspace -u ${OPS_UID} -g ${OPS_GID} ops ops; \
    echo 'export PATH="/workspace/bin:$PATH"' >>/etc/profile; \
    echo 'export PS1="\\u@\\h:\\w\\\$ "' >>/etc/profile; \
    mkdir /workspace; \
    chown -R ops:ops /workspace; \
    echo "root:root" | chpasswd


ARG k8s_version=1.16.4
RUN set -e -u -o pipefail -x; \
    curl -L -o /usr/local/bin/kubectl \
      https://storage.googleapis.com/kubernetes-release/release/v${k8s_version}/bin/linux/amd64/kubectl; \
    chmod 755 /usr/local/bin/kubectl; \
    kubectl version --client=true

ARG doctl_version=1.36.0
RUN set -e -u -o pipefail -x; \
    curl -L \
      https://github.com/digitalocean/doctl/releases/download/v${doctl_version}/doctl-${doctl_version}-linux-amd64.tar.gz \
      | tar -C /usr/local/bin -x -v -z; \
    chmod 755 /usr/local/bin/doctl; \
    chown root:root /usr/local/bin/doctl; \
    doctl version

ARG terraform_version=0.12.8
RUN set -e -u -o pipefail -x; \
    cd /usr/local/bin; \
    curl -L -o tf.zip \
      https://releases.hashicorp.com/terraform/${terraform_version}/terraform_${terraform_version}_linux_amd64.zip; \
    unzip tf.zip terraform; \
    rm tf.zip; \
    chmod 755 /usr/local/bin/terraform; \
    ls -la; \
    cd /workspace; \
    terraform version

ARG helm_version=3.0.2
RUN set -e -u -o pipefail -x; \
    curl -s -L -o /tmp/get_helm \
      https://raw.githubusercontent.com/helm/helm/master/scripts/get; \
    HELM_INSTALL_DIR=/usr/local/bin USE_SUDO=false bash /tmp/get_helm -v v${helm_version}; \
    rm /tmp/get_helm; \
    helm version --client

VOLUME /workspace
WORKDIR /workspace
USER ops

