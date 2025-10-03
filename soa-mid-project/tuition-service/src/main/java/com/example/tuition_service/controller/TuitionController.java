package com.example.tuition_service.controller;

import java.util.List;

import com.example.tuition_service.dto.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.tuition_service.model.Tuition;
import com.example.tuition_service.service.TuitionService;

@RestController
@RequestMapping("/api/tuition")
public class TuitionController {
    
    private final TuitionService tuitionService;
    
    @Autowired
    public TuitionController(TuitionService tuitionService) {
        this.tuitionService = tuitionService;
    }


    @GetMapping("/student/{id}")
    public ResponseEntity<StudentTuitionResponse> getStudentTuitions(@PathVariable("id") int id) {
        StudentTuitionResponse response = tuitionService.getStudentTuitions(id);
        return ResponseEntity.ok(response);
    }
    
    @PatchMapping("/{tuitionId}/status")
    public ResponseEntity<TuitionDTO> updateTuitionStatus(
            @PathVariable("tuitionId") String tuitionId,
            @RequestBody StatusUpdateDTO statusUpdateDTO) {
        TuitionDTO updatedTuition = tuitionService.updateTuitionStatus(tuitionId, statusUpdateDTO);
        return ResponseEntity.ok(updatedTuition);
    }
    
    @PostMapping("/create-by-major")
    public ResponseEntity<TuitionMajorResponse> createTuitionByMajor(@RequestBody TuitionMajorRequest request) {
        TuitionMajorResponse result = tuitionService.createTuitionByMajor(request);
        return ResponseEntity.ok(result);
    }

    @GetMapping("/{tuitionCode}")
    public ResponseEntity<TuitionDTO> getTuitionByCode(@PathVariable("tuitionCode") String tuitionCode) {
        TuitionDTO tuition = tuitionService.getTuitionByCode(tuitionCode);
        if (tuition != null) {
            return ResponseEntity.ok(tuition);
        } else {
            return ResponseEntity.notFound().build();
        }
    }

    @DeleteMapping("/{tuitionId}")
    public ResponseEntity<Void> deleteTuition(@PathVariable String tuitionId) {
        tuitionService.deleteTuition(tuitionId);
        return ResponseEntity.noContent().build();
    }

    @PatchMapping("/{tuitionId}")
    public ResponseEntity<TuitionDTO> updateTuition(@PathVariable String tuitionId, @RequestBody TuitionDTO updateDTO) {
        TuitionDTO updated = tuitionService.updateTuition(tuitionId, updateDTO);
        return ResponseEntity.ok(updated);
    }

    @GetMapping("/all")
    public ResponseEntity<List<TuitionDTO>> getAllTuition() {
        List<TuitionDTO> tuitionList = tuitionService.getAllTuition();
        return ResponseEntity.ok(tuitionList);
    }

    @PostMapping("/inquiry/request")
    public ResponseEntity<ApiResponse> requestTuitionInquiry(@RequestBody TuitionInquiryRequest request) {
        tuitionService.requestTuitionInquiry(request.getStudentCode());
        ApiResponse response = new ApiResponse("OTP đã được gửi đến email của sinh viên. Vui lòng kiểm tra email.");
        return ResponseEntity.ok(response);
    }

    @PostMapping("/inquiry/verify")
    public ResponseEntity<StudentTuitionResponse> verifyOtpAndGetTuitions(@RequestBody OtpVerificationRequest request) {
        StudentTuitionResponse response = tuitionService.verifyOtpAndGetTuitions(
            request.getStudentCode(), request.getOtpCode());
        return ResponseEntity.ok(response);
    }
}