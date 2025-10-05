package com.example.payment_service.client;

import com.example.common_library.dto.TuitionDTO;
import com.example.common_library.dto.StatusUpdateDTO;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@FeignClient(name = "tuition-service")
public interface TuitionServiceClient {
    
    @GetMapping("/api/tuition/{tuitionCode}")
    TuitionDTO getTuition(@PathVariable("tuitionCode") String tuitionCode);
    
    @GetMapping("/api/tuition/all")
    List<TuitionDTO> getAllTuition();
    
    @PatchMapping("/api/tuition/{tuitionCode}/status")
    void updateTuitionStatus(@PathVariable("tuitionCode") String tuitionCode, @RequestBody StatusUpdateDTO statusUpdate);
}
