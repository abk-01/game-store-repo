@echo off
setlocal
set PROJECT=%~dp0GameStore.Api\GameStore.Api.csproj
if not exist "%PROJECT%" (
  echo Project not found: %PROJECT%
  exit /b 1
)
if /I "%1"=="--watch" (
  dotnet watch run --project "%PROJECT%"
) else (
  dotnet run --project "%PROJECT%"
)
