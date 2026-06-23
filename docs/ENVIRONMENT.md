# Environment variables

All configuration lives in `.env` (copy from `.env.example`). Variable **names mirror the DevOps
task definition**, so local and EKS differ only in values. `docker compose` reads `.env` automatically.

## Versions
| Var | Meaning | Local |
|---|---|---|
| `OPENMETADATA_VERSION` | OM server + ingestion image tag (1.10.0 ⇒ Airflow 2.10.5) | `1.10.0` |
| `POSTGRES_VERSION` | Postgres image tag | `16.6` |
| `ELASTICSEARCH_VERSION` | Elasticsearch image tag | `8.11.4` |

## Host ports
| Var | Service | Local |
|---|---|---|
| `OM_SERVER_PORT` | OM UI + API | `8585` |
| `OM_ADMIN_PORT` | OM health/metrics | `8586` |
| `POSTGRES_PORT` | Postgres | `5432` |
| `ES_PORT` | Elasticsearch | `9200` |
| `AIRFLOW_PORT` | Airflow UI | `8080` |

## OpenMetadata → database (DevOps names)
| Var | Meaning | Local | Change for EKS |
|---|---|---|---|
| `DB_DRIVER_CLASS` | JDBC driver | `org.postgresql.Driver` | — |
| `DB_SCHEME` | JDBC scheme | `postgresql` | — |
| `DB_HOST` | DB host | `postgresql` | **Aurora endpoint** |
| `DB_PORT` | DB port | `5432` | Aurora port |
| `DB_USER` | OM DB user | `openmetadata_user` | **from Secrets Manager** |
| `DB_PASSWORD` | OM DB password (compose maps → OM's `DB_USER_PASSWORD`) | `openmetadata_password` | **from Secrets Manager** |
| `OM_DATABASE` | OM database name | `openmetadata_db` | — |
| `DB_PARAMS` | extra JDBC params | `…useSSL=false…` | enable SSL |
| `ENVIRONMENT` | DevOps env code (informational) | `local` | env code |

> `POSTGRES_SUPERUSER` / `POSTGRES_SUPERUSER_PASSWORD` exist only for the local container's init
> (creating the DBs/users). No equivalent on EKS — Aurora is managed.

## Search (local Elasticsearch — DevOps has no managed search yet)
| Var | Meaning | Local | Change for EKS |
|---|---|---|---|
| `SEARCH_TYPE` | `elasticsearch` or `opensearch` | `elasticsearch` | per managed service |
| `ELASTICSEARCH_HOST` / `_PORT` / `_SCHEME` | search endpoint | `elasticsearch` / `9200` / `http` | **managed search endpoint** |

## Airflow / ingestion (DevOps will use a separate instance)
| Var | Meaning | Local | Change for EKS |
|---|---|---|---|
| `PIPELINE_SERVICE_CLIENT_ENDPOINT` | Airflow URL the server drives | `http://ingestion:8080` | **real Airflow URL** |
| `SERVER_HOST_API_URL` | how Airflow calls back to OM | `http://openmetadata-server:8585/api` | OM service URL |
| `AIRFLOW_USERNAME` / `AIRFLOW_PASSWORD` | Airflow REST creds | `admin` / `admin` | **real creds** |
| `AIRFLOW_DB_HOST/_PORT/_DB/_USER/_PASSWORD/_SCHEME` | Airflow's own metadata DB | local Postgres | managed / drop |
| `FERNET_KEY` | Airflow secret encryption | demo key | **generate a real key** |

## OM server tuning
| Var | Meaning | Local |
|---|---|---|
| `OPENMETADATA_CLUSTER_NAME` | cluster name | `openmetadata` |
| `OPENMETADATA_HEAP_OPTS` | JVM heap | `-Xmx1G -Xms1G` |

## EKS checklist
1. Set `DB_HOST` / `DB_PORT` / `DB_USER` / `DB_PASSWORD` from the Aurora secret; enable SSL in `DB_PARAMS`.
2. Set `SEARCH_TYPE` + `ELASTICSEARCH_*` (or OpenSearch) to the managed search.
3. Set `PIPELINE_SERVICE_CLIENT_ENDPOINT` + `AIRFLOW_*` to the real Airflow instance.
4. Generate a real `FERNET_KEY`.
5. Run only `openmetadata-server` (+ the one-shot migrate); drop the local `postgresql`,
   `elasticsearch`, and `ingestion` services.
