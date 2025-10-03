package com.example.student_service.controller;

import com.example.student_service.dto.CreateStudentRequest;
import com.example.student_service.dto.StudentDTO;
import com.example.student_service.model.Student;
import com.example.student_service.service.StudentService;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

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

    // Tạo sinh viên mới 
    @PostMapping
    public ResponseEntity<StudentDTO> createStudent(@RequestBody CreateStudentRequest request) {
        StudentDTO createdStudent = studentService.createStudent(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(createdStudent);
    }

    // Cập nhật sinh viên
    @PutMapping("/{id}")
    public ResponseEntity<StudentDTO> updateStudent(@PathVariable("id") int id, @RequestBody CreateStudentRequest request) {
        StudentDTO updatedStudent = studentService.updateStudent(id, request);
        return ResponseEntity.ok(updatedStudent);
    }

    // Xóa sinh viên
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteStudent(@PathVariable("id") int id) {
        studentService.deleteStudent(id);
        return ResponseEntity.noContent().build();
    }

    // Lấy sinh viên theo student code
    @GetMapping("/code/{studentCode}")
    public ResponseEntity<StudentDTO> getStudentByCode(@PathVariable("studentCode") String studentCode) {
        StudentDTO student = studentService.getStudentByCode(studentCode);
        return ResponseEntity.ok(student);
    }
}
