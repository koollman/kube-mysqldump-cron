FROM alpine:3.4
RUN apk add --update mysql-client bash openssh-client && rm -rf /var/cache/apk/*
COPY dump.sh /
COPY import.sh /

RUN mkdir -p /mysqldump && chmod +x /dump.sh /import.sh

ENTRYPOINT ["/dump.sh"]
