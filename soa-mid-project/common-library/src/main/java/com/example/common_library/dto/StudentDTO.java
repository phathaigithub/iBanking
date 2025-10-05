package com.example.common_library.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentDTO {
    private int id;
    private String studentCode;  // Mã số sinh viên
    private String name;         // Họ tên
    private int age;            // Tuổi
    private String email;       // Email sinh viên
    private String phone;       // Số điện thoại
    private String majorCode;   // Mã ngành học
    private String majorName;   // Tên ngành học
}
