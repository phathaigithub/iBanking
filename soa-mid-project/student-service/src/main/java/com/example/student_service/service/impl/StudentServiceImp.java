package com.example.student_service.service.impl;

import com.example.common_library.exception.ApiException;
import com.example.common_library.exception.ErrorCode;
import com.example.student_service.dto.CreateStudentRequest;
import com.example.student_service.dto.StudentDTO;
import com.example.student_service.model.Major;
import com.example.student_service.model.Student;
import com.example.student_service.repository.MajorRepository;
import com.example.student_service.repository.StudentRepository;
import com.example.student_service.service.StudentService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

@Service
public class StudentServiceImp implements StudentService {

     private final StudentRepository studentRepository;
     private final MajorRepository majorRepository;

     public StudentServiceImp(StudentRepository studentRepository, MajorRepository majorRepository) {
         this.studentRepository = studentRepository;
         this.majorRepository = majorRepository;
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
        // Kiểm tra major có tồn tại không
        if (!majorRepository.existsByCode(majorCode)) {
            throw new ApiException(ErrorCode.MAJOR_NOT_FOUND, "Major with code '" + majorCode + "' not found");
        }
        
        List<Student> students = studentRepository.findByMajorCode(majorCode);
        return students.stream()
                .map(this::convertToDTO)
                .collect(Collectors.toList());
    }
    
    @Override
    public StudentDTO createStudent(CreateStudentRequest request) {
        if (studentRepository.existsByStudentCode(request.getStudentCode())) {
            throw new ApiException(ErrorCode.STUDENT_ALREADY_EXISTS);
        }
        
        Major major = majorRepository.findByCode(request.getMajorCode())
                .orElseThrow(() -> new ApiException(ErrorCode.MAJOR_NOT_FOUND));
        
        Student student = new Student();
        student.setStudentCode(request.getStudentCode());
        student.setName(request.getName());
        student.setAge(request.getAge());
        student.setEmail(request.getEmail());
        student.setPhone(request.getPhone());
        student.setMajor(major);
        
        Student savedStudent = studentRepository.save(student);
        return convertToDTO(savedStudent);
    }

    @Override
    public StudentDTO updateStudent(int id, CreateStudentRequest request) {
        Student student = studentRepository.findById(id)
                .orElseThrow(() -> new ApiException(ErrorCode.STUDENT_NOT_FOUND));
        
        Major major = majorRepository.findByCode(request.getMajorCode())
                .orElseThrow(() -> new ApiException(ErrorCode.MAJOR_NOT_FOUND));
        
        student.setName(request.getName());
        student.setAge(request.getAge());
        student.setEmail(request.getEmail());
        student.setPhone(request.getPhone());
        student.setMajor(major);
        
        Student updatedStudent = studentRepository.save(student);
        return convertToDTO(updatedStudent);
    }

    @Override
    public void deleteStudent(int id) {
        if (!studentRepository.existsById(id)) {
            throw new ApiException(ErrorCode.STUDENT_NOT_FOUND);
        }
        studentRepository.deleteById(id);
    }

    @Override
    public StudentDTO getStudentByCode(String studentCode) {
        Student student = studentRepository.findByStudentCode(studentCode)
                .orElseThrow(() -> new ApiException(ErrorCode.STUDENT_NOT_FOUND));
        return convertToDTO(student);
    }

    private StudentDTO convertToDTO(Student student) {
        return new StudentDTO(
            student.getId(),
            student.getStudentCode(),    // Mã số sinh viên
            student.getName(),           // Họ tên
            student.getAge(),            // Tuổi 
            student.getEmail(),          // Email sinh viên
            student.getPhone(),          // Số điện thoại 
            student.getMajor().getCode(),    // Mã ngành học
            student.getMajor().getName()     // Tên ngành học
        );
    }
}
