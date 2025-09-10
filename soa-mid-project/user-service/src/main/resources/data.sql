-- Tài khoản admin
INSERT INTO user (username, password, email, full_name, phone, balance, role) VALUES 
('admin', 'admin123', 'admin@example.com', 'Admin User', '0123456789', 1000.00, 'ADMIN'),
('testuser', 'test123', 'test@example.com', 'Test User', '0444555666', 100.00, 'USER'),
('user1', 'password123', 'user1@example.com', 'User One', '0987654321', 500.00, 'USER'),
('user2', 'password456', 'user2@example.com', 'User Two', '0111222333', 300.00, 'USER');
