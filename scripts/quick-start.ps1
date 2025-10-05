# Quick start script for iBanking
# Run this script to quickly start the system

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║     iBanking Quick Start               ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan

# Check if .env exists
if (-not (Test-Path ".env")) {
    Write-Host "`n⚠️  .env file not found!" -ForegroundColor Yellow
    Write-Host "Creating .env from .env.example..." -ForegroundColor Cyan
    Copy-Item .env.example .env
    Write-Host "✅ .env created! Please configure it before continuing." -ForegroundColor Green
    Write-Host "Press any key to open .env file..." -ForegroundColor Yellow
    $null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
    notepad .env
    Write-Host "`nAfter configuring .env, run this script again." -ForegroundColor Yellow
    exit
}

Write-Host "`n📋 Checking Docker..." -ForegroundColor Cyan
try {
    docker --version | Out-Null
    docker-compose --version | Out-Null
    Write-Host "✅ Docker is installed" -ForegroundColor Green
} catch {
    Write-Host "❌ Docker is not installed or not running!" -ForegroundColor Red
    Write-Host "Please install Docker Desktop and try again." -ForegroundColor Yellow
    exit
}

Write-Host "`n🔍 Checking if system is already running..." -ForegroundColor Cyan
$running = docker-compose ps -q
if ($running) {
    Write-Host "⚠️  System is already running!" -ForegroundColor Yellow
    Write-Host "Do you want to restart? (Y/N)" -ForegroundColor Yellow
    $response = Read-Host
    if ($response -eq 'Y' -or $response -eq 'y') {
        Write-Host "`n🔄 Restarting system..." -ForegroundColor Cyan
        docker-compose down
    } else {
        Write-Host "Opening logs..." -ForegroundColor Cyan
        docker-compose logs -f
        exit
    }
}

Write-Host "`n🔨 Building services (this may take 10-15 minutes on first run)..." -ForegroundColor Cyan
docker-compose build

if ($LASTEXITCODE -ne 0) {
    Write-Host "`n❌ Build failed! Please check the errors above." -ForegroundColor Red
    exit
}

Write-Host "`n🚀 Starting services..." -ForegroundColor Cyan
docker-compose up -d

Write-Host "`n⏳ Waiting for services to be ready..." -ForegroundColor Yellow
Start-Sleep -Seconds 30

Write-Host "`n📊 Service Status:" -ForegroundColor Cyan
docker-compose ps

Write-Host "`n✅ System is starting up!" -ForegroundColor Green
Write-Host "`n🌐 Access URLs:" -ForegroundColor Cyan
Write-Host "  Frontend:     http://localhost" -ForegroundColor White
Write-Host "  API Gateway:  http://localhost:8086" -ForegroundColor White
Write-Host "  Eureka:       http://localhost:8761" -ForegroundColor White

Write-Host "`n📝 Useful commands:" -ForegroundColor Yellow
Write-Host "  View logs:           docker-compose logs -f"
Write-Host "  View service logs:   docker-compose logs -f <service-name>"
Write-Host "  Stop system:         docker-compose stop"
Write-Host "  Restart service:     docker-compose restart <service-name>"

Write-Host "`n💡 Tip: Services may take 1-2 minutes to fully start and register with Eureka." -ForegroundColor Yellow
Write-Host "`nDo you want to view logs? (Y/N)" -ForegroundColor Cyan
$viewLogs = Read-Host
if ($viewLogs -eq 'Y' -or $viewLogs -eq 'y') {
    docker-compose logs -f
}
