import { Router } from 'express';
import { login, refresh, logout, me } from '../controllers/auth.controller';
import { authenticate } from '../middlewares/auth';

const router = Router();

// POST /api/auth/login
router.post('/login', login);

// POST /api/auth/refresh
router.post('/refresh', refresh);

// POST /api/auth/logout
router.post('/logout', logout);

// GET /api/auth/me (protegido)
router.get('/me', authenticate, me);

export default router;
