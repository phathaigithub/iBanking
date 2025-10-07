package com.example.common_library.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class PaymentSuccessEmailRequest {
    private String toEmail;       // Thay vì "to"
    private String userName;      // Thay vì "studentName"
    private String tuitionCode;
    private BigDecimal amount;
    private String semester;      // Thêm field này
}
