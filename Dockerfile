FROM alpine:3.5

RUN apk add --no-cache --virtual .run-deps rsync openssh tzdata curl
#COPY docker-entrypoint.sh /
COPY rsyncd.conf /etc/


#this should match rsync modulename path.
RUN ["mkdir", "-p", "/home/rsync"]
RUN ["chmod","777", "/home/rsync"]
#RUN ["/usr/bin/rsync","--daemon"]

EXPOSE 873
#CMD  ["sh"]
ENTRYPOINT ["/usr/bin/rsync","--daemon","--no-detach"]