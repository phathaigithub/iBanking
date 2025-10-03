package com.example.tuition_service.service.impl;

import com.example.tuition_service.service.OtpService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.stereotype.Service;

import java.security.SecureRandom;
import java.util.concurrent.TimeUnit;

@Service
public class OtpServiceImpl implements OtpService {
    
    private static final String OTP_PREFIX = "tuition:otp:inquiry:";
    private static final int OTP_EXPIRE_MINUTES = 1;
    
    private final SecureRandom random = new SecureRandom();
    
    @Autowired
    private StringRedisTemplate redisTemplate;
    
    @Override
    public String generateOtp(String studentCode) {
        // Sinh OTP 6 chữ số
        String otp = String.format("%06d", random.nextInt(1000000));
        
        // Lưu OTP vào Redis với thời gian hết hạn
        String key = OTP_PREFIX + studentCode;
        redisTemplate.opsForValue().set(key, otp);
        redisTemplate.expire(key, OTP_EXPIRE_MINUTES, TimeUnit.MINUTES);
        
        return otp;
    }
    
    @Override
    public boolean verifyOtp(String studentCode, String otpCode) {
        String key = OTP_PREFIX + studentCode;
        String storedOtp = redisTemplate.opsForValue().get(key);
        
        if (storedOtp == null) {
            return false; // OTP không tồn tại hoặc đã hết hạn
        }
        
        return storedOtp.equals(otpCode);
    }
    
    @Override
    public void removeOtp(String studentCode) {
        String key = OTP_PREFIX + studentCode;
        redisTemplate.delete(key);
    }
}