import nodemailer from 'nodemailer';
import dns from 'dns';

// Force Node.js to resolve IPv4 addresses first (prevents ENETUNREACH IPv6 errors on Render/Cloud hosts)
try {
  dns.setDefaultResultOrder('ipv4first');
} catch (_) {}

let transporter: nodemailer.Transporter | null = null;

async function getTransporter() {
  if (transporter) return transporter;

  // 1. If explicit SMTP credentials are provided in .env
  if (process.env.SMTP_HOST && process.env.SMTP_USER && process.env.SMTP_PASS) {
    transporter = nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: parseInt(process.env.SMTP_PORT || '587'),
      secure: process.env.SMTP_SECURE === 'true',
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASS,
      },
      connectionTimeout: 8000,
      greetingTimeout: 8000,
      socketTimeout: 8000,
      family: 4,
    } as any);
    console.log(`📧 Configured custom SMTP transporter for ${process.env.SMTP_USER}`);
    return transporter;
  }

  // 2. If Gmail user & app password provided
  if (process.env.GMAIL_USER && process.env.GMAIL_PASS) {
    transporter = nodemailer.createTransport({
      host: 'smtp.gmail.com',
      port: 587,
      secure: false,
      requireTLS: true,
      auth: {
        user: process.env.GMAIL_USER,
        pass: process.env.GMAIL_PASS,
      },
      connectionTimeout: 8000,
      greetingTimeout: 8000,
      socketTimeout: 8000,
      family: 4,
    } as any);
    console.log(`📧 Configured Gmail IPv4 TLS SMTP transporter for ${process.env.GMAIL_USER}`);
    return transporter;
  }

  console.warn('⚠️ GMAIL_USER / GMAIL_PASS environment variables are NOT set on this server! Falling back to test sandbox.');

  // 3. Fallback: Ethereal test account (sandbox for developer inspection)
  try {
    const testAccount = await nodemailer.createTestAccount();
    transporter = nodemailer.createTransport({
      host: 'smtp.ethereal.email',
      port: 587,
      secure: false,
      auth: {
        user: testAccount.user,
        pass: testAccount.pass,
      },
      connectionTimeout: 8000,
    });
    console.log(`✉️ Ethereal Test SMTP created: ${testAccount.user}`);
  } catch (err) {
    console.warn('⚠️ Could not create Ethereal SMTP transporter:', err);
  }

  return transporter;
}

export async function sendWelcomeEmail(toEmail: string, userName: string): Promise<{ success: boolean; error?: string; messageId?: string }> {
  console.log(`\n📧 [EMAIL DISPATCH START] Attempting welcome email for ${userName} <${toEmail}>...`);

  const htmlContent = `
    <!DOCTYPE html>
    <html>
    <head>
      <style>
        body { font-family: 'Segoe UI', Helvetica, Arial, sans-serif; background-color: #F8F7F4; margin: 0; padding: 20px; color: #2C3931; }
        .container { max-width: 580px; margin: 0 auto; background: #FFFFFF; border-radius: 20px; padding: 32px; box-shadow: 0 10px 30px rgba(0,0,0,0.05); }
        .header { text-align: center; padding-bottom: 24px; border-bottom: 1px solid #EAE8E2; }
        .logo { font-size: 24px; font-weight: 700; color: #385E46; }
        .title { font-size: 22px; font-weight: 700; color: #2C3931; margin-top: 24px; }
        .body-text { font-size: 15px; line-height: 1.6; color: #5B6860; margin-top: 16px; }
        .feature-box { background: #F2F0EB; border-radius: 14px; padding: 16px; margin: 20px 0; }
        .feature-title { font-weight: 700; color: #385E46; font-size: 14px; }
        .cta-btn { display: inline-block; background: linear-gradient(135deg, #385E46, #4E7C5D); color: #FFFFFF !important; text-decoration: none; padding: 14px 28px; border-radius: 14px; font-weight: 600; margin-top: 24px; text-align: center; }
        .footer { text-align: center; font-size: 12px; color: #8C9890; margin-top: 32px; border-top: 1px solid #EAE8E2; padding-top: 16px; }
      </style>
    </head>
    <body>
      <div class="container">
        <div class="header">
          <div class="logo">🌱 GoalFlow</div>
        </div>
        <div class="title">Welcome aboard, ${userName}! 🎉</div>
        <p class="body-text">
          We are thrilled to welcome you to GoalFlow — your personal daily companion for achieving meaningful goals, building lasting habits, and mastering focus.
        </p>
        <div class="feature-box">
          <div class="feature-title">✨ What you can do with GoalFlow:</div>
          <ul style="margin: 8px 0 0 0; padding-left: 20px; color: #5B6860; font-size: 14px;">
            <li>Set daily focus goals and track progress</li>
            <li>Maintain unbroken streaks with habit tracking</li>
            <li>Use focus timers to boost productivity</li>
            <li>Monitor real-time stats and unlock achievements</li>
          </ul>
        </div>
        <p class="body-text">
          Your JWT session has been successfully authenticated and verified. Let's make today productive!
        </p>
        <div style="text-align: center;">
          <a href="#" class="cta-btn">Start Flowing Goals</a>
        </div>
        <div class="footer">
          &copy; 2026 GoalFlow Inc. All rights reserved.
        </div>
      </div>
    </body>
    </html>
  `;

  // 1. Resend HTTP API (HTTPS Port 443 - Bypasses Render SMTP port restrictions)
  if (process.env.RESEND_API_KEY) {
    try {
      const fetchApi = globalThis.fetch || fetch;
      const resendRes = await fetchApi('https://api.resend.com/emails', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Authorization': `Bearer ${process.env.RESEND_API_KEY}`,
        },
        body: JSON.stringify({
          from: 'GoalFlow <onboarding@resend.dev>',
          to: [toEmail],
          subject: `🎉 Welcome to GoalFlow, ${userName}!`,
          html: htmlContent,
        }),
      });

      if (resendRes.ok) {
        const resendData: any = await resendRes.json();
        console.log(`✅ Welcome Email sent via Resend API to ${toEmail} (Id: ${resendData.id})`);
        return { success: true, messageId: resendData.id };
      }
    } catch (httpErr) {
      console.warn('⚠️ Resend HTTP API failed, falling back to SMTP:', httpErr);
    }
  }

  // 2. Brevo HTTP API (HTTPS Port 443)
  if (process.env.BREVO_API_KEY) {
    try {
      const fetchApi = globalThis.fetch || fetch;
      const brevoRes = await fetchApi('https://api.brevo.com/v3/smtp/email', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'api-key': process.env.BREVO_API_KEY,
        },
        body: JSON.stringify({
          sender: { name: 'GoalFlow Team', email: process.env.GMAIL_USER || 'welcome@goalflow.app' },
          to: [{ email: toEmail, name: userName }],
          subject: `🎉 Welcome to GoalFlow, ${userName}!`,
          htmlContent: htmlContent,
        }),
      });

      if (brevoRes.ok) {
        const brevoData: any = await brevoRes.json();
        console.log(`✅ Welcome Email sent via Brevo API to ${toEmail} (Id: ${brevoData.messageId})`);
        return { success: true, messageId: brevoData.messageId };
      }
    } catch (httpErr) {
      console.warn('⚠️ Brevo HTTP API failed:', httpErr);
    }
  }

  // 3. Fallback: Nodemailer SMTP
  try {
    const mailTransporter = await getTransporter();
    if (!mailTransporter) {
      console.log(`⚠️ [SIMULATED EMAIL LOG] Welcome email sent to ${toEmail} for ${userName}`);
      return { success: true };
    }

    const senderAddress = process.env.GMAIL_USER || process.env.SMTP_USER || 'welcome@goalflow.app';
    const info = await mailTransporter.sendMail({
      from: `"GoalFlow Team" <${senderAddress}>`,
      to: toEmail,
      subject: `🎉 Welcome to GoalFlow, ${userName}!`,
      html: htmlContent,
    });

    console.log(`✅ Welcome Email sent to ${toEmail} (MessageId: ${info.messageId})`);
    
    const previewUrl = nodemailer.getTestMessageUrl(info);
    if (previewUrl) {
      console.log(`🔗 VIEW SENT WELCOME EMAIL HERE: ${previewUrl}`);
    }
    
    return { success: true, messageId: info.messageId };
  } catch (error: any) {
    console.error(`❌ Failed to send welcome email to ${toEmail}:`, error);
    const errMsg = error?.message || String(error);
    const isTimeout = errMsg.toLowerCase().includes('timeout') || errMsg.toLowerCase().includes('enetunreach');
    const userFriendlyError = isTimeout
      ? `Render free tier blocked outbound SMTP port 587 (${errMsg}). Add a free RESEND_API_KEY or BREVO_API_KEY in Render Environment Variables to send emails via HTTPS port 443!`
      : errMsg;
    return { success: false, error: userFriendlyError };
  }
}
