import express = require('express');
const helmet = require('helmet');
import morgan = require('morgan');

// Import local modules
import { config } from './config';
import { syncDatabase } from './models';
const routes = require('./routes');
import { corsMiddleware } from './middleware/cors';
import { errorHandler } from './middleware/errorHandler';

const app = express();

// Security middleware
app.use(helmet());

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
app.use('/uploads', express.static('uploads'));

// API Routes
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

// Initialize database and start server
const startServer = async () => {
  try {
    // Sync database
    await syncDatabase();

    // Start server
    app.listen(config.port, () => {
      console.log(`🚀 Server is running on http://localhost:${config.port}`);
      console.log(`📊 Health check: http://localhost:${config.port}/api/health`);
      console.log(`📚 API Documentation: http://localhost:${config.port}/api`);
      console.log(`🌍 Environment: ${config.nodeEnv}`);
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
process.on('SIGTERM', () => {
  console.log('SIGTERM received, shutting down gracefully');
  process.exit(0);
});

startServer();