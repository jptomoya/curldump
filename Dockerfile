FROM alpine:3

RUN apk add --no-cache ca-certificates curl wireshark-common  && update-ca-certificates

COPY curldump.sh /
WORKDIR /work
ENTRYPOINT ["/curldump.sh"]
