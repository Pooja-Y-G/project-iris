$ErrorActionPreference = "Stop"

Write-Host "Starting Project IRIS database..."

docker compose up -d

Write-Host "Waiting for PostgreSQL..."

do {
    Start-Sleep -Seconds 2
    $status = docker inspect --format='{{.State.Health.Status}}' iris-db 2>$null
} while ($status -ne "healthy")

Write-Host "Running migrations..."

Get-ChildItem .\migrations\*.sql |
    Sort-Object Name |
    ForEach-Object {
        Write-Host "Running $($_.Name)"
        Get-Content $_.FullName |
            docker compose exec -T db psql -v ON_ERROR_STOP=1 -U iris -d iris

        if ($LASTEXITCODE -ne 0) {
            throw "Migration failed: $($_.Name)"
        }
    }

Write-Host "Loading fixtures..."

Get-Content .\seeds\seed.sql |
    docker compose exec -T db psql -v ON_ERROR_STOP=1 -U iris -d iris

if ($LASTEXITCODE -ne 0) {
    throw "Fixture loading failed."
}

Write-Host "Running verification..."

Get-Content .\verification\verify.sql |
    docker compose exec -T db psql -v ON_ERROR_STOP=1 -U iris -d iris

if ($LASTEXITCODE -ne 0) {
    throw "Verification failed."
}

Write-Host "Project IRIS database ready."
Write-Host "Running automated tests..."

Get-Content .\tests\test_schema.sql |
    docker compose exec -T db psql -v ON_ERROR_STOP=1 -U iris -d iris

if ($LASTEXITCODE -ne 0) {
    throw "Automated tests failed."
}