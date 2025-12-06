# MinIO Deployment Guide (Standalone – for MLflow Artifacts)

Official Helm chart:  
https://charts.bitnami.com/bitnami/minio  
ArtifactHub: https://artifacthub.io/packages/helm/bitnami/minio


## 1. Create Namespace (only once)

```bash
kubectl create namespace mlflow
```

## 2.  Apply Minio Secrets

```sh
kubectl apply -f ./minio/secrets.yaml
```

## 3. Add / Update Bitnami Helm Repository

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

## 4. Deploy MinIO

```bash
helm upgrade --install minio bitnami/minio \
  --namespace mlflow \
  -f values-minio.yaml
```

## 5. Quick Access

```bash
# Web Console (MinIO Browser)
kubectl port-forward svc/minio-console 9090:9090 -n mlflow
# → open http://localhost:9090
# Login: minioadmin / minioadmin1234

# S3 API endpoint (for MLflow, mc, aws cli, etc.)
kubectl port-forward svc/minio 9000:9000 -n mlflow
# → http://localhost:9000
```

## 6. Verify Bucket Was Created

```bash
mc alias set local http://localhost:9000 minioadmin minioadmin1234
mc ls local
# → should show: mlflow-artifacts
```

## 7. Use in MLflow (values snippet)

```yaml
mlflow:
  extraEnvVars:
    MLFLOW_S3_ENDPOINT_URL: http://minio.mlflow.svc.cluster.local:9000
  artifactRoot:
    s3:
      enabled: true
      bucket: mlflow-artifacts
      existingSecret:
        name: minio-root-secret
        keyOfAccessKeyId: MINIO_ROOT_USER
        keyOfSecretAccessKey: MINIO_ROOT_PASSWORD
```

## 8. Uninstall MinIO

```bash
helm uninstall minio -n mlflow

# Optional – remove secret
kubectl delete secret minio-root-secret -n mlflow
```