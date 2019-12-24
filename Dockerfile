FROM alpine:3.11

ENV PATH="/workspace/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin"

ARG OPS_UID=1000
ARG OPS_GID=1000

COPY *.sh /usr/local/bin/

RUN set -e -u -o pipefail -x; \
    chmod +x /usr/local/bin/*.sh; \
    apk --no-cache update; \
    apk --no-cache upgrade; \
    apk --no-cache add --no-scripts \
      ca-certificates jq python3 curl unzip tree git openssl openssh bash \
      rsync make; \
    update-ca-certificates; \
    pip3 install --upgrade pip; \
    adduser -H -D -h /workspace -u ${OPS_UID} -g ${OPS_GID} ops ops; \
    echo 'export PATH="/workspace/bin:$PATH"' >>/etc/profile; \
    echo 'export PS1="\\u@\\h:\\w\\\$ "' >>/etc/profile; \
    mkdir /workspace; \
    chown -R ops:ops /workspace

RUN /usr/local/bin/install.sh \
    && rm /usr/local/bin/install.sh

USER ops
ENTRYPOINT [ "/usr/local/bin/entrypoint.sh" ]
VOLUME /workspace
WORKDIR /workspace

