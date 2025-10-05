# Database Backup Script for iBanking
# Tạo backup cho tất cả databases

param(
    [string]$BackupDir = "./backups",
    [switch]$Compress
)

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   iBanking Database Backup             ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan

# Tạo thư mục backup nếu chưa có
if (-not (Test-Path $BackupDir)) {
    New-Item -ItemType Directory -Path $BackupDir | Out-Null
    Write-Host "`n✅ Created backup directory: $BackupDir" -ForegroundColor Green
}

# Tạo timestamp cho backup
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupPath = Join-Path $BackupDir $timestamp

# Tạo thư mục cho backup này
New-Item -ItemType Directory -Path $backupPath | Out-Null

Write-Host "`n📦 Starting backup..." -ForegroundColor Cyan
Write-Host "Backup location: $backupPath" -ForegroundColor Yellow

$databases = @("user_db", "student_db", "tuition_db")
$success = 0
$failed = 0

foreach ($db in $databases) {
    Write-Host "`nBacking up $db..." -ForegroundColor Cyan
    
    $filename = "$db.sql"
    $filepath = Join-Path $backupPath $filename
    
    try {
        # Thực hiện backup
        $cmd = "docker-compose exec -T mysql mysqldump -uroot -proot --databases $db"
        Invoke-Expression $cmd | Out-File -FilePath $filepath -Encoding UTF8
        
        if (Test-Path $filepath) {
            $size = (Get-Item $filepath).Length / 1KB
            Write-Host "  ✅ $db backed up successfully ($([math]::Round($size, 2)) KB)" -ForegroundColor Green
            $success++
            
            # Compress nếu được yêu cầu
            if ($Compress) {
                Write-Host "  🗜️  Compressing..." -ForegroundColor Yellow
                Compress-Archive -Path $filepath -DestinationPath "$filepath.zip" -Force
                Remove-Item $filepath
                Write-Host "  ✅ Compressed" -ForegroundColor Green
            }
        } else {
            Write-Host "  ❌ Backup failed for $db" -ForegroundColor Red
            $failed++
        }
    } catch {
        Write-Host "  ❌ Error backing up $db : $_" -ForegroundColor Red
        $failed++
    }
}

Write-Host "`n📊 Backup Summary:" -ForegroundColor Cyan
Write-Host "  Total: $($databases.Count)" -ForegroundColor White
Write-Host "  Success: $success" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "White" })

if ($success -gt 0) {
    # Tạo file metadata
    $metadata = @{
        Timestamp = $timestamp
        Date = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
        Databases = $databases
        Success = $success
        Failed = $failed
        Compressed = $Compress.IsPresent
    } | ConvertTo-Json

    $metadata | Out-File -FilePath (Join-Path $backupPath "backup-info.json") -Encoding UTF8

    Write-Host "`n✅ Backup completed successfully!" -ForegroundColor Green
    Write-Host "Location: $backupPath" -ForegroundColor Yellow
} else {
    Write-Host "`n❌ Backup failed!" -ForegroundColor Red
}

# Liệt kê các backup cũ
Write-Host "`n📂 Existing backups:" -ForegroundColor Cyan
Get-ChildItem -Path $BackupDir -Directory | Sort-Object Name -Descending | Select-Object -First 5 | ForEach-Object {
    $size = (Get-ChildItem -Path $_.FullName -Recurse | Measure-Object -Property Length -Sum).Sum / 1MB
    Write-Host "  $($_.Name) - $([math]::Round($size, 2)) MB" -ForegroundColor White
}

Write-Host "`n💡 Tip: Use 'backup-db.ps1 -Compress' to create compressed backups" -ForegroundColor Yellow
