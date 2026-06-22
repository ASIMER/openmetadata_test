# Ingestion configs

One YAML per source. Secrets come from the environment (`${VAR}` from `.env`) — OpenMetadata
expands env vars when it loads the file, so nothing here is a secret.

| File | Purpose |
|------|---------|
| `connections/snowflake.yaml` | **Primary** — Snowflake metadata (databases, schemas, tables, columns) |
| `connections/snowflake_lineage.yaml` | Snowflake lineage from query history (run after metadata) |
| `connections/mysql.yaml` | Smoke test against the stack's built-in MySQL (no external creds) |
| `connections/_template.yaml` | Starting point for a new source |

## Run a config
```bash
make ingest CFG=snowflake.yaml          # Linux/WSL
./run.ps1 ingest snowflake.yaml         # Windows
```
This runs `metadata ingest -c /workflows/<file>` inside the official `ingestion:1.13.0` image,
attached to the platform network (`openmetadata_app_net`).

## Add a new source (recipe)
1. **Pick the connector** from the catalog: https://docs.open-metadata.org/latest/connectors
2. `cp connections/_template.yaml connections/<source>.yaml`.
3. Set `source.type` (lowercase id, e.g. `postgres`) and `serviceConnection.config.type`
   (PascalCase, e.g. `Postgres`), plus the connector's connection fields.
4. Reference secrets as `${MY_VAR}` and add them to **both** `.env` and `.env.example`
   (example with empty value + a comment).
5. Connection target:
   - SaaS/remote (Snowflake, BigQuery): use its hostname/account directly.
   - A DB on **your host machine**: use `host.docker.internal:<port>` (Docker Desktop).
   - A DB in **this compose**: use the service name (e.g. `mysql:3306`).
6. `sourceConfig.config.type`: `DatabaseMetadata` for databases (`DashboardMetadata`,
   `PipelineMetadata`, `MessagingMetadata` for other asset kinds).
7. Run it (see above) and verify in the UI under *Explore*.

## Notes
- Keep `sink: metadata-rest` and the `workflowConfig` block as-is — they target the local server
  and authenticate with `${OM_JWT_TOKEN}` (minted by `scripts/get-ingestion-token.*`).
- The pip extra for local installs usually equals the `type` (`openmetadata-ingestion[postgres]`),
  but you don't need it here — ingestion runs in the prebuilt image.
- Prefer the **as-code** path (these YAMLs) for reproducibility; the **UI + Airflow** path
  (Settings → Services) is also available and uses the same `ingestion` container.
