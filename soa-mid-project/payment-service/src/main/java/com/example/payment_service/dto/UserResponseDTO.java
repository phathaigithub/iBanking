package com.example.payment_service.dto;

import lombok.Data;
import java.math.BigDecimal;

@Data
public class UserResponseDTO {
    private Long id;
    private String username;
    private String fullName;
    private String email;
    private BigDecimal balance;
}
