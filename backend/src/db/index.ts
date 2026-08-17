import { Pool } from 'pg';
import dotenv from 'dotenv';
import path from 'path';

dotenv.config({ path: path.resolve(__dirname, '../../.env') });
dotenv.config();

export const pool = new Pool({
  user: process.env.PGUSER || 'bharathreddy',
  host: process.env.PGHOST || '127.0.0.1',
  database: process.env.PGDATABASE || 'goalflow',
  password: process.env.PGPASSWORD || '',
  port: parseInt(process.env.PGPORT || '5432', 10),
  connectionTimeoutMillis: 2000,
});

pool.on('connect', () => {
  // Connected to PostgreSQL
});

pool.on('error', (err) => {
  console.error('Unexpected error on idle PostgreSQL client:', err.message || err);
});
