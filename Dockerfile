FROM composer/satis
RUN apk add --no-cache jq
COPY rootfs /
ENV PATH="$PATH:/satis/bin"