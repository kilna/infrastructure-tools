FROM alpine:3.12.1

ENV PATH="/workspace/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

ARG OPS_UID=1000
ARG OPS_GID=1000

COPY bin/* /usr/local/bin/

RUN set -e -u -o pipefail -x; \
    apk --no-cache update; \
    apk --no-cache upgrade; \
    apk --no-cache add --no-scripts \
      ca-certificates jq python3 py3-pip curl unzip tree git openssl openssh bash \
      rsync make alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev \
      fuse groff; \
    update-ca-certificates; \
    pip install --upgrade pip; \
    adduser -H -D -h /workspace -u ${OPS_UID} -g ${OPS_GID} ops ops; \
    echo 'export PATH="/workspace/bin:$PATH"' >>/etc/profile; \
    echo 'export PS1="\\u@\\h:\\w\\\$ "' >>/etc/profile; \
    mkdir /workspace; \
    chown -R ops:ops /workspace

RUN chmod +rx /usr/local/bin/* \
    && /usr/local/bin/install.sh \
    && rm /usr/local/bin/install.sh

USER ops
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
VOLUME /workspace
WORKDIR /workspace

