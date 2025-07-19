CREATE TABLE IF NOT EXISTS emotion_logs (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id VARCHAR(255) NOT NULL,
    joy VARCHAR(50),
    anger VARCHAR(50),
    sorrow VARCHAR(50),
    surprise VARCHAR(50),
    confidence FLOAT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(firebase_uid)
);
