#!/bin/bash
set -euo pipefail

NAMESPACE="data-platform"

echo "=== 1. Creating namespace ==="
kubectl create namespace "$NAMESPACE" || echo "Namespace $NAMESPACE already exists"

echo "=== 2. Applying secrets ==="
kubectl apply -f artifacts/secrets/ -n "$NAMESPACE"

echo "=== 3. Installing local-path storage ==="
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "=== 4. Updating Helm dependencies ==="
helm dependency update ./helm

echo "=== 5. Deploying Helm chart ==="
sleep 5
helm upgrade --install data-platform ./helm --namespace "$NAMESPACE"

echo "=== Waiting for Strimzi operator pod to be ready ==="
kubectl wait --for=condition=ready pod -l name=strimzi-cluster-operator -n "$NAMESPACE" --timeout=180s || \
  kubectl wait --for=condition=ready pod -l strimzi.io/kind=ClusterOperator -n "$NAMESPACE" --timeout=180s

echo "=== Strimzi operator is ready ==="

echo "=== 6. Applying Kafka cluster artifacts ==="
kubectl apply -f artifacts/kafka/ -n "$NAMESPACE"

echo "=== Deployment completed ==="
