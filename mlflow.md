# MLflow Deployment Guide

Official Helm chart:  
https://artifacthub.io/packages/helm/community-charts/mlflow



## 1. Add Helm Repository

```sh
helm repo add community-charts https://community-charts.github.io/helm-charts
helm repo update
```

---

## 2. Deploy PostgreSQL (Required)

MLflow requires a backend database.
Before installing MLflow, deploy PostgreSQL using:

```
./postgres.md
```

Ensure PostgreSQL is running in the **db** namespace and reachable.

---

## 3. Create MLflow Namespace

```sh
kubectl create ns mlflow
```

---

## 4. Apply MLflow Secrets

```sh
kubectl apply -f ./mlflow/secrets.yaml
```

This secret contains MLflow backend store credentials.

---

## 5. Deploy MLflow

```sh
helm upgrade --install mlflow community-charts/mlflow \
  -n mlflow \
  -f values-mlflow.yaml
```

MLflow will automatically run DB migrations using the Postgres settings from the values file.

---
Got it! Here's a simplified version:

---

### 6. View MLflow Dashboard

To access the MLflow dashboard, use port forwarding with this command:

```sh
kubectl port-forward svc/mlflow 5000:5000 -n mlflow
```

Now, open your browser and go to:

```
http://localhost:5000
```

## 7. Uninstall MLflow

```sh
helm uninstall mlflow -n mlflow
```

---

## Notes

* Ensure the Postgres host in `values-mlflow.yaml` matches the correct service:

  ```
  mlflow-postgresql.db.svc.cluster.local
  ```
* If database migration fails, verify:

  * Secrets are applied
  * PostgreSQL user + database exist
  * MLflow pod can reach PostgreSQL service

kubectl port-forward svc/kafka 9092:9092 -n kafka