# Database Restore Script for iBanking
# Khôi phục database từ backup

param(
    [Parameter(Mandatory=$true)]
    [string]$BackupPath,
    [string[]]$Databases = @("user_db", "student_db", "tuition_db")
)

Write-Host "╔════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║   iBanking Database Restore            ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════╝" -ForegroundColor Cyan

# Kiểm tra backup path
if (-not (Test-Path $BackupPath)) {
    Write-Host "`n❌ Backup path not found: $BackupPath" -ForegroundColor Red
    Write-Host "`n📂 Available backups:" -ForegroundColor Yellow
    Get-ChildItem -Path "./backups" -Directory -ErrorAction SilentlyContinue | Sort-Object Name -Descending | ForEach-Object {
        Write-Host "  $($_.Name)" -ForegroundColor White
    }
    exit
}

Write-Host "`n⚠️  WARNING: This will overwrite existing data!" -ForegroundColor Red
Write-Host "Backup path: $BackupPath" -ForegroundColor Yellow
Write-Host "Databases: $($Databases -join ', ')" -ForegroundColor Yellow
Write-Host "`nContinue? (Y/N)" -ForegroundColor Yellow
$confirm = Read-Host

if ($confirm -ne 'Y' -and $confirm -ne 'y') {
    Write-Host "`n❌ Restore cancelled" -ForegroundColor Yellow
    exit
}

Write-Host "`n🔄 Starting restore..." -ForegroundColor Cyan

$success = 0
$failed = 0

foreach ($db in $Databases) {
    Write-Host "`nRestoring $db..." -ForegroundColor Cyan
    
    $filename = "$db.sql"
    $filepath = Join-Path $BackupPath $filename
    
    # Kiểm tra nếu file bị compress
    if (-not (Test-Path $filepath) -and (Test-Path "$filepath.zip")) {
        Write-Host "  🗜️  Extracting compressed backup..." -ForegroundColor Yellow
        Expand-Archive -Path "$filepath.zip" -DestinationPath $BackupPath -Force
    }
    
    if (Test-Path $filepath) {
        try {
            Write-Host "  📥 Restoring from $filename..." -ForegroundColor Yellow
            
            # Drop và recreate database
            $dropCmd = "docker-compose exec -T mysql mysql -uroot -proot -e `"DROP DATABASE IF EXISTS $db; CREATE DATABASE $db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;`""
            Invoke-Expression $dropCmd | Out-Null
            
            # Restore data
            Get-Content $filepath | docker-compose exec -T mysql mysql -uroot -proot
            
            Write-Host "  ✅ $db restored successfully" -ForegroundColor Green
            $success++
        } catch {
            Write-Host "  ❌ Error restoring $db : $_" -ForegroundColor Red
            $failed++
        }
        
        # Xóa file tạm nếu đã extract
        if (Test-Path "$filepath.zip") {
            Remove-Item $filepath -ErrorAction SilentlyContinue
        }
    } else {
        Write-Host "  ⚠️  Backup file not found: $filename" -ForegroundColor Yellow
        $failed++
    }
}

Write-Host "`n📊 Restore Summary:" -ForegroundColor Cyan
Write-Host "  Total: $($Databases.Count)" -ForegroundColor White
Write-Host "  Success: $success" -ForegroundColor Green
Write-Host "  Failed: $failed" -ForegroundColor $(if ($failed -gt 0) { "Red" } else { "White" })

if ($success -gt 0) {
    Write-Host "`n✅ Restore completed!" -ForegroundColor Green
    Write-Host "💡 Tip: Restart services to ensure they pick up the restored data" -ForegroundColor Yellow
    Write-Host "   docker-compose restart" -ForegroundColor White
} else {
    Write-Host "`n❌ Restore failed!" -ForegroundColor Red
}
