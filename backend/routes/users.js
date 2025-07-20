const express = require('express');
const router = express.Router();

// Signup route
router.post('/signup', async (req, res) => {
  // Contoh: ambil data dari body
  const { full_name, email, phone, password } = req.body;
  if (!full_name || !email || !phone || !password) {
    return res.status(400).json({ error: 'All fields are required' });
  }
  try {
    const db = require('../config/db');
    // Contoh insert ke table users (pastikan table dan field wujud)
    await db.query(
      'INSERT INTO users (full_name, email, phone, password, created_at) VALUES (?, ?, ?, ?, NOW())',
      [full_name, email, phone, password]
    );
    res.sendStatus(200);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
