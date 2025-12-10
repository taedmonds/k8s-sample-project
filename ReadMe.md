# Deployment Guides

## Helm Deployment

You have two options to deploy the Data Platform:

> 1. **Automatic**: Run `./init.sh` to deploy everything automatically.
> 2. **Manual**: Follow the steps below to deploy piece by piece.

### Manual Deployment Steps

#### 1. Create namespace

```bash
kubectl create namespace data-platform
```

#### 2. Apply secrets

```bash
kubectl apply -f artifacts/secrets/ -n data-platform
```

#### 3. Install local-path storage (for Colima)

```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

#### 4. Download Helm dependencies

```bash
helm dependency update ./helm
```

#### 5. Deploy everything with ONE command

```bash
helm upgrade --install data-platform ./helm \
  --namespace data-platform
```

#### 6. Apply kafka cluster artifacts

```bash
kubectl apply -f artifacts/kafka/ -n data-platform
```

#### 7. Undeploy everything with ONE command

```bash
kubectl delete -f artifacts/kafka/ -n data-platform
kubectl delete -f artifacts/secrets/ -n data-platform

helm uninstall data-platform -n data-platform
```

#### Prometheus & Grafana monitoring

```bash
# prometheus dashboard
kubectl port-forward -n kube-prometheus-stack svc/data-platform-kube-prometh-prometheus 9090:9090 -n data-platform

# grafana dashboard
kubectl port-forward -n kube-prometheus-stack svc/data-platform-grafana 8080:80 -n data-platform
```

#### (Optional) Set namespace as default for debug

```bash
kubectl config set-context --current --namespace=data-platform
```

---

## Individual Services

Deploy the services in the following order:

1. **MongoDB** → [`mongo.md`](./mongo.md)
2. **PostgreSQL** → [`postgres.md`](./postgres.md)
3. **MLflow** → [`mlflow.md`](./mlflow.md)
4. **Kafka** → [`kafka.md`](./kafka.md)