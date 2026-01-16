import express = require('express');
import dotenv = require('dotenv');
const helmet = require('helmet');
import morgan = require('morgan');
import path = require('path');

// Load environment variables
dotenv.config();

// Import local modules
import { prisma } from './lib/prisma';
import routes from './routes';
import { corsMiddleware } from './middleware/cors';
import { errorHandler } from './middleware/errorHandler';

const app = express();

// Configuration
const config = {
  port: process.env.PORT || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  jwtSecret: process.env.JWT_SECRET || 'your-secret-key',
};

// Security middleware
app.use(helmet({
  contentSecurityPolicy: {
    directives: {
      defaultSrc: ["'self'"],
      imgSrc: ["'self'", "data:", "http://localhost:3000", "http://10.64.75.71:3000", "blob:"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
    },
  },
}));

// CORS middleware
app.use(corsMiddleware);

// Logging middleware
if (config.nodeEnv === 'development') {
  app.use(morgan('dev'));
}

// Body parsing middleware
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Static files
const uploadsPath = path.join(process.cwd(), 'uploads');
const fs = require('fs');
if (!fs.existsSync(uploadsPath)) {
  fs.mkdirSync(uploadsPath, { recursive: true });
}

// CORS middleware for uploads
app.use('/uploads', (req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Cross-Origin-Resource-Policy', 'cross-origin');
  res.setHeader('Access-Control-Allow-Private-Network', 'true');

  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }

  next();
});

app.use('/uploads', express.static(uploadsPath, {
  setHeaders: (res: any) => {
    res.setHeader('Cross-Origin-Resource-Policy', 'cross-origin');
  },
}));

// API routes
app.use('/api', routes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Absensi System API',
    version: '1.0.0',
    status: 'Running',
    timestamp: new Date().toISOString(),
    docs: '/api/health'
  });
});

// Error handling middleware (must be last)
app.use(errorHandler);

export default app;

