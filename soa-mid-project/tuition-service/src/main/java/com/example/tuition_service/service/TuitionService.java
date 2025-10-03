package com.example.tuition_service.service;

import org.springframework.stereotype.Service;

import com.example.tuition_service.dto.StatusUpdateDTO;
import com.example.tuition_service.dto.StudentTuitionResponse;
import com.example.tuition_service.dto.TuitionDTO;
import com.example.tuition_service.dto.TuitionMajorRequest;
import com.example.tuition_service.dto.TuitionMajorResponse;

import java.util.List;

@Service
public interface TuitionService {
    
//    Tuition createTuition(Tuition tuition);

    TuitionDTO updateTuitionStatus(String tuitionId, StatusUpdateDTO statusUpdateDTO);
    
    TuitionMajorResponse createTuitionByMajor(TuitionMajorRequest request);

    TuitionDTO getTuitionByCode(String tuitionCode);
    
    StudentTuitionResponse getStudentTuitions(int studentId);


    void deleteTuition(String tuitionId);

    TuitionDTO updateTuition(String tuitionId, TuitionDTO updateDTO);

    List<TuitionDTO> getAllTuition();

    void requestTuitionInquiry(String studentCode);
    StudentTuitionResponse verifyOtpAndGetTuitions(String studentCode, String otpCode);
}
