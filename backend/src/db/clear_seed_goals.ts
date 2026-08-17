import { pool } from './index';

async function clearSeedGoals() {
  try {
    console.log('🧹 Purging all static seed goals from PostgreSQL...');
    await pool.query('DELETE FROM progress_logs');
    await pool.query('DELETE FROM milestones');
    await pool.query('DELETE FROM goals');
    console.log('✅ All static seed goals successfully purged from PostgreSQL!');
  } catch (err: any) {
    console.error('Error clearing static goals:', err);
  } finally {
    process.exit(0);
  }
}

clearSeedGoals();
