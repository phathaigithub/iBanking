CREATE DATABASE IF NOT EXISTS tuition_db;
USE tuition_db;

DROP TABLE IF EXISTS tuitions;

CREATE TABLE tuitions (
                          tuition_id VARCHAR(255) PRIMARY KEY,
                          student_id VARCHAR(255) NOT NULL,
                          amount DECIMAL(19, 2) NOT NULL,
                          semester VARCHAR(255) NOT NULL,
                          due_date DATE,
                          status VARCHAR(255) NOT NULL,
                          created_at TIMESTAMP
);
