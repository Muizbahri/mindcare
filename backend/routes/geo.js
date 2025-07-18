const express = require('express');
const router = express.Router();
const axios = require('axios');
require('dotenv').config({ path: 'C:/Mindcare_project/mindcare/backend/.env' });

router.get('/location', async (req, res) => {
  const { query } = req.query; // e.g., query=UITM Shah Alam
  try {
    const response = await axios.get(`https://api.geoapify.com/v1/geocode/search`, {
      params: {
        text: query,
        apiKey: process.env.GEOAPIFY_API_KEY
      }
    });
    res.json(response.data);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/clinics', async (req, res) => {
  try {
    const db = require('../models/db');
    const [rows] = await db.query('SELECT * FROM clinics');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/counselors', async (req, res) => {
  try {
    const db = require('../models/db');
    const [rows] = await db.query('SELECT id, full_name FROM counselors');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
