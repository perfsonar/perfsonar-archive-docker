# perfSONAR Archive Docker

This project provides a containerized deployment of the perfSONAR archive using Docker Compose and official GitHub Container Registry (`ghcr.io`) images.

The deployment includes an Apache reverse proxy by default, providing a single entry point to access the archive services. An alternative configuration is also available for users who prefer to expose each service individually.

## 📦 Services Overview

| Service | Description |
|---|---|
| **opensearch-node** | Main OpenSearch container, running with custom configuration and required security setup. |
| **perfsonar-logstash** | Ingests and transforms perfSONAR metrics, sending data to OpenSearch. |
| **opensearch-dashboards** | (Optional) Web-based dashboard frontend for visualizing data in OpenSearch. |
| **perfsonar-grafana** | (Optional) Grafana visualization with preloaded perfSONAR dashboards. |
| **apache-proxy** | (Default) Apache reverse proxy providing centralized access to the archive services and handling Logstash authentication. |

## 🚀 How to Deploy

The perfSONAR archive can be deployed in different flavors using the provided Makefile.

### Default deployment (with Apache proxy)

Apache reverse proxy is enabled by default. Only port 80 is exposed to the host, providing access to the archive services through a single entry point.

| Command | Services |
|---|---|
| `make basic` | OpenSearch + Logstash + Apache |
| `make dashboards` | Basic + OpenSearch Dashboards |
| `make grafana` | Basic + Grafana |
| `make full` | All services |

Start the desired deployment with `make <flavor>`.

### Direct deployment (without Apache proxy)

Alternatively, the archive can run without the Apache proxy, exposing each service individually. This option is useful when deploying the archive behind an existing reverse proxy or when direct service access is preferred.

| Command | Services |
|---|---|
| `make up-direct` | OpenSearch + Logstash |
 
For optional services, use Docker Compose profiles:

```bash
# Basic + OpenSearch Dashboards
docker compose -f compose.yaml -f compose.direct.yaml --profile dashboards up -d

# Basic + Grafana
docker compose -f compose.yaml -f compose.direct.yaml --profile grafana up -d

# All services
docker compose -f compose.yaml -f compose.direct.yaml --profile dashboards --profile grafana up -d
```

### Managing the deployment

To check running containers, use:

```bash
make ps
```

To follow logs:

```bash
make logs
```

Stop and remove containers with:

```bash
make down
```

For direct deployments, use:

```bash
make down-direct
```

Persistent data stored in Docker volumes is preserved when containers are removed.

## 🌐 Accessing the Services

### With Apache proxy (default)

When using the default deployment, services are accessed through the Apache reverse proxy:

| Service | URL |
|---|---|
| OpenSearch API | `http://localhost/opensearch` |
| OpenSearch Dashboards | `http://localhost/opensearchdash` |
| Logstash | `http://localhost/logstash` |
| Grafana | `http://localhost/grafana` |

Logstash access requires HTTP Basic Authentication. The proxy credentials are generated automatically when the Apache container starts and are persisted in the `perfsonar-config` Docker volume.

### Without Apache proxy

When using the direct deployment, each service is accessible through its own published port:

| Service | URL |
|---|---|
| OpenSearch API | `https://localhost:9200` |
| OpenSearch Performance Analyzer | `http://localhost:9600` |
| Logstash | `http://localhost:11283` |
| OpenSearch Dashboards | `http://localhost:5601` |
| Grafana | `http://localhost:3000/grafana/` |

OpenSearch uses HTTPS and may require certificate verification to be disabled when using its default self-signed certificate.

## 🔐 OpenSearch Credentials

To log into OpenSearch Dashboards or access the OpenSearch API, you'll need the **admin** credentials generated during the archive setup process.

You can retrieve the admin password by running:

```bash
make password
```

## 📁 Docker Compose Configuration

The deployment uses separate Compose files to keep service definitions independent of the chosen access method:

| File | Description |
|---|---|
| `compose.yaml` | Defines the common archive services, networks, volumes, and configurations. |
| `compose.proxy.yaml` | Adds the Apache reverse proxy. Used by default. |
| `compose.direct.yaml` | Publishes individual service ports instead of using Apache. |

Optional services are enabled through Docker Compose profiles:

- `dashboards`: enables OpenSearch Dashboards.
- `grafana`: enables Grafana.

This approach avoids duplicating service configurations and makes it easier to maintain both deployment options.