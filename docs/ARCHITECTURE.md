# Architecture

A running OpenMetadata instance is a small set of cooperating containers (defined in
`docker-compose.yml`, OpenMetadata **1.13.0**), plus an ingestion runner we start on demand.

## Services (the platform)

| Container | Role | Host port |
|-----------|------|-----------|
| `openmetadata_server` | Java/Dropwizard app — serves **both** the REST API and the React UI | **8585** (API+UI), 8586 (health/metrics) |
| `openmetadata_mysql` | System of record — all metadata, lineage, policies; also the Airflow DB | 3306 |
| `openmetadata_elasticsearch` | Search index powering Explore/discovery (rebuildable from MySQL) | 9200 / 9300 |
| `execute_migrate_all` | One-shot DB migration job; exits on success (server waits for it) | — |
| `openmetadata_ingestion` | Apache Airflow — runs ingestion pipelines created from the **UI** | 8080 |

All containers share one bridge network. With `COMPOSE_PROJECT_NAME=openmetadata` (set in
`.env`) that network is **`openmetadata_app_net`** and services resolve each other by name
(`openmetadata-server`, `mysql`, `elasticsearch`).

## Ingestion runner (the code path)

`scripts/run-ingestion.*` starts a throwaway `docker.getcollate.io/openmetadata/ingestion:1.13.0`
container that:
1. **joins** `openmetadata_app_net`, so it reaches the server at `http://openmetadata-server:8585/api`;
2. gets `.env` injected via `--env-file`, so the YAML's `${VAR}` placeholders resolve;
3. runs `metadata ingest -c /workflows/<config>.yaml`, which connects to the source
   (e.g. Snowflake over the internet), walks its metadata, and pushes entities to the server's
   REST API (`sink: metadata-rest`).

```
                       ┌─────────────────────────── openmetadata_app_net ───────────────────────────┐
   you @ host ──8585──▶│  openmetadata-server ──▶ mysql (3306)                                       │
   browser/API         │        ▲   │  ▲          elasticsearch (9200)                               │
                       │        │   │  └────────── ingestion/Airflow (8080)  ── UI-driven pipelines   │
   run-ingestion ─────▶│  ingestion-runner (metadata ingest) ──▶ server REST  ──▶ MySQL + ES index   │
   (throwaway)         │        │                                                                     │
                       └────────┼─────────────────────────────────────────────────────────────────┘
                                ▼
                          Snowflake (non-prod, over the internet)
```

## Auth

- Server auth provider is **basic** (email/password). Default admin: `admin@open-metadata.org` / `admin`.
- Ingestion authenticates as the **`ingestion-bot`** using a JWT. `scripts/get-ingestion-token.*`
  mints it via REST (admin login → `bots/name/ingestion-bot` → `users/token/{id}`) and writes
  `OM_JWT_TOKEN` into `.env`. The bot token is long-lived; re-mint if it expires.

## Footprint

Two JVMs (server + Elasticsearch) + Airflow + MySQL ⇒ budget **~6–8 GB RAM** for Docker.
Persistent data lives in named/bound volumes (DB + ES index); `down` keeps them, `down-clean`
(`down -v`) deletes them.

## Target deployment (future)

The ticket's end state is a **pre-prod instance on AWS ECS**. The same images and env model port
to ECS task definitions (one service per container, or managed MySQL/OpenSearch). Treat ECS as a
follow-up once the local evaluation is signed off.
