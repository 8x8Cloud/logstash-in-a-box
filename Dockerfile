# Use one of the smaller Alpine based distros with Java 8
FROM frolvlad/alpine-oraclejdk8:slim
MAINTAINER Greg Feigenson <greg.feigenson@8x8.com>

ENV LOGSTASH_VERSION=2.4.1 LOGSTASH_HOME=/usr/share/logstash
ENV PATH=${PATH}:${LOGSTASH_HOME}/bin

RUN apk update && apk upgrade && apk add --no-cache ca-certificates curl bash su-exec && \
    curl -Ls https://download.elastic.co/logstash/logstash/logstash-${LOGSTASH_VERSION}.tar.gz | tar -xz -C /usr/share && \
    ln -s /usr/share/logstash-$LOGSTASH_VERSION $LOGSTASH_HOME && \

    # Add a non-root user
    addgroup -S logstash && \
    adduser -S -G logstash logstash && \
    chown -R logstash /usr/share/logstash && \

    # Clean up after ourselves...
    rm -rf /tmp/* /var/cache/apk/* && apk del ca-certificates

# Copy the stuff we need to copy
COPY app/docker-entrypoint.sh /
COPY app/kibana-goodies ${LOGSTASH_HOME}/bin/kibana-goodies
COPY app/logstash.conf ${LOGSTASH_HOME}/bin
COPY app/jetty-request-template.json ${LOGSTASH_HOME}/bin

# Get ready to run
ENTRYPOINT ["/docker-entrypoint.sh"]
CMD ["logstash", "-f",  "/config/logstash.conf"]
