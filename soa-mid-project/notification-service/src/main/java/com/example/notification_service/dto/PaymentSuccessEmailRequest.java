package com.example.notification_service.dto;

import lombok.Data;

@Data
public class PaymentSuccessEmailRequest {
    private String toEmail;
    private String userName;
    private String tuitionCode;
    private Double amount;
    private String semester;

    // getters và setters
}

