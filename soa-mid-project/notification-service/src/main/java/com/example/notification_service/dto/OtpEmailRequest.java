package com.example.notification_service.dto;

@Data
public class OtpEmailRequest {
    private String toEmail;   // email sinh viên hoặc user
    private String otpCode;   // mã OTP
    private int expireMinutes; // thời hạn (vd: 5 phút)

    // getters và setters
}
