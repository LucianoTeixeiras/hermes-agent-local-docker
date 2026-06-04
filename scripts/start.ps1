$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)
Set-Location $Root

if (-not (Test-Path ".env")) {
    throw "Missing .env. Run scripts/bootstrap.ps1 first, then set API_SERVER_KEY."
}

docker compose up -d --build
docker compose ps
