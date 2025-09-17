package com.example.tuition_service.model;

import jakarta.persistence.*;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

@Entity
@Table(name = "tuitions")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Tuition {
    
    @Id
    @Column(name = "tuition_id")
    private String tuitionId;
    
    @Column(name = "student_id", nullable = false)
    private String studentId;
    
    @Column(nullable = false)
    private BigDecimal amount;
    
    @Column(nullable = false)
    private String semester;
    
    @Column(name = "due_date")
    private LocalDate dueDate;
    
    @Column(nullable = false)
    private String status;
    
    @Column(name = "created_at")
    private LocalDateTime createdAt;
    
    @PrePersist
    protected void onCreate() {
        if (createdAt == null) {
            createdAt = LocalDateTime.now();
        }
    }
}
