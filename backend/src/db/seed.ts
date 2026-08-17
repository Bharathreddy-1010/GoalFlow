import { pool } from './index';
import fs from 'fs';
import path from 'path';

async function seed() {
  try {
    console.log('🌱 Initializing PostgreSQL schema for GoalFlow...');

    // Run Schema SQL
    const schemaSql = fs.readFileSync(path.join(__dirname, 'schema.sql'), 'utf-8');
    await pool.query(schemaSql);

    console.log('✅ PostgreSQL database ready for real-time user data!');
    process.exit(0);
  } catch (error) {
    console.error('❌ Error initializing PostgreSQL database:', error);
    process.exit(1);
  }
}

seed();
