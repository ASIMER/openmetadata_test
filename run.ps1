#!/usr/bin/env pwsh
# OpenMetadata Snowflake pilot — command entrypoint for Windows / PowerShell.
# Usage:  ./run.ps1 <command> [config]
param(
    [Parameter(Position = 0)][string]$Command = 'help',
    [Parameter(Position = 1)][string]$Config = 'snowflake.yaml'
)
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

switch ($Command) {
    'up'    { docker compose up -d }
    'down'  { docker compose down }
    'down-clean' { docker compose down -v }
    'ps'    { docker compose ps }
    'logs'  { docker compose logs -f openmetadata-server }
    'wait'  { ./scripts/wait-for-healthy.ps1 }
    'token' { ./scripts/get-ingestion-token.ps1 }
    'smoke' { ./scripts/run-ingestion.ps1 mysql.yaml }
    'ingest-snowflake' { ./scripts/run-ingestion.ps1 snowflake.yaml }
    'ingest-lineage'   { ./scripts/run-ingestion.ps1 snowflake_lineage.yaml }
    'ingest' { ./scripts/run-ingestion.ps1 $Config }
    default {
        Write-Host 'Usage: ./run.ps1 <command> [config]'
        Write-Host ''
        Write-Host '  up           Start the stack (pull + run, detached)'
        Write-Host '  down         Stop the stack (keep data)'
        Write-Host '  down-clean   Stop the stack AND delete all data volumes'
        Write-Host '  ps           Show stack status'
        Write-Host '  logs         Tail the server logs'
        Write-Host '  wait         Wait until the server is healthy'
        Write-Host '  token        Mint the ingestion-bot JWT into .env'
        Write-Host '  smoke        Ingest the built-in MySQL (proves the code path)'
        Write-Host '  ingest-snowflake   Ingest Snowflake metadata'
        Write-Host '  ingest-lineage     Ingest Snowflake lineage (after metadata)'
        Write-Host '  ingest <cfg> Ingest an arbitrary config, e.g. ./run.ps1 ingest postgres.yaml'
    }
}
