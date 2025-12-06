-- Migración 009: Datos de prueba (seed)

-- NOTA: Este archivo es OPCIONAL y solo para desarrollo/testing
-- NO ejecutar en producción a menos que se necesiten datos de ejemplo

-- ========================================
-- USUARIOS DE PRUEBA
-- ========================================

-- Contraseña para todos los usuarios de prueba: "password123"
-- Hash bcrypt: $2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7
-- IMPORTANTE: En producción usar contraseñas seguras reales

INSERT INTO usuario (username, password_hash, nombre_completo, rol_id, sede_id) VALUES
-- Admin
('admin', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'Administrador Sistema',
    (SELECT id FROM rol WHERE nombre = 'ADMIN'), NULL),

-- Operadores COP
('cop01', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'Juan Pérez - COP',
    (SELECT id FROM rol WHERE nombre = 'COP'), (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('cop02', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'María López - COP',
    (SELECT id FROM rol WHERE nombre = 'COP'), (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),

-- Brigadas
('brigada01', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'Carlos Ramírez - Brigada',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'), (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('brigada02', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'Ana Morales - Brigada',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'), (SELECT id FROM sede WHERE codigo = 'SEDE-NORTE')),

-- Operaciones
('operaciones01', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'Luis García - Operaciones',
    (SELECT id FROM rol WHERE nombre = 'OPERACIONES'), (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),

-- Accidentología
('accidentologia01', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'Patricia Hernández - Accidentología',
    (SELECT id FROM rol WHERE nombre = 'ACCIDENTOLOGIA'), (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),

-- Mandos
('mando01', '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7', 'General Roberto Vásquez',
    (SELECT id FROM rol WHERE nombre = 'MANDOS'), NULL);

-- ========================================
-- UNIDADES DE PRUEBA
-- ========================================

INSERT INTO unidad (codigo, tipo_unidad, marca, modelo, anio, placa, sede_id) VALUES
('PROV-001', 'MOTORIZADA', 'Honda', 'XR190', 2023, 'P-001GT', (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('PROV-002', 'MOTORIZADA', 'Yamaha', 'FZ16', 2022, 'P-002GT', (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('PROV-003', 'PICKUP', 'Toyota', 'Hilux', 2021, 'P-003GT', (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('PROV-004', 'MOTORIZADA', 'Suzuki', 'GN125', 2023, 'P-004GT', (SELECT id FROM sede WHERE codigo = 'SEDE-NORTE')),
('PROV-005', 'PICKUP', 'Nissan', 'Frontier', 2020, 'P-005GT', (SELECT id FROM sede WHERE codigo = 'SEDE-SUR'));

-- ========================================
-- BRIGADAS DE PRUEBA
-- ========================================

INSERT INTO brigada (codigo, nombre, sede_id) VALUES
('BRIG-A1', 'Brigada Alpha 1', (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('BRIG-A2', 'Brigada Alpha 2', (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL')),
('BRIG-N1', 'Brigada Norte 1', (SELECT id FROM sede WHERE codigo = 'SEDE-NORTE')),
('BRIG-S1', 'Brigada Sur 1', (SELECT id FROM sede WHERE codigo = 'SEDE-SUR'));

-- ========================================
-- INCIDENTES DE PRUEBA
-- ========================================

-- Incidente 1: Accidente vial en CA-9
INSERT INTO incidente (
    origen, estado, tipo_hecho_id, subtipo_hecho_id, ruta_id, km, sentido,
    unidad_id, brigada_id,
    fecha_hora_aviso, fecha_hora_asignacion, fecha_hora_llegada, fecha_hora_finalizacion,
    hay_heridos, cantidad_heridos, hay_fallecidos, cantidad_fallecidos,
    requiere_ambulancia, observaciones_iniciales, observaciones_finales,
    creado_por, actualizado_por
) VALUES (
    'BRIGADA', 'CERRADO',
    (SELECT id FROM tipo_hecho WHERE nombre = 'Accidente Vial'),
    (SELECT id FROM subtipo_hecho WHERE nombre = 'Colisión'),
    (SELECT id FROM ruta WHERE codigo = 'CA-9'),
    52.5, 'NORTE',
    (SELECT id FROM unidad WHERE codigo = 'PROV-001'),
    (SELECT id FROM brigada WHERE codigo = 'BRIG-A1'),
    NOW() - INTERVAL '2 hours',
    NOW() - INTERVAL '1 hour 55 minutes',
    NOW() - INTERVAL '1 hour 40 minutes',
    NOW() - INTERVAL '30 minutes',
    TRUE, 2, FALSE, 0,
    TRUE,
    'Colisión entre automóvil y pickup, 2 heridos leves',
    'Ambulancia trasladó heridos, vía despejada',
    (SELECT id FROM usuario WHERE username = 'brigada01'),
    (SELECT id FROM usuario WHERE username = 'brigada01')
);

-- Vehículos del incidente 1
INSERT INTO vehiculo_incidente (
    incidente_id, tipo_vehiculo_id, marca_id, color, placa,
    estado_piloto, heridos_en_vehiculo, danos_estimados
) VALUES
(
    (SELECT id FROM incidente WHERE numero_reporte LIKE 'INC-%' ORDER BY created_at DESC LIMIT 1),
    (SELECT id FROM tipo_vehiculo WHERE nombre = 'Automóvil'),
    (SELECT id FROM marca_vehiculo WHERE nombre = 'Toyota'),
    'Rojo', 'P-123ABC',
    'HERIDO', 1, 'MODERADO'
),
(
    (SELECT id FROM incidente WHERE numero_reporte LIKE 'INC-%' ORDER BY created_at DESC LIMIT 1),
    (SELECT id FROM tipo_vehiculo WHERE nombre = 'Pickup'),
    (SELECT id FROM marca_vehiculo WHERE nombre = 'Nissan'),
    'Blanco', 'P-456DEF',
    'HERIDO', 1, 'LEVE'
);

-- Obstrucción del incidente 1
INSERT INTO obstruccion_incidente (
    incidente_id, descripcion_generada, datos_carriles_json
) VALUES (
    (SELECT id FROM incidente WHERE numero_reporte LIKE 'INC-%' ORDER BY created_at DESC LIMIT 1),
    'Obstruido carril derecho hacia el Norte, flujo lento',
    '{"norte": {"totalCarriles": 2, "carrilObstruido": 1, "carrilHabilitado": 2, "flujo": "LENTO"}}'
);

-- Incidente 2: Vehículo varado
INSERT INTO incidente (
    origen, estado, tipo_hecho_id, subtipo_hecho_id, ruta_id, km, sentido,
    unidad_id, brigada_id,
    fecha_hora_aviso, fecha_hora_llegada,
    observaciones_iniciales,
    creado_por
) VALUES (
    'BRIGADA', 'EN_ATENCION',
    (SELECT id FROM tipo_hecho WHERE nombre = 'Vehículo Varado'),
    (SELECT id FROM subtipo_hecho WHERE nombre = 'Falla Mecánica'),
    (SELECT id FROM ruta WHERE codigo = 'CA-1'),
    78.3, 'OESTE',
    (SELECT id FROM unidad WHERE codigo = 'PROV-003'),
    (SELECT id FROM brigada WHERE codigo = 'BRIG-A2'),
    NOW() - INTERVAL '30 minutes',
    NOW() - INTERVAL '15 minutes',
    'Cabezal varado en curva, solicitando grúa',
    (SELECT id FROM usuario WHERE username = 'brigada02')
);

-- Vehículo del incidente 2
INSERT INTO vehiculo_incidente (
    incidente_id, tipo_vehiculo_id, color,
    estado_piloto, danos_estimados
) VALUES (
    (SELECT id FROM incidente WHERE numero_reporte LIKE 'INC-%' ORDER BY created_at DESC LIMIT 1),
    (SELECT id FROM tipo_vehiculo WHERE nombre = 'Cabezal'),
    'Azul',
    'ILESO', NULL
);

-- Recurso solicitado
INSERT INTO recurso_incidente (
    incidente_id, tipo_recurso, descripcion, hora_solicitud
) VALUES (
    (SELECT id FROM incidente WHERE numero_reporte LIKE 'INC-%' ORDER BY created_at DESC LIMIT 1),
    'GRUA', 'Grúa para cabezal', NOW() - INTERVAL '10 minutes'
);

-- ========================================
-- ACTIVIDADES DE PRUEBA
-- ========================================

-- Actividad cerrada: Patrullaje
INSERT INTO actividad_unidad (
    unidad_id, tipo_actividad_id, ruta_id, km, sentido,
    hora_inicio, hora_fin, observaciones, registrado_por
) VALUES (
    (SELECT id FROM unidad WHERE codigo = 'PROV-001'),
    (SELECT id FROM tipo_actividad WHERE nombre = 'Patrullaje'),
    (SELECT id FROM ruta WHERE codigo = 'CA-9'),
    45.0, 'NORTE',
    NOW() - INTERVAL '3 hours',
    NOW() - INTERVAL '2 hours',
    'Patrullaje rutinario km 40-55',
    (SELECT id FROM usuario WHERE username = 'brigada01')
);

-- Actividad activa: En accidente
INSERT INTO actividad_unidad (
    unidad_id, tipo_actividad_id, ruta_id, km, incidente_id,
    hora_inicio, observaciones, registrado_por
) VALUES (
    (SELECT id FROM unidad WHERE codigo = 'PROV-003'),
    (SELECT id FROM tipo_actividad WHERE nombre = 'Vehículo Varado'),
    (SELECT id FROM ruta WHERE codigo = 'CA-1'),
    78.3,
    (SELECT id FROM incidente WHERE estado = 'EN_ATENCION' ORDER BY created_at DESC LIMIT 1),
    NOW() - INTERVAL '15 minutes',
    'Atendiendo vehículo varado',
    (SELECT id FROM usuario WHERE username = 'brigada02')
);

-- ========================================
-- NOTAS
-- ========================================

-- Para ver los datos insertados:
-- SELECT * FROM v_incidentes_completos ORDER BY created_at DESC;
-- SELECT * FROM v_actividades_completas ORDER BY hora_inicio DESC;
-- SELECT * FROM v_estado_actual_unidades;

COMMENT ON SCHEMA public IS 'Datos de prueba cargados correctamente. Usuarios: admin, cop01, cop02, brigada01, brigada02, operaciones01, accidentologia01, mando01. Password: password123';
