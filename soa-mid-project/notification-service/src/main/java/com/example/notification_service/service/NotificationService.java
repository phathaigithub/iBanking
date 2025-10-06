package com.example.notification_service.service;

import com.example.notification_service.dto.OtpEmailRequest;
import com.example.notification_service.dto.PaymentSuccessEmailRequest;

public interface NotificationService {
    void sendOtp(OtpEmailRequest request);
    void sendInquiryOtp(OtpEmailRequest request);
    void sendPaymentSuccess(PaymentSuccessEmailRequest request);
}
