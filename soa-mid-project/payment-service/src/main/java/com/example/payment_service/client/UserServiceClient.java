package com.example.payment_service.client;

import com.example.common_library.dto.DeductBalanceRequest;
import com.example.common_library.dto.UserResponse;
import org.springframework.cloud.openfeign.FeignClient;
import org.springframework.web.bind.annotation.*;

@FeignClient(name = "user-service")
public interface UserServiceClient {
    
    @GetMapping("/api/users/{userId}")
    UserResponse getUser(@PathVariable("userId") Long userId); // Thêm "userId"
    
    @PostMapping("/api/users/{userId}/deduct-balance")
    void deductBalance(@PathVariable("userId") Long userId, @RequestBody DeductBalanceRequest request); // Thêm "userId"
    
    @PostMapping("/api/users/{userId}/reserve-balance")
    void reserveBalance(@PathVariable("userId") Long userId, @RequestBody DeductBalanceRequest request); // Thêm "userId"
    
    @PostMapping("/api/users/{userId}/release-balance")
    void releaseBalance(@PathVariable("userId") Long userId, @RequestBody DeductBalanceRequest request); // Thêm "userId"
}
