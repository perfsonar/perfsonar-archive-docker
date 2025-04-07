# perfSONAR Archive Docker

This project defines a containerized deployment of the perfSONAR archive using Docker Compose. It includes:

- A one-time downloader for perfSONAR components

- OpenSearch node for data storage and search

- Logstash for data processing

- OpenSearch Dashboards for visualization

## 📦  Services Overview

### perfsonar-downloader

This container is responsible for preparing the installation environment for other components. It runs only once, clones the perfSONAR Git repositories at the specified **PERFSONAR_VERSION** and makes them available for subsequent containers.

### opensearch-node

Main OpenSearch container, running with custom configuration and required security setup.

### logstash

Ingests and transforms perfSONAR metrics, sending data to OpenSearch.

### opensearch-dashboards

Web-based dashboard frontend for visualizing data in OpenSearch.

### Custom Entrypoints and perfSONAR Scripts

Each container (**opensearch-node**, **logstash**, **opensearch-dashboards**) is built with a custom image that includes a custom entrypoint script. On the first run, the entrypoint executes perfSONAR setup scripts stored in the shared volume.

## 🚀 How to Deploy

### 1. Clone the repository

```bash
git clone https://github.com/DanielNeto/perfsonar-archive-docker.git
cd perfsonar-archive-docker
```

### 2. Set environment variables

```env
OPENSEARCH_VERSION=2.18.0
LOGSTASH_VERSION=8.11.0
PERFSONAR_VERSION=5.2.0
```

### 3. Build and run the stack

```bash
docker compose up --build
```

The first time you run, the perfsonar-downloader will populate the shared volumes. After that, the OpenSearch stack will start using those resources.


## 🧼 Tear Down

To stop and remove containers:

```bash
docker compose down
```

To remove all volumes (⚠️ includes data loss):

```bash
docker compose down -v
```