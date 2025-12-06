# PostgreSQL Deployment Guide ( For MLFlow )

This PostgreSQL instance is used as the backend store for MLflow.

---

## 1. Apply Secrets
Make sure the `db` namespace exists, then apply the credentials:

```sh
kubectl apply -f ./postgres/secrets.yaml
```

---

## 2. Deploy PostgreSQL

```sh
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm upgrade --install mlflow-postgresql bitnami/postgresql \
  -n db \
  -f values-postgres.yaml
```

---

## 3. Uninstall PostgreSQL

```sh
helm uninstall mlflow-postgresql -n db
```

---

## 4. Test Login Manually

Open a shell inside the PostgreSQL pod:

```sh
kubectl exec -it mlflow-postgresql-0 -n db -- bash
```

Inside the pod, test database access:

```sh
psql -U mlflow -d mlflow_db
```

Password:

```
mlflow_password
```

---

## 6. PVC / PV Stuck Deleting

If PersistentVolume or PersistentVolumeClaim gets stuck:

Useful references:

* [https://stackoverflow.com/questions/55672498/kubernetes-cluster-stuck-on-removing-pv-pvc](https://stackoverflow.com/questions/55672498/kubernetes-cluster-stuck-on-removing-pv-pvc)
* [https://github.com/bitnami/charts/issues/25472](https://github.com/bitnami/charts/issues/25472)