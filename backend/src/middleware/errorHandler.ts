import { type Request, type Response, type NextFunction } from 'express';
import { ApiResponse } from '../types';

export const errorHandler = (
  err: Error,
  req: Request,
  res: Response<ApiResponse>,
  next: NextFunction
) => {
  console.error('Error:', err);

  // Default error response
  let statusCode = 500;
  let message = 'Internal server error';

  // Handle specific error types
  if (err.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation error';
  } else if (err.name === 'UnauthorizedError') {
    statusCode = 401;
    message = 'Unauthorized';
  } else if (err.name === 'NotFoundError') {
    statusCode = 404;
    message = 'Resource not found';
  }

  res.status(statusCode).json({
    success: false,
    message,
    error: process.env.NODE_ENV === 'development' ? err.message : undefined,
  });
};
