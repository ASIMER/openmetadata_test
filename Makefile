# OpenMetadata Snowflake pilot — common commands (Linux / WSL / macOS).
# On Windows use:  ./run.ps1 <command>
.DEFAULT_GOAL := help
COMPOSE := docker compose

.PHONY: help up down down-clean ps logs wait token smoke ingest ingest-snowflake ingest-lineage

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## ' $(MAKEFILE_LIST) | awk 'BEGIN{FS=":.*?## "}{printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

up: ## Start the OpenMetadata stack (pull + run, detached)
	$(COMPOSE) up -d

down: ## Stop the stack (keep data)
	$(COMPOSE) down

down-clean: ## Stop the stack AND delete all data volumes
	$(COMPOSE) down -v

ps: ## Show stack status
	$(COMPOSE) ps

logs: ## Tail the server logs
	$(COMPOSE) logs -f openmetadata-server

wait: ## Wait until the server is healthy
	./scripts/wait-for-healthy.sh

token: ## Mint the ingestion-bot JWT into .env
	./scripts/get-ingestion-token.sh

smoke: ## Smoke test: ingest the built-in MySQL (proves the code path)
	./scripts/run-ingestion.sh mysql.yaml

ingest-snowflake: ## Ingest Snowflake metadata
	./scripts/run-ingestion.sh snowflake.yaml

ingest-lineage: ## Ingest Snowflake lineage (run after ingest-snowflake)
	./scripts/run-ingestion.sh snowflake_lineage.yaml

ingest: ## Ingest an arbitrary config:  make ingest CFG=postgres.yaml
	./scripts/run-ingestion.sh $(CFG)
