@echo off
REM Quick Start Script for iBanking
REM Windows Batch version

echo.
echo ========================================
echo    iBanking Quick Start
echo ========================================
echo.

REM Check if .env exists
if not exist ".env" (
    echo [WARNING] .env file not found!
    echo Creating .env from .env.example...
    copy .env.example .env
    echo.
    echo [SUCCESS] .env created!
    echo Please configure it before continuing.
    echo.
    echo Opening .env file...
    notepad .env
    echo.
    echo After configuring .env, run this script again.
    pause
    exit /b
)

REM Check Docker
echo [INFO] Checking Docker...
docker --version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Docker is not installed or not running!
    echo Please install Docker Desktop and try again.
    pause
    exit /b 1
)
echo [SUCCESS] Docker is installed
echo.

REM Check if system is already running
echo [INFO] Checking if system is already running...
docker-compose ps -q >nul 2>&1
if not errorlevel 1 (
    echo [WARNING] System is already running!
    echo.
    set /p RESTART="Do you want to restart? (Y/N): "
    if /i "%RESTART%"=="Y" (
        echo.
        echo [INFO] Restarting system...
        docker-compose down
    ) else (
        echo.
        echo Opening logs...
        docker-compose logs -f
        exit /b
    )
)

echo [INFO] Building services...
echo This may take 10-15 minutes on first run...
echo.
docker-compose build

if errorlevel 1 (
    echo.
    echo [ERROR] Build failed! Please check the errors above.
    pause
    exit /b 1
)

echo.
echo [INFO] Starting services...
docker-compose up -d

echo.
echo [INFO] Waiting for services to be ready...
timeout /t 30 /nobreak >nul

echo.
echo [SUCCESS] System is starting up!
echo.
echo ========================================
echo    Access URLs
echo ========================================
echo  Frontend:     http://localhost
echo  API Gateway:  http://localhost:8086
echo  Eureka:       http://localhost:8761
echo ========================================
echo.
echo [INFO] Services may take 1-2 minutes to fully start.
echo.
set /p VIEWLOGS="Do you want to view logs? (Y/N): "
if /i "%VIEWLOGS%"=="Y" (
    docker-compose logs -f
)
