
INSERT INTO payments (user_id, tuition_code, amount, status, otp_code, otp_expired_at, created_at, updated_at)
VALUES (1,  '12025sv1', 30000000, '', '123456', TIMESTAMPADD(MINUTE, 5, CURRENT_TIMESTAMP), CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);
