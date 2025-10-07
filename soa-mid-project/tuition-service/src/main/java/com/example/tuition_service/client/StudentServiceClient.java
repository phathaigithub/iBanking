package com.example.tuition_service.client;

import java.util.List;

import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import com.example.common_library.dto.StudentDTO;

@FeignClient(name = "student-service")
public interface StudentServiceClient {

    @GetMapping("/api/students/major/{majorCode}")
    List<StudentDTO> getStudentsByMajor(@PathVariable("majorCode") String majorCode);

    @GetMapping("/api/students/{id}")
    StudentDTO getStudentById(@PathVariable("id") int id);

    @GetMapping("/api/students/code/{studentCode}")
    StudentDTO getStudentByCode(@PathVariable("studentCode") String studentCode);
}
