FROM alpine:3.13.2

ARG OPS_UID=1000
ARG OPS_GID=1000

RUN set -e -u -o pipefail -x; \
    apk --no-cache update; \
    apk --no-cache upgrade; \
    apk --no-cache add --no-scripts \
      ca-certificates jq python3 py3-pip curl unzip tree git openssl openssh bash \
      rsync make alpine-sdk automake autoconf libxml2-dev fuse-dev curl-dev \
      fuse groff vim; \
    update-ca-certificates; \
    pip install --upgrade pip

COPY bin/* /usr/local/bin/

RUN chmod +x /usr/local/bin/*

RUN /usr/local/bin/install.sh

COPY ops/ /ops/

RUN set -e -u -x; \
    adduser -H -D -h /ops -u ${OPS_UID} -g ${OPS_GID} ops ops; \
    chown -R ops:ops /ops

USER ops
VOLUME /workspace
WORKDIR /workspace

