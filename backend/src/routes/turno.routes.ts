import { Router } from 'express';
import {
  getTurnoHoy,
  getAsignacionesPendientes,
  getMiAsignacionHoy,
  createTurno,
  createAsignacion,
  updateAsignacion,
  deleteAsignacion,
  marcarSalida,
  marcarEntrada,
  createReporteHorario,
  getReportesHorarios,
  cambiarRutaActiva,
  registrarCombustible
} from '../controllers/turno.controller';
import { authenticate, authorize } from '../middlewares/auth';

const router = Router();

// Rutas públicas (requieren autenticación básica)
router.get('/hoy', authenticate, getTurnoHoy);
router.get('/pendientes', authenticate, authorize('OPERACIONES', 'ADMIN'), getAsignacionesPendientes);
router.get('/mi-asignacion-hoy', authenticate, getMiAsignacionHoy);

// Crear turno (solo Operaciones y Admin)
router.post('/', authenticate, authorize('OPERACIONES', 'ADMIN'), createTurno);

// Crear asignación (solo Operaciones y Admin)
router.post('/:id/asignaciones', authenticate, authorize('OPERACIONES', 'ADMIN'), createAsignacion);

// Actualizar y eliminar asignación (solo Operaciones y Admin)
router.put('/asignaciones/:id', authenticate, authorize('OPERACIONES', 'ADMIN'), updateAsignacion);
router.delete('/asignaciones/:id', authenticate, authorize('OPERACIONES', 'ADMIN'), deleteAsignacion);

// Marcar salida/entrada (Brigadas)
router.post('/marcar-salida', authenticate, authorize('BRIGADA'), marcarSalida);
router.post('/marcar-entrada', authenticate, authorize('BRIGADA'), marcarEntrada);

// Cambiar ruta activa (Brigadas)
router.post('/cambiar-ruta', authenticate, authorize('BRIGADA'), cambiarRutaActiva);

// Registrar combustible (Brigadas)
router.post('/registrar-combustible', authenticate, authorize('BRIGADA'), registrarCombustible);

// Reportes horarios
router.post('/reportes-horarios', authenticate, authorize('BRIGADA'), createReporteHorario);
router.get('/reportes-horarios/:asignacionId', authenticate, getReportesHorarios);

export default router;
