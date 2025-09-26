package com.example.tuition_service.dto;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StudentDTO {
    @JsonProperty("id")
    private String studentId;
    private String studentCode;
    private String name;
    private String majorCode;
}