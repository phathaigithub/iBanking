package com.example.payment_service.client;

import com.example.common_library.dto.UserResponse;
import com.example.common_library.dto.DeductBalanceRequest;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(name = "user-service")
public interface UserServiceClient {
    
    @GetMapping("/api/users/{id}")
    UserResponse getUser(@PathVariable("id") Long id);
    
    @PostMapping("/api/users/{userId}/deduct-balance")
    void deductBalance(@PathVariable("userId") Long userId, @RequestBody DeductBalanceRequest request);
}
