package com.example.tuition_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TuitionMajorRequest {
    private String semester;    // Định dạng: [1-3][YYYY] (VD: 12025)
    private String majorCode;
    private double amount;
    private String dueDate;     // Định dạng: dd-MM-yyyy (VD: 15-10-2025)
}