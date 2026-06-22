#!/usr/bin/env bash
# Run a metadata ingestion workflow via the official OpenMetadata ingestion image.
# The container joins the platform's docker network and reads ${VAR} from .env.
# Usage: scripts/run-ingestion.sh <config.yaml>     e.g. snowflake.yaml
set -euo pipefail
cd "$(dirname "$0")/.."

[ $# -ge 1 ] || { echo "Usage: $0 <config.yaml under ingestion/connections/>" >&2; exit 1; }
cfg="$1"
[ -f "ingestion/connections/$cfg" ] || { echo "ERROR: ingestion/connections/$cfg not found" >&2; exit 1; }
[ -f .env ] || { echo "ERROR: .env not found (copy .env.example to .env)" >&2; exit 1; }

getenv() { grep -E "^$1=" .env | head -1 | cut -d= -f2-; }
ver="$(getenv OPENMETADATA_VERSION)"; ver="${ver:-1.13.0}"
net="$(getenv OM_DOCKER_NETWORK)";   net="${net:-openmetadata_app_net}"
tok="$(getenv OM_JWT_TOKEN)"
[ -n "$tok" ] || { echo "ERROR: OM_JWT_TOKEN is empty. Run scripts/get-ingestion-token.sh first." >&2; exit 1; }

echo "Running ingestion: $cfg  (image ingestion:$ver, network $net)"
exec docker run --rm \
  --entrypoint metadata \
  --network "$net" \
  --env-file .env \
  -v "$(pwd)/ingestion/connections:/workflows:ro" \
  "docker.getcollate.io/openmetadata/ingestion:$ver" \
  ingest -c "/workflows/$cfg"
