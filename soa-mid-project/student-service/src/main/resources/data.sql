-- Thêm các ngành học mẫu
INSERT INTO major (code, name) VALUES
                                   ('CNTT', 'Công nghệ thông tin'),
                                   ('QTKD', 'Quản trị kinh doanh'),
                                   ('KTE', 'Kinh tế học');

-- Thêm sinh viên mẫu (giả sử id ngành là 1, 2, 3 tương ứng)
INSERT INTO student (student_code, name, age, major_id, email, phone) VALUES
                                                                                      ('SV001', 'Nguyễn Văn A', 20, 1, 'a@example.com', '0123456789'),
                                                                                      ('SV002', 'Trần Thị B', 21, 1, 'b@example.com', '0987654321'),
                                                                                      ('SV003', 'Lê Văn C', 22, 2, 'c@example.com', '0911223344');
