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
      // Mengizinkan gambar dari localhost dan format data base64
      imgSrc: ["'self'", "data:", "http://localhost:3000", "http://localhost:3000/uploads/"],
      styleSrc: ["'self'", "'unsafe-inline'"],
      scriptSrc: ["'self'"],
    },
  },
}));

// CORS middleware
app.use(corsMiddleware);

// Logging middleware (hanya di mode development)
if (config.nodeEnv === 'development') {
  app.use(morgan('dev'));
}

// Body parsing middleware dengan limit 10mb untuk upload foto
app.use(express.json({ limit: '10mb' }));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// Memastikan direktori uploads tersedia
const uploadsPath = path.join(__dirname, 'uploads');
const fs = require('fs');
if (!fs.existsSync(uploadsPath)) {
  fs.mkdirSync(uploadsPath, { recursive: true });
}

// Konfigurasi Header untuk file statis
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

// Menyajikan file statis
app.use('/uploads', express.static(uploadsPath, {
  setHeaders: (res: any) => {
    res.setHeader('Cross-Origin-Resource-Policy', 'cross-origin');
  },
}));

// Mendaftarkan rute API utama
app.use('/api', routes);

// Endpoint Root untuk pengecekan status server
app.get('/', (req, res) => {
  res.json({
    message: 'Absensi System API',
    status: 'Running',
    timestamp: new Date().toISOString()
  });
});

// Global Error Handler (Wajib diletakkan terakhir)
app.use(errorHandler);

export default app;
