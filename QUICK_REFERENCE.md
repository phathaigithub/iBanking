# iBanking - Quick Reference

## 🚀 Quick Commands

### Start & Stop
```powershell
# Quick start (recommended)
.\quick-start.ps1

# Manual start
docker-compose up -d

# Stop
docker-compose stop

# Stop and remove
docker-compose down

# Stop and remove with data
docker-compose down -v
```

### Build
```powershell
# Build all
docker-compose build

# Build specific service
docker-compose build user-service

# Build without cache
docker-compose build --no-cache
```

### Logs
```powershell
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f student-service

# Last 100 lines
docker-compose logs --tail=100 -f
```

### Restart
```powershell
# Restart all
docker-compose restart

# Restart specific service
docker-compose restart api-gateway
```

### Status
```powershell
# Check status
docker-compose ps

# Health check
.\health-check.ps1
```

## 🛠️ Management Scripts

### Using docker-scripts.ps1
```powershell
# Load scripts
. .\docker-scripts.ps1

# Show menu
Show-Menu

# Build & Start
Build-All
Start-System

# View logs
Show-Logs student-service 50

# Check status
Check-Status

# Restart service
Restart-Service api-gateway

# Reset everything
Reset-System

# Connect to database
Connect-Database
```

## 🗄️ Database Operations

### Backup
```powershell
# Create backup
.\backup-db.ps1

# Create compressed backup
.\backup-db.ps1 -Compress

# Backup to specific directory
.\backup-db.ps1 -BackupDir "D:\backups"
```

### Restore
```powershell
# Restore from backup
.\restore-db.ps1 -BackupPath "./backups/20250104_120000"

# Restore specific databases
.\restore-db.ps1 -BackupPath "./backups/20250104_120000" -Databases @("user_db")
```

### Manual Database Access
```powershell
# Connect to MySQL
docker-compose exec mysql mysql -uroot -proot

# Show databases
docker-compose exec mysql mysql -uroot -proot -e "SHOW DATABASES;"

# Dump database
docker-compose exec mysql mysqldump -uroot -proot user_db > user_db_backup.sql

# Import database
Get-Content user_db_backup.sql | docker-compose exec -T mysql mysql -uroot -proot user_db
```

### Redis Operations
```powershell
# Connect to Redis
docker-compose exec redis redis-cli

# Check Redis
docker-compose exec redis redis-cli ping

# Flush all Redis data
docker-compose exec redis redis-cli FLUSHALL
```

## 🔍 Troubleshooting

### Check Eureka Dashboard
```
http://localhost:8761
```
All services should be registered here.

### Service Not Responding
```powershell
# Check logs
docker-compose logs -f service-name

# Restart service
docker-compose restart service-name

# Rebuild and restart
docker-compose build service-name
docker-compose up -d service-name
```

### Port Already in Use
```powershell
# Find process using port
netstat -ano | findstr :8081

# Kill process
taskkill /PID <PID> /F

# Or change port in docker-compose.yml
```

### Database Connection Issues
```powershell
# Check MySQL is running
docker-compose logs mysql

# Restart MySQL
docker-compose restart mysql

# Check databases exist
docker-compose exec mysql mysql -uroot -proot -e "SHOW DATABASES;"
```

### Clean Up Everything
```powershell
# Remove all containers, networks, volumes
docker-compose down -v

# Remove images too
docker-compose down -v --rmi all

# Clean Docker system
docker system prune -a -f
```

## 📊 Monitoring

### Container Stats
```powershell
# Live stats
docker stats

# Single snapshot
docker stats --no-stream
```

### Health Check
```powershell
# Run health check script
.\health-check.ps1

# Check specific service health
curl http://localhost:8081/actuator/health
```

### Logs Analysis
```powershell
# Search for errors
docker-compose logs | Select-String -Pattern "ERROR"

# Count errors
docker-compose logs | Select-String -Pattern "ERROR" | Measure-Object

# Export logs
docker-compose logs > logs.txt
```

## 🌐 Access Points

| Service | URL | Notes |
|---------|-----|-------|
| Frontend | http://localhost | Flutter Web App |
| API Gateway | http://localhost:8086 | Main API entry |
| Eureka | http://localhost:8761 | Service Registry |
| User Service | http://localhost:8081 | Direct access |
| Student Service | http://localhost:8082 | Direct access |
| Tuition Service | http://localhost:8083 | Direct access |
| Payment Service | http://localhost:8084 | Direct access |
| Notification | http://localhost:8085 | Direct access |

## 🔐 Default Credentials

### MySQL
- Host: localhost:3307
- User: root
- Password: root

### Redis
- Host: localhost:6379
- Password: (none by default)

## 📝 Development Workflow

### 1. Make Code Changes
Edit your code in IDE

### 2. Rebuild Service
```powershell
docker-compose build student-service
```

### 3. Restart Service
```powershell
docker-compose up -d student-service
```

### 4. Check Logs
```powershell
docker-compose logs -f student-service
```

### 5. Test
Test your changes through API or Frontend

## 🎯 Common Tasks

### Update Dependencies (Maven/Gradle)
1. Edit pom.xml or build.gradle
2. Rebuild: `docker-compose build --no-cache service-name`
3. Restart: `docker-compose up -d service-name`

### Update Flutter Dependencies
1. Edit pubspec.yaml
2. Rebuild: `docker-compose build --no-cache app-fe`
3. Restart: `docker-compose up -d app-fe`

### View Service Registered in Eureka
1. Open http://localhost:8761
2. Check "Instances currently registered with Eureka"
3. Wait 30-60s if service just started

### Clear All Data and Start Fresh
```powershell
docker-compose down -v
docker-compose up -d
```

## 💡 Tips

1. **First time build takes 10-15 minutes** - Be patient!
2. **Services need 30-60s to register with Eureka** - Don't panic if not immediate
3. **Use health-check.ps1** - Regularly check system health
4. **Backup before major changes** - Use backup-db.ps1
5. **Check logs when debugging** - Most issues show up in logs
6. **Use .env for configuration** - Don't hardcode values
7. **Restart after DB restore** - Ensure services pick up new data

## 📞 Quick Help

### Services Won't Start
1. Check Docker Desktop is running
2. Check ports are not in use
3. Check logs: `docker-compose logs`
4. Try: `docker-compose down && docker-compose up -d`

### Can't Access Frontend
1. Check container is running: `docker-compose ps`
2. Check port 80 is free
3. Try: `docker-compose restart app-fe`
4. Check logs: `docker-compose logs app-fe`

### Database Connection Errors
1. Wait for MySQL to be ready (check logs)
2. Verify databases exist: `docker-compose exec mysql mysql -uroot -proot -e "SHOW DATABASES;"`
3. Restart services: `docker-compose restart`

### Eureka Shows No Services
1. Wait 30-60 seconds
2. Check Eureka is running: http://localhost:8761
3. Check service logs for registration errors
4. Restart services: `docker-compose restart`

---

**For detailed documentation, see:**
- [DOCKER_GUIDE.md](./DOCKER_GUIDE.md) - Complete Docker guide
- [README.md](./README.md) - Project overview
