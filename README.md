# 🏦 iBanking - Hệ Thống Ngân Hàng Trực Tuyến

<div align="center">

![iBanking Logo](https://static.vecteezy.com/system/resources/previews/046/302/664/non_2x/bank-logo-icon-illustration-vector.jpg)
![Spring Boot](https://upload.wikimedia.org/wikipedia/commons/7/79/Spring_Boot.svg)
![Flutter](https://avatars.githubusercontent.com/u/14101776?s=200&v=4)
![Docker](https://images.viblo.asia/c6297f98-075f-4dd2-8bfc-9cf0d0e5ddb3.png)

**Hệ thống ngân hàng học phí hiện đại với kiến trúc Microservices**

[Tính năng](#-tính-năng) •
[Công nghệ](#-công-nghệ-sử-dụng) •
[Bắt đầu](#-bắt-đầu-nhanh) •
[Tài liệu](#-tài-liệu) •
[Kiến trúc](#-kiến-trúc-hệ-thống)

</div>

---

## 📋 Tổng quan

iBanking là hệ thống quản lý và thanh toán học phí trực tuyến, được xây dựng với kiến trúc **Microservices** hiện đại. Hệ thống cho phép sinh viên tra cứu, thanh toán học phí và nhận thông báo qua email một cách nhanh chóng và an toàn.

### 🎯 Mục tiêu dự án

- ✅ Xây dựng hệ thống Microservices hoàn chỉnh
- ✅ Áp dụng Service Discovery và API Gateway
- ✅ Tích hợp Cache và Message Queue
- ✅ Deploy với Docker và Docker Compose
- ✅ Frontend responsive với Flutter Web

---

## ✨ Tính năng

### 👤 Quản lý người dùng
- Đăng ký tài khoản mới
- Đăng nhập với JWT Authentication
- Phân quyền Admin/User
- Quản lý profile

### 👨‍🎓 Quản lý sinh viên
- CRUD thông tin sinh viên
- Tra cứu sinh viên theo mã/tên
- Quản lý ngành học
- Import/Export danh sách

### 💰 Quản lý học phí
- Tra cứu học phí theo sinh viên
- Tạo hóa đơn học phí
- Tính toán học phí theo ngành
- Lịch sử học phí

### 💳 Thanh toán
- Thanh toán học phí online
- Xác thực OTP
- Lịch sử giao dịch
- Hóa đơn điện tử

### 📧 Thông báo
- Gửi email xác nhận thanh toán
- Thông báo học phí đến hạn
- Email OTP
- Báo cáo định kỳ

---

## 🛠️ Công nghệ sử dụng

### Backend
| Công nghệ | Phiên bản | Mục đích |
|-----------|-----------|----------|
| **Spring Boot** | 3.5.5 | Framework backend |
| **Spring Cloud** | 2025.0.0 | Microservices toolkit |
| **Eureka Server** | Latest | Service Discovery |
| **Spring Cloud Gateway** | Latest | API Gateway |
| **MySQL** | 8.0 | Database |
| **Redis** | 7 | Cache & Session |
| **JWT** | Latest | Authentication |
| **JavaMail** | Latest | Email notification |

### Frontend
| Công nghệ | Phiên bản | Mục đích |
|-----------|-----------|----------|
| **Flutter** | Stable | UI Framework |
| **Provider** | Latest | State Management |
| **HTTP** | Latest | API Client |
| **Nginx** | Alpine | Web Server |

### DevOps
| Công nghệ | Phiên bản | Mục đích |
|-----------|-----------|----------|
| **Docker** | Latest | Containerization |
| **Docker Compose** | Latest | Orchestration |
| **Maven** | 3.9 | Build Tool |

---

## 🚀 Bắt đầu nhanh

### 📋 Yêu cầu hệ thống

- **Docker Desktop** (Windows/Mac) hoặc **Docker Engine** (Linux)
- **RAM:** Tối thiểu 8GB (khuyến nghị 16GB)
- **Disk:** 10GB trống
- **OS:** Windows 10+, macOS 10.14+, Ubuntu 20.04+

### ⚡ Khởi động hệ thống

#### Chạy toàn bộ hệ thống:
```bash
docker-compose up -d
```

#### Chỉ chạy frontend:
```bash
docker-compose up -d app-fe
```

#### Chỉ chạy backend (không frontend):
```bash
docker-compose up -d mysql redis eureka-server api-gateway user-service student-service tuition-service payment-service notification-service
```

#### Manual setup (nâng cao):
```bash
# 1. Tạo file cấu hình
cp .env.example .env

# 2. Build và khởi động
docker-compose build
docker-compose up -d

# 3. Kiểm tra trạng thái
docker-compose ps
```

### 🌐 Truy cập ứng dụng

Sau khi khởi động thành công (1-2 phút):

| Service | URL | Mô tả |
|---------|-----|-------|
| **Frontend** | http://localhost | Giao diện người dùng |
| **API Gateway** | http://localhost:8086 | API Gateway |
| **Eureka Dashboard** | http://localhost:8761 | Service Registry |
| **MySQL** | localhost:3307 | Database (root/root) |
| **Redis** | localhost:6379 | Cache |

---

## 📚 Tài liệu

### Hướng dẫn nhanh
- 📄 [TLDR.md](./docs/TLDR.md) - Bắt đầu trong 2 phút
- 📄 [START_HERE.md](./docs/START_HERE.md) - Hướng dẫn đầy đủ
- 📄 [QUICK_REFERENCE.md](./docs/QUICK_REFERENCE.md) - Tham khảo nhanh

### Tài liệu chi tiết
- 📖 [DOCKER_GUIDE.md](./docs/DOCKER_GUIDE.md) - Hướng dẫn Docker
- 📖 [DEPLOYMENT_GUIDE.md](./docs/DEPLOYMENT_SUMMARY.md) - Deployment
- 📖 [API_DOCUMENTATION.md](./docs/API_ROUTES_GUIDE.md) - API Routes

### Checklist & Tools
- ✅ [DEPLOYMENT_CHECKLIST.md](./docs/DEPLOYMENT_CHECKLIST.md) - Checklist
- 🛠️ [DOCUMENTATION_INDEX.md](./docs/DOCUMENTATION_INDEX.md) - Danh mục tài liệu

---

## 🏗️ Kiến trúc hệ thống

### Tổng quan

```
┌─────────────────────────────────────────────────┐
│                 Client Browser                  │
│              (Frontend - Flutter Web)           │
└──────────────────────┬──────────────────────────┘
                       │ HTTP/HTTPS
                       ▼
┌─────────────────────────────────────────────────┐
│            API Gateway (Port 8086)              │
│         Spring Cloud Gateway + Load Balancer    │
└──────────────────────┬──────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────┐
│         Eureka Server (Port 8761)               │
│              Service Discovery                  │
└──────────────────────┬──────────────────────────┘
                       │
        ┌──────────────┼──────────────┬──────────┐
        ▼              ▼              ▼          ▼
┌──────────────┐ ┌──────────┐ ┌──────────┐ ┌─────────┐
│ User Service │ │ Student  │ │ Tuition  │ │ Payment │
│   (8081)     │ │ Service  │ │ Service  │ │ Service │
│              │ │  (8082)  │ │  (8083)  │ │ (8084)  │
│ - Auth/JWT   │ │ - CRUD   │ │ - Fees   │ │ - Pay   │
│ - Users      │ │ - Search │ │ - Cache  │ │ - OTP   │
└──────┬───────┘ └────┬─────┘ └────┬─────┘ └────┬────┘
       │              │             │            │
       ▼              ▼             ▼            ▼
┌──────────────┐ ┌──────────┐ ┌─────────────────────┐
│   user_db    │ │ student  │ │    tuition_db       │
│   (MySQL)    │ │   _db    │ │     (MySQL)         │
└──────────────┘ └──────────┘ └───────┬─────────────┘
                                      │
                              ┌───────┴────────┐
                              ▼                ▼
                        ┌──────────┐    ┌────────────┐
                        │  Redis   │    │Notification│
                        │  Cache   │    │  Service   │
                        │  (6379)  │    │   (8085)   │
                        └──────────┘    │  - Email   │
                                        └────────────┘
```

### Microservices

#### 🔐 User Service (8081)
- **Chức năng:** Quản lý người dùng và xác thực
- **Database:** user_db
- **Công nghệ:** Spring Security, JWT
- **Endpoints:** `/api/users/*`, `/api/auth/*`

#### 👨‍🎓 Student Service (8082)
- **Chức năng:** Quản lý thông tin sinh viên
- **Database:** student_db
- **Công nghệ:** Spring Data JPA
- **Endpoints:** `/api/students/*`

#### 💰 Tuition Service (8083)
- **Chức năng:** Quản lý học phí
- **Database:** tuition_db
- **Cache:** Redis
- **Endpoints:** `/api/tuition/*`

#### 💳 Payment Service (8084)
- **Chức năng:** Xử lý thanh toán
- **Database:** tuition_db (shared)
- **Cache:** Redis
- **Endpoints:** `/api/payments/*`

#### 📧 Notification Service (8085)
- **Chức năng:** Gửi email thông báo
- **Công nghệ:** JavaMail
- **Endpoints:** `/api/notifications/*`

#### 🚪 API Gateway (8086)
- **Chức năng:** Routing, Load Balancing
- **Công nghệ:** Spring Cloud Gateway
- **Routes:** Tất cả request từ client

#### 🔍 Eureka Server (8761)
- **Chức năng:** Service Discovery
- **Công nghệ:** Netflix Eureka
- **Dashboard:** http://localhost:8761

---

## 🔧 Quản lý và vận hành

### Scripts có sẵn

#### Windows Batch (.bat)
```batch
scripts\quick-start.bat      REM Khởi động nhanh
scripts\health-check.bat     REM Kiểm tra sức khỏe
scripts\backup-db.bat        REM Backup database
scripts\preflight-check.bat  REM Kiểm tra trước khi deploy
```

#### PowerShell (.ps1)
```powershell
.\scripts\quick-start.ps1      # Khởi động nhanh
.\scripts\health-check.ps1     # Kiểm tra sức khỏe
.\scripts\backup-db.ps1        # Backup database
.\scripts\restore-db.ps1       # Restore database
.\scripts\docker-scripts.ps1   # Công cụ quản lý
.\scripts\preflight-check.ps1  # Kiểm tra trước khi deploy
```

### Docker Commands

```bash
# Khởi động
docker-compose up -d

# Dừng
docker-compose stop

# Xem logs
docker-compose logs -f

# Xem logs của service cụ thể
docker-compose logs -f student-service

# Restart service
docker-compose restart student-service

# Rebuild service
docker-compose build student-service
docker-compose up -d student-service

# Xem trạng thái
docker-compose ps

# Dừng và xóa tất cả
docker-compose down -v
```

---

## 🔐 Bảo mật

### Authentication & Authorization
- **JWT Tokens** cho authentication
- **Role-based access control** (ADMIN, USER)
- **Password hashing** với BCrypt
- **OTP verification** cho thanh toán

### Best Practices
- ✅ Không commit file `.env`
- ✅ Đổi tất cả passwords trong production
- ✅ Sử dụng HTTPS cho production
- ✅ Enable database encryption
- ✅ Regular security updates

---

## 📊 Monitoring & Logging

### Health Checks
```bash
# Sử dụng script
.\scripts\health-check.ps1

# Manual check
curl http://localhost:8761   # Eureka
curl http://localhost:8086   # API Gateway
```

### Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f user-service

# Search for errors
docker-compose logs | findstr /i "error"
```

### Metrics
- **Eureka Dashboard:** http://localhost:8761
- **Docker Stats:** `docker stats`
- **Service Health:** Actuator endpoints

---

## 🧪 Testing

### Unit Tests
```bash
# Run tests in container
docker-compose exec user-service mvn test
```

### Integration Tests
```bash
# Test with Bruno API Client
# See bruno-api/ folder for API collections
```

### Manual Testing
1. Truy cập Frontend: http://localhost
2. Đăng ký tài khoản mới
3. Đăng nhập
4. Test các chức năng CRUD
5. Test thanh toán với OTP

---

## 🤝 Đóng góp

Chúng tôi rất hoan nghênh mọi đóng góp! Vui lòng:

1. Fork repository
2. Tạo feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Tạo Pull Request

### Coding Standards
- Java: Follow Google Java Style Guide
- Flutter: Follow Effective Dart
- Commit messages: Conventional Commits
- Documentation: Always update docs

---

## 🐛 Troubleshooting

### Port đã được sử dụng
```bash
# Tìm process đang dùng port
netstat -ano | findstr :8081

# Kill process
taskkill /PID <PID> /F
```

### Service không kết nối được
1. Kiểm tra Eureka: http://localhost:8761
2. Đợi 30-60 giây cho services đăng ký
3. Check logs: `docker-compose logs -f service-name`
4. Restart: `docker-compose restart service-name`

### Database connection error
```bash
# Check MySQL
docker-compose logs mysql

# Verify databases
docker-compose exec mysql mysql -uroot -proot -e "SHOW DATABASES;"

# Restart
docker-compose restart mysql
```

### Build failed
```bash
# Clean build
docker-compose build --no-cache

# Remove old images
docker-compose down --rmi all
docker-compose build
```

---

## 📈 Roadmap

### Phase 1 - ✅ Completed
- [x] Microservices architecture
- [x] Service Discovery
- [x] API Gateway
- [x] Docker deployment
- [x] Basic CRUD operations

### Phase 2 - 🚧 In Progress
- [ ] Enhanced security
- [ ] Performance optimization
- [ ] Comprehensive testing
- [ ] CI/CD pipeline

### Phase 3 - 📋 Planned
- [ ] Kubernetes deployment
- [ ] Monitoring dashboard
- [ ] Mobile app (Flutter)
- [ ] Advanced analytics
- [ ] Payment gateway integration

---

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgments

- Spring Boot Team
- Flutter Team
- Docker Community
- Open Source Contributors

---

<div align="center">

**Made with ❤️ by iBanking Team**

[⬆ Back to top](#-ibanking---hệ-thống-ngân-hàng-trực-tuyến)

</div>
