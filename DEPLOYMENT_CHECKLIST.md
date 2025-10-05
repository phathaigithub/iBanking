# ✅ Docker Deployment Checklist

## Pre-Deployment

- [ ] Docker Desktop đã cài đặt và chạy
- [ ] Git repository đã clone về
- [ ] Đủ disk space (>10GB free)
- [ ] Đủ RAM (>8GB)
- [ ] Ports không bị conflict (80, 3307, 6379, 8761, 8081-8086)

## Configuration

- [ ] File `.env` đã được tạo từ `.env.example`
- [ ] Database credentials đã cấu hình (nếu dùng external DB)
- [ ] Email credentials đã cấu hình (cho notification service)
- [ ] JWT secret đã thay đổi (production)
- [ ] Redis credentials đã cấu hình (nếu dùng external Redis)

## Build & Deploy

- [ ] Chạy `.\preflight-check.ps1` - PASS
- [ ] Chạy `.\quick-start.ps1` - SUCCESS
- [ ] Tất cả containers đang chạy: `docker-compose ps`
- [ ] Không có errors trong logs: `docker-compose logs`

## Verification

### Infrastructure
- [ ] Eureka Dashboard accessible: http://localhost:8761
- [ ] Tất cả services đã register với Eureka
- [ ] MySQL đang chạy: `docker-compose exec mysql mysql -uroot -proot`
- [ ] Redis đang chạy: `docker-compose exec redis redis-cli ping`

### Databases
- [ ] Database `user_db` đã tồn tại
- [ ] Database `student_db` đã tồn tại
- [ ] Database `tuition_db` đã tồn tại
- [ ] Schema đã được tạo (tables exist)
- [ ] Initial data đã được load

### Services
- [ ] Eureka Server (8761) - UP
- [ ] API Gateway (8086) - UP and registered
- [ ] User Service (8081) - UP and registered
- [ ] Student Service (8082) - UP and registered
- [ ] Tuition Service (8083) - UP and registered
- [ ] Payment Service (8084) - UP and registered
- [ ] Notification Service (8085) - UP and registered
- [ ] Frontend (80) - Accessible

### Health Checks
- [ ] Run `.\health-check.ps1` - ALL GREEN
- [ ] No critical errors in any service logs
- [ ] All HTTP endpoints responding
- [ ] Database connections working

## Functional Testing

### Frontend
- [ ] Frontend loads at http://localhost
- [ ] No console errors in browser
- [ ] Can navigate between pages

### API Gateway
- [ ] Can access via http://localhost:8086
- [ ] Routes to services working
- [ ] CORS configured correctly (if needed)

### User Service
- [ ] Can register new user
- [ ] Can login
- [ ] JWT token received
- [ ] Authentication working

### Student Service
- [ ] Can fetch students list
- [ ] Can create student
- [ ] Can update student
- [ ] Can delete student

### Tuition Service
- [ ] Can fetch tuition fees
- [ ] Can create tuition fee
- [ ] Redis caching working

### Payment Service
- [ ] Can process payment
- [ ] Can verify OTP
- [ ] Transaction history working

### Notification Service
- [ ] Can send email (if configured)
- [ ] No errors in notification logs

## Performance

- [ ] Services start within reasonable time (<5 min)
- [ ] Response time acceptable (<2s for most requests)
- [ ] No memory leaks detected
- [ ] CPU usage normal (<80%)
- [ ] No container crashes or restarts

## Documentation

- [ ] README.md reviewed
- [ ] DOCKER_GUIDE.md available
- [ ] QUICK_REFERENCE.md available
- [ ] START_HERE.md reviewed
- [ ] Team members understand deployment process

## Backup & Recovery

- [ ] Backup script tested: `.\backup-db.ps1`
- [ ] Restore script tested: `.\restore-db.ps1`
- [ ] Backup location configured
- [ ] Backup schedule planned (if production)

## Security (Production)

- [ ] All default passwords changed
- [ ] `.env` not committed to git
- [ ] JWT secret is strong and unique
- [ ] Database passwords are strong
- [ ] HTTPS configured (production)
- [ ] Firewall rules configured
- [ ] Secrets management configured
- [ ] Nginx security headers enabled

## Monitoring (Production)

- [ ] Logging configured
- [ ] Monitoring tools configured
- [ ] Alerts configured
- [ ] Health check endpoints verified
- [ ] Resource limits configured

## Troubleshooting

If any item fails:

1. **Check logs:**
   ```powershell
   docker-compose logs -f <service-name>
   ```

2. **Run health check:**
   ```powershell
   .\health-check.ps1
   ```

3. **Restart service:**
   ```powershell
   docker-compose restart <service-name>
   ```

4. **Rebuild if needed:**
   ```powershell
   docker-compose build --no-cache <service-name>
   docker-compose up -d <service-name>
   ```

5. **Reset if all else fails:**
   ```powershell
   docker-compose down -v
   docker-compose build
   docker-compose up -d
   ```

## Sign-off

- [ ] Deployment tested by: ________________
- [ ] Date: ________________
- [ ] All checks passed: YES / NO
- [ ] Ready for use: YES / NO

---

## Quick Verification Commands

```powershell
# Check all containers running
docker-compose ps

# Check Eureka
curl http://localhost:8761

# Check databases
docker-compose exec mysql mysql -uroot -proot -e "SHOW DATABASES;"

# Check Redis
docker-compose exec redis redis-cli ping

# Check logs
docker-compose logs --tail=50

# Health check
.\health-check.ps1

# Resource usage
docker stats --no-stream
```

---

**Use this checklist every time you deploy!**
