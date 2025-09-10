package com.example.student_service.service.imp;

import com.example.common_library.exception.ApiException;
import com.example.common_library.exception.ErrorCode;
import com.example.student_service.model.Student;
import com.example.student_service.repository.StudentRepository;
import com.example.student_service.service.StudentService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;

@Service
public class StudentServiceImp implements StudentService {

     StudentRepository studentRepository;

     public StudentServiceImp(StudentRepository studentRepository) {
         this.studentRepository = studentRepository;
     }

    public List<Student> getAllStudents() {
        return studentRepository.findAll();
    }

    @Override
    public Student findStudentById(int id) {
        Optional<Student> student = studentRepository.findById(id);
        return student.orElseThrow(() -> new ApiException(ErrorCode.STUDENT_NOT_FOUND));
    }
}
