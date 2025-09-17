package com.example.tuition_service.controller;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import com.example.tuition_service.dto.StatusUpdateDTO;
import com.example.tuition_service.dto.StudentTuitionResponse;
import com.example.tuition_service.dto.TuitionDTO;
import com.example.tuition_service.dto.TuitionMajorRequest;
import com.example.tuition_service.dto.TuitionMajorResponse;
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
    
    @PostMapping
    public ResponseEntity<Tuition> createTuition(@RequestBody Tuition tuition) {
        Tuition createdTuition = tuitionService.createTuition(tuition);
        return new ResponseEntity<>(createdTuition, HttpStatus.CREATED);
    }

    @GetMapping("/student/{id}")
    public ResponseEntity<StudentTuitionResponse> getStudentTuitions(@PathVariable("id") int id) {
        StudentTuitionResponse response = tuitionService.getStudentTuitions(id);
        return ResponseEntity.ok(response);
    }
    
    @PatchMapping("/{tuitionId}/status")
    public ResponseEntity<TuitionDTO> updateTuitionStatus(
            @PathVariable String tuitionId,
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
    public ResponseEntity<TuitionDTO> getTuitionByCode(@PathVariable String tuitionCode) {
        TuitionDTO tuition = tuitionService.getTuitionByCode(tuitionCode);
        if (tuition != null) {
            return ResponseEntity.ok(tuition);
        } else {
            return ResponseEntity.notFound().build();
        }
    }
}