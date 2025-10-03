package com.example.tuition_service.client;

import com.example.common_library.exception.ApiException;
import com.example.common_library.exception.ErrorCode;
import com.example.tuition_service.dto.OtpEmailRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

@Component
public class NotificationServiceClient {
    
    @Autowired
    private RestTemplate restTemplate;

    public void sendInquiryOtp(String toEmail, String otpCode, String studentName) {
        String url = "http://localhost:8086/notification-service/api/notification/send-inquiry-otp";
        
        OtpEmailRequest request = new OtpEmailRequest();
        request.setToEmail(toEmail);
        request.setOtpCode(otpCode);
        request.setExpireMinutes(5);
        request.setUserName(studentName);
        
        try {
            restTemplate.postForObject(url, request, Void.class);
        } catch (Exception e) {
            throw new ApiException(ErrorCode.INTERNAL_ERROR, 
                "Failed to send inquiry OTP email: " + e.getMessage());
        }
    }
}