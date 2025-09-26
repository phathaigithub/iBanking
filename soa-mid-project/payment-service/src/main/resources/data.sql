-- Giao dịch chờ OTP
INSERT INTO payments (user_id, tuition_code, amount, status, otp_code, otp_expired_at, created_at, updated_at)
VALUES (1,  '12025sv1', 30000000, 'PENDING_OTP', '123456', TIMESTAMPADD(MINUTE, 5, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Giao dịch đã thanh toán thành công
INSERT INTO payments (user_id, tuition_code, amount, status, created_at, updated_at)
VALUES (2,  '12025sv2', 30000000, 'SUCCESS', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Giao dịch thất bại
INSERT INTO payments (user_id, tuition_code, amount, status, created_at, updated_at)
VALUES (3,  '12025sv3', 30000000, 'FAILED', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
