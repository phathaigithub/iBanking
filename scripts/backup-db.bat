@echo off
REM Backup Database Script for iBanking
REM Windows Batch version

setlocal enabledelayedexpansion

echo.
echo ========================================
echo    iBanking Database Backup
echo ========================================
echo.

REM Set backup directory
set BACKUP_DIR=backups
if not exist "%BACKUP_DIR%" (
    mkdir "%BACKUP_DIR%"
    echo [SUCCESS] Created backup directory: %BACKUP_DIR%
)

REM Create timestamp for backup
for /f "tokens=2 delims==" %%I in ('wmic os get localdatetime /value') do set datetime=%%I
set TIMESTAMP=%datetime:~0,8%_%datetime:~8,6%
set BACKUP_PATH=%BACKUP_DIR%\%TIMESTAMP%

mkdir "%BACKUP_PATH%"

echo.
echo [INFO] Starting backup...
echo Backup location: %BACKUP_PATH%
echo.

REM Databases to backup
set DATABASES=user_db student_db tuition_db
set SUCCESS=0
set FAILED=0

for %%D in (%DATABASES%) do (
    echo Backing up %%D...
    
    docker-compose exec -T mysql mysqldump -uroot -proot --databases %%D > "%BACKUP_PATH%\%%D.sql" 2>nul
    
    if exist "%BACKUP_PATH%\%%D.sql" (
        echo [OK] %%D backed up successfully
        set /a SUCCESS+=1
    ) else (
        echo [FAIL] Backup failed for %%D
        set /a FAILED+=1
    )
)

echo.
echo ========================================
echo    Backup Summary
echo ========================================
echo  Total: 3
echo  Success: %SUCCESS%
echo  Failed: %FAILED%
echo ========================================
echo.

if %SUCCESS% gtr 0 (
    echo [SUCCESS] Backup completed!
    echo Location: %BACKUP_PATH%
) else (
    echo [ERROR] Backup failed!
)

echo.
pause
