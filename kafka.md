# Kafka Deployment Guide

This deploys Apache Kafka using the Bitnami Helm chart.

---

## 1. Create Namespace

```sh
kubectl create ns kafka
```

---

## 2. Deploy Kafka

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade --install kafka bitnami/kafka \
  -n kafka \
  -f values-kafka.yaml
```

Your `values-kafka.yaml` must include the legacy image override because Bitnami removed Kafka images from Docker Hub.

---

## 3. Uninstall Kafka

```sh
helm uninstall kafka -n kafka
```

---

## 4. Known Issues

Bitnami removed Kafka container images from their public Docker registry.
You can use the legacy image repository:

```
image:
  repository: bitnamilegacy/kafka
```

Reference issue:
[https://github.com/bitnami/charts/issues/36325](https://github.com/bitnami/charts/issues/36325)