package com.example.student_service.dto;

import lombok.Data;

@Data
public class StudentDTO {
    private int id;
    private String studentCode;  // Mã số sinh viên
    private String name;         // Họ tên
    private int age;            // Tuổi
    private String email;       // Email sinh viên
    private String phone;       // Số điện thoại
    private String majorCode;   // Mã ngành học
    private String majorName;   // Tên ngành học
    
    public StudentDTO() {}
    
    // Constructor đầy đủ theo thứ tự model Student
    public StudentDTO(int id, String studentCode, String name, int age, String email, String phone, String majorCode, String majorName) {
        this.id = id;
        this.studentCode = studentCode;
        this.name = name;
        this.age = age;
        this.email = email;
        this.phone = phone;
        this.majorCode = majorCode;
        this.majorName = majorName;
    }
}
