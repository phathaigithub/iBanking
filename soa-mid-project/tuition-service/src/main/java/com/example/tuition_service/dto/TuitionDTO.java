package com.example.tuition_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TuitionDTO {
    private String tuitionId;
    private String studentCode;
    private String semester;
    private BigDecimal amount;
    private String status;
}