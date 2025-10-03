package com.example.student_service.repository;

import com.example.student_service.model.Major;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

@Repository
public interface MajorRepository extends JpaRepository<Major, Integer> {
    Optional<Major> findByCode(String code);
    boolean existsByCode(String code);
}
