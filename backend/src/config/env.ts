import dotenv from 'dotenv';
import path from 'path';

// Cargar variables de entorno
dotenv.config({ path: path.join(__dirname, '../../.env') });

export const config = {
  // Server
  env: process.env.NODE_ENV || 'development',
  port: parseInt(process.env.PORT || '3000', 10),
  apiPrefix: process.env.API_PREFIX || '/api',

  // Database
  db: {
    url: process.env.DATABASE_URL,
    host: process.env.DB_HOST || 'localhost',
    port: parseInt(process.env.DB_PORT || '5432', 10),
    name: process.env.DB_NAME || 'provial_db',
    user: process.env.DB_USER || 'postgres',
    password: process.env.DB_PASSWORD || 'postgres',
  },

  // Redis
  redis: {
    url: process.env.REDIS_URL,
    host: process.env.REDIS_HOST || 'localhost',
    port: parseInt(process.env.REDIS_PORT || '6379', 10),
  },

  // JWT
  jwt: {
    secret: process.env.JWT_SECRET || 'dev-secret-change-in-production',
    refreshSecret: process.env.JWT_REFRESH_SECRET || 'dev-refresh-secret',
    expiresIn: process.env.JWT_EXPIRES_IN || '24h',
    refreshExpiresIn: process.env.JWT_REFRESH_EXPIRES_IN || '7d',
  },

  // CORS
  cors: {
    origins: process.env.CORS_ORIGIN?.split(',') || ['http://localhost:5173', 'http://localhost:8081'],
  },

  // Rate Limiting
  rateLimit: {
    windowMs: parseInt(process.env.RATE_LIMIT_WINDOW_MS || '900000', 10), // 15 min
    maxRequests: parseInt(process.env.RATE_LIMIT_MAX_REQUESTS || '100', 10),
  },

  // Logging
  logLevel: process.env.LOG_LEVEL || 'debug',

  // Socket.io
  socket: {
    corsOrigins: process.env.SOCKET_IO_CORS_ORIGIN?.split(',') || ['http://localhost:5173', 'http://localhost:8081'],
  },
};

// Validar configuración crítica
function validateConfig() {
  const requiredEnvVars = ['JWT_SECRET'];

  if (config.env === 'production') {
    requiredEnvVars.push('DATABASE_URL', 'REDIS_URL');
  }

  const missing = requiredEnvVars.filter(varName => {
    const value = process.env[varName];
    return !value || value === 'dev-secret-change-in-production';
  });

  if (missing.length > 0 && config.env === 'production') {
    throw new Error(`❌ Variables de entorno faltantes: ${missing.join(', ')}`);
  }
}

validateConfig();
