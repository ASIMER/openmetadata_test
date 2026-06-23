# Copilot instructions — OpenMetadata local stack

Read [`../AGENTS.md`](../AGENTS.md) first — it is the source of truth. Short version:

- This repo is a **minimal local OpenMetadata stack** (Postgres + Elasticsearch + Airflow + server)
  in Docker Compose. No Snowflake, no ingestion-as-code. The same compose later targets EKS via env values.
- **Runtime:** Windows + Docker Desktop, `docker compose` v2. Everything runs in containers.
- **Pinned:** OpenMetadata **1.10.0** (Airflow **2.10.5**), Postgres **16.6**, Elasticsearch **8.11.4**.
  Don't change versions — they match the deployment (see README "Versions").

## Run
```powershell
cp .env.example .env
./run.ps1 up        # or:  docker compose up -d --wait
```
UI http://localhost:8585 (`admin@open-metadata.org` / `admin`).

## Conventions (must follow)
- All settings come from `.env` (DevOps variable names). `.env.example` is committed with working
  local values; `.env` is gitignored. Never hardcode connection values in `docker-compose.yml`.
- Mapping to keep: DevOps `DB_PASSWORD` → OM `DB_USER_PASSWORD` (already wired in the compose).
- `.sh`/`.yaml` = LF, `.ps1` = CRLF.
- Validate changes by running `up` and confirming the server is healthy on :8585. Keep it minimal.
- For EKS, follow `docs/ENVIRONMENT.md`; don't run the local postgres/elasticsearch/ingestion there.
