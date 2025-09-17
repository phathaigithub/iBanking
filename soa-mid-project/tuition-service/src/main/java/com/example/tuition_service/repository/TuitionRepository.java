package com.example.tuition_service.repository;

import com.example.tuition_service.model.Tuition;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface TuitionRepository extends JpaRepository<Tuition, String> {
    List<Tuition> findByStudentId(String studentId);
}