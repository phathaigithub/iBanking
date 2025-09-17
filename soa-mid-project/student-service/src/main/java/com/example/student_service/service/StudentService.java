package com.example.student_service.service;

import com.example.student_service.dto.StudentDTO;
import com.example.student_service.model.Student;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface StudentService {

    StudentDTO findStudentById(int id);

    List<StudentDTO> getAllStudents();

    public List<StudentDTO> findStudentsByMajorCode(String majorCode);
}
