package com.example.student_service.repository;

import com.example.student_service.model.Student;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface StudentRepository extends JpaRepository<Student, Integer> {
    
    List<Student> findByMajorCode(String majorCode);
    boolean existsByStudentCode(String studentCode);
    Optional<Student> findByStudentCode(String studentCode);
}
