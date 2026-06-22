# OpenMetadata — Snowflake Cataloging Pilot

Minimal, self-contained setup to stand up **OpenMetadata** and ingest metadata from
**Snowflake**, for the R&D evaluation described in
[`docs/TICKET.md`](docs/TICKET.md) (User Story 7354786).

This repo is **not** a fork of OpenMetadata. It only vendors the official released
`docker-compose.yml` plus thin config/scripts/docs so the pilot is reproducible and
easy to hand off. See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for what runs.

## Prerequisites

- **Docker** with the **`docker compose`** (v2) plugin. Nothing else — no Java, Python, or Node.
- ~6–8 GB RAM free for Docker (two JVMs + Airflow + DB).
- Network access to `docker.getcollate.io` (images) and to your non-prod Snowflake account.

## Quickstart

```bash
# 1. Configure
cp .env.example .env
#    edit .env -> fill SNOWFLAKE_* (see docs/sources/snowflake.md)

# 2. Start the platform (Linux/WSL/macOS: make ; Windows: ./run.ps1)
make up         # or: ./run.ps1 up
make wait       # waits until the server answers

# 3. Mint the ingestion-bot token (writes OM_JWT_TOKEN into .env)
make token      # or: ./run.ps1 token

# 4. (optional) Prove the pipeline works with a zero-credential smoke test
make smoke      # ingests the stack's own built-in MySQL

# 5. Ingest Snowflake
make ingest-snowflake     # metadata: databases, schemas, tables, columns
make ingest-lineage       # lineage from query history (run after metadata)
```

Open the UI at **http://localhost:8585** — default login `admin@open-metadata.org` / `admin`.
Browse **Explore** to see the ingested Snowflake assets; the **Airflow** ingestion UI is at
http://localhost:8080 (`admin` / `admin`).

## Two ways to ingest (both supported)

- **As-code (this repo):** YAML under [`ingestion/connections/`](ingestion/connections/),
  run via `make ingest-*` / `./run.ps1 ingest-*`. Reproducible, versioned, agent-friendly.
- **Via the UI + Airflow:** add a service under *Settings → Services → Databases* and
  deploy/schedule the ingestion pipeline from the UI. Uses the same `ingestion` container.

See [`ingestion/README.md`](ingestion/README.md) for the recipe to add a new source.

## Repo map

| Path | What |
|------|------|
| `docker-compose.yml` | The platform (MySQL, Elasticsearch, server/UI :8585, Airflow :8080) — OM **1.13.0** |
| `.env.example` | All config & secrets (copy to `.env`; gitignored) |
| `ingestion/connections/` | One YAML per source — `snowflake.yaml`, `snowflake_lineage.yaml`, `mysql.yaml` (smoke), `_template.yaml` |
| `scripts/` | `get-ingestion-token`, `run-ingestion`, `wait-for-healthy` (`.sh` + `.ps1`) |
| `Makefile` / `run.ps1` | Command entrypoints (Linux/WSL vs Windows) |
| `docs/` | `TICKET.md`, `ARCHITECTURE.md`, `EVALUATION.md`, `sources/snowflake.md` |
| `AGENTS.md` | Instructions for an AI agent continuing this work |

## Security note

`.env` holds Snowflake credentials and the OpenMetadata JWT — it is **gitignored; never commit it**.
Prefer **key-pair auth** and a **least-privilege read-only role** for Snowflake — see
[`docs/sources/snowflake.md`](docs/sources/snowflake.md).
