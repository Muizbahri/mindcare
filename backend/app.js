const express = require('express');
const cors = require('cors');
require('dotenv').config();
const db = require('./models/db');
const geoRoutes = require('./routes/geo');
const secureRoutes = require('./routes/secure');
const testFirebase = require('./routes/testFirebase');

const app = express();

app.use(cors());
app.use(express.json());

// Test route
app.get('/', async (req, res) => {
  try {
    const [rows] = await db.query('SELECT 1 + 1 AS result');
    res.json({ dbTest: rows[0].result });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Geoapify routes
app.use('/api/geo', geoRoutes);

// Secure routes (Firebase Auth protected)
app.use('/api/secure', secureRoutes);

// Firebase test routes
app.use('/api/test', testFirebase);

module.exports = app; 