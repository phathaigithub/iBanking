package com.example.tuition_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TuitionMajorRequest {
    private String semester;
    private String majorCode;
    private double amount;
}