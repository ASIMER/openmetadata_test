# OpenMetadata local stack — common commands (Linux / WSL / macOS).
# No make? Use the plain commands in README "Quickstart → Option 2", or ./run.ps1 on Windows.
.DEFAULT_GOAL := help
COMPOSE := docker compose

.PHONY: help up down restart ps logs logs-server clean

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-12s\033[0m %s\n", $$1, $$2}'

up: ## Start the whole stack and wait until healthy
	$(COMPOSE) up -d --wait

down: ## Stop the stack (keep data)
	$(COMPOSE) down

restart: ## Restart the stack
	$(COMPOSE) down && $(COMPOSE) up -d --wait

ps: ## Show stack status
	$(COMPOSE) ps

logs: ## Tail all logs
	$(COMPOSE) logs -f

logs-server: ## Tail the OpenMetadata server logs
	$(COMPOSE) logs -f openmetadata-server

clean: ## Stop the stack AND delete all data volumes
	$(COMPOSE) down -v
