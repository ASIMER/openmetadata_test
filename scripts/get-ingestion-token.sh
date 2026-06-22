#!/usr/bin/env bash
# Mint the ingestion-bot JWT from a running OpenMetadata server and write it to .env.
# Verified REST flow: admin login -> bots/name/ingestion-bot -> users/token/{id}.
# Usage: scripts/get-ingestion-token.sh
set -euo pipefail
cd "$(dirname "$0")/.."

[ -f .env ] || { echo "ERROR: .env not found. Copy .env.example to .env first." >&2; exit 1; }
getenv() { grep -E "^$1=" .env | head -1 | cut -d= -f2-; }

base="$(getenv OM_HOST_URL)";        base="${base:-http://localhost:8585}"
email="$(getenv OM_ADMIN_EMAIL)";    email="${email:-admin@open-metadata.org}"
password="$(getenv OM_ADMIN_PASSWORD)"; password="${password:-admin}"

b64pwd="$(printf '%s' "$password" | base64)"
echo "Logging in as $email ..."
access="$(curl -fsS -X POST "$base/api/v1/users/login" \
  -H 'Content-Type: application/json' \
  -d "{\"email\":\"$email\",\"password\":\"$b64pwd\"}" \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['accessToken'])")"

botid="$(curl -fsS "$base/api/v1/bots/name/ingestion-bot" \
  -H "Authorization: Bearer $access" \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['botUser']['id'])")"

token="$(curl -fsS "$base/api/v1/users/token/$botid" \
  -H "Authorization: Bearer $access" \
  | python3 -c "import sys,json;print(json.load(sys.stdin)['JWTToken'])")"

[ -n "$token" ] || { echo "ERROR: received empty token" >&2; exit 1; }

if grep -q '^OM_JWT_TOKEN=' .env; then
  tmp="$(mktemp)"
  grep -v '^OM_JWT_TOKEN=' .env > "$tmp"
  printf 'OM_JWT_TOKEN=%s\n' "$token" >> "$tmp"
  mv "$tmp" .env
else
  printf 'OM_JWT_TOKEN=%s\n' "$token" >> .env
fi
echo "OK: ingestion-bot JWT written to .env (OM_JWT_TOKEN)."
