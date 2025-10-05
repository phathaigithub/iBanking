package com.example.payment_service.controller;

import com.example.common_library.dto.TuitionDTO;
import com.example.payment_service.dto.CreatePaymentRequest;
import com.example.payment_service.dto.TransactionHistoryDTO;
import com.example.payment_service.dto.VerifyOtpRequest;
import com.example.payment_service.model.Payment;
import com.example.payment_service.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

@RestController
@RequestMapping("/api/payments")
public class PaymentController {

    private final PaymentService paymentService;

    @Autowired
    public PaymentController(PaymentService paymentService) {
        this.paymentService = paymentService;
    }

    // Tạo payment, gửi OTP
    @PostMapping
    public ResponseEntity<Payment> createPayment(@RequestBody CreatePaymentRequest request) {
        Payment payment = paymentService.createPayment(request);
        return ResponseEntity.ok(payment);
    }

    // Xác thực OTP
    @PostMapping("/{id}/verify-otp")
    public ResponseEntity<Payment> verifyOtp(
        @PathVariable("id") Long paymentId,
        @RequestBody VerifyOtpRequest request) {

        Payment payment = paymentService.verifyOtpAndReturn(paymentId, request.getOtpCode());
        return ResponseEntity.ok(payment);
    }

    @GetMapping("/history/{userId}")
    public ResponseEntity<List<TransactionHistoryDTO>> getTransactionHistory(
        @PathVariable("userId") Long userId) {

        List<TransactionHistoryDTO> history = paymentService.getTransactionHistoryWithTuition(userId);
        return ResponseEntity.ok(history);
    }

    @GetMapping("/tuition/all")
    public ResponseEntity<List<TuitionDTO>> getAllTuition() {
        List<TuitionDTO> tuitionList = paymentService.getAllTuition();
        return ResponseEntity.ok(tuitionList);
    }
}
