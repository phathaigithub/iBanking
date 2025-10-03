package com.example.student_service.dto;

import lombok.Data;

@Data
public class CreateStudentRequest {
    private String studentCode;
    private String name;
    private int age;
    private String email;
    private String phone;
    private String majorCode;  
    
}