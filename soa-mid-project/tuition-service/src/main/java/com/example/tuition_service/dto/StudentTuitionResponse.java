package com.example.tuition_service.dto;

import lombok.Data;
import java.util.List;

@Data
public class StudentTuitionResponse {
    private StudentInfo student;
    private List<TuitionInfo> tuitions;

    @Data
    public static class StudentInfo {
        private String studentCode;
        private String name;
        private String majorCode;
    }

    @Data
    public static class TuitionInfo {
        private String tuitionCode;
        private String semester;
        private double amount;
        private String status;
    }
}