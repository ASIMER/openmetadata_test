#!/usr/bin/env bash
# Entrypoint for the standalone OpenMetadata server image.
#
#   (default) server  -> optional DB migrations, then start the server (foreground)
#             migrate -> run DB migrations only, then exit
#             <other> -> exec the given command as-is
set -euo pipefail
cd /opt/openmetadata

# Convenience: accept DB_PASSWORD as an alias for OpenMetadata's native DB_USER_PASSWORD,
# so teams already using DB_PASSWORD (e.g. from a secrets manager) don't have to rename it.
if [ -z "${DB_USER_PASSWORD:-}" ] && [ -n "${DB_PASSWORD:-}" ]; then
  export DB_USER_PASSWORD="${DB_PASSWORD}"
fi

case "${1:-server}" in
  server)
    if [ "${OM_MIGRATE_ON_START:-true}" = "true" ]; then
      echo "[entrypoint] OM_MIGRATE_ON_START=true -> running database migrations..."
      ./bootstrap/openmetadata-ops.sh migrate
    fi
    echo "[entrypoint] starting OpenMetadata server (UI/API on :8585, health on :8586)..."
    exec ./bin/openmetadata-server-start.sh ./conf/openmetadata.yaml
    ;;
  migrate)
    echo "[entrypoint] running database migrations only..."
    exec ./bootstrap/openmetadata-ops.sh migrate
    ;;
  *)
    exec "$@"
    ;;
esac
