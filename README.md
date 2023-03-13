# Kafka Docker

A self-contained Docker image for Kafka. Typically you must run multiple
images ([example](https://developer.confluent.io/quickstart/kafka-docker/)). This only requires a single image. This
reduces the complexity by an order of magnitude.

On Docker:

```bash
docker run --rm -p 9092:9092 --name kafka ghcr.io/kitproj/kafka
```

On Kubernetes:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: kafka
spec:
  containers:
    - name: main
      image: ghcr.io/kitproj/kafka
      ports:
        - containerPort: 9092
```