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
    
    @GetMapping("/api/tuition")
    List<TuitionDTO> getAllTuition();
    
    // Thay PATCH bằng PUT để tránh vấn đề với Feign
    @PutMapping("/api/tuition/{tuitionCode}/status")
    TuitionDTO updateTuitionStatus(@PathVariable("tuitionCode") String tuitionCode, @RequestBody StatusUpdateDTO statusUpdate);
}
