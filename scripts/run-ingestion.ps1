# Run a metadata ingestion workflow via the official OpenMetadata ingestion image.
# Usage:  pwsh scripts/run-ingestion.ps1 snowflake.yaml
param([Parameter(Mandatory = $true)][string]$Config)
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

if (-not (Test-Path "ingestion/connections/$Config")) { throw "ingestion/connections/$Config not found" }
if (-not (Test-Path .env)) { throw '.env not found (copy .env.example to .env)' }

function Get-EnvVar($key) {
    $line = Get-Content .env | Where-Object { $_ -match "^$key=" } | Select-Object -First 1
    if ($line) { return ($line -replace "^$key=", '') } else { return $null }
}
$ver = Get-EnvVar 'OPENMETADATA_VERSION'; if (-not $ver) { $ver = '1.13.0' }
$net = Get-EnvVar 'OM_DOCKER_NETWORK';    if (-not $net) { $net = 'openmetadata_app_net' }
$tok = Get-EnvVar 'OM_JWT_TOKEN'
if (-not $tok) { throw 'OM_JWT_TOKEN is empty. Run scripts/get-ingestion-token.ps1 first.' }

Write-Host "Running ingestion: $Config (image ingestion:$ver, network $net)"
docker run --rm `
    --entrypoint metadata `
    --network $net `
    --env-file .env `
    -v "${PWD}/ingestion/connections:/workflows:ro" `
    "docker.getcollate.io/openmetadata/ingestion:$ver" `
    ingest -c "/workflows/$Config"
if ($LASTEXITCODE -ne 0) { throw "ingestion failed (exit $LASTEXITCODE)" }
