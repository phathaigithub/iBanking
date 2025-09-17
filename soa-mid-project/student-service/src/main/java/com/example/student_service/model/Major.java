package com.example.student_service.model;

import jakarta.persistence.*;
import lombok.*;

@Getter
@Setter
@NoArgsConstructor
@AllArgsConstructor
@Entity
@Table(name = "major")
public class Major {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private int id;

    @Column(nullable = false, unique = true)
    private String code;  // Ví dụ: "CNTT"

    @Column(nullable = false)
    private String name;  // Ví dụ: "Công nghệ thông tin"
}
