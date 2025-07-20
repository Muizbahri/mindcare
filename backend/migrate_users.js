const db = require('./config/db');
const fs = require('fs');

async function migrateUsers() {
  try {
    const sql = fs.readFileSync('./migrations/create_users_table.sql', 'utf8');
    await db.query(sql);
    console.log('Users table created successfully');
  } catch (err) {
    console.error('Error:', err.message);
  } finally {
    process.exit();
  }
}

migrateUsers(); 