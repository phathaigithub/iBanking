package com.example.user_service.service;

import com.example.user_service.dto.UserResponse;
import com.example.user_service.model.User;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Optional;

@Service
public interface UserService {

    Optional<User> findByUsername(String username);
    
    UserResponse getUserById(Long userId);

    void deductBalance(Long userId, BigDecimal amount);

    void reserveBalance(Long userId, BigDecimal amount);

    void releaseReservedBalance(Long userId, BigDecimal amount);
}
