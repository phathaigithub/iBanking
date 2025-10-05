package com.example.payment_service.client;

import com.example.payment_service.dto.OtpEmailRequest;
import com.example.common_library.dto.PaymentSuccessEmailRequest;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "notification-service")
public interface NotificationServiceClient {
    
    @PostMapping("/api/notification/send-otp")
    void sendOtp(@RequestBody OtpEmailRequest otpRequest);
    
    @PostMapping("/api/notification/payment-success")
    void sendPaymentSuccess(@RequestBody PaymentSuccessEmailRequest successRequest);
}
