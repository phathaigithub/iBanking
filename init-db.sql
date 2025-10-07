-- Initialize databases for iBanking microservices

-- Create user database
CREATE DATABASE IF NOT EXISTS user_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create student database
CREATE DATABASE IF NOT EXISTS student_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Create tuition database (shared with payment service)
CREATE DATABASE IF NOT EXISTS tuition_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant privileges
GRANT ALL PRIVILEGES ON user_db.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON student_db.* TO 'root'@'%';
GRANT ALL PRIVILEGES ON tuition_db.* TO 'root'@'%';

FLUSH PRIVILEGES;
