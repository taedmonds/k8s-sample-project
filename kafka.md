# Kafka Deployment Guide

This deploys Apache Kafka using the Strimzi Helm chart.

---

## 1. Create Namespace

```sh
kubectl create ns kafka
```

---

## 2. Deploy Kafka

```sh
helm repo add strimzi https://strimzi.io/charts/
helm repo update

helm upgrade --install kafka strimzi/strimzi-kafka-operator \
  --namespace kafka \
  -f values-kafka.yaml

```

## 3. Create Kafka Cluster & Node Pool

```sh
k apply -f ./kafka/cluster-and-node-pool.yaml -n kafka
```

Check cluster status:

```sh
kubectl get pods -n kafka
kubectl get kafka -n kafka
```


## 4. Test Kafka Producer & Consumer

Replace my-kraft-cluster with your actual cluster name (if different).

### Producer
```sh
kubectl -n kafka run kafka-producer \
  -ti --image=quay.io/strimzi/kafka:0.42.0-kafka-3.7.1 \
  --rm=true --restart=Never \
  -- bin/kafka-console-producer.sh \
  --bootstrap-server my-kraft-cluster-kafka-bootstrap:9092 \
  --topic my-topic
```

### Consumer
```sh
kubectl -n kafka run kafka-consumer \
  -ti --image=quay.io/strimzi/kafka:0.42.0-kafka-3.7.1 \
  --rm=true --restart=Never \
  -- bin/kafka-console-consumer.sh \
  --bootstrap-server my-kraft-cluster-kafka-bootstrap:9092 \
  --topic my-topic --from-beginning
```
---

## 3. Uninstall Kafka

```sh
kubectl delete -f ./kafka/cluster-and-node-pool.yaml -n kafka

helm uninstall kafka -n kafka
```