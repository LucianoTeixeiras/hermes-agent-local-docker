param(
    [switch]$Portal
)

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent (Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path))
$EnvPath = Join-Path $Root ".env"
$ExamplePath = Join-Path $Root ".env.example"
$DataPath = Join-Path $Root "hermes-data"

if (-not (Test-Path $EnvPath)) {
    Copy-Item $ExamplePath $EnvPath
    Write-Host "Created .env from .env.example. Edit API_SERVER_KEY before starting the gateway."
}

New-Item -ItemType Directory -Force -Path $DataPath | Out-Null

$setupArgs = @("run", "-it", "--rm", "-v", "${DataPath}:/opt/data", "nousresearch/hermes-agent", "setup")
if ($Portal) {
    $setupArgs = @("run", "-it", "--rm", "-v", "${DataPath}:/opt/data", "nousresearch/hermes-agent", "setup", "--portal")
}

docker @setupArgs
