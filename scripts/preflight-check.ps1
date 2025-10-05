# Pre-flight check before starting Docker deployment

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   iBanking Pre-flight Check            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan

$issues = 0
$warnings = 0

# Check Docker
Write-Host "`n🐳 Checking Docker..." -ForegroundColor Cyan
try {
    $dockerVersion = docker --version
    Write-Host "  ✅ Docker installed: $dockerVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Docker not found!" -ForegroundColor Red
    Write-Host "     Install Docker Desktop from: https://www.docker.com/products/docker-desktop" -ForegroundColor Yellow
    $issues++
}

# Check Docker Compose
Write-Host "`n📦 Checking Docker Compose..." -ForegroundColor Cyan
try {
    $composeVersion = docker-compose --version
    Write-Host "  ✅ Docker Compose installed: $composeVersion" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Docker Compose not found!" -ForegroundColor Red
    $issues++
}

# Check Docker is running
Write-Host "`n🔄 Checking Docker daemon..." -ForegroundColor Cyan
try {
    docker ps | Out-Null
    Write-Host "  ✅ Docker daemon is running" -ForegroundColor Green
} catch {
    Write-Host "  ❌ Docker daemon not running!" -ForegroundColor Red
    Write-Host "     Start Docker Desktop" -ForegroundColor Yellow
    $issues++
}

# Check required files
Write-Host "`n📁 Checking required files..." -ForegroundColor Cyan

$requiredFiles = @(
    "docker-compose.yml",
    ".env.example",
    "init-db.sql",
    "soa-mid-project/eureka-server/Dockerfile",
    "soa-mid-project/api-gateway/Dockerfile",
    "soa-mid-project/user-service/Dockerfile",
    "soa-mid-project/student-service/Dockerfile",
    "soa-mid-project/tuition-service/Dockerfile",
    "soa-mid-project/payment-service/Dockerfile",
    "soa-mid-project/notification-service/Dockerfile",
    "app-fe/Dockerfile"
)

foreach ($file in $requiredFiles) {
    if (Test-Path $file) {
        Write-Host "  ✅ $file" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $file not found!" -ForegroundColor Red
        $issues++
    }
}

# Check .env file
Write-Host "`n⚙️  Checking configuration..." -ForegroundColor Cyan
if (Test-Path ".env") {
    Write-Host "  ✅ .env file exists" -ForegroundColor Green
    
    # Check if email is configured
    $envContent = Get-Content ".env" -Raw
    if ($envContent -match "MAIL_USERNAME=your-email@gmail.com") {
        Write-Host "  ⚠️  Email not configured in .env" -ForegroundColor Yellow
        Write-Host "     Notification service won't work without email config" -ForegroundColor DarkYellow
        $warnings++
    }
} else {
    Write-Host "  ⚠️  .env file not found (will be created)" -ForegroundColor Yellow
    $warnings++
}

# Check available ports
Write-Host "`n🔌 Checking required ports..." -ForegroundColor Cyan

$requiredPorts = @(80, 3307, 6379, 8761, 8081, 8082, 8083, 8084, 8085, 8086)

foreach ($port in $requiredPorts) {
    try {
        $connection = Test-NetConnection -ComputerName localhost -Port $port -WarningAction SilentlyContinue -InformationLevel Quiet -ErrorAction SilentlyContinue
        if ($connection) {
            Write-Host "  ⚠️  Port $port is already in use" -ForegroundColor Yellow
            $warnings++
        } else {
            Write-Host "  ✅ Port $port is available" -ForegroundColor Green
        }
    } catch {
        Write-Host "  ✅ Port $port is available" -ForegroundColor Green
    }
}

# Check disk space
Write-Host "`n💾 Checking disk space..." -ForegroundColor Cyan
$drive = (Get-Location).Drive
$freeSpace = (Get-PSDrive $drive.Name).Free / 1GB

if ($freeSpace -lt 10) {
    Write-Host "  ⚠️  Low disk space: $([math]::Round($freeSpace, 2)) GB available" -ForegroundColor Yellow
    Write-Host "     Recommended: 10GB+ for Docker images and builds" -ForegroundColor DarkYellow
    $warnings++
} else {
    Write-Host "  ✅ Sufficient disk space: $([math]::Round($freeSpace, 2)) GB available" -ForegroundColor Green
}

# Check RAM
Write-Host "`n🧠 Checking available RAM..." -ForegroundColor Cyan
$ram = (Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize / 1MB
$freeRam = (Get-CimInstance Win32_OperatingSystem).FreePhysicalMemory / 1MB

Write-Host "  Total RAM: $([math]::Round($ram, 2)) GB" -ForegroundColor White
Write-Host "  Free RAM: $([math]::Round($freeRam, 2)) GB" -ForegroundColor White

if ($ram -lt 8) {
    Write-Host "  ⚠️  Low total RAM (recommended: 8GB+)" -ForegroundColor Yellow
    $warnings++
} else {
    Write-Host "  ✅ Sufficient RAM" -ForegroundColor Green
}

# Check Java source files exist
Write-Host "`n☕ Checking Java services..." -ForegroundColor Cyan
$services = @("eureka-server", "api-gateway", "user-service", "student-service", "tuition-service", "payment-service", "notification-service")
foreach ($service in $services) {
    $pomFile = "soa-mid-project/$service/pom.xml"
    if (Test-Path $pomFile) {
        Write-Host "  ✅ $service pom.xml found" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $service pom.xml not found!" -ForegroundColor Red
        $issues++
    }
}

# Check Flutter files
Write-Host "`n🎨 Checking Flutter app..." -ForegroundColor Cyan
if (Test-Path "app-fe/pubspec.yaml") {
    Write-Host "  ✅ Flutter pubspec.yaml found" -ForegroundColor Green
} else {
    Write-Host "  ❌ Flutter pubspec.yaml not found!" -ForegroundColor Red
    $issues++
}

# Summary
Write-Host "`n" + ("=" * 50) -ForegroundColor Cyan
Write-Host "📊 Pre-flight Check Summary" -ForegroundColor Cyan
Write-Host ("=" * 50) -ForegroundColor Cyan

if ($issues -eq 0 -and $warnings -eq 0) {
    Write-Host "`n✅ All checks passed! Ready to deploy." -ForegroundColor Green
    Write-Host "`n🚀 Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Review .env file (if needed)" -ForegroundColor White
    Write-Host "  2. Run: .\quick-start.ps1" -ForegroundColor White
} elseif ($issues -eq 0) {
    Write-Host "`n⚠️  $warnings warning(s) found, but you can proceed" -ForegroundColor Yellow
    Write-Host "`n🚀 Next steps:" -ForegroundColor Cyan
    Write-Host "  1. Review warnings above" -ForegroundColor White
    Write-Host "  2. Fix if necessary" -ForegroundColor White
    Write-Host "  3. Run: .\quick-start.ps1" -ForegroundColor White
} else {
    Write-Host "`n❌ $issues critical issue(s) found!" -ForegroundColor Red
    Write-Host "   $warnings warning(s) found" -ForegroundColor Yellow
    Write-Host "`nPlease fix the issues above before deploying." -ForegroundColor Red
}

Write-Host "`n💡 For help, see DOCKER_GUIDE.md or README.md" -ForegroundColor Yellow
