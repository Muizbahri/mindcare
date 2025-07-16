const express = require('express');
const router = express.Router();
const admin = require('../config/firebase');

router.get('/firebase-test', async (req, res) => {
  try {
    const appName = admin.app().name;
    res.json({ success: true, app: appName });
  } catch (error) {
    console.error(error);
    res.status(500).json({ success: false, error: error.message });
  }
});

module.exports = router; 