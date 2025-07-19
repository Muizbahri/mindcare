const express = require('express');
const router = express.Router();
const vision = require('@google-cloud/vision');

// Create a client
const client = new vision.ImageAnnotatorClient({
  keyFilename: './google-cloud-credentials.json'  // Make sure to have your credentials JSON file here
});

// Analyze emotions in an image
router.post('/analyze', async (req, res) => {
  try {
    const { imageUrl, imageBase64 } = req.body;

    let request;
    if (imageBase64) {
      // If base64 image is provided, use it
      request = { image: { content: imageBase64 } };
    } else if (imageUrl) {
      // If imageUrl is provided, use it
      request = { image: { source: { imageUri: imageUrl } } };
    } else {
      return res.status(400).json({ error: 'Image URL or base64 image is required' });
    }

    // Perform face detection
    const [result] = await client.faceDetection(request);
    const faces = result.faceAnnotations;

    if (!faces || faces.length === 0) {
      return res.status(404).json({ error: 'No faces detected in the image' });
    }

    // Get emotions for each face
    const emotions = faces.map(face => ({
      joy: face.joyLikelihood,
      anger: face.angerLikelihood,
      sorrow: face.sorrowLikelihood,
      surprise: face.surpriseLikelihood,
      confidence: face.detectionConfidence,
    }));

    // Save emotion data to database
    const userId = req.body.userId;
    if (userId) {
      await db.query(
        'INSERT INTO emotion_logs (user_id, joy, anger, sorrow, surprise, confidence, created_at) VALUES (?, ?, ?, ?, ?, ?, NOW())',
        [
          userId,
          emotions[0].joy,
          emotions[0].anger,
          emotions[0].sorrow,
          emotions[0].surprise,
          emotions[0].confidence
        ]
      );
    }

    res.json({
      success: true,
      emotions: emotions[0], // Return the first face's emotions
      message: faces.length > 1 ? 'Multiple faces detected, showing primary face' : 'Analysis complete'
    });

  } catch (error) {
    console.error('Error analyzing emotions:', error);
    res.status(500).json({ error: 'Failed to analyze emotions' });
  }
});

// Get emotion history for a user
router.get('/history/:userId', async (req, res) => {
  try {
    const { userId } = req.params;
    const [rows] = await db.query(
      'SELECT * FROM emotion_logs WHERE user_id = ? ORDER BY created_at DESC LIMIT 10',
      [userId]
    );

    res.json({ success: true, history: rows });
  } catch (error) {
    console.error('Error fetching emotion history:', error);
    res.status(500).json({ error: 'Failed to fetch emotion history' });
  }
});

module.exports = router;
