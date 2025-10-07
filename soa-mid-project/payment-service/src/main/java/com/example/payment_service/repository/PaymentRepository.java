package com.example.payment_service.repository;

import com.example.payment_service.model.PaymentStatus;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import com.example.payment_service.model.Payment;
import java.time.LocalDateTime;
import java.util.List;

@Repository
public interface PaymentRepository extends JpaRepository<Payment, Long> {
    List<Payment> findByUserId(Long userId);
    List<Payment> findByTuitionCodeAndStatus(String tuitionCode, PaymentStatus status);
    List<Payment> findByStatusAndOtpExpiredAtBefore(PaymentStatus status, LocalDateTime time);
}