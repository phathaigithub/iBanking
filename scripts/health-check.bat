@echo off
REM Health Check Script for iBanking
REM Windows Batch version

echo.
echo ========================================
echo    iBanking Health Check
echo ========================================
echo.

echo [INFO] Checking Docker containers...
docker-compose ps
echo.

echo [INFO] Checking HTTP Endpoints...
echo.

REM Check Eureka
echo Checking Eureka Server...
curl -s -o nul -w "%%{http_code}" http://localhost:8761 | findstr "200" >nul
if not errorlevel 1 (
    echo [OK] Eureka Server: RUNNING
) else (
    echo [FAIL] Eureka Server: NOT RESPONDING
)

REM Check API Gateway
echo Checking API Gateway...
curl -s -o nul -w "%%{http_code}" http://localhost:8086 | findstr "200" >nul
if not errorlevel 1 (
    echo [OK] API Gateway: RUNNING
) else (
    echo [FAIL] API Gateway: NOT RESPONDING
)

REM Check Frontend
echo Checking Frontend...
curl -s -o nul -w "%%{http_code}" http://localhost | findstr "200" >nul
if not errorlevel 1 (
    echo [OK] Frontend: RUNNING
) else (
    echo [FAIL] Frontend: NOT RESPONDING
)

echo.
echo [INFO] Checking Database...
docker-compose exec -T mysql mysqladmin ping -uroot -proot 2>nul | findstr "alive" >nul
if not errorlevel 1 (
    echo [OK] MySQL: RUNNING
) else (
    echo [FAIL] MySQL: NOT RESPONDING
)

echo.
echo [INFO] Checking Redis...
docker-compose exec -T redis redis-cli ping 2>nul | findstr "PONG" >nul
if not errorlevel 1 (
    echo [OK] Redis: RUNNING
) else (
    echo [FAIL] Redis: NOT RESPONDING
)

echo.
echo ========================================
echo    Health check completed!
echo ========================================
echo.
pause
