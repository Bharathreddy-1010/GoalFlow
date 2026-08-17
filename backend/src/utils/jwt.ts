import crypto from 'crypto';

const JWT_SECRET = process.env.JWT_SECRET || 'goalflow_super_secret_jwt_key_2026';

export interface TokenPayload {
  userId?: string;
  email: string;
  name?: string;
  [key: string]: any;
}

export const generateToken = (payload: TokenPayload): string => {
  const header = Buffer.from(JSON.stringify({ alg: 'HS256', typ: 'JWT' })).toString('base64url');
  const exp = Math.floor(Date.now() / 1000) + 7 * 24 * 60 * 60; // 7 days
  const body = Buffer.from(JSON.stringify({ ...payload, exp })).toString('base64url');
  const signature = crypto
    .createHmac('sha256', JWT_SECRET)
    .update(`${header}.${body}`)
    .digest('base64url');
  return `${header}.${body}.${signature}`;
};

export const verifyToken = (token: string): TokenPayload => {
  const parts = token.split('.');
  if (parts.length !== 3) throw new Error('Invalid token');
  const [header, body, signature] = parts;
  const expectedSig = crypto
    .createHmac('sha256', JWT_SECRET)
    .update(`${header}.${body}`)
    .digest('base64url');
  if (signature !== expectedSig) throw new Error('Invalid signature');
  const payload = JSON.parse(Buffer.from(body, 'base64url').toString('utf8'));
  if (payload.exp && Math.floor(Date.now() / 1000) > payload.exp) {
    throw new Error('Token expired');
  }
  return payload;
};
