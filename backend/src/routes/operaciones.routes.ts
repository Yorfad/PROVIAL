import { Router } from 'express';
import {
  getDashboardOperaciones,
  getEstadisticasBrigadas,
  getEstadisticasBrigada,
  getEstadisticasUnidades,
  getEstadisticasUnidad,
  getBrigadasDisponibles,
  getUnidadesDisponibles,
  validarDisponibilidadBrigada,
  validarDisponibilidadUnidad,
  registrarCombustible,
  getHistorialCombustible,
} from '../controllers/operaciones.controller';
import { authenticate, authorize } from '../middlewares/auth';

const router = Router();

// ========================================
// DASHBOARD
// ========================================

router.get(
  '/dashboard',
  authenticate,
  authorize('OPERACIONES', 'ADMIN'),
  getDashboardOperaciones
);

// ========================================
// ESTADÍSTICAS DE BRIGADAS
// ========================================

router.get(
  '/brigadas/estadisticas',
  authenticate,
  authorize('OPERACIONES', 'ADMIN'),
  getEstadisticasBrigadas
);

router.get(
  '/brigadas/estadisticas/:id',
  authenticate,
  authorize('OPERACIONES', 'ADMIN'),
  getEstadisticasBrigada
);

// ========================================
// ESTADÍSTICAS DE UNIDADES
// ========================================

router.get(
  '/unidades/estadisticas',
  authenticate,
  authorize('OPERACIONES', 'ADMIN'),
  getEstadisticasUnidades
);

router.get(
  '/unidades/estadisticas/:id',
  authenticate,
  authorize('OPERACIONES', 'ADMIN'),
  getEstadisticasUnidad
);

// ========================================
// DISPONIBILIDAD PARA ASIGNACIÓN
// ========================================

router.get(
  '/brigadas/disponibles',
  authenticate,
  authorize('OPERACIONES', 'ADMIN'),
  getBrigadasDisponibles
);

router.get(
  '/unidades/disponibles',
  authenticate,
  authorize('OPERACIONES', 'ADMIN'),
  getUnidadesDisponibles
);

// ========================================
// VALIDACIONES
// ========================================

router.post(
  '/validar/brigada',
  authenticate,
  authorize('OPERACIONES', 'ADMIN'),
  validarDisponibilidadBrigada
);

router.post(
  '/validar/unidad',
  authenticate,
  authorize('OPERACIONES', 'ADMIN'),
  validarDisponibilidadUnidad
);

// ========================================
// COMBUSTIBLE
// ========================================

// Registrar combustible (brigadas también pueden)
router.post(
  '/combustible',
  authenticate,
  registrarCombustible
);

// Ver historial de combustible
router.get(
  '/combustible/unidad/:id',
  authenticate,
  authorize('OPERACIONES', 'BRIGADA', 'ADMIN'),
  getHistorialCombustible
);

export default router;
