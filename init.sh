#!/bin/bash
set -euo pipefail

NAMESPACE="data-platform"
SKIP_DEP_UPDATE=false

# Parse arguments
for arg in "$@"; do
  case "$arg" in
    --no-dep-update)
      SKIP_DEP_UPDATE=true
      ;;
  esac
done

echo "=== 1. Creating namespace ==="
kubectl create namespace "$NAMESPACE" || echo "Namespace $NAMESPACE already exists"

echo "=== 2. Applying secrets ==="
kubectl apply -f artifacts/secrets/ -n "$NAMESPACE"

echo "=== 3. Installing local-path storage & prometheus CRDs ==="
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

echo "=== 4. Updating Helm dependencies ==="
if [[ "$SKIP_DEP_UPDATE" == false ]]; then
  helm dependency update ./helm
else
  echo "Skipping 'helm dependency update' because --no-dep-update was provided"
fi

echo "=== 5. Deploying Helm chart ==="
set +e
helm upgrade --install data-platform ./helm --namespace "$NAMESPACE"
HELM_EXIT_CODE=$?
set -e

if [[ $HELM_EXIT_CODE -ne 0 ]]; then
  echo "Helm upgrade failed with exit code $HELM_EXIT_CODE"

  # Check if the error was caused by missing ServiceMonitor CRDs
  if kubectl get crd servicemonitors.monitoring.coreos.com >/dev/null 2>&1; then
    echo "CRDs exist now. Retrying Helm upgrade..."
    helm upgrade --install data-platform ./helm --namespace "$NAMESPACE"
  else
    echo "ServiceMonitor CRD does NOT exist. Waiting and rechecking..."
    sleep 5
    kubectl wait --for=condition=Established crd/servicemonitors.monitoring.coreos.com --timeout=60s || true
    
    echo "Retrying Helm upgrade..."
    helm upgrade --install data-platform ./helm --namespace "$NAMESPACE"
  fi
fi

echo "=== Waiting for Strimzi operator pod to be ready ==="
kubectl wait --for=condition=ready pod -l name=strimzi-cluster-operator -n "$NAMESPACE" --timeout=180s || \
  kubectl wait --for=condition=ready pod -l strimzi.io/kind=ClusterOperator -n "$NAMESPACE" --timeout=180s

echo "=== Strimzi operator is ready ==="

echo "=== 6. Applying Kafka cluster artifacts ==="
kubectl apply -f artifacts/kafka/ -n "$NAMESPACE"

echo "=== Deployment completed ==="
