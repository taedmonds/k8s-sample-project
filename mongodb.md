# MongoDB Deployment Guide

## 1. Create a Kubernetes Namespace for MongoDB

```bash
kubectl create ns db
```

## 2. Set Up Local Path Storage for MongoDB (for Colima storage)

```bash
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml
kubectl patch storageclass local-path -p '{"metadata":{"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'
```

## 3. Create Replica Set Key for MongoDB

Generate a random 32-byte key for the MongoDB replica set. Then update the content to "mongodb-replica-set-key" in ./mongo/secrets.yaml

```bash
openssl rand -base64 32 > ./mongo/replicaset.key
```

## 4. Add Helm Repository and Update

```bash
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update
```

## 5. Apply MongoDB Secrets

Apply your custom secrets configuration.

```bash
kubectl apply -f ./mongo/secrets.yaml
```

## 6. Install MongoDB Using Helm

Use the Bitnami MongoDB Helm chart to install MongoDB, passing in the custom `values-mongodb.yaml` file.

```bash
helm upgrade --install mongodb bitnami/mongodb \
  -n db \
  -f values-mongodb.yaml
```

## 7. Uninstall MongoDB

If you need to uninstall MongoDB, run:

```bash
helm uninstall mongodb -n db
```

## 8. Port Forward MongoDB to Local Machine

To connect to MongoDB locally, run the following port-forward command:

```bash
kubectl port-forward -n db mongodb-0 27000:27017
```

## 9. Connect to MongoDB

* **Connect as Root User**:

```bash
mongosh "mongodb://root:test123@localhost:27000/?authSource=admin"
```

* **Connect as a MongoUser**:

```bash
mongosh "mongodb://mongouser:test123@localhost:27000/sample_db?authSource=sample_db"
```

* **Connect as ReadOnly User**:

```bash
mongosh "mongodb://readonly:readonly@localhost:27000/sample_db"
```