# OpenMetadata server — standalone image

A **single Docker image with only the OpenMetadata server**. It connects to your
**already-deployed PostgreSQL, Elasticsearch/OpenSearch and Airflow** entirely through
**environment variables**. No database, search or Airflow is bundled — you bring those.

This is a thin, transparent wrapper over the official `docker.getcollate.io/openmetadata/server`
image that adds one convenience: the container **runs DB migrations and then starts the server**,
so a single `docker run` is all the team needs.

## Prerequisites (your side)
- A reachable **PostgreSQL** (or MySQL) with the OpenMetadata database created (default `openmetadata_db`) and a user.
- A reachable **Elasticsearch 8.x** (or OpenSearch) endpoint.
- *(optional)* A reachable **Airflow** if you want UI-driven ingestion.

## 1. Configure
```bash
cp .env.example .env
# edit .env -> set DB_HOST / DB_USER / DB_PASSWORD, ELASTICSEARCH_HOST, and (optional) Airflow
```

## 2. Build
```bash
docker build --build-arg OPENMETADATA_VERSION=1.10.0 \
  -t <your-registry>/openmetadata-server:1.10.0 .
```

## 3. Run
```bash
# Plain docker:
docker run --env-file .env -p 8585:8585 -p 8586:8586 \
  <your-registry>/openmetadata-server:1.10.0

# …or via the example compose (builds + runs just the server):
docker compose -f docker-compose.example.yml up -d
```
Open **http://localhost:8585** — default login `admin@open-metadata.org` / `admin`.

## Environment variables (the start parameters)

| Variable | Required | Default | Meaning |
|---|---|---|---|
| `DB_HOST` | ✅ | — | PostgreSQL/MySQL host |
| `DB_PORT` | | `5432` | DB port |
| `DB_USER` | ✅ | — | DB user |
| `DB_PASSWORD` | ✅ | — | DB password (aliased to `DB_USER_PASSWORD` internally) |
| `OM_DATABASE` | | `openmetadata_db` | OpenMetadata database name |
| `DB_SCHEME` / `DB_DRIVER_CLASS` | | postgres | `postgresql`+`org.postgresql.Driver` or `mysql`+`com.mysql.cj.jdbc.Driver` |
| `DB_PARAMS` | | no-SSL | JDBC params; enable SSL for prod |
| `ELASTICSEARCH_HOST` | ✅ | — | Search host |
| `ELASTICSEARCH_PORT` / `ELASTICSEARCH_SCHEME` | | `9200` / `http` | Search port/scheme |
| `SEARCH_TYPE` | | `elasticsearch` | `elasticsearch` or `opensearch` |
| `PIPELINE_SERVICE_CLIENT_ENABLED` | | `true` | set `false` if you have no Airflow |
| `PIPELINE_SERVICE_CLIENT_ENDPOINT` | | — | your Airflow URL |
| `SERVER_HOST_API_URL` | | — | how Airflow calls back to this server |
| `AIRFLOW_USERNAME` / `AIRFLOW_PASSWORD` | | `admin` | Airflow REST creds |
| `OM_MIGRATE_ON_START` | | `true` | run DB migrations on container start |
| `OPENMETADATA_HEAP_OPTS` | | `-Xmx1G -Xms1G` | JVM heap |
| `FERNET_KEY` | | demo key | replace in prod |

Full list with comments: [`.env.example`](.env.example).

## Migrations
By default the container runs `bootstrap/openmetadata-ops.sh migrate` before starting the server.
To manage migrations separately (e.g. one job before a rollout):
```bash
docker run --env-file .env <your-registry>/openmetadata-server:1.10.0 migrate   # run migrations only
# then run the server with OM_MIGRATE_ON_START=false
```

## Notes
- **Version**: pinned to OpenMetadata **1.10.0** via the `OPENMETADATA_VERSION` build arg — bump it to upgrade.
- **DB password**: both `DB_PASSWORD` and OpenMetadata's native `DB_USER_PASSWORD` are accepted.
- **Health**: container healthcheck hits `http://localhost:8586/healthcheck`; the server is healthy ~1–2 min after start.
- The image runs as the non-root `openmetadata` user (uid 1000), same as the official image.
