package com.example.payment_service.service;

import com.example.payment_service.dto.CreatePaymentRequest;
import com.example.payment_service.model.Payment;

public interface PaymentService {
    Payment createPayment(CreatePaymentRequest request);
    boolean verifyOtp(Long paymentId, String otpCode);
}
