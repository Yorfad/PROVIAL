import { Router } from 'express';
import {
  createIncidente,
  getIncidente,
  getIncidentes,
  updateIncidente,
  cambiarEstado,
  addVehiculo,
  setObstruccion,
  addRecurso,
  cerrarIncidente,
  getMensajeGeneral,
  getMensajeMandos,
} from '../controllers/incidente.controller';
import { authenticate, authorize } from '../middlewares/auth';

const router = Router();

// ========================================
// RUTAS PÚBLICAS (con autenticación)
// ========================================

// Crear incidente (cualquier usuario autenticado puede crear un incidente)
router.post('/', authenticate, createIncidente);

// Obtener incidente por ID o UUID
router.get('/:id', authenticate, getIncidente);

// Listar incidentes (con filtros)
router.get('/', authenticate, getIncidentes);

// ========================================
// RUTAS PARA BRIGADAS Y COP
// ========================================

// Actualizar incidente (brigadas y COP pueden actualizar)
router.patch('/:id', authenticate, authorize('BRIGADA', 'COP', 'ADMIN'), updateIncidente);

// Cambiar estado del incidente
router.patch(
  '/:id/estado',
  authenticate,
  authorize('BRIGADA', 'COP', 'ADMIN'),
  cambiarEstado
);

// Agregar vehículo al incidente
router.post('/:id/vehiculos', authenticate, authorize('BRIGADA', 'COP', 'ADMIN'), addVehiculo);

// Agregar/actualizar obstrucción
router.post(
  '/:id/obstruccion',
  authenticate,
  authorize('BRIGADA', 'COP', 'ADMIN'),
  setObstruccion
);

// Agregar recurso solicitado
router.post('/:id/recursos', authenticate, authorize('BRIGADA', 'COP', 'ADMIN'), addRecurso);

// Cerrar incidente
router.post('/:id/cerrar', authenticate, authorize('BRIGADA', 'COP', 'ADMIN'), cerrarIncidente);

// ========================================
// GENERACIÓN DE MENSAJES
// ========================================

// Mensaje para grupo general de WhatsApp
router.get('/:id/mensaje-general', authenticate, getMensajeGeneral);

// Mensaje resumido para mandos
router.get('/:id/mensaje-mandos', authenticate, getMensajeMandos);

export default router;
