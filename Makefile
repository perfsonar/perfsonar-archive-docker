COMPOSE = docker compose

# Default: Apache reverse proxy
COMPOSE_FILES = -f compose.yaml -f compose.proxy.yaml

.PHONY: build basic dashboards grafana full
.PHONY: up-direct down-direct
.PHONY: down logs ps config password

# Build Apache reverse proxy image
build:
	$(COMPOSE) $(COMPOSE_FILES) build

# Opensearch + Logstash + Apache reverse proxy (no dashboards or grafana)
basic:
	$(COMPOSE) $(COMPOSE_FILES) up -d

# Basic services + OpenSearch Dashboards
dashboards:
	$(COMPOSE) $(COMPOSE_FILES) --profile dashboards up -d

# Basic services + Grafana
grafana:
	$(COMPOSE) $(COMPOSE_FILES) --profile grafana up -d

# All services
full:
	$(COMPOSE) $(COMPOSE_FILES) --profile dashboards --profile grafana up -d

# Stop and remove containers (preserve named volumes)
down:
	$(COMPOSE) $(COMPOSE_FILES) --profile dashboards --profile grafana down

# Useful management commands
logs:
	$(COMPOSE) $(COMPOSE_FILES) logs -f

ps:
	$(COMPOSE) $(COMPOSE_FILES) ps

config:
	$(COMPOSE) $(COMPOSE_FILES) config

password:
	$(COMPOSE) $(COMPOSE_FILES) exec opensearch-node sh -c "grep -w admin /etc/perfsonar/opensearch/auth_setup.out | awk '{print \$$2}'"

# Deployment without proxy
up-direct:
	$(COMPOSE) -f compose.yaml -f compose.direct.yaml up -d

down-direct:
	$(COMPOSE) -f compose.yaml -f compose.direct.yaml down