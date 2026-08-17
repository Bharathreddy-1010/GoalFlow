import { Request, Response } from 'express';

interface AiTipItem {
  category: string; // 'Strategy' | 'Optimal Timing' | 'Pro-Tip' | 'Mindset'
  title: string;
  description: string;
}

export const getAiTips = async (req: Request, res: Response) => {
  try {
    const { goalTitle, description, category, taskTitle } = req.body;

    const targetGoal = goalTitle || 'Daily Task';
    const targetDesc = description || 'Stay consistent and focus on daily execution.';
    const targetCategory = category || 'General';
    const targetTask = taskTitle || 'Complete daily action step';

    const apiKey = process.env.GROQ_API_KEY;

    if (apiKey && apiKey.trim().length > 0) {
      try {
        const prompt = `You are GoalFlow's AI Productivity Coach.
Generate 3 highly practical, actionable, and inspiring tips for a user trying to complete their goal and task.

Goal Title: "${targetGoal}"
Goal Description: "${targetDesc}"
Goal Category: "${targetCategory}"
Current Task: "${targetTask}"

Return ONLY a valid JSON array of 3 objects with keys "category", "title", and "description".
Example JSON format:
[
  { "category": "Strategy", "title": "Break into Micro-Steps", "description": "Divide this task into 10-minute focus blocks to avoid overwhelm." },
  { "category": "Timing & Prep", "title": "Prime Your Environment", "description": "Set up your workspace 5 minutes before starting." },
  { "category": "Mindset", "title": "Focus on Completion", "description": "Done is better than perfect. Aim for consistent execution daily." }
]`;

        const fetchApi = (globalThis as any).fetch || fetch;
        const groqResponse = await fetchApi('https://api.groq.com/openai/v1/chat/completions', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${apiKey}`,
          },
          body: JSON.stringify({
            model: 'llama-3.3-70b-versatile',
            messages: [
              { role: 'system', content: 'You are an expert AI productivity assistant. Respond with strictly valid JSON only.' },
              { role: 'user', content: prompt }
            ],
            temperature: 0.6,
            max_tokens: 500,
          }),
        });

        if (groqResponse.ok) {
          const data = await groqResponse.json();
          const content = data.choices?.[0]?.message?.content || '';
          
          // Clean codeblock formatting if returned by LLM
          const jsonStr = content.replace(/```json/g, '').replace(/```/g, '').trim();
          const parsedTips: AiTipItem[] = JSON.parse(jsonStr);

          if (Array.isArray(parsedTips) && parsedTips.length > 0) {
            return res.status(200).json({
              success: true,
              source: 'Groq LLM (Llama-3.3-70b)',
              tips: parsedTips,
            });
          }
        } else {
          const errorText = await groqResponse.text();
          console.warn('⚠️ Groq API Response Error:', errorText);
        }
      } catch (groqErr) {
        console.error('❌ Groq API Call Exception:', groqErr);
      }
    }

    // Dynamic Context-Aware Fallback Tips
    const fallbackTips: AiTipItem[] = [
      {
        category: 'Optimal Strategy',
        title: `Mastering ${targetGoal}`,
        description: `For "${targetTask}", leverage 25-minute uninterrupted Pomodoro blocks. ${targetDesc}`,
      },
      {
        category: 'Environment Prep',
        title: 'Eliminate Friction',
        description: `Set up all tools required for ${targetCategory.toLowerCase()} goals the night before so you can start instantly.`,
      },
      {
        category: 'Mindset & Consistency',
        title: 'Focus on Momentum',
        description: `Completing "${targetTask}" today builds unbroken streak momentum towards your long-term vision.`,
      },
    ];

    return res.status(200).json({
      success: true,
      source: 'GoalFlow AI Engine',
      tips: fallbackTips,
    });
  } catch (error) {
    console.error('Error generating AI tips:', error);
    return res.status(500).json({
      success: false,
      message: 'Failed to generate AI tips',
    });
  }
};
