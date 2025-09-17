package com.example.student_service.service.imp;

import com.example.common_library.exception.ApiException;
import com.example.common_library.exception.ErrorCode;
import com.example.student_service.dto.StudentDTO;
import com.example.student_service.model.Student;
import com.example.student_service.repository.StudentRepository;
import com.example.student_service.service.StudentService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class StudentServiceImp implements StudentService {

     private final StudentRepository studentRepository;

     public StudentServiceImp(StudentRepository studentRepository) {
         this.studentRepository = studentRepository;
     }

    @Override
    public List<StudentDTO> getAllStudents() {
        List<Student> students = studentRepository.findAll();
        return students.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }

    @Override
    public StudentDTO findStudentById(int id) {
        Optional<Student> studentOptional = studentRepository.findById(id);
        Student student = studentOptional.orElseThrow(() -> new ApiException(ErrorCode.STUDENT_NOT_FOUND));
        return convertToDTO(student);
    }

    @Override
    public List<StudentDTO> findStudentsByMajorCode(String majorCode) {
        List<Student> students = studentRepository.findByMajorCode(majorCode);
        return students.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    private StudentDTO convertToDTO(Student student) {
        return new StudentDTO(
            student.getId(),
            student.getName(),
            student.getEmail(),
            student.getMajor() != null ? student.getMajor().getCode() : null,
            student.getMajor() != null ? student.getMajor().getName() : null
        );
    }
}
