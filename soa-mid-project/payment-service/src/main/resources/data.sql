-- Giao dịch chờ OTP
INSERT INTO payments (user_id, student_id, tuition_code, amount, status, otp_code, otp_expired_at, created_at, updated_at)
VALUES (1, 101, '12025sv01', 30000000, 'PENDING_OTP', '123456', TIMESTAMPADD(MINUTE, 5, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Giao dịch đã thanh toán thành công
INSERT INTO payments (user_id, student_id, tuition_code, amount, status, created_at, updated_at)
VALUES (2, 102, '12025sv02', 30000000, 'SUCCESS', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Giao dịch thất bại
INSERT INTO payments (user_id, student_id, tuition_code, amount, status, created_at, updated_at)
VALUES (3, 103, '12025sv03', 30000000, 'FAILED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
