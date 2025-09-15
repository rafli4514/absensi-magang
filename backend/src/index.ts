import express = require('express');
import dotenv = require('dotenv');
const helmet = require('helmet');
import morgan = require('morgan');
import path = require('path');

// Load environment variables
dotenv.config();

// Import local modules
import { prisma } from './lib/prisma';
const routes = require('./routes');
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
      imgSrc: ["'self'", "data:", "http://localhost:3000", "http://localhost:3000/uploads/"],
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
const uploadsPath = path.join(__dirname, 'uploads');
console.log('__dirname:', __dirname);
console.log('uploads path:', uploadsPath);
console.log('uploads path (alternative):', path.join(__dirname, '..', 'uploads'));

// Check if uploads directory exists
const fs = require('fs');
if (fs.existsSync(uploadsPath)) {
  console.log('✅ Uploads directory exists:', uploadsPath);
  const files = fs.readdirSync(uploadsPath);
  console.log('Files in uploads:', files.slice(0, 5)); // Show first 5 files
} else {
  console.log('❌ Uploads directory does not exist:', uploadsPath);
}

// CORS middleware for uploads
app.use('/uploads', (req, res, next) => {
  res.setHeader('Access-Control-Allow-Origin', '*');
  res.setHeader('Access-Control-Allow-Methods', 'GET, OPTIONS');
  res.setHeader('Access-Control-Allow-Headers', 'Content-Type, Authorization');
  res.setHeader('Cross-Origin-Resource-Policy', 'cross-origin');
  
  if (req.method === 'OPTIONS') {
    res.status(200).end();
    return;
  }
  
  next();
});

app.use('/uploads', express.static(uploadsPath, {
  setHeaders: (res, path) => {
    res.setHeader('Cache-Control', 'public, max-age=31536000');
  }
}));

// API Routes
app.use('/api', routes);

// Root endpoint
app.get('/', (req, res) => {
  res.json({
    message: 'Absensi System API with Prisma',
    version: '2.0.0',
    status: 'Running',
    timestamp: new Date().toISOString(),
    docs: '/api/health'
  });
});

// Error handling middleware (must be last)
app.use(errorHandler);

// Initialize database and start server
const startServer = async () => {
  try {
    // Test database connection
    await prisma.$connect();
    console.log('✅ Database connected successfully');

    // Start server
    app.listen(config.port, () => {
      console.log(`🚀 Server is running on http://localhost:${config.port}`);
      console.log(`📊 Health check: http://localhost:${config.port}/api/health`);
      console.log(`📚 API Documentation: http://localhost:${config.port}/api`);
      console.log(`🌍 Environment: ${config.nodeEnv}`);
      console.log(`🗄️ Database: Prisma + SQLite`);
    });
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
};

// Handle unhandled promise rejections
process.on('unhandledRejection', (err) => {
  console.error('Unhandled Promise Rejection:', err);
  process.exit(1);
});

// Handle uncaught exceptions
process.on('uncaughtException', (err) => {
  console.error('Uncaught Exception:', err);
  process.exit(1);
});

// Graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received, shutting down gracefully');
  await prisma.$disconnect();
  process.exit(0);
});

process.on('SIGINT', async () => {
  console.log('SIGINT received, shutting down gracefully');
  await prisma.$disconnect();
  process.exit(0);
});

startServer();