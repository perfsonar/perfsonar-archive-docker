COMPOSE := docker compose

.PHONY: basic dashboards grafana full down logs ps

# Mandatory services only
basic:
	$(COMPOSE) up -d

# Mandatory services + OpenSearch Dashboards
dashboards:
	$(COMPOSE) --profile dashboards up -d

# Mandatory services + Grafana
grafana:
	$(COMPOSE) --profile grafana up -d

# All services
full:
	$(COMPOSE) --profile dashboards --profile grafana up -d

# Stop and remove containers (preserve named volumes)
down:
	$(COMPOSE) --profile dashboards --profile grafana down

# Useful management commands
logs:
	$(COMPOSE) logs -f

ps:
	$(COMPOSE) ps