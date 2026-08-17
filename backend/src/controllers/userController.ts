import { Request, Response } from 'express';
import { pool } from '../db';

export const getUserProfile = async (req: Request, res: Response) => {
  try {
    const userRes = await pool.query('SELECT * FROM users ORDER BY created_at DESC LIMIT 1');
    const user = userRes.rows[0] || {
      name: 'Bharath B',
      email: 'bharath404074@gmail.com',
      greeting: 'Good morning',
      on_track_percentage: 92,
      preferred_areas: ['Fitness & Health', 'Learning & Education'],
      morning_time: '7:00 AM',
      daily_focus_target: '1h 30m',
    };

    const goalsRes = await pool.query('SELECT COUNT(*) FROM goals WHERE status = $1', ['active']);
    const activeGoalsCount = parseInt(goalsRes.rows[0]?.count || '0', 10);

    res.json({
      name: user.name,
      email: user.email,
      avatarUrl: user.avatar_url,
      greeting: user.greeting,
      onTrackPercentage: user.on_track_percentage,
      preferredAreas: user.preferred_areas || ['Fitness & Health', 'Learning & Education'],
      morningTime: user.morning_time || '7:00 AM',
      dailyFocusTarget: user.daily_focus_target || '1h 30m',
      activeGoalsCount,
    });
  } catch (error) {
    console.error('Error fetching user profile:', error);
    res.status(500).json({ error: 'Failed to fetch user profile' });
  }
};

export const updateUserProfile = async (req: Request, res: Response) => {
  try {
    const { email, name, greeting, preferredAreas, morningTime, dailyFocusTarget } = req.body;
    const areas = Array.isArray(preferredAreas) ? preferredAreas : ['Fitness & Health', 'Learning & Education'];

    if (email) {
      await pool.query(
        `UPDATE users 
         SET name = COALESCE($1, name), 
             greeting = COALESCE($2, greeting),
             preferred_areas = $3::TEXT[], 
             morning_time = COALESCE($4, morning_time), 
             daily_focus_target = COALESCE($5, daily_focus_target)
         WHERE LOWER(email) = LOWER($6)`,
        [name || null, greeting || null, areas, morningTime || null, dailyFocusTarget || null, email.trim()]
      );
    } else {
      await pool.query(
        `UPDATE users 
         SET name = COALESCE($1, name), 
             greeting = COALESCE($2, greeting),
             preferred_areas = $3::TEXT[], 
             morning_time = COALESCE($4, morning_time), 
             daily_focus_target = COALESCE($5, daily_focus_target)
         WHERE id = (SELECT id FROM users ORDER BY created_at DESC LIMIT 1)`,
        [name || null, greeting || null, areas, morningTime || null, dailyFocusTarget || null]
      );
    }

    return res.status(200).json({ success: true, message: 'Profile updated successfully' });
  } catch (error: any) {
    console.error('Error updating user profile in PostgreSQL:', error);
    return res.status(500).json({ success: false, error: error.message });
  }
};
