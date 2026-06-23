#!/usr/bin/env pwsh
# OpenMetadata local stack — command entrypoint for Windows / PowerShell.
# Usage:  ./run.ps1 <command>
param([Parameter(Position = 0)][string]$Command = 'help')
$ErrorActionPreference = 'Stop'
Set-Location $PSScriptRoot

switch ($Command) {
    'up'          { docker compose up -d --wait }
    'down'        { docker compose down }
    'restart'     { docker compose down; docker compose up -d --wait }
    'ps'          { docker compose ps }
    'logs'        { docker compose logs -f }
    'logs-server' { docker compose logs -f openmetadata-server }
    'clean'       { docker compose down -v }
    default {
        Write-Host 'Usage: ./run.ps1 <command>'
        Write-Host '  up           Start the whole stack and wait until healthy'
        Write-Host '  down         Stop the stack (keep data)'
        Write-Host '  restart      Restart the stack'
        Write-Host '  ps           Show stack status'
        Write-Host '  logs         Tail all logs'
        Write-Host '  logs-server  Tail the OpenMetadata server logs'
        Write-Host '  clean        Stop the stack AND delete all data volumes'
    }
}
