import mysql from 'mysql2/promise';
import 'dotenv/config';

// Configure MySQL connection pool using environment variables
const pool = mysql.createPool({
  host: process.env.DB_HOST || 'localhost',
  port: Number(process.env.DB_PORT) || 3306,
  user: process.env.DB_USER || 'root',
  password: process.env.DB_PASSWORD || '',
  database: process.env.DB_NAME || 'exquisiweb',
  waitForConnections: true,
  connectionLimit: 10,
  queueLimit: 0
});

// Verify active database connectivity
export async function verifyConnection() {
  const connection = await pool.getConnection();
  try {
    await connection.ping();
    console.log('Database connection established successfully.');
  } finally {
    connection.release();
  }
}

export default pool;