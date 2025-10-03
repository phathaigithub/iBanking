package com.example.tuition_service.service;

public interface OtpService {
    String generateOtp(String studentCode);
    boolean verifyOtp(String studentCode, String otpCode);
    void removeOtp(String studentCode);
}