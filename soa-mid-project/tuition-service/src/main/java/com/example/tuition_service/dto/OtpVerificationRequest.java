package com.example.tuition_service.dto;

import lombok.Data;

@Data
public class OtpVerificationRequest {
    private String studentCode;
    private String otpCode;
}