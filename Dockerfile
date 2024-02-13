FROM composer/satis@sha256:c6a97493c22663edfaf7f687be63ac3615d32e4aa8d20a2f50f7a96ff18e6e8c
RUN apk add --no-cache jq
COPY rootfs /
ENV PATH="$PATH:/satis/bin"
