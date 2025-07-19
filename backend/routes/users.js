const express = require('express');
const router = express.Router();
const db = require('../config/db'); // Pastikan path ni betul ikut config sebenar awak

router.post('/', async (req, res) => {
  const { firebase_uid, email, full_name, phone } = req.body;

  if (!firebase_uid || !email || !full_name || !phone) {
    return res.status(400).json({ message: 'Missing required fields' });
  }

  try {
    const [result] = await db.query(
      'INSERT INTO users (firebase_uid, email, full_name, phone) VALUES (?, ?, ?, ?)',
      [firebase_uid, email, full_name, phone]
    );

    return res.status(200).json({ message: 'User saved successfully', id: result.insertId });
  } catch (error) {
    console.error('Database error:', error);
    return res.status(500).json({ message: 'Database error', error });
  }
});

module.exports = router;
