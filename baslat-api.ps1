$ErrorActionPreference = "Stop"
$project = Join-Path $PSScriptRoot "ExpenseTracker.Api"
if (-not (Test-Path (Join-Path $project "ExpenseTracker.Api.csproj"))) {
    throw "ExpenseTracker.Api.csproj bulunamadı: $project"
}

Get-Process dotnet -ErrorAction SilentlyContinue | Stop-Process -Force
Start-Sleep -Seconds 1

$env:Database__Provider = "InMemory"
$env:ASPNETCORE_ENVIRONMENT = "Development"
Set-Location $project
Write-Host "API başlıyor: http://localhost:5123  (InMemory)"
dotnet run --launch-profile http -- --Database:Provider=InMemory
