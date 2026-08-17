import { pool } from './index';

async function migrate() {
  try {
    console.log('🔄 Running PostgreSQL migration for user onboarding preferences...');
    await pool.query(`
      ALTER TABLE users ADD COLUMN IF NOT EXISTS email VARCHAR(150);
      ALTER TABLE users ADD COLUMN IF NOT EXISTS google_id VARCHAR(100);
      ALTER TABLE users ADD COLUMN IF NOT EXISTS apple_id VARCHAR(100);
      ALTER TABLE users ADD COLUMN IF NOT EXISTS avatar_url TEXT;
      ALTER TABLE users ADD COLUMN IF NOT EXISTS preferred_areas TEXT[] DEFAULT '{}';
      ALTER TABLE users ADD COLUMN IF NOT EXISTS morning_time VARCHAR(50) DEFAULT '7:00 AM';
      ALTER TABLE users ADD COLUMN IF NOT EXISTS daily_focus_target VARCHAR(50) DEFAULT '1h 30m';
      ALTER TABLE goals ADD COLUMN IF NOT EXISTS start_date VARCHAR(50);
      ALTER TABLE goals ADD COLUMN IF NOT EXISTS user_id VARCHAR(50);
      ALTER TABLE habits ADD COLUMN IF NOT EXISTS user_id VARCHAR(50);
    `);
    console.log('✅ PostgreSQL schema successfully updated with user preferences!');
  } catch (err: any) {
    console.warn('Migration note:', err.message);
  } finally {
    process.exit(0);
  }
}

migrate();
