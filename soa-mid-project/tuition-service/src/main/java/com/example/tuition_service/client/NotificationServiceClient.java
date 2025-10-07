package com.example.tuition_service.client;

import com.example.tuition_service.dto.OtpEmailRequest;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;

@FeignClient(name = "notification-service")
public interface NotificationServiceClient {
    
    @PostMapping("/api/notification/send-inquiry-otp")
    void sendInquiryOtp(@RequestBody OtpEmailRequest request);
}
