import dotenv = require('dotenv');
import app from './app';
import { prisma } from './lib/prisma';

import userRoutes from "./routes/userRoutes";
import pembimbingRoutes from "./routes/pembimbingRoutes";

// Load environment variables
dotenv.config();

// Configuration
const config = {
  port: process.env.PORT || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  jwtSecret: process.env.JWT_SECRET || 'your-secret-key',
};

// Initialize database and start server
const startServer = async () => {
  try {
    // Test database connection
    await prisma.$connect();
    console.log('✅ Database connected successfully');

    // Start server binding to 0.0.0.0 (Allow external access)
    const server = app.listen(Number(config.port), '0.0.0.0', () => {
      console.log(`🚀 Server is running on http://0.0.0.0:${config.port}`);
      console.log(`📊 Health check: http://localhost:${config.port}/api/health`);
      console.log(`🌍 Environment: ${config.nodeEnv}`);

      // Tampilkan IP Address lokal komputer untuk memudahkan copy-paste ke Flutter
      const { networkInterfaces } = require('os');
      const nets = networkInterfaces();
      console.log('\n📡 --- AVAILABLE NETWORK INTERFACES (Use one of these in Flutter) ---');
      for (const name of Object.keys(nets)) {
        for (const net of nets[name]) {
          // Skip internal (non-IPv4) and non-internet addresses
          if (net.family === 'IPv4' && !net.internal) {
            console.log(`👉 http://${net.address}:${config.port}/api`);
          }
        }
      }
      console.log('------------------------------------------------------------------\n');
    });

    return server;
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

// Only start server if not in test environment
if (process.env.NODE_ENV !== 'test') {
  startServer();
}