package com.example.user_service.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class DeductBalanceRequest {
    private BigDecimal amount;
}