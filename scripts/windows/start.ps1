$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))
Set-Location $Root

if ($Root -match "\\OneDrive\\") {
    Write-Warning "This repository appears to be under OneDrive. For Docker runtime use, prefer a local non-synced clone such as D:\00-agents2ai-agents\hermes-agent-local-docker."
}

if (-not (Test-Path ".env")) {
    throw "Missing .env. Run scripts/windows/bootstrap.ps1 first, then set API_SERVER_KEY."
}

docker compose up -d --build
docker compose ps
