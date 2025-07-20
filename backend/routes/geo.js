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
    const db = require('../config/db');
    const [rows] = await db.query('SELECT * FROM clinics');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Endpoint: GET /api/geo/nearby-clinics?lat=...&lon=...
router.get('/nearby-clinics', async (req, res) => {
  const { lat, lon } = req.query;
  if (!lat || !lon) {
    return res.status(400).json({ error: 'lat and lon are required' });
  }
  try {
    const db = require('../config/db');
    // Cari klinik/hospital dalam radius 20km
    const [rows] = await db.query(`
      SELECT *, 
        (6371 * acos(
          cos(radians(?)) * cos(radians(latitude)) *
          cos(radians(longitude) - radians(?)) +
          sin(radians(?)) * sin(radians(latitude))
        )) AS distance
      FROM clinics
      HAVING distance < 20
      ORDER BY distance ASC
      LIMIT 10
    `, [lat, lon, lat]);
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

router.get('/counselors', async (req, res) => {
  try {
    const db = require('../config/db');
    const [rows] = await db.query('SELECT id, full_name FROM counselors');
    res.json(rows);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Endpoint: GET /api/geo/nearby-hospitals?lat=...&lon=...
router.get('/nearby-hospitals', async (req, res) => {
  const { lat, lon } = req.query;
  if (!lat || !lon) {
    return res.status(400).json({ error: 'lat and lon are required' });
  }
  try {
    const response = await axios.get('https://api.geoapify.com/v2/places', {
      params: {
        categories: 'healthcare.hospital',
        filter: `circle:${lon},${lat},20000`, // 20km radius for more results
        bias: `proximity:${lon},${lat}`,
        limit: 10,
        apiKey: process.env.GEOAPIFY_API_KEY
      }
    });
    // Return hanya features yang penting
    const hospitals = (response.data.features || []).map(f => ({
      name: f.properties.name,
      address: f.properties.formatted,
      lat: f.geometry.coordinates[1],
      lon: f.geometry.coordinates[0],
      distance: f.properties.distance
    }));
    res.json(hospitals);
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
