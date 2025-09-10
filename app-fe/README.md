# TUI iBanking - Tuition Payment App

A Flutter application for convenient tuition payment for TDTU students, following MVVM architecture pattern.

## Features

### User Features
- **User Authentication**: Login with username/password
- **Account Information**: View personal details and available balance
- **Tuition Payment**: Pay tuition for any student using student ID
- **OTP Verification**: Secure transaction confirmation via email OTP
- **Transaction History**: View payment history
- **Responsive UI**: Optimized for both mobile and desktop/web

### Admin Features
- **Admin Dashboard**: Overview of payment statistics
- **Student Management**: View all students and payment status
- **Revenue Tracking**: Monitor total collected tuition fees
- **Real-time Updates**: Refresh data functionality

## Architecture

The application follows **MVVM (Model-View-ViewModel)** pattern:

- **Models**: Data structures (User, Student, Transaction, OTP, etc.)
- **Views**: UI components (Login, User Home, Admin Dashboard)
- **ViewModels**: Business logic and state management using Provider
- **Services**: Data access layer (Auth, Payment, Student, OTP services)

## Technical Stack

- **Flutter SDK**: ^3.9.0
- **State Management**: Provider ^6.1.2
- **Local Storage**: shared_preferences ^2.2.3
- **Unique IDs**: uuid ^4.4.0
- **Cryptography**: crypto ^3.0.3
- **Internationalization**: intl ^0.19.0

## Demo Accounts

### Admin Account
- Username: `admin`
- Password: `admin`

### Regular User
- Username: Any string (e.g., `user1`)
- Password: Any string (e.g., `password`)

## Student Test Data

The app includes sample student data:
- **52000001**: Nguyễn Văn A (₫15,000,000)
- **52000002**: Trần Thị B (₫15,000,000)
- **52000003**: Lê Văn C (₫15,000,000) - Already paid
- **52000004**: Phạm Thị D (₫15,000,000)
- **52000005**: Hoàng Văn E (₫15,000,000)

## Payment Flow

1. **Login**: Enter credentials
2. **Student Search**: Enter 8-digit student ID
3. **Payment Form**: Review payment details and accept terms
4. **OTP Verification**: Enter 6-digit OTP sent to email
5. **Confirmation**: Complete transaction and receive confirmation

## Security Features

- **Account Locking**: Prevents concurrent transactions on same account
- **OTP Expiration**: 5-minute validity period
- **Balance Validation**: Ensures sufficient funds before payment
- **Duplicate Payment Prevention**: Checks if student already paid

## Installation & Setup

1. **Prerequisites**:
   ```bash
   flutter --version  # Ensure Flutter SDK is installed
   ```

2. **Install Dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run the App**:
   ```bash
   # For web
   flutter run -d chrome
   
   # For mobile (with emulator/device connected)
   flutter run
   
   # For desktop
   flutter run -d windows  # or macos/linux
   ```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
│   ├── user.dart
│   ├── student.dart
│   ├── transaction.dart
│   ├── otp.dart
│   └── tuition_payment_request.dart
├── services/                 # Business logic services
│   ├── auth_service.dart
│   ├── student_service.dart
│   ├── payment_service.dart
│   └── otp_service.dart
├── viewmodels/              # State management
│   ├── auth_viewmodel.dart
│   ├── payment_viewmodel.dart
│   └── admin_viewmodel.dart
├── views/                   # UI screens
│   ├── login_view.dart
│   ├── user_home_view.dart
│   └── admin_dashboard_view.dart
└── utils/                   # Helper utilities
    ├── app_theme.dart
    └── helpers.dart
```

## TODO Comments for Backend Integration

The codebase includes TODO comments marking areas that need modification when integrating with a real backend:

- **Authentication**: Replace static login with API calls
- **OTP Service**: Integrate with actual email service
- **Payment Processing**: Connect to banking API
- **Data Persistence**: Replace in-memory storage with database
- **Transaction Locking**: Implement proper database locks
- **Email Notifications**: Set up email service for confirmations

## Color Scheme

The app uses a sky blue color scheme as requested:
- **Primary**: #1976D2 (Sky Blue)
- **Primary Dark**: #1565C0
- **Primary Light**: #42A5F5
- **Accent Colors**: Green for success, Orange for pending, Red for errors

## Responsive Design

The UI adapts to different screen sizes:
- **Mobile**: Single column layout with cards
- **Tablet**: Optimized spacing and navigation
- **Desktop**: Multi-column layouts and data tables

## Notes

This is a demo application with static data. In a production environment:
- Replace static data with database integration
- Implement proper authentication and authorization
- Add real email service for OTP delivery
- Implement proper logging and error tracking
- Add data validation and sanitization
- Implement proper transaction rollback mechanisms
