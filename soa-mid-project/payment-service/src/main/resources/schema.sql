CREATE TABLE payments (
                          id BIGINT AUTO_INCREMENT PRIMARY KEY,
                          user_id BIGINT NOT NULL,              -- Người đóng tiền
                          student_id BIGINT NOT NULL,           -- Sinh viên được đóng
                          tuition_code VARCHAR(50) NOT NULL,    -- Mã học phí (vd: 12025sv01)
                          amount DECIMAL(15,2) NOT NULL,        -- Số tiền

                          status VARCHAR(20) NOT NULL,          -- PENDING_OTP, SUCCESS, FAILED, CANCELLED

                          otp_code VARCHAR(10),                 -- Mã OTP
                          otp_expired_at TIMESTAMP,             -- Hạn OTP

                          created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                          updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);
