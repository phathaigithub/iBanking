# 📚 Documentation Index

## 🎯 Bắt đầu từ đâu?

### Nếu bạn chưa biết gì
👉 **[TLDR.md](./TLDR.md)** - 2 phút đọc xong, hiểu ngay cách dùng

### Nếu bạn muốn hướng dẫn đầy đủ
👉 **[START_HERE.md](./START_HERE.md)** - Complete guide từ A-Z

### Nếu bạn cần deploy ngay
👉 **[DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)** - Checklist từng bước

---

## 📖 Tài liệu chính

### Getting Started
1. **[TLDR.md](./TLDR.md)** ⚡ FASTEST
   - Quick commands
   - Minimal explanation
   - Get running in 5 minutes

2. **[START_HERE.md](./START_HERE.md)** 🚀 RECOMMENDED
   - Complete beginner guide
   - Step-by-step instructions
   - Troubleshooting included
   - Daily workflow
   - All you need to know

3. **[README.md](./README.md)** 📋 OVERVIEW
   - Project overview
   - Architecture diagram
   - Technology stack
   - Team information

### Detailed Guides
4. **[DOCKER_GUIDE.md](./DOCKER_GUIDE.md)** 🐳 DOCKER DEEP DIVE
   - Complete Docker documentation
   - Configuration options
   - Advanced setup
   - Production deployment
   - Troubleshooting guide

5. **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** 📝 CHEAT SHEET
   - Quick command reference
   - Common tasks
   - Troubleshooting commands
   - Access points
   - Credentials

### Deployment
6. **[DEPLOYMENT_SUMMARY.md](./DEPLOYMENT_SUMMARY.md)** 📦 WHAT WE BUILT
   - Files created
   - Architecture explained
   - Features overview
   - How everything works

7. **[DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)** ✅ CHECKLIST
   - Pre-deployment checks
   - Verification steps
   - Testing checklist
   - Production readiness

---

## 🛠️ Scripts & Tools

### PowerShell Scripts
- **[quick-start.ps1](./quick-start.ps1)** - One-click deployment
- **[docker-scripts.ps1](./docker-scripts.ps1)** - Management utilities
- **[health-check.ps1](./health-check.ps1)** - System health checker
- **[backup-db.ps1](./backup-db.ps1)** - Database backup
- **[restore-db.ps1](./restore-db.ps1)** - Database restore
- **[preflight-check.ps1](./preflight-check.ps1)** - Pre-deployment check

### Configuration Files
- **[docker-compose.yml](./docker-compose.yml)** - Main compose file
- **[.env.example](./.env.example)** - Environment template
- **[docker-compose.prod.yml](./docker-compose.prod.yml)** - Production config
- **[init-db.sql](./init-db.sql)** - DB initialization

---

## 🗂️ Tài liệu theo use case

### "Tôi muốn chạy project lần đầu"
1. Read: [TLDR.md](./TLDR.md)
2. Run: `.\preflight-check.ps1`
3. Run: `.\quick-start.ps1`
4. Done!

### "Tôi cần hiểu rõ hệ thống"
1. Read: [README.md](./README.md) - Architecture
2. Read: [START_HERE.md](./START_HERE.md) - How to use
3. Read: [DOCKER_GUIDE.md](./DOCKER_GUIDE.md) - Docker details

### "Tôi đang develop và cần reference"
1. Read: [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)
2. Use: `.\docker-scripts.ps1`
3. Check: `.\health-check.ps1`

### "Tôi cần deploy production"
1. Read: [DOCKER_GUIDE.md](./DOCKER_GUIDE.md) - Production section
2. Follow: [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)
3. Use: [docker-compose.prod.yml](./docker-compose.prod.yml)

### "Tôi gặp lỗi cần fix"
1. Check: [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - Troubleshooting
2. Check: [DOCKER_GUIDE.md](./DOCKER_GUIDE.md) - Troubleshooting
3. Check: [START_HERE.md](./START_HERE.md) - Common issues
4. Run: `.\health-check.ps1`

### "Tôi cần backup/restore database"
1. Backup: `.\backup-db.ps1 -Compress`
2. Restore: `.\restore-db.ps1 -BackupPath "./backups/xxx"`
3. See: [START_HERE.md](./START_HERE.md) - Database section

---

## 📊 Tài liệu theo level

### 🟢 Beginner
**Goal:** Chạy được project
- [TLDR.md](./TLDR.md) - Quickest start
- [START_HERE.md](./START_HERE.md) - Complete guide
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - Common commands

### 🟡 Intermediate
**Goal:** Customize và develop
- [DOCKER_GUIDE.md](./DOCKER_GUIDE.md) - Configuration
- [DEPLOYMENT_SUMMARY.md](./DEPLOYMENT_SUMMARY.md) - How it works
- Scripts: docker-scripts.ps1, health-check.ps1

### 🔴 Advanced
**Goal:** Production deployment
- [DOCKER_GUIDE.md](./DOCKER_GUIDE.md) - Production section
- [docker-compose.prod.yml](./docker-compose.prod.yml)
- [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)
- Security best practices

---

## 🔍 Quick Search

### Commands
→ [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)

### Docker
→ [DOCKER_GUIDE.md](./DOCKER_GUIDE.md)

### Troubleshooting
→ [START_HERE.md](./START_HERE.md#troubleshooting)
→ [QUICK_REFERENCE.md](./QUICK_REFERENCE.md#troubleshooting)

### Configuration
→ [.env.example](./.env.example)
→ [DOCKER_GUIDE.md](./DOCKER_GUIDE.md#configuration)

### Architecture
→ [README.md](./README.md#architecture)
→ [DEPLOYMENT_SUMMARY.md](./DEPLOYMENT_SUMMARY.md#architecture)

### Scripts
→ [docker-scripts.ps1](./docker-scripts.ps1)
→ All .ps1 files in root

### Database
→ [START_HERE.md](./START_HERE.md#database)
→ [backup-db.ps1](./backup-db.ps1)
→ [restore-db.ps1](./restore-db.ps1)

---

## 📱 Access URLs

| What | URL | Doc |
|------|-----|-----|
| Frontend | http://localhost | [README.md](./README.md) |
| API Gateway | http://localhost:8086 | [README.md](./README.md) |
| Eureka | http://localhost:8761 | [README.md](./README.md) |
| All services | See table | [START_HERE.md](./START_HERE.md#access-urls) |

---

## 🎓 Learning Path

### Day 1: Get it running
1. [TLDR.md](./TLDR.md) - 5 min
2. Run `.\quick-start.ps1`
3. Access http://localhost
4. Celebrate! 🎉

### Day 2: Understand the system
1. [README.md](./README.md) - Architecture
2. [START_HERE.md](./START_HERE.md) - How it works
3. Explore Eureka dashboard
4. Check logs: `docker-compose logs -f`

### Day 3: Daily workflow
1. [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - Commands
2. Practice: build, restart, logs
3. Try: `.\docker-scripts.ps1`
4. Make code changes and deploy

### Week 2: Advanced topics
1. [DOCKER_GUIDE.md](./DOCKER_GUIDE.md) - Deep dive
2. External databases
3. Production deployment
4. Monitoring & backup

---

## 💡 Pro Tips

### Most used files
1. **[QUICK_REFERENCE.md](./QUICK_REFERENCE.md)** - Daily reference
2. **[docker-scripts.ps1](./docker-scripts.ps1)** - Daily tools
3. **[health-check.ps1](./health-check.ps1)** - Regular check

### Must read
1. **[START_HERE.md](./START_HERE.md)** - Complete guide
2. **[DOCKER_GUIDE.md](./DOCKER_GUIDE.md)** - Docker details

### Keep handy
- [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - For commands
- [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md) - For deployment

---

## 📞 Need Help?

### Check in order:
1. [QUICK_REFERENCE.md](./QUICK_REFERENCE.md) - Quick fixes
2. [START_HERE.md](./START_HERE.md) - Common issues
3. [DOCKER_GUIDE.md](./DOCKER_GUIDE.md) - Detailed troubleshooting
4. Run: `.\health-check.ps1`
5. Check logs: `docker-compose logs -f`

---

## ✅ Checklist

### For first time users:
- [ ] Read [TLDR.md](./TLDR.md)
- [ ] Run `.\preflight-check.ps1`
- [ ] Run `.\quick-start.ps1`
- [ ] Access http://localhost
- [ ] Bookmark [QUICK_REFERENCE.md](./QUICK_REFERENCE.md)

### For developers:
- [ ] Read [START_HERE.md](./START_HERE.md)
- [ ] Understand [README.md](./README.md) architecture
- [ ] Learn [docker-scripts.ps1](./docker-scripts.ps1) commands
- [ ] Know how to backup: [backup-db.ps1](./backup-db.ps1)

### For deployment:
- [ ] Follow [DEPLOYMENT_CHECKLIST.md](./DEPLOYMENT_CHECKLIST.md)
- [ ] Review [DOCKER_GUIDE.md](./DOCKER_GUIDE.md) production section
- [ ] Configure [docker-compose.prod.yml](./docker-compose.prod.yml)
- [ ] Change all passwords

---

**Happy coding! 🚀**
