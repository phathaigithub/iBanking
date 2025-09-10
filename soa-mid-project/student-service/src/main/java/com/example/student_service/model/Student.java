package com.example.student_service.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;

@Getter
@Setter
@AllArgsConstructor
@NoArgsConstructor
@Entity
@Table(name = "student")  // bảng student trong schema.sql
public class Student {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY) // tự tăng trong DB
    private int id;

    @Column(nullable = false, unique = true)
    private String student_code;

    private String name;
    private int age;
    private String major;

    @Column(nullable = false, unique = true)
    private String email;

    private String phone;

    @Column(name = "tuition_id")
    private int tuitionId;
}
