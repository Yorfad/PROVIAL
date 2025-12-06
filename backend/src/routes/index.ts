import { Router } from 'express';
import authRoutes from './auth.routes';
import turnoRoutes from './turno.routes';
import incidenteRoutes from './incidente.routes';
import situacionesRoutes from './situaciones.routes';
import gruposRoutes from './grupos.routes';
import movimientosRoutes from './movimientos.routes';
import auditoriaRoutes from './auditoria.routes';
import geografiaRoutes from './geografia.routes';
import salidaRoutes from './salida.routes';
import ingresoRoutes from './ingreso.routes';
import sedeRoutes from './sede.routes';
import intelligenceRoutes from './intelligence.routes';
import operacionesRoutes from './operaciones.routes';
import generadorTurnosRoutes from './generador-turnos.routes';

const router = Router();

// Rutas de autenticación
router.use('/auth', authRoutes);

// Rutas de turnos y asignaciones
router.use('/turnos', turnoRoutes);

// Rutas de incidentes
router.use('/incidentes', incidenteRoutes);

// Rutas de situaciones operativas
router.use('/situaciones', situacionesRoutes);

// Rutas de grupos y calendario
router.use('/grupos', gruposRoutes);

// Rutas de movimientos de brigadas
router.use('/movimientos', movimientosRoutes);

// Rutas de auditoría
router.use('/auditoria', auditoriaRoutes);

// Rutas de geografía (departamentos/municipios)
router.use('/geografia', geografiaRoutes);

// Rutas de salidas y asignaciones permanentes
router.use('/salidas', salidaRoutes);

// Rutas de ingresos a sede
router.use('/ingresos', ingresoRoutes);

// Rutas de sedes y reasignaciones
router.use('/sedes', sedeRoutes);

// Rutas de inteligencia y análisis
router.use('/intelligence', intelligenceRoutes);

// Rutas del módulo de operaciones
router.use('/operaciones', operacionesRoutes);

// Rutas del generador automático de turnos
router.use('/generador-turnos', generadorTurnosRoutes);

// TODO: Agregar más rutas aquí
// router.use('/catalogos', catalogosRoutes);

export default router;
