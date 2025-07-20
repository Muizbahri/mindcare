const db = require('./config/db');
const fs = require('fs');

async function migrateAppointments() {
  try {
    // Drop existing table if it exists
    await db.query('DROP TABLE IF EXISTS appointments');
    console.log('Dropped existing appointments table');
    
    // Create new table with correct schema
    const sql = fs.readFileSync('./migrations/create_appointments_table.sql', 'utf8');
    await db.query(sql);
    console.log('Appointments table created successfully');
  } catch (err) {
    console.error('Error:', err.message);
  } finally {
    process.exit();
  }
}

migrateAppointments(); 