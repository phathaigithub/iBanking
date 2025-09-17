package com.example.tuition_service.dto;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TuitionMajorResponse {
    private String semester;
    private String majorCode;
    private List<TuitionResponse> tuitions;
}