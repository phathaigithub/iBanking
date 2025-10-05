# Admin Dashboard - Hướng dẫn sử dụng

## 📋 Tổng quan

Admin Dashboard mới với giao diện desktop chuyên nghiệp, sử dụng Riverpod cho state management và tích hợp API backend microservices.

## 🎨 Giao diện

### Layout Desktop
```
┌────────────────────────────────────────────────┐
│ ┌──────────┐ ┌──────────────────────────────┐ │
│ │          │ │   Top Bar (User Info)        │ │
│ │ Sidebar  │ ├──────────────────────────────┤ │
│ │  (250px) │ │                              │ │
│ │          │ │   Main Content Area          │ │
│ │ • Menu 1 │ │   - Tab Switcher             │ │
│ │ • Menu 2 │ │   - Content Cards            │ │
│ │ • Menu 3 │ │   - Data Lists               │ │
│ │          │ │                              │ │
│ │ [Logout] │ │                              │ │
│ └──────────┘ └──────────────────────────────┘ │
└────────────────────────────────────────────────┘
```

### Sidebar Menu
1. **Ngành học & Sinh viên** ✅ (Đã hoàn thành)
2. **Học phí** 🚧 (Placeholder)
3. **Tạo đợt đóng học phí** 🚧 (Placeholder)

## 🔧 Kiến trúc

### Models
```dart
// lib/models/major.dart
class Major {
  final int id;
  final String code;
  final String name;
}

// lib/models/student_detail.dart
class StudentDetail {
  final int id;
  final String studentCode;
  final String name;
  final int age;
  final String email;
  final String phone;
  final String majorCode;
  final String majorName;
}
```

### API Services
```dart
// lib/services/api/major_api_service.dart
class MajorApiService {
  Future<List<Major>> getAllMajors()
  // GET ${ApiRoutes.studentServiceEndpoint}/majors
}

// lib/services/api/student_api_service.dart (updated)
class StudentApiService {
  Future<List<StudentDetail>> getAllStudentDetails()
  // GET ${ApiRoutes.studentServiceEndpoint}/students
}
```

### Riverpod State Management
```dart
// lib/providers/admin_provider.dart

// State
class AdminDashboardState {
  final AdminViewTab currentTab;
  final MajorStudentTab majorStudentTab;
  final List<Major> majors;
  final List<StudentDetail> students;
  final bool isLoadingMajors;
  final bool isLoadingStudents;
  final String? errorMajors;
  final String? errorStudents;
  
  // Group students by major
  Map<String, List<StudentDetail>> get studentsByMajor;
}

// Notifier
class AdminDashboardNotifier extends StateNotifier<AdminDashboardState> {
  void setTab(AdminViewTab tab);
  void setMajorStudentTab(MajorStudentTab tab);
  Future<void> loadMajors();
  Future<void> loadStudents();
}

// Providers
final adminDashboardProvider = StateNotifierProvider...
final majorApiServiceProvider = Provider...
final studentApiServiceProvider = Provider...
```

## 📡 API Endpoints

### 1. Lấy danh sách ngành học
```
GET http://localhost:8086/student-service/api/majors

Response:
[
  {
    "id": 1,
    "code": "CNTT",
    "name": "Công nghệ thông tin"
  },
  {
    "id": 2,
    "code": "QTKD",
    "name": "Quản trị kinh doanh"
  }
]
```

### 2. Lấy danh sách sinh viên
```
GET http://localhost:8086/student-service/api/students

Response:
[
  {
    "id": 1,
    "studentCode": "52200001",
    "name": "Nguyễn Văn A",
    "age": 20,
    "email": "a@example.com",
    "phone": "0123456789",
    "majorCode": "CNTT",
    "majorName": "Công nghệ thông tin"
  }
]
```

## 🎯 Tính năng

### Tab "Ngành học & Sinh viên"

#### Sub-tab: Ngành học
- **Hiển thị**: Danh sách tất cả ngành học
- **Features**:
  - Avatar với chữ cái đầu mã ngành
  - Tên ngành học đầy đủ
  - Mã ngành
  - ID ngành
  - Tổng số ngành học

#### Sub-tab: Sinh viên
- **Hiển thị**: Danh sách sinh viên nhóm theo ngành học
- **Features**:
  - ExpansionTile cho mỗi ngành
  - Tên ngành + số lượng sinh viên
  - Chi tiết sinh viên khi expand:
    - MSSV, Tên, Email, SĐT
    - Tuổi, ID
  - Tổng số sinh viên

### Error Handling
- Loading states với CircularProgressIndicator
- Error states với thông báo và nút "Thử lại"
- Empty states với thông báo phù hợp

## 🔐 Authentication Flow

```
1. User login với role="ADMIN"
   ↓
2. AuthWrapper kiểm tra role
   ↓
3. Navigate đến AdminDashboardView
   ↓
4. Auto-load danh sách ngành học (initState)
   ↓
5. User tương tác với menu
```

## 🚀 Cách sử dụng

### 1. Đăng nhập
```dart
// Login với tài khoản admin
username: "admin" (hoặc tài khoản có role="ADMIN")
password: "your_password"
```

### 2. Xem danh sách ngành học
- Dashboard tự động load ngành học khi khởi động
- Click vào tab "Ngành học" để xem chi tiết

### 3. Xem danh sách sinh viên
- Click nút "Sinh viên" trong SegmentedButton
- Dữ liệu tự động load nếu chưa có
- Click vào từng ngành để expand và xem sinh viên

### 4. Điều hướng
- Click các menu trong sidebar để chuyển tab
- "Học phí" và "Tạo đợt đóng học phí" hiện tại là placeholder

### 5. Đăng xuất
- Click "Đăng xuất" ở cuối sidebar
- Xác nhận trong dialog

## 📦 Files đã tạo/cập nhật

### Models
- ✅ `lib/models/major.dart`
- ✅ `lib/models/major.g.dart` (generated)
- ✅ `lib/models/student_detail.dart`
- ✅ `lib/models/student_detail.g.dart` (generated)

### Services
- ✅ `lib/services/api/major_api_service.dart`
- ✅ `lib/services/api/student_api_service.dart` (updated)

### Providers
- ✅ `lib/providers/admin_provider.dart`

### Views
- ✅ `lib/views/admin_dashboard_view.dart` (replaced)
- ✅ `lib/views/admin_dashboard_view.dart.old` (backup)

## 🐛 Troubleshooting

### Lỗi: "Không thể tải danh sách ngành học"
**Nguyên nhân**: Backend service không chạy hoặc endpoint không đúng
**Giải pháp**:
1. Kiểm tra backend service đang chạy trên port 8086
2. Test endpoint: `curl http://localhost:8086/student-service/api/majors`
3. Click nút "Thử lại"

### Lỗi: "Không thể tải danh sách sinh viên"
**Nguyên nhân**: Backend service không trả về dữ liệu đúng format
**Giải pháp**:
1. Kiểm tra response format từ API
2. Đảm bảo có field `majorCode` và `majorName`
3. Check console logs

### UI không responsive
**Giải pháp**: Dashboard được thiết kế cho desktop (width >= 800px)

## 🔜 Phát triển tiếp theo

### Tab "Học phí"
- [ ] Hiển thị danh sách kỳ học
- [ ] Lọc theo trạng thái (Đã thanh toán/Chưa thanh toán)
- [ ] Export báo cáo

### Tab "Tạo đợt đóng học phí"
- [ ] Form tạo đợt mới
- [ ] Chọn kỳ học, năm học
- [ ] Chọn ngành học áp dụng
- [ ] Nhập số tiền học phí
- [ ] Xác nhận và tạo

### Tính năng khác
- [ ] Search/Filter trong danh sách
- [ ] Sort theo các trường
- [ ] Pagination cho danh sách lớn
- [ ] Export Excel/PDF
- [ ] Dark mode

## 📝 Notes

- **State Management**: Sử dụng Riverpod thay vì Provider
- **API Client**: Dùng chung `ApiClient` từ `auth_provider`
- **Error Messages**: Vietnamese language cho user-friendly
- **Loading**: Auto-load khi switch tabs lần đầu
- **Design**: Material 3 design với AppColors theme

## 🎓 Best Practices

1. **Lazy Loading**: Chỉ load data khi cần thiết
2. **Error Boundaries**: Mỗi tab có error handling riêng
3. **State Isolation**: State của majors và students tách biệt
4. **API Reuse**: Dùng chung ApiClient cho tất cả services
5. **Type Safety**: Sử dụng json_serializable cho models

---

**Version**: 1.0.0  
**Last Updated**: 2025-01-04  
**Author**: AI Assistant

