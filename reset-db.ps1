$ErrorActionPreference = "Stop"

Write-Host "Removing existing Project IRIS database..."

docker compose down -v

Write-Host "Rebuilding from an empty database..."

& .\init-db.ps1

if ($LASTEXITCODE -ne 0) {
    throw "Database rebuild failed."
}