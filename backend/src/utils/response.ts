import { type Response } from 'express';
import { ApiResponse, PaginatedResponse } from '../types';

export const sendSuccess = <T>(
  res: Response<ApiResponse<T>>,
  message: string,
  data?: T,
  statusCode = 200
) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
  });
};

export const sendError = (
  res: Response<ApiResponse>,
  message: string,
  statusCode = 500,
  error?: string
) => {
  return res.status(statusCode).json({
    success: false,
    message,
    error,
  });
};

export const sendPaginatedSuccess = <T>(
  res: Response<PaginatedResponse<T>>,
  message: string,
  data: T[],
  pagination: {
    page: number;
    limit: number;
    total: number;
    totalPages: number;
  },
  statusCode = 200
) => {
  return res.status(statusCode).json({
    success: true,
    message,
    data,
    pagination,
  });
};
