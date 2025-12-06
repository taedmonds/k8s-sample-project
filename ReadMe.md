# Deployment Guides

Deploy the services in the following order:

1. **MongoDB** → [`mongo.md`](./mongo.md)
2. **PostgreSQL** → [`postgres.md`](./postgres.md)
3. **MLflow** → [`mlflow.md`](./mlflow.md)
4. **Kafka** → [`kafka.md`](./kafka.md)

Got you — here is a **very simple and short** Helm deployment section.

---

## Helm Deployment

### 1. Create namespace

```bash
kubectl create namespace data-platform
```

### 2. Apply secrets

(Your MongoDB, PostgreSQL, MinIO, MLflow secrets)

```bash
kubectl apply -f secrets/ -n data-platform
```

### 3. Install local-path storage (for Colima)

```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

### 4. Download Helm dependencies

```bash
helm dependency update ./helm
```

### 5. Deploy everything with ONE command

```bash
helm upgrade --install data-platform ./helm \
  --namespace data-platform
```
### 6. Undeploy everything with ONE command

```bash
helm uninstall data-platform -n data-platform
```

### (Optional) Set namespace as default for debug

```bash
kubectl config set-context --current --namespace=data-platform
```

---

Let me know if you want an equally simple uninstall section.


## Issues

- How to find the exact version (tag) of an image

Each guide contains the commands needed to install and uninstall the service.