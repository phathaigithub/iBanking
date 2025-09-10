package com.example.student_service.service;

import com.example.student_service.model.Student;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public interface StudentService {

    Student findStudentById(int id);

    List<Student> getAllStudents();

}
