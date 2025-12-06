import { Router } from 'express';
import {
  registrarIngreso,
  registrarSalidaDeSede,
  getMiIngresoActivo,
  getHistorialIngresos,
  getIngreso
} from '../controllers/ingreso.controller';
import { authenticate, authorize } from '../middlewares/auth';

const router = Router();

// ========================================
// REGISTRO DE INGRESOS
// ========================================

// Registrar ingreso a sede (Brigada)
router.post('/registrar', authenticate, authorize('BRIGADA'), registrarIngreso);

// Registrar salida de sede - volver a la calle (Brigada)
router.post('/:id/salir', authenticate, authorize('BRIGADA'), registrarSalidaDeSede);

// ========================================
// CONSULTAS DE INGRESOS
// ========================================

// Mi ingreso activo (Brigada)
router.get('/mi-ingreso-activo', authenticate, authorize('BRIGADA'), getMiIngresoActivo);

// Historial de ingresos de una salida
router.get('/historial/:salidaId', authenticate, getHistorialIngresos);

// Obtener ingreso específico
router.get('/:id', authenticate, getIngreso);

export default router;
