DROP TABLE IF EXISTS student;

CREATE TABLE student (
                         id INT PRIMARY KEY AUTO_INCREMENT,
                         student_code VARCHAR(50) NOT NULL UNIQUE,
                         name VARCHAR(100) NOT NULL,
                         age INT NOT NULL,
                         major VARCHAR(100),
                         email VARCHAR(100) UNIQUE,
                         phone VARCHAR(20) UNIQUE,
                         tuition_id INT
);
