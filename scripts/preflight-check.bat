@echo off
REM Pre-flight Check Script for iBanking
REM Windows Batch version

echo.
echo ========================================
echo    iBanking Pre-flight Check
echo ========================================
echo.

set ISSUES=0
set WARNINGS=0

REM Check Docker
echo [INFO] Checking Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Docker not found!
    echo        Install Docker Desktop from: https://www.docker.com/products/docker-desktop
    set /a ISSUES+=1
) else (
    for /f "tokens=*" %%i in ('docker --version') do echo [OK] Docker installed: %%i
)

echo.
echo [INFO] Checking Docker Compose...
docker-compose --version >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Docker Compose not found!
    set /a ISSUES+=1
) else (
    for /f "tokens=*" %%i in ('docker-compose --version') do echo [OK] Docker Compose installed: %%i
)

echo.
echo [INFO] Checking Docker daemon...
docker ps >nul 2>&1
if errorlevel 1 (
    echo [FAIL] Docker daemon not running!
    echo        Start Docker Desktop
    set /a ISSUES+=1
) else (
    echo [OK] Docker daemon is running
)

echo.
echo [INFO] Checking required files...
if exist "docker-compose.yml" (
    echo [OK] docker-compose.yml
) else (
    echo [FAIL] docker-compose.yml not found!
    set /a ISSUES+=1
)

if exist ".env.example" (
    echo [OK] .env.example
) else (
    echo [FAIL] .env.example not found!
    set /a ISSUES+=1
)

if exist "init-db.sql" (
    echo [OK] init-db.sql
) else (
    echo [FAIL] init-db.sql not found!
    set /a ISSUES+=1
)

echo.
echo [INFO] Checking configuration...
if exist ".env" (
    echo [OK] .env file exists
) else (
    echo [WARN] .env file not found ^(will be created^)
    set /a WARNINGS+=1
)

echo.
echo ========================================
echo    Pre-flight Check Summary
echo ========================================

if %ISSUES%==0 (
    if %WARNINGS%==0 (
        echo [SUCCESS] All checks passed! Ready to deploy.
        echo.
        echo Next steps:
        echo   1. Review .env file ^(if needed^)
        echo   2. Run: scripts\quick-start.bat
    ) else (
        echo [WARNING] %WARNINGS% warning^(s^) found, but you can proceed
        echo.
        echo Next steps:
        echo   1. Review warnings above
        echo   2. Fix if necessary
        echo   3. Run: scripts\quick-start.bat
    )
) else (
    echo [ERROR] %ISSUES% critical issue^(s^) found!
    echo        %WARNINGS% warning^(s^) found
    echo.
    echo Please fix the issues above before deploying.
)

echo ========================================
echo.
pause
