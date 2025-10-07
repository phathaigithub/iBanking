INSERT INTO tuitions (tuition_id, student_code, amount, semester, due_date, status, created_at)
VALUES
    ('T001', 'sv01', 150.00, '12025', '2025-10-01', 'Đã thanh toán', '2025-09-01 10:00:00'),

    -- Thêm học phí cho các test case
    -- Học phí hiện tại
    ('2202552200002', '52200002', 50000, '22025', '2025-12-15', 'Chưa thanh toán', CURRENT_TIMESTAMP),
    ('1202552200002', '52200002', 50000, '12025', '2025-06-15', 'Chưa thanh toán', CURRENT_TIMESTAMP),

    -- Học phí cho test race condition
    ('TEST-RACE-1', '52200003', 80000, '22025', '2025-12-15', 'Chưa thanh toán', CURRENT_TIMESTAMP),
    ('TEST-RACE-2', '52200003', 90000, '22025', '2025-12-15', 'Chưa thanh toán', CURRENT_TIMESTAMP),

    -- Học phí cho test số dư giới hạn
    ('LIMIT-TEST-1', '52200004', 40000, '22025', '2025-12-15', 'Chưa thanh toán', CURRENT_TIMESTAMP),
    ('LIMIT-TEST-2', '52200004', 20000, '22025', '2025-12-15', 'Chưa thanh toán', CURRENT_TIMESTAMP),

    -- Học phí cho test nhiều thanh toán
    ('MULTI-TEST-1', '52200005', 30000, '22025', '2025-12-15', 'Chưa thanh toán', CURRENT_TIMESTAMP),
    ('MULTI-TEST-2', '52200005', 30000, '22025', '2025-12-15', 'Chưa thanh toán', CURRENT_TIMESTAMP),
    ('MULTI-TEST-3', '52200005', 30000, '22025', '2025-12-15', 'Chưa thanh toán', CURRENT_TIMESTAMP),
    ('MULTI-TEST-4', '52200005', 30000, '22025', '2025-12-15', 'Chưa thanh toán', CURRENT_TIMESTAMP);

