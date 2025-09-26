package com.example.student_service.dto;

import lombok.Data;

@Data
public class StudentDTO {
    private int id;
    private String name;
    private String studentCode;
    private String email;
    private String majorCode;
    private String majorName;
    
    // Constructors, getters, setters
    
    public StudentDTO() {}
    
    public StudentDTO(int id, String studentCode, String name, String email, String majorCode, String majorName) {
        this.id = id;
        this.name = name;
        this.studentCode = studentCode;
        this.email = email;
        this.majorCode = majorCode;
        this.majorName = majorName;
    }
    
}
