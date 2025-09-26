package com.example.payment_service.dto;

import lombok.Data;

@Data
public class CreatePaymentRequest {
    private Long userId;
    private String tuitionCode;
    private Double amount;
}