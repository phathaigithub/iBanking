DROP TABLE IF EXISTS student;
DROP TABLE IF EXISTS major;

CREATE TABLE major (
                       id INT PRIMARY KEY AUTO_INCREMENT,
                       code VARCHAR(10) NOT NULL UNIQUE,
                       name VARCHAR(100) NOT NULL
);

CREATE TABLE student (
                         id INT PRIMARY KEY AUTO_INCREMENT,
                         student_code VARCHAR(20) NOT NULL UNIQUE,
                         name VARCHAR(100),
                         age INT,
                         major_id INT NOT NULL,
                         email VARCHAR(100) NOT NULL UNIQUE,
                         phone VARCHAR(20),
                         CONSTRAINT fk_major FOREIGN KEY (major_id) REFERENCES major(id)
);
