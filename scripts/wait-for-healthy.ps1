# Wait until the OpenMetadata server answers on its host URL.
# Usage:  pwsh scripts/wait-for-healthy.ps1
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

function Get-EnvVar($key) {
    $line = Get-Content .env -ErrorAction SilentlyContinue | Where-Object { $_ -match "^$key=" } | Select-Object -First 1
    if ($line) { return ($line -replace "^$key=", '') } else { return $null }
}
$base = Get-EnvVar 'OM_HOST_URL'; if (-not $base) { $base = 'http://localhost:8585' }

Write-Host "Waiting for OpenMetadata at $base ..."
for ($i = 0; $i -lt 60; $i++) {
    try {
        Invoke-WebRequest -UseBasicParsing -Uri "$base/" -TimeoutSec 5 | Out-Null
        Write-Host "OpenMetadata is up: $base"
        exit 0
    }
    catch { Start-Sleep -Seconds 5 }
}
throw "Timed out waiting for OpenMetadata at $base"
