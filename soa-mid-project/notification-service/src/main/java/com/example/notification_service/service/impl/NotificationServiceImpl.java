package com.example.notification_service.service.impl;

import com.example.notification_service.dto.OtpEmailRequest;
import com.example.notification_service.dto.PaymentSuccessEmailRequest;
import com.example.notification_service.service.NotificationService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.SimpleMailMessage;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.stereotype.Service;

@Service
public class NotificationServiceImpl implements NotificationService {

    @Autowired
    private JavaMailSender mailSender;

    @Override
    public void sendOtp(OtpEmailRequest request) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(request.getToEmail());
        message.setSubject("Mã OTP xác thực thanh toán học phí");
        message.setText("Mã OTP của bạn là: " + request.getOtpCode() +
                "\nThời hạn: " + request.getExpireMinutes() + " phút.");
        mailSender.send(message);
    }

    @Override
    public void sendPaymentSuccess(PaymentSuccessEmailRequest request) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(request.getToEmail());
        message.setSubject("Xác nhận thanh toán học phí thành công");
        message.setText("Chào " + request.getUserName() +
                ",\nBạn đã thanh toán thành công học phí mã: " + request.getTuitionCode() +
                " cho sinh viên \nSố tiền: " + request.getAmount() +
                "\nHọc kỳ: HK" + request.getSemester().charAt(0) + " năm " + request.getSemester().substring(1));
        mailSender.send(message);
    }

    @Override
    public void sendInquiryOtp(OtpEmailRequest request) {
        SimpleMailMessage message = new SimpleMailMessage();
        message.setTo(request.getToEmail());
        message.setSubject("Mã OTP tra cứu thông tin học phí");
        message.setText("Chào sinh viên" + ",\n\n" +
                "Bạn vừa yêu cầu tra cứu thông tin học phí.\n" +
                "Mã OTP của bạn là: " + request.getOtpCode() + "\n" +
                "Thời hạn: " + request.getExpireMinutes() + " phút.\n\n" +
                "Vui lòng không chia sẻ mã này với bất kỳ ai.\n\n" +
                "Trân trọng,\n" +
                "Hệ thống iBanking");
        mailSender.send(message);
    }
}
