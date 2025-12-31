import jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
// Default fallback jika tidak ada parameter yang dikirim
const DEFAULT_EXPIRE = '24h';

// Tambahkan parameter 'expiresIn' dengan default value
export const generateToken = (payload: object, expiresIn: string = DEFAULT_EXPIRE): string => {
return jwt.sign(payload, JWT_SECRET, { expiresIn: expiresIn as any });
};

export const verifyToken = (token: string): any => {
  return jwt.verify(token, JWT_SECRET);
};