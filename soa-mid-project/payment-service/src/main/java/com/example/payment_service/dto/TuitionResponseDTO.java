package com.example.payment_service.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class TuitionResponseDTO {
    private String tuitionCode;
    private String studentCode;
    private String semester;
    private BigDecimal amount;
    private String status;
}
