#!/usr/bin/env bash
# Wait until the OpenMetadata server answers on its host URL.
# Usage: scripts/wait-for-healthy.sh
set -euo pipefail
cd "$(dirname "$0")/.."
getenv() { grep -E "^$1=" .env 2>/dev/null | head -1 | cut -d= -f2-; }
base="$(getenv OM_HOST_URL)"; base="${base:-http://localhost:8585}"

echo "Waiting for OpenMetadata at $base ..."
for _ in $(seq 1 60); do
  if curl -fsS -o /dev/null "$base/"; then
    echo "OpenMetadata is up: $base"
    exit 0
  fi
  sleep 5
done
echo "Timed out waiting for OpenMetadata at $base" >&2
exit 1
