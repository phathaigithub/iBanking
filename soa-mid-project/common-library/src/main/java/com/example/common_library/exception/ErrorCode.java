package com.example.common_library.exception;

import lombok.AllArgsConstructor;
import lombok.Getter;

@Getter
@AllArgsConstructor
public enum ErrorCode {
    BAD_REQUEST(402, "Bad request"),
    INVALID_CREDENTIALS(401, "Invalid username or password"),
    USER_NOT_FOUND(404, "User not found"),
    ACCOUNT_DISABLED(403, "Account is disabled"),
    STUDENT_NOT_FOUND(404, "Student not found"),
    INSUFFICIENT_BALANCE(410,"Do not enough"),
    INTERNAL_ERROR(500, "Internal server error"),

    // Bổ sung cho luồng thanh toán
    PAYMENT_NOT_FOUND(404, "Payment not found"),
    OTP_INVALID(411, "OTP is invalid"),
    OTP_EXPIRED(412, "OTP is expired"),
    TUITION_NOT_FOUND(404, "Tuition not found"),
    AMOUNT_MISMATCH(413, "Amount does not match tuition"),
    PAYMENT_ALREADY_SUCCESS(414, "Payment already completed"),
    USER_EMAIL_NOT_FOUND(415, "User email not found"),


    MAJOR_NOT_FOUND(404, "Major not found"),
    MAJOR_ALREADY_EXISTS(409, "Major already exists"),
    STUDENT_ALREADY_EXISTS(409, "Student already exists"),


    INVALID_SEMESTER_FORMAT(416, "Invalid semester format. Expected format: [1-3][YYYY] (e.g 12025)"),
    INVALID_DUE_DATE(417, "Invalid due date format. Expected format: dd-MM-yyyy"),

 
    INVALID_OTP(401, "Invalid or expired OTP"),

 
    PAYMENT_ALREADY_COMPLETED(409, "Học phí đã được thanh toán"),

    // Thêm mã lỗi mới
    PAYMENT_PROCESSING_ERROR(500, "Error during payment processing"),
    PAYMENT_IN_PROGRESS(409, "Học phí đang được xử lý thanh toán"),

    OTP_MAX_ATTEMPTS_EXCEEDED(401, "Nhập sai OTP quá số lần cho phép");

    private final int status;
    private final String message;
}
