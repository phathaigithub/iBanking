package com.example.tuition_service.client;

import java.util.Arrays;
import java.util.Collections;
import java.util.List;

import com.example.common_library.exception.ApiException;
import com.example.common_library.exception.ErrorCode;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.client.HttpClientErrorException;

import com.example.tuition_service.dto.StudentDTO;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;

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

    public StudentDTO getStudentByCode(String studentCode) {
        String url = "http://localhost:8080/student-service/api/students/code/" + studentCode;
        try {
            return restTemplate.getForObject(url, StudentDTO.class);
        } catch (HttpClientErrorException e) {
            // Parse error response để lấy message gốc từ student-service
            try {
                String responseBody = e.getResponseBodyAsString();
                ObjectMapper mapper = new ObjectMapper();
                JsonNode errorNode = mapper.readTree(responseBody);
                String errorCode = errorNode.get("errorCode").asText();
                String message = errorNode.get("message").asText();
                
                if ("STUDENT_NOT_FOUND".equals(errorCode)) {
                    throw new ApiException(ErrorCode.STUDENT_NOT_FOUND, message);
                } else {
                    throw new ApiException(ErrorCode.BAD_REQUEST, message);
                }
            } catch (Exception ex) {
                throw new ApiException(ErrorCode.STUDENT_NOT_FOUND, 
                    "Student with code '" + studentCode + "' not found");
            }
        }
    }
}