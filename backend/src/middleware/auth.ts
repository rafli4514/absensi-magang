import { type Request, type Response, type NextFunction } from 'express';
import jwt from 'jsonwebtoken';
import { ApiResponse } from '../types';

declare global {
  namespace Express {
    interface Request {
      user?: {
        id: string;
        username: string;
        email?: string;
        role: string;
        nama?: string;
        divisi?: string;
      };
    }
  }
}

interface AuthRequest extends Request {
  user?: {
    id: string;
    username: string;
    role: string;
  };
}

export const authenticateToken = (
  req: AuthRequest,
  res: Response<ApiResponse>,
  next: NextFunction
) => {
  const authHeader = req.headers.authorization;
  const token = authHeader && authHeader.split(' ')[1]; // Bearer TOKEN

  if (!token) {
    return res.status(401).json({
      success: false,
      message: 'Access token required',
    });
  }

  try {
    const secret = process.env.JWT_SECRET || 'your-secret-key';
    const decoded = jwt.verify(token, secret) as any;

    req.user = {
      id: decoded.id,
      username: decoded.username,
      role: decoded.role,
    };

    next();
  } catch (error) {
    return res.status(403).json({
      success: false,
      message: 'Invalid or expired token',
    });
  }
};

export const requireAdmin = (
  req: AuthRequest,
  res: Response<ApiResponse>,
  next: NextFunction
) => {
  if (req.user?.role !== 'ADMIN') {
    return res.status(403).json({
      success: false,
      message: 'Admin access required',
    });
  }
  next();
};

// Middleware untuk memastikan user adalah admin atau pembimbing magang
export const requireAdminOrPembimbing = (
  req: AuthRequest,
  res: Response<ApiResponse>,
  next: NextFunction
) => {
  if (req.user?.role !== 'ADMIN' && req.user?.role !== 'PEMBIMBING_MAGANG') {
    return res.status(403).json({
      success: false,
      message: 'Admin or Pembimbing Magang access required',
    });
  }
  next();
};

// Middleware untuk memastikan user bukan pembimbing magang (untuk create/update/delete operations)
export const requireNotPembimbing = (
  req: AuthRequest,
  res: Response<ApiResponse>,
  next: NextFunction
) => {
  if (req.user?.role === 'PEMBIMBING_MAGANG') {
    return res.status(403).json({
      success: false,
      message: 'Pembimbing Magang tidak memiliki akses untuk operasi ini',
    });
  }
  next();
};