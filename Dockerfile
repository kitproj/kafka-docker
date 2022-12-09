# https://github.com/bashj79/kafka-kraft-docker
 FROM alpine:3.14 AS builder
 ENV KAFKA_VERSION=3.0.0
 ENV SCALA_VERSION=2.13
 COPY <<EOF /bin/install_kafka.sh
 #!/usr/bin/env bash
 set -eux

 path=/kafka/${KAFKA_VERSION}/kafka_${SCALA_VERSION}-${KAFKA_VERSION}.tgz

 downloadUrl="https://archive.apache.org/dist/${path}"

 wget "${downloadUrl}" -O "/tmp/kafka.tgz"

 tar xfz /tmp/kafka.tgz -C /opt

 rm /tmp/kafka.tgz

 ln -s /opt/kafka_${SCALA_VERSION}-${KAFKA_VERSION} /opt/kafka
 EOF
 RUN chmod +x /bin/install_kafka.sh
 RUN apk update \
   && apk add --no-cache bash curl jq \
   && /bin/install_kafka.sh \
   && apk del curl jq

 FROM alpine:3.14
 RUN apk update && apk add --no-cache bash openjdk8-jre
 COPY --from=builder /opt/kafka /opt/kafka
 COPY <<EOF /bin/start_kafka.sh
 #!/usr/bin/env bash
 set -ex

 if [[ -z "$KAFKA_LISTENERS" ]]; then
   echo 'Using default listeners'
 else
   echo "Using listeners: ${KAFKA_LISTENERS}"
   sed -r -i "s@^#?listeners=.*@listeners=$KAFKA_LISTENERS@g" "/opt/kafka/config/kraft/server.properties"
 fi

 if [[ -z "$KAFKA_ADVERTISED_LISTENERS" ]]; then
   echo 'Using default advertised listeners'
 else
   echo "Using advertised listeners: ${KAFKA_ADVERTISED_LISTENERS}"
   sed -r -i "s@^#?advertised.listeners=.*@advertised.listeners=$KAFKA_ADVERTISED_LISTENERS@g" "/opt/kafka/config/kraft/server.properties"
 fi

 if [[ -z "$KAFKA_LISTENER_SECURITY_PROTOCOL_MAP" ]]; then
   echo 'Using default listener security protocol map'
 else
   echo "Using listener security protocol map: ${KAFKA_LISTENER_SECURITY_PROTOCOL_MAP}"
   sed -r -i "s@^#?listener.security.protocol.map=.*@listener.security.protocol.map=$KAFKA_LISTENER_SECURITY_PROTOCOL_MAP@g" "/opt/kafka/config/kraft/server.properties"
 fi

 if [[ -z "$KAFKA_INTER_BROKER_LISTENER_NAME" ]]; then
   echo 'Using default inter broker listener name'
 else
   echo "Using inter broker listener name: ${KAFKA_INTER_BROKER_LISTENER_NAME}"
   sed -r -i "s@^#?inter.broker.listener.name=.*@inter.broker.listener.name=$KAFKA_INTER_BROKER_LISTENER_NAME@g" "/opt/kafka/config/kraft/server.properties"
 fi

 uuid=$(/opt/kafka/bin/kafka-storage.sh random-uuid)
 /opt/kafka/bin/kafka-storage.sh format -t $uuid -c /opt/kafka/config/kraft/server.properties
 /opt/kafka/bin/kafka-server-start.sh /opt/kafka/config/kraft/server.properties
 EOF
 RUN chmod +x /bin/start_kafka.sh
 EXPOSE 9092
 CMD [ "/bin/start_kafka.sh" ]
 HERE
