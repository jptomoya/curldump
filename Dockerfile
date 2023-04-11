FROM alpine

RUN apk add --no-cache ca-certificates curl tshark  && update-ca-certificates

WORKDIR /tmp
COPY curldump.sh .
ENTRYPOINT ["./curldump.sh"]