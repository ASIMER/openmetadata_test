# AGENTS.md — instructions for an AI agent working on this repo

> Written for an autonomous coding agent (e.g. GitHub Copilot agent mode / GPT-5.5) continuing this
> work on a **Windows** workstation with **Docker Desktop**.

## Goal
A **minimal, reproducible local OpenMetadata stack** in Docker Compose — Postgres + Elasticsearch +
Airflow + the OM server — that comes up with one command and has **no external dependencies**. The
same compose targets **EKS** later by swapping env values (no remote DB/Airflow needed to run locally).

## Invariants (do not break)
- **Runtime:** Windows + Docker Desktop, `docker compose` v2. No Java/Python/Node — everything is containers.
- **Pinned versions:** OpenMetadata **1.10.0** (⇒ Airflow **2.10.5**), PostgreSQL **16.6**,
  Elasticsearch **8.11.4**. Don't bump them without reason — they match the deployment (README "Versions").
- **No Snowflake, no ingestion-as-code.** This repo is just the platform. Keep it minimal.
- **Config = env.** All settings come from `.env` (copied from `.env.example`), using the **DevOps
  variable names**. `.env.example` holds working local values and **is committed** (local-only, safe);
  `.env` is gitignored. Never hardcode connection values in the compose.
- The one mapping to remember: DevOps `DB_PASSWORD` → OM's `DB_USER_PASSWORD` (done in the compose).
- **Line endings:** `.sh`/`.yaml` = LF, `.ps1` = CRLF (`.gitattributes`).

## Commands
```
# Windows               # Linux/WSL/macOS      # raw (no make)
./run.ps1 up            make up                docker compose up -d --wait
./run.ps1 down          make down              docker compose down
./run.ps1 logs-server   make logs-server       docker compose logs -f openmetadata-server
./run.ps1 ps            make ps                docker compose ps
./run.ps1 clean         make clean             docker compose down -v
```
UI http://localhost:8585 (`admin@open-metadata.org` / `admin`); Airflow http://localhost:8080 (`admin`/`admin`).

## Repo map
- `docker-compose.yml` — the stack (5 services); `init/postgres-init.sh` creates the DBs/users.
- `.env.example` — all config + per-var comments + the "TO FILL FOR EKS" block.
- `docs/ARCHITECTURE.md`, `docs/ENVIRONMENT.md` — how it fits together / every env var.
- `Makefile` + `run.ps1` — the same handful of commands per OS.

## Working rules
- **Validate every change by running it**: `up` → server healthy at :8585 → `down`. Don't claim
  success without a green run.
- Keep it minimal: config + a thin compose + docs. Don't vendor OpenMetadata source or add services
  that aren't needed to bring the stack up.
- If a port is busy locally, change `*_PORT` in `.env` (don't edit the compose).
- For EKS: follow the checklist in `docs/ENVIRONMENT.md` — swap values, drop the local
  `postgresql` / `elasticsearch` / `ingestion` services.
- Need *exactly* Airflow 2.10.3 (not 2.10.5)? Build a custom ingestion image
  `FROM apache/airflow:2.10.3` + `pip install "openmetadata-managed-apis" "openmetadata-ingestion"`
  pinned to the OM version, and point the `ingestion` service at it. Separate task — ask first.
