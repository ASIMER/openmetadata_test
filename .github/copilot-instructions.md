# Copilot instructions — OpenMetadata Snowflake pilot

This repo stands up OpenMetadata (Docker) and ingests **Snowflake** metadata for an R&D
evaluation. **Read [`../AGENTS.md`](../AGENTS.md) first** — it is the source of truth. This file
is the short version for GitHub Copilot agent mode.

## Context
- Goal & acceptance criteria: `docs/TICKET.md` (User Story 7354786) and `docs/EVALUATION.md`.
- Architecture (what runs, ports): `docs/ARCHITECTURE.md`.
- Runtime: **Windows + Docker Desktop**, `docker compose` v2. No Java/Python/Node — all in containers.
- OpenMetadata is pinned to **1.13.0**.

## How to run (Windows)
```powershell
./run.ps1 up ; ./run.ps1 wait ; ./run.ps1 token
./run.ps1 smoke                 # zero-credential sanity check (built-in MySQL)
./run.ps1 ingest-snowflake ; ./run.ps1 ingest-lineage
```
UI: http://localhost:8585 (`admin@open-metadata.org` / `admin`).

## Conventions (must follow)
- **Secrets only in `.env`** (gitignored). YAML configs reference `${VAR}`; never hardcode
  credentials or JWT tokens, never commit `.env`, `*.p8`, or `*.pem`.
- New data source = copy `ingestion/connections/_template.yaml`, add `${VARS}` to `.env.example`,
  run `./run.ps1 ingest <file>.yaml`. Host databases use `host.docker.internal:<port>`.
- `.sh`/`.yaml` = LF, `.ps1` = CRLF (`.gitattributes` enforces this).
- Keep the repo minimal (config + scripts + docs). Do not vendor OpenMetadata source code.
- Validate changes by actually running `up` → `smoke` → `ingest-snowflake`; don't claim success
  without a green run. Non-prod Snowflake only.
- If Snowflake credentials/permissions are missing, stop and ask the human.
