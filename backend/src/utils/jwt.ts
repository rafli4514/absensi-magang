import jwt = require('jsonwebtoken');

const JWT_SECRET = process.env.JWT_SECRET || 'your-secret-key';
const REFRESH_SECRET = process.env.REFRESH_SECRET || 'your-refresh-secret-key';
const ACCESS_EXPIRE = '1h'; // Short lived
const REFRESH_EXPIRE = '30d'; // Long lived

export const generateToken = (payload: object, expiresIn: string = ACCESS_EXPIRE): string => {
  return jwt.sign(payload, JWT_SECRET, { expiresIn: expiresIn as any });
};

export const generateRefreshToken = (payload: object): string => {
  return jwt.sign(payload, REFRESH_SECRET, { expiresIn: REFRESH_EXPIRE });
};

export const verifyToken = (token: string): any => {
  return jwt.verify(token, JWT_SECRET);
};

export const verifyRefreshToken = (token: string): any => {
  return jwt.verify(token, REFRESH_SECRET);
};