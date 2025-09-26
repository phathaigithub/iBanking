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
    USER_EMAIL_NOT_FOUND(415, "User email not found");

    private final int status;
    private final String message;
}
