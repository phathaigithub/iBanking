package com.example.payment_service.service;

import com.example.payment_service.dto.CreatePaymentRequest;
import com.example.payment_service.dto.TransactionHistoryDTO;
import com.example.payment_service.model.Payment;

import java.util.List;

public interface PaymentService {
    Payment createPayment(CreatePaymentRequest request);
    boolean verifyOtp(Long paymentId, String otpCode);
    Payment verifyOtpAndReturn(Long paymentId, String otpCode);
    List<TransactionHistoryDTO> getTransactionHistoryWithTuition(Long userId);
}
