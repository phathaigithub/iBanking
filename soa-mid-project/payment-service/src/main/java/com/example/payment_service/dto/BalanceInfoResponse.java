package com.example.payment_service.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class BalanceInfoResponse {
    private Long userId;
    private String username;
    private BigDecimal totalBalance;
    private BigDecimal pendingAmount;
    private BigDecimal availableBalance;
}