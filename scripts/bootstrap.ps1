param(
    [switch]$Portal
)

$Script = Join-Path $PSScriptRoot "windows/bootstrap.ps1"
& $Script @PSBoundParameters
