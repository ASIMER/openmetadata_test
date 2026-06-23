# Architecture

A local OpenMetadata instance is five cooperating containers defined in `docker-compose.yml`
(compose project `openmetadata-local`). Pinned to **OpenMetadata 1.10.0** (Airflow **2.10.5**) and
**PostgreSQL 16.6**.

## Services

| Service | Container | Image | Port(s) | Role |
|---|---|---|---|---|
| `postgresql` | openmetadata_postgresql | `postgres:16.6` | 5432 | System of record — OM metadata + Airflow metadata (two DBs) |
| `elasticsearch` | openmetadata_elasticsearch | `elasticsearch:8.11.4` | 9200 | Search index (discovery / Explore); rebuildable from Postgres |
| `execute-migrate-all` | openmetadata_migrate | `openmetadata/server:1.10.0` | — | One-shot `./bootstrap/openmetadata-ops.sh migrate`, then exits |
| `openmetadata-server` | openmetadata_server | `openmetadata/server:1.10.0` | 8585 / 8586 | REST API **and** the React UI (8585); health on 8586 |
| `ingestion` | openmetadata_ingestion | `openmetadata/ingestion:1.10.0` | 8080 | Apache Airflow 2.10.5 + the OM managed-apis plugin |

All share one bridge network (`app_net`) and resolve each other by service name.

## Startup order (enforced by healthchecks)
```
postgresql (healthy) ─┐
elasticsearch (healthy)┼─▶ execute-migrate-all (runs to completion) ─▶ openmetadata-server (healthy) ─▶ ingestion
```
The server `depends_on` the migration finishing (`service_completed_successfully`) and on Postgres +
Elasticsearch being healthy. `docker compose up -d --wait` blocks until the server is healthy.

## Database
Plain **`postgres:16.6`** (not OpenMetadata's bundled postgres image), so the version matches the
deployment exactly. On first boot, `init/postgres-init.sh` (mounted into
`/docker-entrypoint-initdb.d/`) creates both databases and their owners from env vars:
- `openmetadata_db` owned by `openmetadata_user`
- `airflow_db` owned by `airflow_user`

## Auth
Default **basic** auth (no SSO needed locally). Admin: `admin@open-metadata.org` / `admin`. The OM
server drives Airflow as `admin`/`admin` via the pipeline-service client; Airflow calls back to the
server at `SERVER_HOST_API_URL`.

## Environment-variable contract (local ↔ EKS)
The compose reads everything from env (`.env`), using the **same variable names as the DevOps task
definition**, so a deployment and the local run differ only in values. One bridge: OM internally
expects `DB_USER_PASSWORD`, while DevOps uses `DB_PASSWORD` — so the compose maps
`DB_USER_PASSWORD: ${DB_PASSWORD}`. Full table: [ENVIRONMENT.md](ENVIRONMENT.md).

## On EKS
Point `DB_*` at Aurora, search at the managed instance, and `PIPELINE_SERVICE_CLIENT_ENDPOINT` at the
real Airflow; then run only `openmetadata-server` (plus the one-shot migrate) — the local
`postgresql`, `elasticsearch`, and `ingestion` containers are replaced by managed services.
