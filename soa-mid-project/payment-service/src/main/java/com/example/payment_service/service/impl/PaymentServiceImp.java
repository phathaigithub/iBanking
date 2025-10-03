package com.example.payment_service.service.impl;

import com.example.common_library.exception.ApiException;
import com.example.common_library.exception.ErrorCode;
import com.example.notification_service.dto.PaymentSuccessEmailRequest;
import com.example.payment_service.dto.CreatePaymentRequest;
import com.example.payment_service.dto.OtpEmailRequest;
import com.example.payment_service.dto.TransactionHistoryDTO;
import com.example.payment_service.model.Payment;
import com.example.payment_service.model.PaymentStatus;
import com.example.payment_service.model.TransactionHistory;
import com.example.payment_service.repository.PaymentRepository;
import com.example.payment_service.repository.TransactionHistoryRepository;
import com.example.payment_service.service.PaymentService;
import com.example.student_service.dto.StudentDTO;
import com.example.tuition_service.dto.StatusUpdateDTO;
import com.example.tuition_service.dto.TuitionDTO;
import com.example.user_service.dto.DeductBalanceRequest;
import com.example.user_service.dto.UserResponse;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.redis.core.StringRedisTemplate;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpMethod;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.math.BigDecimal;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Random;
import java.util.concurrent.TimeUnit;

@Service
public class PaymentServiceImp implements PaymentService {

    private static final String OTP_PREFIX = "payment:otp:";
    private static final int OTP_EXPIRE_MINUTES = 1;

    @Autowired
    private PaymentRepository paymentRepository;

    @Autowired
    private RestTemplate restTemplate;

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
            
            // Kiểm tra số dư user phải >= amount
            if (user.getBalance() == null || user.getBalance().compareTo(paymentAmount) < 0) {
                throw new ApiException(ErrorCode.INSUFFICIENT_BALANCE, 
                    "Số dư tài khoản không đủ để thanh toán.");
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
            // Không lưu OTP vào database nữa
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
            restTemplate.postForObject("http://localhost:8086/notification-service/api/notification/send-otp", 
                otpRequest, Void.class);

            // Lưu lịch sử giao dịch khi tạo phiên thanh toán - PENDING
            saveTransactionHistory(payment, "PENDING", "Payment session created, waiting for OTP verification");

            return payment;
            
        } catch (ApiException e) {
            // Với lỗi nghiệp vụ, lưu lịch sử và ném lại exception
            Payment failedPayment = new Payment();
            failedPayment.setUserId(request.getUserId());
            failedPayment.setTuitionCode(request.getTuitionCode());
            failedPayment.setAmount(request.getAmount());
            failedPayment.setStatus(PaymentStatus.FAILED);
            failedPayment = paymentRepository.save(failedPayment);
            
            saveTransactionHistory(failedPayment, "FAILED", "Payment failed: " + e.getMessage());
            throw e;
            
        } catch (Exception e) {
            // Với lỗi hệ thống, lưu lịch sử và ném ApiException
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
        
        // Kiểm tra OTP từ Redis
        String redisKey = OTP_PREFIX + paymentId;
        String storedOtp = redisTemplate.opsForValue().get(redisKey);
        
        // Trường hợp OTP không tồn tại hoặc đã hết hạn
        if (storedOtp == null) {
            payment.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(payment);
            saveTransactionHistory(payment, "FAILED", "OTP expired or not found");
            throw new ApiException(ErrorCode.OTP_EXPIRED);
        }
        
        // Trường hợp OTP không khớp
        if (!storedOtp.equals(otpCode)) {
            saveTransactionHistory(payment, "FAILED", "Invalid OTP provided");
            throw new ApiException(ErrorCode.OTP_INVALID);
        }
        
        try {
            // Trừ số dư user qua UserService
            DeductBalanceRequest deductRequest = new DeductBalanceRequest();
            deductRequest.setAmount(BigDecimal.valueOf(payment.getAmount()));
            restTemplate.postForObject("http://localhost:8086/user-service/api/users/" + 
                payment.getUserId() + "/deduct-balance", deductRequest, Void.class);
                
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
            successRequest.setAmount(payment.getAmount());
            successRequest.setSemester(getSemester(payment.getTuitionCode()));
            restTemplate.postForObject("http://localhost:8086/notification-service/api/notification/payment-success", 
                successRequest, Void.class);

            // Cập nhật trạng thái tuition sang "Đã thanh toán"
            updateTuitionStatus(payment.getTuitionCode(), "Đã thanh toán");

            return true;
            
        } catch (Exception e) {
            // Xử lý lỗi trong quá trình thanh toán
            payment.setStatus(PaymentStatus.FAILED);
            paymentRepository.save(payment);
            
            // Xóa OTP từ Redis khi thất bại
            redisTemplate.delete(redisKey);
            
            // Lưu lịch sử thất bại
            saveTransactionHistory(payment, "FAILED", "Payment verification failed: " + e.getMessage());
            
            if (e instanceof ApiException) {
                throw e;
            }
            throw new ApiException(ErrorCode.PAYMENT_PROCESSING_ERROR, 
                "Payment verification failed: " + e.getMessage());
        }
    }

    // Thêm phương thức mới
    public Payment verifyOtpAndReturn(Long paymentId, String otpCode) {
        verifyOtp(paymentId, otpCode); // vẫn giữ logic cũ
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
            
            // Lấy thông tin học phí (chỉ khi tuitionCode không null)
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
        String url = "http://localhost:8086/tuition-service/api/tuition/all";
        TuitionDTO[] tuitions = restTemplate.getForObject(url, TuitionDTO[].class);
        return tuitions != null ? Arrays.asList(tuitions) : new ArrayList<>();
    }

    // Helper methods
    private TuitionDTO getTuition(String tuitionCode) {
        String url = "http://localhost:8086/tuition-service/api/tuition/" + tuitionCode;
        try {
            return restTemplate.getForObject(url, TuitionDTO.class);
        } catch (Exception e) {
            return null;
        }
    }

    private UserResponse getUser(Long userId) {
        String url = "http://localhost:8086/user-service/api/users/" + userId;
        try {
            return restTemplate.getForObject(url, UserResponse.class);
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
        String url = "http://localhost:8086/tuition-service/api/tuition/" + tuitionCode + "/status";
        StatusUpdateDTO statusUpdateDTO = new StatusUpdateDTO();
        statusUpdateDTO.setStatus(newStatus);
        try {
            HttpEntity<StatusUpdateDTO> requestEntity = new HttpEntity<>(statusUpdateDTO);
            restTemplate.exchange(url, HttpMethod.PATCH, requestEntity, Void.class);
        } catch (Exception e) {
            System.out.println("Error updating tuition status: " + e.getMessage());
        }
    }
}
