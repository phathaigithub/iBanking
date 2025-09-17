package com.example.tuition_service.client;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;

import com.example.tuition_service.dto.StudentDTO;

@Component
public class StudentServiceClient {

    private final RestTemplate restTemplate;
    private final String studentServiceUrl;

    @Autowired
    public StudentServiceClient(RestTemplate restTemplate, @Value("${student-service.url}") String studentServiceUrl) {
        this.restTemplate = restTemplate;
        this.studentServiceUrl = studentServiceUrl;
    }

    public List<StudentDTO> getStudentsByMajor(String majorCode) {
        try {
            String url = studentServiceUrl + "/api/students/major/" + majorCode;
            StudentDTO[] students = restTemplate.getForObject(url, StudentDTO[].class);
            
            if (students != null) {
                return Arrays.asList(students);
            }
            return Collections.emptyList();
        } catch (Exception e) {
            // Log lỗi ở đây
            e.printStackTrace();
            return Collections.emptyList();
        }
    }

    public StudentDTO getStudentById(int id) {
        System.out.println(studentServiceUrl + "/api/students/" + id);
        return restTemplate.getForObject( studentServiceUrl + "/api/students/" + id, StudentDTO.class);
    }
}