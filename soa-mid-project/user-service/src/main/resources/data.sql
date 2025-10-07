-- Xóa dữ liệu hiện có để tránh trùng lặp
DELETE FROM user;

-- Tài khoản admin
INSERT INTO user (username, password, email, full_name, phone, balance, pending_amount, role) VALUES 
('admin', 'admin123', 'admin@example.com', 'Admin', '0123456789', 10000000, 0, 'ADMIN');

-- Tài khoản thử nghiệm với các số dư khác nhau
INSERT INTO user (username, password, email, full_name, phone, balance, pending_amount, role) VALUES
('user1', '123', 'phathai2902@gmail.com', 'User One', '0987654321', 100000, 0, 'USER'),
('test_race', '123', 'race@example.com', 'Race Condition Test', '0901234567', 150000, 0, 'USER'),
('limited_balance', '123', 'limited@example.com', 'Limited Balance User', '0909876543', 50000, 0, 'USER'),
('multi_payment', '123', 'multi@example.com', 'Multiple Payments', '0912345678', 200000, 0, 'USER');
