# iBanking Docker Management Scripts
# Sử dụng trong PowerShell

# Script: Build toàn bộ hệ thống
function Build-All {
    Write-Host "🔨 Building all services..." -ForegroundColor Cyan
    docker-compose build
    Write-Host "✅ Build completed!" -ForegroundColor Green
}

# Script: Build một service cụ thể
function Build-Service {
    param([string]$ServiceName)
    Write-Host "🔨 Building $ServiceName..." -ForegroundColor Cyan
    docker-compose build $ServiceName
    Write-Host "✅ Build completed!" -ForegroundColor Green
}

# Script: Khởi động hệ thống
function Start-System {
    Write-Host "🚀 Starting iBanking system..." -ForegroundColor Cyan
    docker-compose up -d
    Write-Host "✅ System started!" -ForegroundColor Green
    Write-Host "📊 Checking service status..." -ForegroundColor Yellow
    Start-Sleep -Seconds 5
    docker-compose ps
}

# Script: Dừng hệ thống
function Stop-System {
    Write-Host "🛑 Stopping iBanking system..." -ForegroundColor Cyan
    docker-compose stop
    Write-Host "✅ System stopped!" -ForegroundColor Green
}

# Script: Restart một service
function Restart-Service {
    param([string]$ServiceName)
    Write-Host "🔄 Restarting $ServiceName..." -ForegroundColor Cyan
    docker-compose restart $ServiceName
    Write-Host "✅ Service restarted!" -ForegroundColor Green
}

# Script: Xem logs
function Show-Logs {
    param(
        [string]$ServiceName = "",
        [int]$Lines = 100
    )
    if ($ServiceName) {
        Write-Host "📜 Showing logs for $ServiceName..." -ForegroundColor Cyan
        docker-compose logs -f --tail=$Lines $ServiceName
    } else {
        Write-Host "📜 Showing logs for all services..." -ForegroundColor Cyan
        docker-compose logs -f --tail=$Lines
    }
}

# Script: Kiểm tra trạng thái
function Check-Status {
    Write-Host "📊 Checking system status..." -ForegroundColor Cyan
    docker-compose ps
    Write-Host "`n🔍 Checking Eureka..." -ForegroundColor Yellow
    try {
        $response = Invoke-WebRequest -Uri "http://localhost:8761" -TimeoutSec 5 -UseBasicParsing
        Write-Host "✅ Eureka is running!" -ForegroundColor Green
    } catch {
        Write-Host "❌ Eureka is not accessible!" -ForegroundColor Red
    }
}

# Script: Reset toàn bộ hệ thống
function Reset-System {
    Write-Host "⚠️  This will delete all data. Are you sure? (Y/N)" -ForegroundColor Yellow
    $confirmation = Read-Host
    if ($confirmation -eq 'Y' -or $confirmation -eq 'y') {
        Write-Host "🗑️  Removing all containers and volumes..." -ForegroundColor Red
        docker-compose down -v
        Write-Host "🔨 Rebuilding..." -ForegroundColor Cyan
        docker-compose build
        Write-Host "🚀 Starting system..." -ForegroundColor Cyan
        docker-compose up -d
        Write-Host "✅ System reset complete!" -ForegroundColor Green
    } else {
        Write-Host "❌ Operation cancelled." -ForegroundColor Yellow
    }
}

# Script: Cleanup
function Clean-System {
    Write-Host "🧹 Cleaning up Docker resources..." -ForegroundColor Cyan
    docker-compose down
    docker system prune -f
    Write-Host "✅ Cleanup completed!" -ForegroundColor Green
}

# Script: Access database
function Connect-Database {
    Write-Host "🗄️  Connecting to MySQL..." -ForegroundColor Cyan
    docker-compose exec mysql mysql -uroot -proot
}

# Script: Hiển thị menu
function Show-Menu {
    Write-Host "`n╔════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║     iBanking Docker Management         ║" -ForegroundColor Cyan
    Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan
    Write-Host "`nAvailable commands:" -ForegroundColor Yellow
    Write-Host "  Build-All                    - Build all services"
    Write-Host "  Build-Service <name>         - Build specific service"
    Write-Host "  Start-System                 - Start all services"
    Write-Host "  Stop-System                  - Stop all services"
    Write-Host "  Restart-Service <name>       - Restart specific service"
    Write-Host "  Show-Logs [name] [lines]     - Show logs"
    Write-Host "  Check-Status                 - Check system status"
    Write-Host "  Reset-System                 - Reset everything"
    Write-Host "  Clean-System                 - Clean up resources"
    Write-Host "  Connect-Database             - Connect to MySQL"
    Write-Host "`nExamples:" -ForegroundColor Yellow
    Write-Host "  Build-Service user-service"
    Write-Host "  Show-Logs student-service 50"
    Write-Host "  Restart-Service api-gateway`n"
}

# Hiển thị menu khi load script
Show-Menu

# Export functions
Export-ModuleMember -Function *
