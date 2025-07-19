CREATE TABLE IF NOT EXISTS appointments (
  id INT AUTO_INCREMENT PRIMARY KEY,
  user_id VARCHAR(64) NOT NULL,
  counselor_id INT NOT NULL,
  date DATE NOT NULL,
  time VARCHAR(16) NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (counselor_id) REFERENCES counselors(id)
  -- user_id should reference users(firebase_uid) if available
);
