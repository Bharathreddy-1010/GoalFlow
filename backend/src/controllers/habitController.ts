import { Request, Response } from 'express';
import { pool } from '../db';

export const getHabits = async (req: Request, res: Response) => {
  try {
    const habitsRes = await pool.query('SELECT * FROM habits');
    const habits = habitsRes.rows.map((h) => ({
      id: h.id,
      title: h.title,
      category: h.category,
      frequency: h.frequency,
      streakDays: h.streak_days,
      completedDates: h.completed_dates || [],
    }));
    res.json(habits);
  } catch (error) {
    console.error('Error fetching habits:', error);
    res.status(500).json({ error: 'Failed to fetch habits' });
  }
};

export const createHabit = async (req: Request, res: Response) => {
  try {
    const { title, category, frequency } = req.body;
    const id = 'h_' + Date.now();
    await pool.query(
      `INSERT INTO habits (id, title, category, frequency, streak_days, completed_dates)
       VALUES ($1, $2, $3, $4, 0, '{}')`,
      [id, title, category, frequency || 'daily']
    );
    res.status(201).json({ id, message: 'Habit created' });
  } catch (error) {
    console.error('Error creating habit:', error);
    res.status(500).json({ error: 'Failed to create habit' });
  }
};

export const toggleHabitDate = async (req: Request, res: Response) => {
  try {
    const { id } = req.params;
    const { date } = req.body;
    const targetDate = date || new Date().toISOString().split('T')[0];

    const habitRes = await pool.query('SELECT completed_dates, streak_days FROM habits WHERE id = $1', [id]);
    if (habitRes.rows.length === 0) {
      return res.status(404).json({ error: 'Habit not found' });
    }

    const currentDates: string[] = habitRes.rows[0].completed_dates || [];
    let updatedDates: string[];
    let streak = habitRes.rows[0].streak_days;

    if (currentDates.includes(targetDate)) {
      updatedDates = currentDates.filter((d) => d !== targetDate);
      streak = Math.max(0, streak - 1);
    } else {
      updatedDates = [...currentDates, targetDate];
      streak = streak + 1;
    }

    await pool.query(
      'UPDATE habits SET completed_dates = $1, streak_days = $2 WHERE id = $3',
      [updatedDates, streak, id]
    );

    res.json({ message: 'Habit date toggled', completedDates: updatedDates, streakDays: streak });
  } catch (error) {
    console.error('Error toggling habit date:', error);
    res.status(500).json({ error: 'Failed to toggle habit' });
  }
};
