package com.example.payment_service.service.impl;

import com.example.common_library.dto.*;
import com.example.common_library.dto.DeductBalanceRequest;
import com.example.common_library.exception.ApiException;
import com.example.common_library.exception.ErrorCode;
import com.example.payment_service.client.NotificationServiceClient;
import com.example.payment_service.client.TuitionServiceClient;
import com.example.payment_service.client.UserServiceClient;
import com.example.payment_service.dto.CreatePaymentRequest;
import com.example.payment_service.dto.OtpEmailRequest;
import com.example.payment_service.dto.TransactionHistoryDTO;
import com.example.payment_service.dto.*;
import com.example.payment_service.model.Payment;
import com.example.payment_service.model.PaymentStatus;
import com.example.payment_service.model.TransactionHistory;
import com.example.payment_service.repository.PaymentRepository;
import com.example.payment_service.repository.TransactionHistoryRepository;
import com.example.payment_service.service.PaymentService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;
import java.util.concurrent.TimeUnit;

@Service
public class PaymentServiceImp implements PaymentService {

    private static final String OTP_PREFIX = "payment:otp:";
    private static final int OTP_EXPIRE_MINUTES = 1;

    // Thêm constants
    private static final String OTP_ATTEMPT_PREFIX = "payment:otp:attempt:";
    private static final int MAX_OTP_ATTEMPTS = 3;

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private UserServiceClient userServiceClient;
    
    @Autowired
    private TuitionServiceClient tuitionServiceClient;
    
    @Autowired
    private NotificationServiceClient notificationServiceClient;

    @Autowired
    private TransactionHistoryRepository transactionHistoryRepository;
    
    @Autowired
    private StringRedisTemplate redisTemplate;

    @Override
    public Payment createPayment(CreatePaymentRequest request) {
        try {
            // Kiểm tra học phí tồn tại
            TuitionDTO tuition = getTuition(request.getTuitionCode());
            if (tuition == null) {
                throw new ApiException(ErrorCode.TUITION_NOT_FOUND);
            }
            
            // Kiểm tra học phí đã thanh toán chưa 
            if (tuition.getStatus() != null && tuition.getStatus().equals("Đã thanh toán")) {
                throw new ApiException(ErrorCode.PAYMENT_ALREADY_COMPLETED, 
                    "Học phí này đã được thanh toán. Không thể tạo giao dịch mới.");
            }
            
            // Kiểm tra có giao dịch đang chờ xác thực OTP cho học phí này không
            List<Payment> pendingPayments = paymentRepository.findByTuitionCodeAndStatus(
                request.getTuitionCode(), PaymentStatus.PENDING_OTP);

            if (!pendingPayments.isEmpty()) {
                Payment pendingPayment = pendingPayments.get(0);
                
                // Kiểm tra thời gian hết hạn
                boolean isExpired = pendingPayment.getOtpExpiredAt() == null || 
                                    pendingPayment.getOtpExpiredAt().isBefore(LocalDateTime.now());
                                    
                if (isExpired) {
                    // Nếu đã hết hạn, xóa để tạo mới
                    paymentRepository.delete(pendingPayment);
                } else if (pendingPayment.getUserId().equals(request.getUserId())) {
                    // Nếu là cùng người dùng và chưa hết hạn
                    throw new ApiException(ErrorCode.PAYMENT_IN_PROGRESS, 
                        "Bạn đã có phiên thanh toán đang chờ xác thực OTP cho học phí này. Vui lòng hoàn tất hoặc đợi hết hạn.");
                } else {
                    // Nếu là người dùng khác và chưa hết hạn
                    throw new ApiException(ErrorCode.PAYMENT_IN_PROGRESS, 
                        "Học phí này đang có người khác thanh toán. Vui lòng thử lại sau.");
                }
            }
            
            // Kiểm tra số tiền phải >= học phí
            BigDecimal paymentAmount = BigDecimal.valueOf(request.getAmount());
            if (paymentAmount.compareTo(tuition.getAmount()) < 0) {
                throw new ApiException(ErrorCode.AMOUNT_MISMATCH, 
                    "Số tiền thanh toán phải lớn hơn hoặc bằng học phí.");
            }
            
            // Kiểm tra user tồn tại
            UserResponse user = getUser(request.getUserId());
            if (user == null) {
                throw new ApiException(ErrorCode.USER_NOT_FOUND);
            }
            
            if (user.getEmail() == null || user.getEmail().isEmpty()) {
                throw new ApiException(ErrorCode.USER_EMAIL_NOT_FOUND);
            }

            
            // Khóa tạm thời số dư ngay khi tạo giao dịch
            DeductBalanceRequest reserveRequest = new DeductBalanceRequest();
            reserveRequest.setAmount(paymentAmount);
            
            try {
                userServiceClient.reserveBalance(request.getUserId(), reserveRequest);
            } catch (Exception e) {
                // Xử lý khi không đủ số dư
                String errorMessage = e.getMessage();
                
                // Kiểm tra xem lỗi có phải là INSUFFICIENT_BALANCE không
                if (errorMessage != null && errorMessage.contains("INSUFFICIENT_BALANCE")) {
                    throw new ApiException(ErrorCode.INSUFFICIENT_BALANCE, 
                        "Số dư tài khoản không đủ hoặc đã có giao dịch đang chờ xử lý.");
                }
                
                // Ném lại lỗi nếu không xác định được
                throw e;
            }
            
            // Sinh OTP
            String otp = String.valueOf(100000 + new Random().nextInt(900000));
            
            // Lưu thông tin payment
            Payment payment = new Payment();
            payment.setUserId(request.getUserId());
            payment.setTuitionCode(request.getTuitionCode());
            payment.setAmount(request.getAmount());
            payment.setStatus(PaymentStatus.PENDING_OTP);
            payment.setOtpExpiredAt(LocalDateTime.now().plusMinutes(OTP_EXPIRE_MINUTES));
            payment = paymentRepository.save(payment);
            
            // Lưu OTP vào Redis với thời gian hết hạn
            String redisKey = OTP_PREFIX + payment.getId();
            redisTemplate.opsForValue().set(redisKey, otp);
            redisTemplate.expire(redisKey, OTP_EXPIRE_MINUTES, TimeUnit.MINUTES);

            // Gửi OTP qua NotificationService
            OtpEmailRequest otpRequest = new OtpEmailRequest();
            otpRequest.setToEmail(user.getEmail());
            otpRequest.setOtpCode(otp);
            otpRequest.setExpireMinutes(OTP_EXPIRE_MINUTES);
            notificationServiceClient.sendOtp(otpRequest);

            // Lưu lịch sử giao dịch khi tạo phiên thanh toán - PENDING
            saveTransactionHistory(payment, "PENDING", "Payment session created, waiting for OTP verification");

            return payment;
            
        } catch (ApiException e) {
            // Nếu có lỗi nghiệp vụ, giải phóng số dư đã khóa (nếu có)
            try {
                if (request.getUserId() != null && request.getAmount() > 0) {
                    DeductBalanceRequest releaseRequest = new DeductBalanceRequest();
                    releaseRequest.setAmount(BigDecimal.valueOf(request.getAmount()));
                    userServiceClient.releaseBalance(request.getUserId(), releaseRequest);
                }
            } catch (Exception ignored) {
                // Không xử lý lỗi khi giải phóng số dư
            }
            
            // Xử lý lỗi như hiện tại...
            Payment failedPayment = new Payment();
            failedPayment.setUserId(request.getUserId());
            failedPayment.setTuitionCode(request.getTuitionCode());
            failedPayment.setAmount(request.getAmount());
            failedPayment.setStatus(PaymentStatus.FAILED);
            failedPayment = paymentRepository.save(failedPayment);
            
            saveTransactionHistory(failedPayment, "FAILED", "Payment failed: " + e.getMessage());
            throw e;
            
        } catch (Exception e) {
            // Nếu có lỗi hệ thống, giải phóng số dư đã khóa (nếu có)
            try {
                if (request.getUserId() != null && request.getAmount() > 0) {
                    DeductBalanceRequest releaseRequest = new DeductBalanceRequest();
                    releaseRequest.setAmount(BigDecimal.valueOf(request.getAmount()));
                    userServiceClient.releaseBalance(request.getUserId(), releaseRequest);
                }
            } catch (Exception ignored) {
                // Không xử lý lỗi khi giải phóng số dư
            }
            
            // Xử lý lỗi như hiện tại...
            Payment failedPayment = new Payment();
            failedPayment.setUserId(request.getUserId());
            failedPayment.setTuitionCode(request.getTuitionCode());
            failedPayment.setAmount(request.getAmount());
            failedPayment.setStatus(PaymentStatus.FAILED);
            failedPayment = paymentRepository.save(failedPayment);
            
            saveTransactionHistory(failedPayment, "FAILED", "System error: " + e.getMessage());
            throw new ApiException(ErrorCode.INTERNAL_ERROR, "Payment creation failed: " + e.getMessage());
        }
    }

    @Override
    public boolean verifyOtp(Long paymentId, String otpCode) {
        Payment payment = paymentRepository.findById(paymentId)
            .orElseThrow(() -> new ApiException(ErrorCode.PAYMENT_NOT_FOUND));
            
        if (payment.getStatus() == PaymentStatus.SUCCESS) {
            throw new ApiException(ErrorCode.PAYMENT_ALREADY_SUCCESS);
        }
        
        // Kiểm tra trạng thái học phí lần nữa để tránh race condition
        TuitionDTO tuition = getTuition(payment.getTuitionCode());
        if (tuition == null) {
            throw new ApiException(ErrorCode.TUITION_NOT_FOUND);
        }
        if ("Đã thanh toán".equals(tuition.getStatus())) {
            payment.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(payment);
            saveTransactionHistory(payment, "FAILED", "Tuition already paid by another user");
            throw new ApiException(ErrorCode.PAYMENT_ALREADY_COMPLETED, 
                "Học phí này đã được thanh toán bởi người khác.");
        }
        
        // Kiểm tra OTP từ Redis
        String redisKey = OTP_PREFIX + paymentId;
        String storedOtp = redisTemplate.opsForValue().get(redisKey);
        
        if (storedOtp == null) {
            payment.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(payment);
            saveTransactionHistory(payment, "FAILED", "OTP expired or not found");
            throw new ApiException(ErrorCode.OTP_EXPIRED);
        }
        
        if (!storedOtp.equals(otpCode)) {
            // Tăng số lần thử OTP không hợp lệ
            String attemptKey = OTP_ATTEMPT_PREFIX + paymentId;
            Integer attemptCount = redisTemplate.opsForValue().increment(attemptKey, 1).intValue();
            redisTemplate.expire(attemptKey, OTP_EXPIRE_MINUTES, TimeUnit.MINUTES);
            
            // Kiểm tra đã vượt quá số lần thử tối đa chưa
            if (attemptCount >= MAX_OTP_ATTEMPTS) {
                payment.setStatus(PaymentStatus.FAILED);
                paymentRepository.save(payment);
                saveTransactionHistory(payment, "FAILED", "Too many invalid OTP attempts");
                
                // Xử lý OTP sai như hiện tại...
                try {
                    DeductBalanceRequest releaseRequest = new DeductBalanceRequest();
                    releaseRequest.setAmount(BigDecimal.valueOf(payment.getAmount()));
                    userServiceClient.releaseBalance(payment.getUserId(), releaseRequest);
                } catch (Exception ignored) {
                    // Không xử lý lỗi khi giải phóng số dư
                }
                
                throw new ApiException(ErrorCode.OTP_INVALID, "Bạn đã nhập sai OTP quá nhiều lần. Giao dịch bị từ chối.");
            }
            
            saveTransactionHistory(payment, "FAILED", "Invalid OTP provided");
            throw new ApiException(ErrorCode.OTP_INVALID);
        }
        
        try {
            // Trừ số dư user qua UserService - số dư đã được khóa trước đó
            DeductBalanceRequest deductRequest = new DeductBalanceRequest();
            deductRequest.setAmount(BigDecimal.valueOf(payment.getAmount()));
            userServiceClient.deductBalance(payment.getUserId(), deductRequest);
                
            // Cập nhật trạng thái payment thành công
            payment.setStatus(PaymentStatus.SUCCESS);
            paymentRepository.save(payment);
            
            // Xóa OTP từ Redis sau khi xác thực thành công
            redisTemplate.delete(redisKey);

            // Lưu lịch sử giao dịch thành công
            saveTransactionHistory(payment, "SUCCESS", "Payment successful");

            // Gửi email xác nhận thành công qua NotificationService
            PaymentSuccessEmailRequest successRequest = new PaymentSuccessEmailRequest();
            UserResponse user = getUser(payment.getUserId());
            successRequest.setToEmail(user.getEmail());
            successRequest.setUserName(user.getFullName());
            successRequest.setTuitionCode(payment.getTuitionCode());
            successRequest.setAmount(BigDecimal.valueOf(payment.getAmount()));
            successRequest.setSemester(getSemester(payment.getTuitionCode()));
            notificationServiceClient.sendPaymentSuccess(successRequest);

            // Cập nhật trạng thái tuition sang "Đã thanh toán"
            updateTuitionStatus(payment.getTuitionCode(), "Đã thanh toán");

            return true;
            
        } catch (Exception e) {
            // Nếu lỗi khi trừ tiền, giải phóng số dư đã khóa
            try {
                DeductBalanceRequest releaseRequest = new DeductBalanceRequest();
                releaseRequest.setAmount(BigDecimal.valueOf(payment.getAmount()));
                userServiceClient.releaseBalance(payment.getUserId(), releaseRequest);
            } catch (Exception ignored) {
                // Không xử lý lỗi khi giải phóng số dư
            }
            
            payment.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(payment);
            redisTemplate.delete(redisKey);
            saveTransactionHistory(payment, "FAILED", "Payment verification failed: " + e.getMessage());
            
            if (e instanceof ApiException) {
                throw e;
            }
            throw new ApiException(ErrorCode.PAYMENT_PROCESSING_ERROR, 
                "Payment verification failed: " + e.getMessage());
        }
    }

    public Payment verifyOtpAndReturn(Long paymentId, String otpCode) {
        verifyOtp(paymentId, otpCode);
        return paymentRepository.findById(paymentId)
            .orElseThrow(() -> new ApiException(ErrorCode.PAYMENT_NOT_FOUND));
    }

    @Override
    public List<TransactionHistoryDTO> getTransactionHistoryWithTuition(Long userId) {
        List<TransactionHistory> histories = transactionHistoryRepository.findByUserId(userId);
        List<TransactionHistoryDTO> result = new ArrayList<>();
        for (TransactionHistory h : histories) {
            TransactionHistoryDTO dto = new TransactionHistoryDTO();
            dto.setId(h.getId());
            dto.setPaymentId(h.getPaymentId());
            dto.setTuitionCode(h.getTuitionCode());
            dto.setAmount(h.getAmount());
            dto.setStatus(h.getStatus());
            dto.setMessage(h.getMessage());
            dto.setCreatedAt(h.getCreatedAt());
            
            if (h.getTuitionCode() != null && !h.getTuitionCode().isEmpty()) {
                TuitionDTO tuition = getTuition(h.getTuitionCode());
                if (tuition != null) {
                    dto.setTuitionAmount(tuition.getAmount());
                    dto.setSemester(tuition.getSemester());
                }
            }
            result.add(dto);
        }
        return result;
    }

    @Override
    public List<TuitionDTO> getAllTuition() {
        return tuitionServiceClient.getAllTuition();
    }

    // Helper methods
    private TuitionDTO getTuition(String tuitionCode) {
        try {
            return tuitionServiceClient.getTuition(tuitionCode);
        } catch (Exception e) {
            return null;
        }
    }

    private UserResponse getUser(Long userId) {
        try {
            return userServiceClient.getUser(userId);
        } catch (Exception e) {
            return null;
        }
    }

    private String getSemester(String tuitionCode) {
        TuitionDTO tuition = getTuition(tuitionCode);
        return tuition != null ? tuition.getSemester() : "";
    }

    private void saveTransactionHistory(Payment payment, String status, String message) {
        TransactionHistory history = new TransactionHistory();
        if (payment.getId() != null) {
            history.setPaymentId(payment.getId());
        }
        history.setUserId(payment.getUserId());
        history.setTuitionCode(payment.getTuitionCode());
        history.setAmount(payment.getAmount());
        history.setStatus(status);
        history.setMessage(message);
        history.setCreatedAt(LocalDateTime.now());
        transactionHistoryRepository.save(history);
    }

    private void updateTuitionStatus(String tuitionCode, String newStatus) {
        StatusUpdateDTO statusUpdateDTO = new StatusUpdateDTO();
        statusUpdateDTO.setStatus(newStatus);
        try {
            tuitionServiceClient.updateTuitionStatus(tuitionCode, statusUpdateDTO);
        } catch (Exception e) {
            System.out.println("Error updating tuition status: " + e.getMessage());
        }
    }

    @Scheduled(fixedRate = 60000) // Chạy mỗi phút
    public void cleanupExpiredPayments() {
        try {
            System.out.println("Running scheduled cleanup of expired payments: " + LocalDateTime.now());
            
            List<Payment> expiredPayments = paymentRepository.findByStatusAndOtpExpiredAtBefore(
                PaymentStatus.PENDING_OTP, LocalDateTime.now());
                
            System.out.println("Found " + expiredPayments.size() + " expired payments");
            
            for (Payment payment : expiredPayments) {
                System.out.println("Processing expired payment ID: " + payment.getId() + 
                    ", expired at: " + payment.getOtpExpiredAt());
                    
                // Giải phóng số dư đã khóa
                try {
                    DeductBalanceRequest releaseRequest = new DeductBalanceRequest();
                    releaseRequest.setAmount(BigDecimal.valueOf(payment.getAmount()));
                    userServiceClient.releaseBalance(payment.getUserId(), releaseRequest);
                    System.out.println("Released reserved balance for payment ID: " + payment.getId());
                } catch (Exception e) {
                    System.err.println("Error releasing reserved balance: " + e.getMessage());
                }
                
                payment.setStatus(PaymentStatus.FAILED);
                paymentRepository.save(payment);
                System.out.println("Updated payment status to FAILED for ID: " + payment.getId());
                
                saveTransactionHistory(payment, "FAILED", "OTP expired automatically");
                System.out.println("Saved transaction history for expired payment ID: " + payment.getId());
                
                // Xóa OTP từ Redis
                String redisKey = OTP_PREFIX + payment.getId();
                redisTemplate.delete(redisKey);
            }
        } catch (Exception e) {
            System.err.println("Error in cleanup task: " + e.getMessage());
            e.printStackTrace();
        }
    }
}
