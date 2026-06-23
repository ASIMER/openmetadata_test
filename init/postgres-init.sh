#!/bin/bash
# Runs ONCE on first PostgreSQL startup (empty data dir), as the superuser.
# Creates the OpenMetadata + Airflow databases and their owners from env vars
# (passed by the postgresql service in docker-compose.yml). Replaces OpenMetadata's
# bundled postgres image so we can pin a plain postgres:16.6.
set -euo pipefail

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname postgres <<EOSQL
CREATE USER ${DB_USER} WITH PASSWORD '${DB_PASSWORD}';
CREATE DATABASE ${OM_DATABASE} OWNER ${DB_USER};

CREATE USER ${AIRFLOW_DB_USER} WITH PASSWORD '${AIRFLOW_DB_PASSWORD}';
CREATE DATABASE ${AIRFLOW_DB} OWNER ${AIRFLOW_DB_USER};
ALTER USER ${AIRFLOW_DB_USER} SET search_path = public;
EOSQL

echo "[postgres-init] created ${OM_DATABASE} (owner ${DB_USER}) and ${AIRFLOW_DB} (owner ${AIRFLOW_DB_USER})"
