# perfSONAR Archive Helm Chart

This Helm chart deploys a containerized perfSONAR archive stack on Kubernetes, including OpenSearch, Logstash, and OpenSearch Dashboards.

## Prerequisites

- Kubernetes 1.19+
- Helm 3.0+
- A pre-configured StorageClass for PersistentVolume provisioning.
- Docker images for each service (`perfsonar-downloader`, `opensearch-node`, `logstash`, and `opensearch-dashboards`) must be built and available in a container registry accessible by your Kubernetes cluster.

## Installing the Chart

To install the chart with the release name `perfsonar-archive`:

```bash
helm install perfsonar-archive .
```

The command deploys perfSONAR archive on the Kubernetes cluster with the default configuration. The [Parameters](#parameters) section lists the parameters that can be configured during installation.

> **Tip**: List all releases using `helm list`

## Uninstalling the Chart

To uninstall/delete the `perfsonar-archive` deployment:

```bash
helm delete perfsonar-archive
```

The command removes all the Kubernetes components associated with the chart and deletes the release.

## Configuration

The following table lists the configurable parameters of the perfSONAR Archive chart and their default values.

### Global Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `perfsonarVersion` | The version of perfSONAR components to be used by the downloader job. | `5.2.0` |

### Downloader Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `images.repository` | Downloader image repository | `perfsonar/downloader` |
| `images.tag` | Downloader image tag | `5.2.0` |
| `images.pullPolicy` | Downloader image pull policy | `Always` |

### Opensearch Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `images.repository` | OpenSearch image repository | `perfsonar/opensearch-node` |
| `images.tag` | OpenSearch image tag | `5.2.0` |
| `images.pullPolicy` | OpenSearch image pull policy | `Always` |
| `opensearchVersion` | The version of OpenSearch to use | `2.18.0` |
| `initialAdminPassword` | Initial admin password | `"perfSONAR123!"` |
| `persistence.enabled` | Enable persistence for OpenSearch Data using a PersistentVolumeClaim | `true` |
| `persistence.storageClass` | The StorageClass to use for the PersistentVolumeClaim | `standard` |
| `persistence.size` | The size of the PersistentVolumeClaim for OpenSearch data. | `10Gi` |

### Logstash Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `images.repository` | Logstash image repository | `perfsonar/logstash` |
| `images.tag` | Logstash image tag | `5.2.0` |
| `images.pullPolicy` | Logstash image pull policy | `Always` |
| `logstashVersion` | The version of Logstash to use | `8.17.3` |

### Dashboards Parameters

| Parameter | Description | Default |
|-----------|-------------|---------|
| `images.repository` | Dashboards image repository | `perfsonar/opensearch-dashboards` |
| `images.tag` | Dashboards image tag | `5.2.0` |
| `images.pullPolicy` | Dashboards image pull policy | `Always` |
| `opensearchVersion` | The version of OpenSearch-Dashboards to use | `2.18.0` |

## Deployment Process

The chart follows this deployment sequence:

1. **PVC Creation**: Persistent volumes are created for data storage
2. **Downloader Job**: Downloads and prepares perfSONAR components
3. **OpenSearch**: Starts after downloader job completes
4. **Logstash**: Starts after downloader job completes
5. **Dashboards**: Starts after downloader job completes

## Accessing the Application

After deployment:

1. **Get the dashboards URL**:
   ```bash
    export NODE_PORT=$(kubectl get --namespace [NAMESPACE] -o jsonpath="{.spec.ports[0].nodePort}" services perfsonar-archive-opensearch-dashboards)
    export NODE_IP=$(kubectl get nodes --namespace [NAMESPACE] -o jsonpath="{.items[0].status.addresses[0].address}")
    echo http://$NODE_IP:$NODE_PORT
   ```

2. **Get the admin password**:
   ```bash
   kubectl exec -it statefulset/perfsonar-archive-opensearch-node -- grep -w admin /usr/lib/perfsonar/archive/auth_setup.out
   ```

## Troubleshooting

### Check deployment status:
```bash
kubectl get pods -l app.kubernetes.io/instance=perfsonar-archive
```

### View logs:
```bash
# Downloader job logs
kubectl logs job/perfsonar-archive-downloader

# OpenSearch logs
kubectl logs statefulset/perfsonar-archive-opensearch-node

# Logstash logs
kubectl logs deployment/perfsonar-archive-logstash

# Dashboards logs
kubectl logs deployment/perfsonar-archive-opensearch-dashboards
```

### Common Issues

1. **Pods stuck in Pending**: Check if PVCs are bound and nodes have sufficient resources
2. **OpenSearch fails to start**: Verify memory limits and ensure no memory swapping
3. **Services not ready**: Wait for the downloader job to complete first

## License

This chart is licensed under the Apache License 2.0.