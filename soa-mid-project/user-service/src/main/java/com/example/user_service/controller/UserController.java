package com.example.user_service.controller;

import com.example.user_service.dto.DeductBalanceRequest;
import com.example.user_service.dto.UserResponse;
import com.example.user_service.service.UserService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserService userService;

    @Autowired
    public UserController(UserService userService) {
        this.userService = userService;
    }

    @GetMapping("/{userId}")
    public ResponseEntity<UserResponse> getUserById(@PathVariable("userId") Long userId) {
        UserResponse userResponse = userService.getUserById(userId);
        return ResponseEntity.ok(userResponse);
    }

    @PostMapping("/{userId}/deduct-balance")
    public ResponseEntity<Void> deductBalance(@PathVariable("userId") Long userId, @RequestBody DeductBalanceRequest request) {
        userService.deductBalance(userId, request.getAmount());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{userId}/reserve-balance")
    public ResponseEntity<Void> reserveBalance(
            @PathVariable("userId") Long userId,
            @RequestBody DeductBalanceRequest request) {
        userService.reserveBalance(userId, request.getAmount());
        return ResponseEntity.ok().build();
    }

    @PostMapping("/{userId}/release-balance")
    public ResponseEntity<Void> releaseBalance(
            @PathVariable("userId") Long userId,
            @RequestBody DeductBalanceRequest request) {
        userService.releaseReservedBalance(userId, request.getAmount());
        return ResponseEntity.ok().build();
    }
}
