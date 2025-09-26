package com.example.payment_service.dto;

import lombok.Data;
import java.math.BigDecimal;
import java.time.LocalDateTime;

@Data
public class TransactionHistoryDTO {
    private Long id;
    private Long paymentId;
    private String tuitionCode;
    private Double amount;
    private String status;
    private String message;
    private LocalDateTime createdAt;
    // Thông tin học phí
    private BigDecimal tuitionAmount;
    private String semester;
}
