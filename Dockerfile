FROM alpine:3.18

ARG INSTALL_COMODO_AAA_CERT=0

RUN apk add --no-cache ca-certificates curl wireshark-common iproute2-ss && update-ca-certificates

COPY ./curldump.sh ./docker-entrypoint.sh ./install-comodo-aaa-cert.sh /

# Temporary workaround for Alpine trust stores missing the Comodo AAA root.
# See https://gitlab.alpinelinux.org/alpine/aports/-/issues/17445
RUN if [ "$INSTALL_COMODO_AAA_CERT" = "1" ]; then /install-comodo-aaa-cert.sh; fi

WORKDIR /work
ENTRYPOINT ["/docker-entrypoint.sh"]
