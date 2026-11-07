# perfSONAR Archive Docker

This project defines a containerized deployment of the perfSONAR archive using Docker Compose. It leverages official GitHub Container Registry (ghcr.io) images.

## 📦  Services Overview

| Service | Description |
|---|---|
| **opensearch-node** | Main OpenSearch container, running with custom configuration and required security setup. |
| **logstash** | Ingests and transforms perfSONAR metrics, sending data to OpenSearch. |
| **opensearch-dashboards** | (Optional) Web-based dashboard frontend for visualizing data in OpenSearch. |
| **perfsonar-grafana** | (Optional) Grafana visualization with preloaded perfSONAR dashboards. |

## 🚀 How to Deploy

The perfsonar-archive stack can be started in different flavors using the provided Makefile:

| Command | Services |
|---|---|
| `make basic` | OpenSearch + Logstash |
| `make dashboards` | Basic + OpenSearch Dashboards |
| `make grafana` | Basic + Grafana |
| `make full` | All services |

Start the desired deployment with `make <flavor>`.

To check running containers, use `make ps`. To follow logs, use `make logs`.

Stop and remove all containers with `make down`. Persistent data stored in Docker volumes is preserved.

## 📊 Accessing OpenSearch Dashboards

Once the containers are up and running, the dashboard UI should be available at:

➡️ **http://localhost:5601**

Use this interface to explore data indexed by Logstash and visualize it through OpenSearch Dashboards.

To log into the dashboard, you'll need the **admin** credentials generated during the archive setup process.

🔐 You can retrieve the **admin** password by running the command below:

`make password`