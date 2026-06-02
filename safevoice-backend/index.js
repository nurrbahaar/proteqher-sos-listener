const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');
require('dotenv').config();

const app = express();
app.use(cors());
app.use(express.json());

const pool = new Pool({
  user: process.env.DB_USER,
  host: process.env.DB_HOST,
  database: process.env.DB_NAME,
  password: process.env.DB_PASSWORD,
  port: process.env.DB_PORT,
  ssl: false, // Yerel baðlantýlarda el sýkýþma hatasýný (ECONNRESET) önler
  max: 20,    // Maksimum havuz baðlantý sayýsý
  idleTimeoutMillis: 30000,
  connectionTimeoutMillis: 2000,
});

async function initDatabase() {
  try {
    await pool.query(`
      CREATE TABLE IF NOT EXISTS emergency_logs (
        id SERIAL PRIMARY KEY,
        user_name VARCHAR(100),
        status VARCHAR(50),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log("PostgreSQL tablolari dogrulandi.");
  } catch (err) {
    console.error("Veritabaný tablosu olusturulurken hata:", err);
  }
}

// Admin paneli testi
app.get('/admin', (req, res) => {
  res.send('<h1 style="color:purple; font-family:sans-serif; text-align:center; margin-top:50px;">SafeVoice Admin Paneli</h1>');
});

// Mobil uygulamadan gelen verileri yakalayan yeni endpoint
app.post('/api/emergency', async (req, res) => {
  const { user_name, status } = req.body;
  try {
    const result = await pool.query(
      'INSERT INTO emergency_logs (user_name, status) VALUES ($1, $2) RETURNING *',
      [user_name, status]
    );
    console.log(`TELEFONDAN SINYAL GELDI! Kullanici: ${user_name}, Durum: ${status}`);
    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error("Gelen veri veritabanina yazilirken hata olustu:", err);
    res.status(500).send("Veritabaný hatasý");
  }
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, async () => {
  console.log(`Sunucu aktif! Port: ${PORT}`);
  await initDatabase();
});