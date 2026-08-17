import { Request, Response } from 'express';
import { pool } from '../db';

export const getGoals = async (req: Request, res: Response) => {
  try {
    const goalsRes = await pool.query('SELECT * FROM goals ORDER BY created_at DESC');
    const goals = goalsRes.rows;

    const milestonesRes = await pool.query('SELECT * FROM milestones');
    const milestones = milestonesRes.rows;

    const logsRes = await pool.query('SELECT * FROM progress_logs ORDER BY created_at DESC');
    const logs = logsRes.rows;

    const formattedGoals = goals.map((g) => {
      const gMilestones = milestones
        .filter((m) => m.goal_id === g.id)
        .map((m) => ({
          id: m.id,
          title: m.title,
          completed: m.completed,
          dueDate: m.due_date,
        }));

      const gLogs = logs
        .filter((l) => l.goal_id === g.id)
        .map((l) => ({
          id: l.id,
          goalId: l.goal_id,
          date: l.log_date,
          valueAdded: Number(l.value_added),
          note: l.note,
        }));

      return {
        id: g.id,
        title: g.title,
        description: g.description,
        category: g.category,
        priority: g.priority,
        status: g.status,
        currentProgress: Number(g.current_progress),
        targetProgress: Number(g.target_progress),
        unit: g.unit,
        startDate: g.start_date || 'Today',
        targetDate: g.target_date,
        isTodayFocus: g.is_today_focus,
        milestones: gMilestones,
        logs: gLogs,
      };
    });

    res.json(formattedGoals);
  } catch (error) {
    console.error('Error fetching goals:', error);
    res.status(500).json({ error: 'Failed to fetch goals' });
  }
};

export const createGoal = async (req: Request, res: Response) => {
  try {
    const { title, description, category, priority, targetProgress, unit, startDate, targetDate, milestones } = req.body;
    const goalId = 'g_' + Date.now();

    await pool.query(
      `INSERT INTO goals (id, title, description, category, priority, status, current_progress, target_progress, unit, start_date, target_date, is_today_focus)
       VALUES ($1, $2, $3, $4, $5, 'active', 0, $6, $7, $8, $9, false)`,
      [goalId, title, description || '', category, priority || 'medium', targetProgress || 100, unit || '%', startDate || 'Today', targetDate || '']
    );

    if (Array.isArray(milestones)) {
      for (let i = 0; i < milestones.length; i++) {
        const mTitle = milestones[i];
        if (typeof mTitle === 'string' && mTitle.trim().length > 0) {
          await pool.query(
            `INSERT INTO milestones (id, goal_id, title, completed) VALUES ($1, $2, $3, false)`,
            [`m_${goalId}_${i}`, goalId, mTitle.trim()]
          );
        }
      }
    }

    res.status(201).json({ id: goalId, message: 'Goal created successfully' });
  } catch (error) {
    console.error('Error creating goal:', error);
    res.status(500).json({ error: 'Failed to create goal' });
  }
};

export const logProgress = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { valueAdded, note } = req.body;
    const logId = 'l_' + Date.now();
    const todayStr = new Date().toISOString().split('T')[0];

    await pool.query(
      `INSERT INTO progress_logs (id, goal_id, log_date, value_added, note)
       VALUES ($1, $2, $3, $4, $5)`,
      [logId, id, todayStr, valueAdded, note || '']
    );

    await pool.query(
      `UPDATE goals SET current_progress = LEAST(target_progress, current_progress + $1) WHERE id = $2`,
      [valueAdded, id]
    );

    res.json({ message: 'Progress logged successfully' });
  } catch (error) {
    console.error('Error logging progress:', error);
    res.status(500).json({ error: 'Failed to log progress' });
  }
};

export const setTodayFocus = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await pool.query('UPDATE goals SET is_today_focus = false');
    await pool.query('UPDATE goals SET is_today_focus = true WHERE id = $1', [id]);
    res.json({ message: 'Today focus updated' });
  } catch (error) {
    console.error('Error setting today focus:', error);
    res.status(500).json({ error: 'Failed to set today focus' });
  }
};

export const toggleMilestone = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    await pool.query('UPDATE milestones SET completed = NOT completed WHERE id = $1', [id]);
    res.json({ message: 'Milestone toggled' });
  } catch (error) {
    console.error('Error toggling milestone:', error);
    res.status(500).json({ error: 'Failed to toggle milestone' });
  }
};
