package com.example.payment_service.dto;

import lombok.Data;

@Data
public class VerifyOtpRequest {
    private String otpCode;
}