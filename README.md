# kafka-kraft

A self-contained Docker image for Kafka. Only one image needed, no Zookeeper (it uses KRaft). So much much easier for use in automated tests.

## Usage

```bash
docker run --rm -p 9092:9092 alexcollinsintuit/kafka 
```

## Building

```bash
# build the image
docker build --tag kafka .
```

```bash
# push to repository
docker tag kafka alexcollinsintuit/kafka
docker push alexcollinsintuit/kafka 
```