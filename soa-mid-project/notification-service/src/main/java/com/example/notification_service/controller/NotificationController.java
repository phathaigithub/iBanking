package com.example.notification_service.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.notification_service.dto.OtpEmailRequest;
import com.example.notification_service.dto.PaymentSuccessEmailRequest;
import com.example.notification_service.service.NotificationService;

@RestController
@RequestMapping("/api/notification")
public class NotificationController {

    @Autowired
    private NotificationService notificationService;

    @PostMapping("/send-otp")
    public ResponseEntity<Void> sendOtp(@RequestBody OtpEmailRequest request) {
        notificationService.sendOtp(request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/payment-success")
    public ResponseEntity<Void> sendPaymentSuccess(@RequestBody PaymentSuccessEmailRequest request) {
        notificationService.sendPaymentSuccess(request);
        return ResponseEntity.ok().build();
    }

    @PostMapping("/send-inquiry-otp")
    public ResponseEntity<Void> sendInquiryOtp(@RequestBody OtpEmailRequest request) {
        notificationService.sendInquiryOtp(request);
        return ResponseEntity.ok().build();
    }
}
