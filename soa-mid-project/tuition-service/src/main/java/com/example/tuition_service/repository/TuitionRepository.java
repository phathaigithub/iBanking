package com.example.tuition_service.repository;

import java.util.List;

import org.springframework.data.jpa.repository.JpaRepository;

import com.example.tuition_service.model.Tuition;

public interface TuitionRepository extends JpaRepository<Tuition, String> {
    List<Tuition> findByStudentCode(String studentCode);
}