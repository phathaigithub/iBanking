package com.example.user_service.service;

import com.example.user_service.model.User;
import org.springframework.stereotype.Service;

import java.util.Optional;

@Service
public interface AuthService {

    Optional<User> findByUsername(String username);

    User login(String username, String password);

}
