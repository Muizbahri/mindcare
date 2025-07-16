const express = require('express');
const router = express.Router();
const verifyToken = require('../middlewares/firebaseAuth');

router.get('/profile', verifyToken, (req, res) => {
  res.json({ message: 'Protected route accessed', user: req.user });
});

module.exports = router; 