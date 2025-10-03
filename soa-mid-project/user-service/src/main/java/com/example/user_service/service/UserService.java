package com.example.user_service.service;

import com.example.tuition_service.model.Tuition;
import com.example.user_service.dto.UserResponse;
import com.example.user_service.model.User;
import jakarta.persistence.LockModeType;
import org.springframework.data.jpa.repository.Lock;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.Optional;

@Service
public interface UserService {

    Optional<User> findByUsername(String username);
    
    UserResponse getUserById(Long userId);

    void deductBalance(Long userId, BigDecimal amount);

}
