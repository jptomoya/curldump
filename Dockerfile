FROM alpine:3

RUN apk add --no-cache ca-certificates curl wireshark-common && update-ca-certificates

COPY ./*.sh /
WORKDIR /work
ENTRYPOINT ["/docker-entrypoint.sh"]
