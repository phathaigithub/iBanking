package com.example.tuition_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentTuitionResponse {
    private StudentInfo student;
    private List<TuitionInfo> tuitions;
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class StudentInfo {
        private String studentCode;
        private String name;
        private String majorCode;
        private String majorName; 
        private String email;     
    }
    
    @Data
    @NoArgsConstructor
    @AllArgsConstructor
    public static class TuitionInfo {
        private String tuitionId;     
        private String semester;
        private BigDecimal amount;    
        private String status;
        private LocalDate dueDate;    
        private LocalDateTime createdAt; 
    }
}