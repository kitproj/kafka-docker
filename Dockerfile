FROM alpine:3 AS builder
ENV KAFKA_VERSION=3.0.0
ENV SCALA_VERSION=2.13
RUN apk update \
  && apk add --no-cache bash curl jq
COPY install_kafka.sh /bin/
RUN /bin/install_kafka.sh
FROM alpine:3
RUN apk update && apk add --no-install-recommends --no-cache bash openjdk8-jre
COPY --from=builder /opt/kafka /opt/kafka
COPY start_kafka.sh /bin/
EXPOSE 9092
VOLUME [ "/tmp/kraft-combined-logs" ]
LABEL org.opencontainers.image.title="Kafka ${KAFKA_VERSION} with Kraft" \
      org.opencontainers.image.description="Standalone Kafka image that uses Kraft." \
      org.opencontainers.image.url="https://github.com/kitproj/kafka-docker" \
      org.opencontainers.image.licenses="MIT"
CMD [ "/bin/start_kafka.sh" ]