-- Thêm các ngành học mẫu
INSERT INTO major (code, name) VALUES
                                   ('CNTT', 'Công nghệ thông tin'),
                                   ('QTKD', 'Quản trị kinh doanh'),
                                   ('KTE', 'Kinh tế học');

-- Thêm sinh viên mẫu (giả sử id ngành là 1, 2, 3 tương ứng)
INSERT INTO student (student_code, name, age, major_id, email, phone) VALUES
                                                                                      ('sv1', 'Nguyễn Văn A', 20, 1, 'a@example.com', '0123456789'),
                                                                                      ('52200002', 'Bui Le Phat Hai', 21, 1, 'phathai2902@gmail.com', '0987654321'),
                                                                                      ('sv3', 'Nguyễn Văn C', 20, 2, 'C@example.com', '0123457789');
