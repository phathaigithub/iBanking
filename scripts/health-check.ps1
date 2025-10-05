# Health Check Script for iBanking Services

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   iBanking Health Check                ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan

$services = @(
    @{Name="Eureka Server"; URL="http://localhost:8761"; Port=8761},
    @{Name="API Gateway"; URL="http://localhost:8086"; Port=8086},
    @{Name="User Service"; URL="http://localhost:8081"; Port=8081},
    @{Name="Student Service"; URL="http://localhost:8082"; Port=8082},
    @{Name="Tuition Service"; URL="http://localhost:8083"; Port=8083},
    @{Name="Payment Service"; URL="http://localhost:8084"; Port=8084},
    @{Name="Notification Service"; URL="http://localhost:8085"; Port=8085},
    @{Name="Frontend"; URL="http://localhost"; Port=80}
)

Write-Host "`n🔍 Checking Docker containers..." -ForegroundColor Yellow
$containers = docker-compose ps --format json | ConvertFrom-Json

Write-Host "`n📊 Container Status:" -ForegroundColor Cyan
foreach ($container in $containers) {
    $status = $container.State
    $name = $container.Service
    
    if ($status -eq "running") {
        Write-Host "  ✅ $name : RUNNING" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $name : $status" -ForegroundColor Red
    }
}

Write-Host "`n🌐 Checking HTTP Endpoints..." -ForegroundColor Cyan
foreach ($service in $services) {
    $name = $service.Name
    $url = $service.URL
    
    try {
        $response = Invoke-WebRequest -Uri $url -TimeoutSec 5 -UseBasicParsing -ErrorAction Stop
        Write-Host "  ✅ $name : OK (HTTP $($response.StatusCode))" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ $name : FAILED" -ForegroundColor Red
    }
}

Write-Host "`n🔌 Checking Ports..." -ForegroundColor Cyan
foreach ($service in $services) {
    $name = $service.Name
    $port = $service.Port
    
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue -ErrorAction Stop
        if ($connection.TcpTestSucceeded) {
            Write-Host "  ✅ $name (Port $port) : OPEN" -ForegroundColor Green
        } else {
            Write-Host "  ❌ $name (Port $port) : CLOSED" -ForegroundColor Red
        }
    } catch {
        Write-Host "  ❌ $name (Port $port) : ERROR" -ForegroundColor Red
    }
}

Write-Host "`n🗄️  Checking Database..." -ForegroundColor Cyan
try {
    $mysqlCheck = docker-compose exec -T mysql mysqladmin ping -uroot -proot 2>&1
    if ($mysqlCheck -match "alive") {
        Write-Host "  ✅ MySQL : RUNNING" -ForegroundColor Green
        
        # Check databases
        $databases = docker-compose exec -T mysql mysql -uroot -proot -e "SHOW DATABASES;" 2>&1
        if ($databases -match "user_db" -and $databases -match "student_db" -and $databases -match "tuition_db") {
            Write-Host "  ✅ Databases : INITIALIZED" -ForegroundColor Green
        } else {
            Write-Host "  ⚠️  Databases : MISSING" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  ❌ MySQL : NOT RESPONDING" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ MySQL : ERROR" -ForegroundColor Red
}

Write-Host "`n🔴 Checking Redis..." -ForegroundColor Cyan
try {
    $redisCheck = docker-compose exec -T redis redis-cli ping 2>&1
    if ($redisCheck -match "PONG") {
        Write-Host "  ✅ Redis : RUNNING" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Redis : NOT RESPONDING" -ForegroundColor Red
    }
} catch {
    Write-Host "  ❌ Redis : ERROR" -ForegroundColor Red
}

Write-Host "`n📈 Resource Usage:" -ForegroundColor Cyan
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" | Select-Object -First 10

Write-Host "`n✅ Health check completed!" -ForegroundColor Green
Write-Host "`nPress any key to exit..." -ForegroundColor Yellow
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
