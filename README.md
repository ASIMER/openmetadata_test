# OpenMetadata — Local Docker Compose Stack

Spin up a full **OpenMetadata** instance locally with one command — **PostgreSQL + Elasticsearch +
Airflow + the OM server**, all in Docker Compose. No remote database, no remote Airflow, no cloud
access needed. The same compose is meant to run later on **EKS** by only swapping environment
variables (see [docs/ENVIRONMENT.md](docs/ENVIRONMENT.md)).

## Prerequisites
- **Docker** with the **`docker compose`** v2 plugin. Nothing else (no Java/Python/Node).
- ~6–8 GB RAM free for Docker (two JVMs + Airflow + Postgres).

## Quickstart

### Option 1 — with `make`
```bash
cp .env.example .env       # local-test config (safe defaults, no real secrets)
make up                    # pulls images, starts everything, waits until healthy
```
`make down` stop · `make logs-server` logs · `make ps` status · `make clean` wipe all data.

### Option 2 — plain commands (no `make`)
```bash
cp .env.example .env
docker compose up -d --wait
```
```bash
docker compose down                              # stop (keep data)
docker compose logs -f openmetadata-server       # follow server logs
docker compose ps                                # status
docker compose down -v                           # stop AND delete all data
```

Then open **http://localhost:8585** and log in with **`admin@open-metadata.org`** / **`admin`**.
The Airflow UI is at **http://localhost:8080** (`admin` / `admin`).

> First start takes a few minutes (image pulls + one-shot DB migration). `--wait` blocks until the
> server is healthy. If a port is already in use, change the `*_PORT` values in `.env`.

## What runs

| Container | Image | Port | Role |
|---|---|---|---|
| `openmetadata_server` | `openmetadata/server:1.10.0` | 8585 / 8586 | REST API + Web UI |
| `openmetadata_postgresql` | `postgres:16.6` | 5432 | Metadata DB (OM + Airflow) |
| `openmetadata_elasticsearch` | `elasticsearch:8.11.4` | 9200 | Search / discovery |
| `openmetadata_migrate` | `openmetadata/server:1.10.0` | — | One-shot DB migration, then exits |
| `openmetadata_ingestion` | `openmetadata/ingestion:1.10.0` | 8080 | Airflow 2.10.5 (ingestion) |

Architecture details: [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md). Every connection setting is an
environment variable whose **name mirrors the DevOps deployment** — full reference and what to change
for EKS: [docs/ENVIRONMENT.md](docs/ENVIRONMENT.md).

## Versions — why OpenMetadata 1.10.0 (not 1.13)

The deployment uses **Airflow 2.10.3** and **PostgreSQL 16.6**. OpenMetadata bundles its own Airflow
inside the ingestion image, and that version is fixed per OM release:

| OpenMetadata | Airflow |
|---|---|
| 1.6.0 | 2.9.1 |
| **1.7.0 – 1.10.0** | **2.10.5** |
| 1.11 – 1.12 | 3.1.x |
| 1.13.0 | 3.2.1 |

OM **1.13** ships Airflow **3.2.1** — a different major version with breaking changes — which would
**not** match the deployed 2.10.3. So we pin **OM 1.10.0**, the newest release still on Airflow
**2.10.5** (the same minor as 2.10.3), to keep local behaviour as close to production as possible.
PostgreSQL is pinned to **16.6** exactly. (If you ever need *exactly* Airflow 2.10.3, build a custom
ingestion image `FROM apache/airflow:2.10.3` + `openmetadata-managed-apis` — see [AGENTS.md](AGENTS.md).)

## Going to EKS / production

The stack is portable by design: keep the variable **names**, change their **values** to the managed
services (Aurora Postgres, the real Airflow, managed search) and drop the local `postgresql` /
`elasticsearch` / `ingestion` containers. See the **"TO FILL FOR EKS"** block in `.env.example` and
[docs/ENVIRONMENT.md](docs/ENVIRONMENT.md).
