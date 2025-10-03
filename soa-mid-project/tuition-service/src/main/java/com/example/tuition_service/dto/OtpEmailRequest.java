package com.example.tuition_service.dto;

import lombok.Data;

@Data
public class OtpEmailRequest {
    private String toEmail;
    private String otpCode;
    private int expireMinutes;
    private String userName;
}