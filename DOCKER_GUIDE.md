# iBanking Docker Deployment Guide

Hướng dẫn build và chạy toàn bộ hệ thống iBanking với Docker Compose.

## 📋 Yêu cầu hệ thống

- Docker Desktop (Windows/Mac) hoặc Docker Engine + Docker Compose (Linux)
- RAM tối thiểu: 8GB (khuyến nghị 16GB)
- Disk space: ~10GB

## 🚀 Hướng dẫn sử dụng

### 1. Chuẩn bị môi trường

Tạo file `.env` từ template:

```powershell
Copy-Item .env.example .env
```

Sau đó chỉnh sửa file `.env` để cấu hình:
- Thông tin database (nếu dùng DB bên ngoài)
- Thông tin email cho notification service
- Các secret keys

### 2. Build toàn bộ hệ thống

**Lần đầu tiên hoặc khi có thay đổi code:**

```powershell
docker-compose build
```

Lệnh này sẽ:
- Build tất cả microservices từ source code
- Build Flutter web app
- Tạo Docker images cho từng service

**Build lại một service cụ thể:**

```powershell
docker-compose build user-service
```

### 3. Chạy hệ thống

**Khởi động tất cả services:**

```powershell
docker-compose up -d
```

**Xem logs:**

```powershell
# Xem logs tất cả services
docker-compose logs -f

# Xem logs một service cụ thể
docker-compose logs -f user-service
```

**Kiểm tra trạng thái:**

```powershell
docker-compose ps
```

### 4. Truy cập ứng dụng

Sau khi tất cả services đã chạy (khoảng 1-2 phút):

- **Frontend (Flutter Web):** http://localhost
- **API Gateway:** http://localhost:8086
- **Eureka Dashboard:** http://localhost:8761
- **User Service:** http://localhost:8081
- **Student Service:** http://localhost:8082
- **Tuition Service:** http://localhost:8083
- **Payment Service:** http://localhost:8084
- **Notification Service:** http://localhost:8085

### 5. Dừng hệ thống

**Dừng tất cả services (giữ lại data):**

```powershell
docker-compose stop
```

**Dừng và xóa containers (giữ lại data):**

```powershell
docker-compose down
```

**Dừng và xóa tất cả (bao gồm data):**

```powershell
docker-compose down -v
```

## 🔧 Cấu hình nâng cao

### Sử dụng Database bên ngoài

Chỉnh sửa file `.env`:

```env
# Thay đổi từ mysql (container) sang host bên ngoài
USER_DB_URL=jdbc:mysql://your-db-host:3306/user_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
STUDENT_DB_URL=jdbc:mysql://your-db-host:3306/student_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
TUITION_DB_URL=jdbc:mysql://your-db-host:3306/tuition_db?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC
MYSQL_USER=your-username
MYSQL_PASSWORD=your-password
```

Sau đó comment hoặc xóa service `mysql` trong `docker-compose.yml`.

### Sử dụng Redis bên ngoài

Chỉnh sửa file `.env`:

```env
REDIS_HOST=your-redis-host
REDIS_PORT=6379
```

Sau đó comment hoặc xóa service `redis` trong `docker-compose.yml`.

## 🛠️ Troubleshooting

### Service không kết nối được với Eureka

Đợi thêm 30-60 giây để Eureka khởi động hoàn toàn. Kiểm tra:

```powershell
docker-compose logs eureka-server
```

### Database connection error

Kiểm tra MySQL đã sẵn sàng:

```powershell
docker-compose logs mysql
```

Đảm bảo databases đã được tạo:

```powershell
docker-compose exec mysql mysql -uroot -proot -e "SHOW DATABASES;"
```

### Port đã được sử dụng

Nếu port bị conflict, chỉnh sửa trong `.env` hoặc `docker-compose.yml`:

```yaml
ports:
  - "8087:8086"  # Đổi port bên ngoài từ 8086 sang 8087
```

### Build lỗi hoặc chậm

Xóa cache và build lại:

```powershell
docker-compose build --no-cache user-service
```

### Xem logs chi tiết của một service

```powershell
docker-compose logs -f --tail=100 student-service
```

## 📊 Monitoring

### Kiểm tra health của services

```powershell
# Kiểm tra MySQL
docker-compose exec mysql mysqladmin ping -uroot -proot

# Kiểm tra Redis
docker-compose exec redis redis-cli ping

# Kiểm tra Eureka
curl http://localhost:8761/actuator/health
```

### Kiểm tra resource usage

```powershell
docker stats
```

## 🔄 Workflow phát triển

### Khi thay đổi code backend

1. Rebuild service đã thay đổi:
```powershell
docker-compose build student-service
```

2. Restart service:
```powershell
docker-compose up -d student-service
```

### Khi thay đổi code frontend

1. Rebuild frontend:
```powershell
docker-compose build app-fe
```

2. Restart frontend:
```powershell
docker-compose up -d app-fe
```

### Reset toàn bộ hệ thống

```powershell
# Dừng và xóa tất cả
docker-compose down -v

# Build lại
docker-compose build

# Chạy lại
docker-compose up -d
```

## 📝 Notes

1. **Lần đầu chạy:** Quá trình build có thể mất 10-15 phút tùy thuộc vào tốc độ mạng (download dependencies).

2. **Database schema:** Các service sẽ tự động chạy `schema.sql` và `data.sql` khi khởi động lần đầu.

3. **Email configuration:** Nhớ cấu hình email trong `.env` để notification service hoạt động.

4. **Eureka registration:** Các service có thể mất 30-60 giây để đăng ký với Eureka sau khi khởi động.

5. **Production deployment:** File này dành cho development. Với production, cần thêm:
   - SSL/TLS certificates
   - Environment-specific configurations
   - Secrets management
   - Load balancing
   - Monitoring & logging solutions

## 🤝 Support

Nếu gặp vấn đề, kiểm tra:
1. Docker Desktop đang chạy
2. Ports không bị conflict
3. Đủ RAM và disk space
4. File `.env` đã được cấu hình đúng
