-- Migración 011: Datos de ejemplo para sistema de turnos

-- NOTA: Este archivo es OPCIONAL, solo para desarrollo/testing

-- ========================================
-- TURNO DE HOY
-- ========================================

INSERT INTO turno (fecha, estado, observaciones, creado_por) VALUES
(CURRENT_DATE, 'ACTIVO', 'Turno normal, prestar atención a trabajos en CA-9 km 45',
    (SELECT id FROM usuario WHERE username = 'operaciones01'));

-- ========================================
-- ASIGNACIONES DE UNIDADES
-- ========================================

-- Asignación 1: PROV-001 (moto) - CA-9 Norte
INSERT INTO asignacion_unidad (
    turno_id, unidad_id, ruta_id, km_inicio, km_final, sentido,
    acciones, combustible_inicial, combustible_asignado,
    hora_salida, hora_entrada_estimada
) VALUES (
    (SELECT id FROM turno WHERE fecha = CURRENT_DATE),
    (SELECT id FROM unidad WHERE codigo = 'PROV-001'),
    (SELECT id FROM ruta WHERE codigo = 'CA-9'),
    10, 50, 'NORTE',
    'Patrullaje rutinario. Regular tránsito en km 30 si es necesario.',
    8.5, 10.0,
    '07:00', '15:00'
);

-- Tripulación para PROV-001
INSERT INTO tripulacion_turno (asignacion_id, usuario_id, rol_tripulacion, presente) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-001') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    (SELECT id FROM usuario WHERE username = 'brigada01'),
    'PILOTO',
    TRUE
);

-- Asignación 2: PROV-003 (pickup) - CA-1 Occidente
INSERT INTO asignacion_unidad (
    turno_id, unidad_id, ruta_id, km_inicio, km_final, sentido,
    acciones, combustible_inicial, combustible_asignado,
    hora_salida, hora_entrada_estimada
) VALUES (
    (SELECT id FROM turno WHERE fecha = CURRENT_DATE),
    (SELECT id FROM unidad WHERE codigo = 'PROV-003'),
    (SELECT id FROM ruta WHERE codigo = 'CA-1'),
    60, 100, 'OESTE',
    'Patrullaje. Apoyo a trabajos de mantenimiento en km 78.',
    15.2, 20.0,
    '06:30', '14:30'
);

-- Tripulación para PROV-003 (pickup con 2 personas)
INSERT INTO tripulacion_turno (asignacion_id, usuario_id, rol_tripulacion, presente) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-003') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    (SELECT id FROM usuario WHERE username = 'brigada02'),
    'PILOTO',
    TRUE
),
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-003') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    (SELECT id FROM usuario WHERE username = 'cop01'), -- COP puede salir como acompañante en casos especiales
    'ACOMPAÑANTE',
    TRUE
);

-- Asignación 3: PROV-002 (moto) - CA-9 Sur
INSERT INTO asignacion_unidad (
    turno_id, unidad_id, ruta_id, km_inicio, km_final, sentido,
    acciones, combustible_inicial, combustible_asignado,
    hora_salida, hora_entrada_estimada
) VALUES (
    (SELECT id FROM turno WHERE fecha = CURRENT_DATE),
    (SELECT id FROM unidad WHERE codigo = 'PROV-002'),
    (SELECT id FROM ruta WHERE codigo = 'CA-9'),
    50, 90, 'SUR',
    'Patrullaje de retorno. Verificar puente en km 65.',
    7.8, 10.0,
    '07:00', '15:00'
);

-- Tripulación para PROV-002
INSERT INTO tripulacion_turno (asignacion_id, usuario_id, rol_tripulacion, presente) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-002') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    (SELECT id FROM usuario WHERE username = 'cop02'), -- COP también puede ser piloto
    'PILOTO',
    TRUE
);

-- ========================================
-- REPORTES HORARIOS DE EJEMPLO
-- ========================================

-- Reporte de PROV-001 a las 08:00
INSERT INTO reporte_horario (asignacion_id, km_actual, sentido_actual, novedad, reportado_por, created_at) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-001') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    25.3,
    'NORTE',
    'Sin novedad, tránsito fluido',
    (SELECT id FROM usuario WHERE username = 'brigada01'),
    NOW() - INTERVAL '2 hours'
);

-- Reporte de PROV-001 a las 09:00
INSERT INTO reporte_horario (asignacion_id, km_actual, sentido_actual, novedad, reportado_por, created_at) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-001') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    35.7,
    'NORTE',
    'Tráfico lento por trabajos en km 36',
    (SELECT id FROM usuario WHERE username = 'brigada01'),
    NOW() - INTERVAL '1 hour'
);

-- Reporte de PROV-003 a las 08:00
INSERT INTO reporte_horario (asignacion_id, km_actual, sentido_actual, novedad, reportado_por, created_at) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-003') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE)),
    72.1,
    'OESTE',
    'Sin novedad',
    (SELECT id FROM usuario WHERE username = 'brigada02'),
    NOW() - INTERVAL '2 hours'
);

-- ========================================
-- TURNO DE MAÑANA (PLANIFICADO)
-- ========================================

INSERT INTO turno (fecha, estado, observaciones, creado_por) VALUES
(CURRENT_DATE + INTERVAL '1 day', 'PLANIFICADO', 'Turno del día siguiente',
    (SELECT id FROM usuario WHERE username = 'operaciones01'));

-- Asignación para mañana: PROV-001
INSERT INTO asignacion_unidad (
    turno_id, unidad_id, ruta_id, km_inicio, km_final, sentido,
    acciones, combustible_inicial, combustible_asignado,
    hora_salida, hora_entrada_estimada
) VALUES (
    (SELECT id FROM turno WHERE fecha = CURRENT_DATE + INTERVAL '1 day'),
    (SELECT id FROM unidad WHERE codigo = 'PROV-001'),
    (SELECT id FROM ruta WHERE codigo = 'CA-2'),
    0, 40, 'SUR',
    'Patrullaje Carretera del Pacífico',
    9.0, 12.0,
    '06:00', '14:00'
);

-- Tripulación para mañana
INSERT INTO tripulacion_turno (asignacion_id, usuario_id, rol_tripulacion) VALUES
(
    (SELECT id FROM asignacion_unidad WHERE unidad_id = (SELECT id FROM unidad WHERE codigo = 'PROV-001') AND turno_id = (SELECT id FROM turno WHERE fecha = CURRENT_DATE + INTERVAL '1 day')),
    (SELECT id FROM usuario WHERE username = 'brigada01'),
    'PILOTO'
);

-- ========================================
-- VERIFICACIÓN
-- ========================================

-- Ver turnos creados
-- SELECT * FROM v_turnos_completos ORDER BY fecha DESC;

-- Ver mi asignación de hoy (simulando que soy brigada01)
-- SELECT * FROM v_mi_asignacion_hoy WHERE usuario_id = (SELECT id FROM usuario WHERE username = 'brigada01');

COMMENT ON SCHEMA public IS 'Datos de ejemplo de turnos cargados. Ver v_turnos_completos para verificar.';
