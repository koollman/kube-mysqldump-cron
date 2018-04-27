FROM alpine:3.4
RUN apk add --update mysql-client bash openssh-client && rm -rf /var/cache/apk/*
COPY dump.sh /
COPY import.sh /
COPY transport.sh /
COPY dump_and_transport.sh /

RUN mkdir -p /mysqldump && chmod +x /dump.sh /import.sh /transport.sh /dump_and_transport.sh

ENTRYPOINT ["/dump_and_transport.sh"]
