FROM alpine:latest

RUN apk add --no-cache ca-certificates curl wireshark-common iproute2-ss && update-ca-certificates

COPY ./*.sh /
WORKDIR /work
ENTRYPOINT ["/docker-entrypoint.sh"]
