const admin = require('firebase-admin');

// Initialize without service account during development
if (!admin.apps.length) {
  admin.initializeApp({
    // Using dummy config for development
    projectId: process.env.FIREBASE_PROJECT_ID || 'mindcare-dev',
    databaseURL: process.env.FIREBASE_DATABASE_URL || 'https://mindcare-dev.firebaseio.com',
  });
}

module.exports = admin; 