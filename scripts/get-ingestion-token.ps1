# Mint the ingestion-bot JWT from a running OpenMetadata server and write it to .env.
# Verified REST flow: admin login -> bots/name/ingestion-bot -> users/token/{id}.
# Usage:  pwsh scripts/get-ingestion-token.ps1   (or PowerShell on Windows)
$ErrorActionPreference = 'Stop'
Set-Location (Join-Path $PSScriptRoot '..')

if (-not (Test-Path .env)) { throw '.env not found. Copy .env.example to .env first.' }

function Get-EnvVar($key) {
    $line = Get-Content .env | Where-Object { $_ -match "^$key=" } | Select-Object -First 1
    if ($line) { return ($line -replace "^$key=", '') } else { return $null }
}

$base  = Get-EnvVar 'OM_HOST_URL';       if (-not $base)  { $base  = 'http://localhost:8585' }
$email = Get-EnvVar 'OM_ADMIN_EMAIL';    if (-not $email) { $email = 'admin@open-metadata.org' }
$pass  = Get-EnvVar 'OM_ADMIN_PASSWORD'; if (-not $pass)  { $pass  = 'admin' }

$b64 = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($pass))
Write-Host "Logging in as $email ..."
$login   = Invoke-RestMethod -Method Post -Uri "$base/api/v1/users/login" -ContentType 'application/json' -Body (@{ email = $email; password = $b64 } | ConvertTo-Json)
$headers = @{ Authorization = "Bearer $($login.accessToken)" }
$bot     = Invoke-RestMethod -Uri "$base/api/v1/bots/name/ingestion-bot" -Headers $headers
$resp    = Invoke-RestMethod -Uri "$base/api/v1/users/token/$($bot.botUser.id)" -Headers $headers
$token   = $resp.JWTToken
if (-not $token) { throw 'Received empty token' }

$lines  = Get-Content .env | Where-Object { $_ -notmatch '^OM_JWT_TOKEN=' }
$lines += "OM_JWT_TOKEN=$token"
Set-Content -Path .env -Value $lines -Encoding ascii
Write-Host 'OK: ingestion-bot JWT written to .env (OM_JWT_TOKEN).'
