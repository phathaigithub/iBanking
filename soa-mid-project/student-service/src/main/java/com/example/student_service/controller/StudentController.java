package com.example.student_service.controller;

import com.example.student_service.dto.StudentDTO;
import com.example.student_service.model.Student;
import com.example.student_service.service.StudentService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;

@RestController
@RequestMapping ("/api/students")
public class StudentController {

    private final StudentService studentService;

    public StudentController(StudentService studentService) {
        this.studentService = studentService;
    }

    @GetMapping
    ResponseEntity<List<StudentDTO>> getAllStudents() {
        List<StudentDTO> students = studentService.getAllStudents();
        return ResponseEntity.ok(students);
    }

    @GetMapping("/{id}")
    public ResponseEntity<StudentDTO> getStudentById(@PathVariable("id") int id) {
        StudentDTO student = studentService.findStudentById(id);
        return ResponseEntity.ok(student);
    }
    
    @GetMapping("/major/{code}")
    public ResponseEntity<List<StudentDTO>> getStudentsByMajorCode(@PathVariable("code") String code) {
        List<StudentDTO> students = studentService.findStudentsByMajorCode(code);
        return ResponseEntity.ok(students);
    }
}
