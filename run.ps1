param(
    [switch]$Watch
)

$ErrorActionPreference = 'Stop'
$projectDir = Join-Path $PSScriptRoot 'GameStore.Api'
$project = Join-Path $projectDir 'GameStore.Api.csproj'

if (!(Test-Path $project)) {
    Write-Error "Project not found: $project"
}

if ($Watch) {
    Write-Host "Running: dotnet watch run --project $project" -ForegroundColor Cyan
    dotnet watch run --project "$project"
} else {
    Write-Host "Running: dotnet run --project $project" -ForegroundColor Cyan
    dotnet run --project "$project"
}
