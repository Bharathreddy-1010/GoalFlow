import { Router } from 'express';
import { getUserProfile, updateUserProfile } from '../controllers/userController';
import { getGoals, createGoal, logProgress, setTodayFocus, toggleMilestone } from '../controllers/goalController';
import { getHabits, createHabit, toggleHabitDate } from '../controllers/habitController';
import { register, login, googleAuth, appleAuth, googleOAuthRedirect } from '../controllers/authController';
import { getAiTips } from '../controllers/aiController';

const router = Router();

// Auth routes (JWT + Welcome Email + Google OAuth 2.0 Web Redirect)
router.get('/auth/google/oauth', googleOAuthRedirect);
router.post('/auth/register', register);
router.post('/auth/login', login);
router.post('/auth/google', googleAuth);
router.post('/auth/apple', appleAuth);

// User routes
router.get('/user', getUserProfile);
router.post('/user/profile', updateUserProfile);

// Goal routes
router.get('/goals', getGoals);
router.post('/goals', createGoal);
router.post('/goals/:id/log', logProgress);
router.post('/goals/:id/focus', setTodayFocus);
router.post('/milestones/:id/toggle', toggleMilestone);

// AI Tips route (Groq API / Llama 3.3 integration)
router.post('/ai/tips', getAiTips);

// Test Email Dispatch endpoint
router.post('/test-email', async (req, res) => {
  const { email } = req.body;
  const targetEmail = email || 'bharath404074@gmail.com';
  const { sendWelcomeEmail } = await import('../services/emailService');
  const sent = await sendWelcomeEmail(targetEmail, 'GoalFlow Tester');
  return res.json({
    success: sent,
    message: sent
      ? `✅ Welcome email dispatched directly via Render to ${targetEmail}!`
      : `❌ Failed to send welcome email to ${targetEmail}. Check server logs.`,
  });
});

// Habit routes
router.get('/habits', getHabits);
router.post('/habits', createHabit);
router.post('/habits/:id/toggle', toggleHabitDate);

export default router;
