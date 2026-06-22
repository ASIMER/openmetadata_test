# AGENTS.md — instructions for an AI agent continuing this work

> Read this fully before acting. It is written for an autonomous coding agent
> (e.g. GitHub Copilot agent mode / GPT-5.5) that will continue this pilot on a
> **Windows** workstation with **Docker Desktop**. A human teammate (Illia) prototyped
> the scaffold; your job is to finish and run the evaluation.

## 1. Goal (what "done" means)

Deliver the R&D evaluation in [`docs/TICKET.md`](docs/TICKET.md) — *Evaluate OpenMetadata
for Snowflake data cataloging*. Concretely:

1. Stand up OpenMetadata locally (Docker) and keep it healthy.
2. Connect it to the **non-prod Snowflake** account and ingest the agreed pilot scope.
3. Demonstrate: dataset discovery, ownership, schema visibility, and **lineage**.
4. Fill in [`docs/EVALUATION.md`](docs/EVALUATION.md): functional fit, implementation
   effort, security, support model, and a **proceed / defer / reject** recommendation.
5. Produce a short stakeholder readout (append to `docs/EVALUATION.md`).

The eventual target is a **pre-prod instance on AWS ECS** (see ticket). That is a later
step — do **not** attempt ECS until local evaluation is signed off.

## 2. Environment & invariants (do not break these)

- **Runtime:** Windows + Docker Desktop with `docker compose` v2. No Java/Python/Node needed —
  everything runs in containers. Ingestion runs inside `docker.getcollate.io/openmetadata/ingestion`.
- **Pinned version:** OpenMetadata **1.13.0** (image tags in `docker-compose.yml` and
  `OPENMETADATA_VERSION` in `.env` must match). Do not bump versions without a reason.
- **Secrets:** live ONLY in `.env` (gitignored). Never hardcode credentials or JWTs in YAML
  or commit `.env`. Configs reference `${VAR}`; OpenMetadata expands env vars at load time.
- **Line endings:** `.sh`/`.yaml` are LF, `.ps1` is CRLF (enforced by `.gitattributes`).
- **On Windows use `./run.ps1 <cmd>`**; the `Makefile` is the Linux/WSL equivalent. They wrap
  the same scripts under `scripts/`.

## 3. Commands

```powershell
# Windows (PowerShell)               # Linux/WSL equivalent
./run.ps1 up                         # make up          -> start the stack
./run.ps1 wait                       # make wait        -> block until server healthy
./run.ps1 token                      # make token       -> mint ingestion-bot JWT into .env
./run.ps1 smoke                      # make smoke       -> ingest built-in MySQL (no creds; sanity check)
./run.ps1 ingest-snowflake           # make ingest-snowflake
./run.ps1 ingest-lineage             # make ingest-lineage   (run AFTER ingest-snowflake)
./run.ps1 ingest postgres.yaml       # make ingest CFG=postgres.yaml
./run.ps1 logs                       # make logs
./run.ps1 down                       # make down        (keep data)  | down-clean wipes volumes
```

UI: http://localhost:8585 (`admin@open-metadata.org` / `admin`). Airflow: http://localhost:8080 (`admin`/`admin`).

## 4. Step-by-step for this pilot

1. `cp .env.example .env`. Fill `SNOWFLAKE_*`. Prefer **key-pair auth** + a **least-privilege
   read-only role** — the exact Snowflake SQL is in [`docs/sources/snowflake.md`](docs/sources/snowflake.md).
2. `./run.ps1 up` then `./run.ps1 wait`.
3. `./run.ps1 token` (writes `OM_JWT_TOKEN`).
4. `./run.ps1 smoke` — confirm the service `local_mysql_smoke` and its tables appear in the UI
   under *Explore*. This proves the runner + token + REST sink work before touching Snowflake.
5. `./run.ps1 ingest-snowflake`. Watch the run summary (records processed / failures). Verify in
   *Explore* that Snowflake databases → schemas → tables → columns show up.
6. `./run.ps1 ingest-lineage`. Verify lineage appears on a couple of known downstream tables.
7. Document findings in `docs/EVALUATION.md` as you go (screenshots welcome under `docs/`).

## 5. Adding another source

See [`ingestion/README.md`](ingestion/README.md). In short: copy `ingestion/connections/_template.yaml`
to `<source>.yaml`, set `type`/connection fields, add the needed `${VARS}` to `.env`/`.env.example`,
then `./run.ps1 ingest <source>.yaml`. For a source running on the **host** (not Snowflake), use
`host.docker.internal:<port>` as the hostPort.

## 6. Guardrails

- **Do** keep the repo minimal — config, scripts, docs. Don't vendor OpenMetadata source.
- **Do** validate every change by actually running it (`up` → `smoke` → `ingest-snowflake`).
- **Don't** commit `.env`, `*.p8`, `*.pem`, or any token. Check `git status` before committing.
- **Don't** point ingestion at **production** Snowflake — non-prod only (ticket requirement).
- **Don't** silently change pinned versions, ports, or the auth model.
- If blocked on missing Snowflake credentials/permissions, stop and ask the human — that is the
  one thing this scaffold cannot self-provide.

## 7. Repo standard

The target repository name follows the org standard hinted in the ticket thread:
**`GPS.DATALAKE.OPENMETADATA`**. Confirm naming/branch/PR conventions with the team before pushing.
