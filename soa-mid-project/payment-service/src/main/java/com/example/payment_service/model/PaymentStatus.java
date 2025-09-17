package com.example.payment_service.model;

public enum PaymentStatus {
    PENDING_OTP,   // Đã tạo giao dịch, chờ xác thực OTP
    SUCCESS,       // Thanh toán thành công
    FAILED,        // Thanh toán thất bại
    CANCELLED      // Người dùng hủy
}