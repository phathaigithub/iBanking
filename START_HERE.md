# 🎉 iBanking Docker Deployment - Hoàn Thành!

## ✅ Đã tạo xong Docker Compose cho toàn bộ project

### 📦 Những gì đã được tạo:

#### 1. **Docker Configuration Files**
- `docker-compose.yml` - Cấu hình chính cho tất cả services
- `.env.example` - Template cho environment variables
- `docker-compose.prod.yml` - Cấu hình cho production
- `init-db.sql` - Script khởi tạo databases tự động
- `.gitignore` - Bảo vệ file sensitive

#### 2. **Dockerfiles** (8 services)
- ✅ Eureka Server (Service Discovery)
- ✅ API Gateway (Routing)
- ✅ User Service (Authentication)
- ✅ Student Service
- ✅ Tuition Service
- ✅ Payment Service
- ✅ Notification Service
- ✅ Frontend (Flutter Web)

#### 3. **Management Scripts** (PowerShell)
- `quick-start.ps1` - **START HERE!** Tự động setup mọi thứ
- `docker-scripts.ps1` - Công cụ quản lý hệ thống
- `health-check.ps1` - Kiểm tra sức khỏe hệ thống
- `backup-db.ps1` - Backup database
- `restore-db.ps1` - Restore database
- `preflight-check.ps1` - Kiểm tra trước khi deploy

#### 4. **Documentation**
- `README.md` - Tổng quan project
- `DOCKER_GUIDE.md` - Hướng dẫn chi tiết
- `QUICK_REFERENCE.md` - Tham khảo nhanh
- `DEPLOYMENT_SUMMARY.md` - Tổng kết deployment

---

## 🚀 CÁCH SỬ DỤNG

### 🎯 Lần đầu tiên (First Time Setup)

#### Bước 1: Kiểm tra hệ thống
```powershell
.\preflight-check.ps1
```
Script này sẽ kiểm tra:
- Docker đã cài đặt chưa
- Ports có bị conflict không
- Đủ RAM và disk space không
- Files cần thiết có đầy đủ không

#### Bước 2: Chạy Quick Start
```powershell
.\quick-start.ps1
```
Script này sẽ **TỰ ĐỘNG**:
1. Tạo file `.env` nếu chưa có
2. Kiểm tra Docker
3. Build tất cả services (lần đầu mất 10-15 phút)
4. Khởi động toàn bộ hệ thống
5. Hiển thị status và access URLs

#### Bước 3: Cấu hình Email (Optional)
Nếu muốn notification service hoạt động:
```powershell
notepad .env
```
Sửa:
```env
MAIL_USERNAME=your-email@gmail.com
MAIL_PASSWORD=your-app-password
```

#### Bước 4: Truy cập ứng dụng
- **Frontend:** http://localhost
- **API Gateway:** http://localhost:8086
- **Eureka Dashboard:** http://localhost:8761

---

### 🔄 Sử dụng hàng ngày (Daily Usage)

#### Build và Start
```powershell
# Build tất cả
docker-compose build

# Start hệ thống
docker-compose up -d

# Hoặc dùng script
. .\docker-scripts.ps1
Build-All
Start-System
```

#### Stop và Restart
```powershell
# Stop tất cả
docker-compose stop

# Restart tất cả
docker-compose restart

# Restart một service
docker-compose restart student-service
```

#### Xem Logs
```powershell
# Logs tất cả services
docker-compose logs -f

# Logs một service cụ thể
docker-compose logs -f student-service

# Hoặc dùng script
. .\docker-scripts.ps1
Show-Logs student-service 100
```

#### Kiểm tra Status
```powershell
# Docker compose status
docker-compose ps

# Health check toàn diện
.\health-check.ps1
```

---

### 🛠️ Workflow Phát Triển

#### Khi sửa code backend (Java):
```powershell
# 1. Sửa code trong IDE
# 2. Rebuild service
docker-compose build student-service

# 3. Restart service
docker-compose up -d student-service

# 4. Xem logs
docker-compose logs -f student-service
```

#### Khi sửa code frontend (Flutter):
```powershell
# 1. Sửa code trong IDE
# 2. Rebuild frontend
docker-compose build app-fe

# 3. Restart frontend
docker-compose up -d app-fe
```

#### Khi thêm dependency mới:
```powershell
# 1. Sửa pom.xml hoặc pubspec.yaml
# 2. Rebuild không cache
docker-compose build --no-cache service-name

# 3. Restart
docker-compose up -d service-name
```

---

### 💾 Backup và Restore Database

#### Backup
```powershell
# Backup thường
.\backup-db.ps1

# Backup compressed
.\backup-db.ps1 -Compress

# Backup vào thư mục khác
.\backup-db.ps1 -BackupDir "D:\backups"
```

#### Restore
```powershell
# List available backups
Get-ChildItem -Path "./backups" -Directory

# Restore từ backup
.\restore-db.ps1 -BackupPath "./backups/20250104_120000"
```

---

### 🗄️ Quản lý Database

#### Truy cập MySQL
```powershell
# Dùng script
. .\docker-scripts.ps1
Connect-Database

# Hoặc manual
docker-compose exec mysql mysql -uroot -proot
```

#### Xem databases và tables
```sql
-- Trong MySQL shell
SHOW DATABASES;
USE student_db;
SHOW TABLES;
SELECT * FROM students LIMIT 10;
```

#### Export/Import manual
```powershell
# Export
docker-compose exec mysql mysqldump -uroot -proot student_db > backup.sql

# Import
Get-Content backup.sql | docker-compose exec -T mysql mysql -uroot -proot student_db
```

---

## 🎯 Các Tình Huống Thường Gặp

### 🐛 Troubleshooting

#### Service không start được
```powershell
# 1. Xem logs
docker-compose logs -f service-name

# 2. Rebuild
docker-compose build --no-cache service-name

# 3. Restart
docker-compose up -d service-name
```

#### Port bị chiếm
```powershell
# Tìm process đang dùng port
netstat -ano | findstr :8081

# Kill process
taskkill /PID <PID> /F

# Hoặc đổi port trong docker-compose.yml
```

#### Database connection error
```powershell
# Kiểm tra MySQL đang chạy
docker-compose logs mysql

# Restart MySQL
docker-compose restart mysql

# Kiểm tra databases đã tạo
docker-compose exec mysql mysql -uroot -proot -e "SHOW DATABASES;"
```

#### Eureka không thấy services
1. Đợi 30-60 giây (services cần thời gian register)
2. Check http://localhost:8761
3. Xem logs của service: `docker-compose logs -f service-name`
4. Restart services: `docker-compose restart`

#### Build quá chậm
```powershell
# Build song song
docker-compose build --parallel

# Build với nhiều CPUs hơn
# Settings -> Docker Desktop -> Resources -> CPUs
```

---

### 🧹 Clean Up

#### Dừng và xóa containers
```powershell
# Dừng và xóa containers (giữ data)
docker-compose down

# Dừng và xóa containers + volumes (mất data)
docker-compose down -v

# Xóa cả images
docker-compose down -v --rmi all
```

#### Clean Docker system
```powershell
# Xóa unused containers, networks, images
docker system prune -a -f

# Xóa volumes không dùng
docker volume prune -f
```

#### Reset toàn bộ
```powershell
# Dùng script
. .\docker-scripts.ps1
Reset-System

# Hoặc manual
docker-compose down -v
docker-compose build
docker-compose up -d
```

---

## 🌐 Access URLs

| Service | URL | Port | Notes |
|---------|-----|------|-------|
| **Frontend** | http://localhost | 80 | Flutter Web App |
| **API Gateway** | http://localhost:8086 | 8086 | Main API entry point |
| **Eureka** | http://localhost:8761 | 8761 | Service Registry Dashboard |
| User Service | http://localhost:8081 | 8081 | Direct access |
| Student Service | http://localhost:8082 | 8082 | Direct access |
| Tuition Service | http://localhost:8083 | 8083 | Direct access |
| Payment Service | http://localhost:8084 | 8084 | Direct access |
| Notification | http://localhost:8085 | 8085 | Direct access |
| **MySQL** | localhost:3307 | 3307 | root/root |
| **Redis** | localhost:6379 | 6379 | No password |

---

## 📊 Service Dependencies

```
Frontend (80)
    ↓
API Gateway (8086)
    ↓
Eureka Server (8761)
    ↓
┌────────────────┬────────────────┬────────────────┐
↓                ↓                ↓                ↓
User Service  Student Service  Tuition Service  Payment Service
(8081)        (8082)           (8083)           (8084)
↓              ↓                ↓                ↓
user_db        student_db       tuition_db       tuition_db
                                ↓                ↓
                                Redis ←──────────┘
                                
Notification Service (8085) ← triggered by other services
```

---

## 🔐 Default Credentials

### MySQL
- **Host:** localhost
- **Port:** 3307
- **Username:** root
- **Password:** root
- **Databases:** user_db, student_db, tuition_db

### Redis
- **Host:** localhost
- **Port:** 6379
- **Password:** (none)

⚠️ **QUAN TRỌNG:** Đổi passwords trong production!

---

## ⚙️ Cấu hình nâng cao

### Sử dụng Database bên ngoài

1. Edit `.env`:
```env
USER_DB_URL=jdbc:mysql://external-host:3306/user_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
STUDENT_DB_URL=jdbc:mysql://external-host:3306/student_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
TUITION_DB_URL=jdbc:mysql://external-host:3306/tuition_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
MYSQL_USER=your-username
MYSQL_PASSWORD=your-password
```

2. Comment service `mysql` trong `docker-compose.yml`

### Sử dụng Redis bên ngoài

1. Edit `.env`:
```env
REDIS_HOST=external-redis-host
REDIS_PORT=6379
```

2. Comment service `redis` trong `docker-compose.yml`

### Production Deployment

Sử dụng production config:
```powershell
docker-compose -f docker-compose.yml -f docker-compose.prod.yml up -d
```

---

## 📚 Tài liệu tham khảo

- **README.md** - Tổng quan project và architecture
- **DOCKER_GUIDE.md** - Hướng dẫn chi tiết về Docker
- **QUICK_REFERENCE.md** - Tham khảo nhanh các lệnh
- **DEPLOYMENT_SUMMARY.md** - Tổng kết deployment

---

## 💡 Tips & Best Practices

### Performance
1. Tăng RAM cho Docker Desktop (Settings -> Resources)
2. Sử dụng SSD thay vì HDD
3. Build parallel: `docker-compose build --parallel`
4. Close unnecessary applications

### Development
1. Chỉ rebuild service đã thay đổi
2. Sử dụng `docker-compose logs -f` để debug
3. Check Eureka dashboard thường xuyên
4. Backup database trước khi test migration

### Security
1. Không commit file `.env`
2. Đổi tất cả passwords trong production
3. Sử dụng secrets management
4. Enable HTTPS cho production

### Monitoring
1. Chạy `.\health-check.ps1` định kỳ
2. Monitor resource usage: `docker stats`
3. Check logs cho errors
4. Backup database thường xuyên

---

## 🎉 Hoàn thành!

Bạn đã có một hệ thống Docker hoàn chỉnh với:

✅ **One-command deployment** - `.\quick-start.ps1`
✅ **Auto database initialization** - Tự động tạo schemas và data
✅ **Service discovery fixed** - Không còn lỗi DNS
✅ **Health checks** - Tự động monitor và restart
✅ **Backup/Restore tools** - Bảo vệ data
✅ **Complete documentation** - Đầy đủ hướng dẫn

---

## 🚀 BẮT ĐẦU NGAY!

```powershell
# 1. Check system
.\preflight-check.ps1

# 2. Quick start
.\quick-start.ps1

# 3. Access
# Open http://localhost
```

**That's it! 🎊**

---

## 📞 Hỗ trợ

Nếu gặp vấn đề:

1. **Check logs:**
   ```powershell
   docker-compose logs -f
   ```

2. **Run health check:**
   ```powershell
   .\health-check.ps1
   ```

3. **Xem tài liệu:**
   - [DOCKER_GUIDE.md](./DOCKER_GUIDE.md)
   - [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)

4. **Reset nếu cần:**
   ```powershell
   . .\docker-scripts.ps1
   Reset-System
   ```

---

**Made with ❤️ by GitHub Copilot**

**Happy Coding! 🚀**
