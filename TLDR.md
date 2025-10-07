# 🚀 Quick Start - iBanking Docker

## TL;DR (Too Long, Didn't Read)

```powershell
# 1. Check hệ thống
.\preflight-check.ps1

# 2. Start everything
.\quick-start.ps1

# 3. Truy cập
http://localhost          # Frontend
http://localhost:8761     # Eureka
http://localhost:8086     # API Gateway
```

Done! 🎉

---

## Chi tiết hơn một chút

### Lần đầu tiên
```powershell
# Copy file cấu hình
Copy-Item .env.example .env

# Chỉnh sửa .env nếu cần (email, passwords, etc.)
notepad .env

# Chạy!
.\quick-start.ps1
```

### Hàng ngày
```powershell
# Start toàn bộ hệ thống
docker-compose up -d

# Chỉ chạy frontend
docker-compose up -d app-fe

# Chỉ chạy backend (không frontend)
docker-compose up -d mysql redis eureka-server api-gateway user-service student-service tuition-service payment-service notification-service

# Stop
docker-compose stop

# Logs
docker-compose logs -f

# Restart một service sau khi sửa code
docker-compose build student-service
docker-compose up -d student-service
```

### Công cụ hữu ích
```powershell
# Load management scripts
. .\docker-scripts.ps1

# Các lệnh có sẵn
Build-All                    # Build tất cả
Start-System                 # Start
Stop-System                  # Stop
Show-Logs student-service    # Logs
Check-Status                 # Status
Reset-System                 # Reset all
```

### Backup/Restore
```powershell
# Backup
.\backup-db.ps1 -Compress

# Restore
.\restore-db.ps1 -BackupPath "./backups/20250104_120000"
```

---

## Troubleshooting nhanh

### Service không chạy?
```powershell
docker-compose logs -f service-name
docker-compose restart service-name
```

### Port bị chiếm?
```powershell
netstat -ano | findstr :8081
taskkill /PID <PID> /F
```

### Reset toàn bộ?
```powershell
docker-compose down -v
docker-compose up -d
```

### Check health?
```powershell
.\health-check.ps1
```

---

## Access Points

| What | URL |
|------|-----|
| Frontend | http://localhost |
| Eureka | http://localhost:8761 |
| API Gateway | http://localhost:8086 |
| MySQL | localhost:3307 (root/root) |

---

**That's all you need! 🎊**
