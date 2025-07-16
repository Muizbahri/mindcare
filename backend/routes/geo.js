const express = require('express');
const router = express.Router();
const axios = require('axios');
require('dotenv').config();

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

module.exports = router;
