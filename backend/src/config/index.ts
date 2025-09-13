import dotenv = require('dotenv');

// Load environment variables
dotenv.config();

export const config = {
  port: process.env.PORT || 3000,
  nodeEnv: process.env.NODE_ENV || 'development',
  jwtSecret: process.env.JWT_SECRET || 'your-secret-key',
  jwtExpire: process.env.JWT_EXPIRE || '24h',
  databaseUrl: process.env.DATABASE_URL || 'sqlite:./database.sqlite',

  // CORS settings
  corsOrigin: process.env.CORS_ORIGIN || 'http://localhost:5173',

  // Upload settings
  uploadPath: process.env.UPLOAD_PATH || './uploads',
  maxFileSize: parseInt(process.env.MAX_FILE_SIZE || '5242880'), // 5MB
};
