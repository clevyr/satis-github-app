FROM composer/satis@sha256:a4c8bdf7249d8ae93438d195cf8776849e6e6bf001037af95c33537dba9e3235
RUN apk add --no-cache jq
COPY rootfs /
ENV PATH="$PATH:/satis/bin"
