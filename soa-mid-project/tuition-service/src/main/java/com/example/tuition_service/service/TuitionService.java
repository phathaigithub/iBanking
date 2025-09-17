package com.example.tuition_service.service;

import java.util.List;

import com.example.tuition_service.dto.*;
import com.example.tuition_service.model.Tuition;

public interface TuitionService {
    
    Tuition createTuition(Tuition tuition);

    TuitionDTO updateTuitionStatus(String tuitionId, StatusUpdateDTO statusUpdateDTO);
    
    TuitionMajorResponse createTuitionByMajor(TuitionMajorRequest request);

    TuitionDTO getTuitionByCode(String tuitionCode);
    
    StudentTuitionResponse getStudentTuitions(int studentId);
}
