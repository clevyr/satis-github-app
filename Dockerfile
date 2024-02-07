FROM composer/satis@sha256:b9094557f9d6d6508f4836e618ddae0bdbe60d3f8ae0e1eb222f0ad2628fcd11
RUN apk add --no-cache jq
COPY rootfs /
ENV PATH="$PATH:/satis/bin"
