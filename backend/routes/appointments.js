const express = require('express');
const router = express.Router();

router.post('/', async (req, res) => {
  const { appointment_date, appointment_time, counselor_name } = req.body;
  if (!appointment_date || !appointment_time || !counselor_name ||
      appointment_date.trim() === '' || appointment_time.trim() === '' || counselor_name.trim() === '') {
    return res.status(400).json({ error: 'All fields are required' });
  }
  try {
    const db = require('../config/db');
    await db.query(
      'INSERT INTO appointments (appointment_date, appointment_time, counselor_name, created_at) VALUES (?, ?, ?, NOW())',
      [appointment_date, appointment_time, counselor_name]
    );
    res.sendStatus(200);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
