INSERT INTO tuitions (tuition_id, student_code, amount, semester, due_date, status, created_at)
VALUES
    ('T001', 'sv01', 150.00, '12025', '2025-10-01', 'Đã thanh toán', '2025-09-01 10:00:00'),

    -- Thêm học phí cho các test case
    -- Học phí hiện tại
    ('2202552200002', '52200002', 60000, '22025', '2025-12-15', 'Chưa thanh toán', CURRENT_TIMESTAMP),
    ('1202552200002', '52200002', 50000, '12025', '2025-12-15', 'Chưa thanh toán', CURRENT_TIMESTAMP);

