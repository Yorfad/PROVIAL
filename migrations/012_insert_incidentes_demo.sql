-- Migración 012: Insertar incidentes de demostración
-- Fecha: 2025-01-26

-- ========================================
-- INCIDENTES DE DEMOSTRACIÓN
-- ========================================

-- Incidente 1: Accidente de tránsito en CA-9 (Reportado)
INSERT INTO incidente (
    origen,
    estado,
    tipo_hecho_id,
    subtipo_hecho_id,
    ruta_id,
    km,
    sentido,
    referencia_ubicacion,
    latitud,
    longitud,
    unidad_id,
    brigada_id,
    fecha_hora_aviso,
    hay_heridos,
    cantidad_heridos,
    hay_fallecidos,
    cantidad_fallecidos,
    requiere_bomberos,
    requiere_pnc,
    requiere_ambulancia,
    observaciones_iniciales,
    creado_por,
    numero_reporte
) VALUES (
    'BRIGADA',
    'REPORTADO',
    1, -- Accidente de tránsito
    1, -- Colisión
    1, -- CA-9
    28.5,
    'NORTE',
    'Frente a gasolinera Shell, km 28.5',
    14.6407,
    -90.5133,
    1, -- UMV-001
    1, -- Brigada 1
    NOW() - INTERVAL '15 minutes',
    TRUE,
    2,
    FALSE,
    0,
    FALSE,
    TRUE,
    TRUE,
    'Colisión entre pickup y automóvil. 2 personas heridas, trasladadas en ambulancia. Tráfico lento en carril izquierdo.',
    3, -- Usuario brigada01
    'INC-2025-0001'
);

-- Incidente 2: Vehículo averiado en CA-1 (En Atención)
INSERT INTO incidente (
    origen,
    estado,
    tipo_hecho_id,
    ruta_id,
    km,
    sentido,
    referencia_ubicacion,
    latitud,
    longitud,
    unidad_id,
    brigada_id,
    fecha_hora_aviso,
    fecha_hora_llegada,
    hay_heridos,
    cantidad_heridos,
    hay_fallecidos,
    cantidad_fallecidos,
    requiere_bomberos,
    requiere_pnc,
    requiere_ambulancia,
    observaciones_iniciales,
    creado_por,
    numero_reporte
) VALUES (
    'BRIGADA',
    'EN_ATENCION',
    2, -- Vehículo averiado
    2, -- CA-1
    45.0,
    'OESTE',
    'A la altura del km 45, cerca de Chimaltenango',
    14.6621,
    -90.8192,
    2, -- UMV-002
    2, -- Brigada 2
    NOW() - INTERVAL '45 minutes',
    NOW() - INTERVAL '30 minutes',
    FALSE,
    0,
    FALSE,
    0,
    FALSE,
    FALSE,
    FALSE,
    'Bus extraurbano con falla mecánica. Grúa en camino. Pasajeros evacuados a orilla de carretera.',
    4, -- Usuario brigada02
    'INC-2025-0002'
);

-- Incidente 3: Accidente con heridos graves en CA-9 Sur (Regulación)
INSERT INTO incidente (
    origen,
    estado,
    tipo_hecho_id,
    subtipo_hecho_id,
    ruta_id,
    km,
    sentido,
    referencia_ubicacion,
    latitud,
    longitud,
    unidad_id,
    brigada_id,
    fecha_hora_aviso,
    fecha_hora_llegada,
    fecha_hora_estabilizacion,
    hay_heridos,
    cantidad_heridos,
    hay_fallecidos,
    cantidad_fallecidos,
    requiere_bomberos,
    requiere_pnc,
    requiere_ambulancia,
    observaciones_iniciales,
    creado_por,
    numero_reporte
) VALUES (
    'BRIGADA',
    'REGULACION',
    1, -- Accidente de tránsito
    1, -- Colisión
    1, -- CA-9
    18.2,
    'SUR',
    'Altura de Villa Nueva, km 18',
    14.5269,
    -90.5877,
    1, -- UMV-001
    1, -- Brigada 1
    NOW() - INTERVAL '2 hours',
    NOW() - INTERVAL '1 hour 45 minutes',
    NOW() - INTERVAL '1 hour 30 minutes',
    TRUE,
    3,
    FALSE,
    0,
    TRUE,
    TRUE,
    TRUE,
    'Colisión múltiple de 4 vehículos. 3 personas heridas graves trasladadas al Roosevelt. Carriles obstruidos, regulando tráfico.',
    3, -- Usuario brigada01
    'INC-2025-0003'
);

-- Incidente 4: Obstrucción vial en CA-9 Norte (Reportado)
INSERT INTO incidente (
    origen,
    estado,
    tipo_hecho_id,
    ruta_id,
    km,
    sentido,
    referencia_ubicacion,
    latitud,
    longitud,
    unidad_id,
    brigada_id,
    fecha_hora_aviso,
    hay_heridos,
    cantidad_heridos,
    hay_fallecidos,
    cantidad_fallecidos,
    requiere_bomberos,
    requiere_pnc,
    requiere_ambulancia,
    observaciones_iniciales,
    creado_por,
    numero_reporte
) VALUES (
    'USUARIO_PUBLICO',
    'REPORTADO',
    3, -- Obstrucción vial
    1, -- CA-9
    35.0,
    'NORTE',
    'Km 35, cerca de San José Pinula',
    14.5431,
    -90.4089,
    NULL,
    NULL,
    NOW() - INTERVAL '10 minutes',
    FALSE,
    0,
    FALSE,
    0,
    FALSE,
    FALSE,
    FALSE,
    'Usuario reporta árbol caído obstruyendo carril derecho dirección norte.',
    1, -- Usuario admin (como si fuera del público)
    'INC-2025-0004'
);

-- Incidente 5: Accidente leve en CA-2 (En Atención)
INSERT INTO incidente (
    origen,
    estado,
    tipo_hecho_id,
    subtipo_hecho_id,
    ruta_id,
    km,
    sentido,
    referencia_ubicacion,
    latitud,
    longitud,
    unidad_id,
    brigada_id,
    fecha_hora_aviso,
    fecha_hora_llegada,
    hay_heridos,
    cantidad_heridos,
    hay_fallecidos,
    cantidad_fallecidos,
    requiere_bomberos,
    requiere_pnc,
    requiere_ambulancia,
    observaciones_iniciales,
    creado_por,
    numero_reporte
) VALUES (
    'BRIGADA',
    'EN_ATENCION',
    1, -- Accidente de tránsito
    2, -- Choque lateral
    3, -- CA-2
    15.0,
    'ESTE',
    'Altura de Palín, Escuintla',
    14.4053,
    -90.6993,
    3, -- UMV-003 (pickup)
    3, -- Brigada 3
    NOW() - INTERVAL '25 minutes',
    NOW() - INTERVAL '15 minutes',
    FALSE,
    0,
    FALSE,
    0,
    FALSE,
    TRUE,
    FALSE,
    'Choque lateral entre dos vehículos. Sin heridos. Pilotos intercambiando información. PNC en camino para levantar acta.',
    3, -- Usuario brigada01
    'INC-2025-0005'
);

-- ========================================
-- AGREGAR VEHÍCULOS A INCIDENTES
-- ========================================

-- Vehículos del incidente 1 (INC-2025-0001)
INSERT INTO vehiculo_incidente (
    incidente_id,
    tipo_vehiculo_id,
    placa,
    color,
    modelo,
    estado_piloto,
    nombre_piloto,
    heridos_en_vehiculo,
    danos_estimados
) VALUES
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0001'),
    1, -- Automóvil
    'P123ABC',
    'Rojo',
    'Corolla 2018',
    'HERIDO',
    'Juan Carlos Pérez',
    1,
    'MODERADO'
),
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0001'),
    2, -- Pickup
    'C456DEF',
    'Blanco',
    'Ford Ranger 2020',
    'HERIDO',
    'María Elena García',
    1,
    'LEVE'
);

-- Vehículos del incidente 3 (INC-2025-0003)
INSERT INTO vehiculo_incidente (
    incidente_id,
    tipo_vehiculo_id,
    placa,
    color,
    modelo,
    estado_piloto,
    nombre_piloto,
    heridos_en_vehiculo,
    danos_estimados
) VALUES
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0003'),
    1, -- Automóvil
    'P789GHI',
    'Negro',
    'Civic 2019',
    'HERIDO',
    'Pedro López Morales',
    2,
    'GRAVE'
),
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0003'),
    2, -- Pickup
    'C111JKL',
    'Azul',
    'Toyota Hilux 2021',
    'HERIDO',
    'Ana Sofía Ramírez',
    1,
    'MODERADO'
);

-- ========================================
-- AGREGAR OBSTRUCCIONES
-- ========================================

INSERT INTO obstruccion_incidente (
    incidente_id,
    descripcion_generada,
    datos_carriles_json
) VALUES
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0001'),
    'Carril izquierdo parcialmente obstruido. Tráfico lento.',
    '{"norte": {"total_carriles": 2, "carriles_bloqueados": 1, "carriles_libres": 1}, "sur": {"total_carriles": 2, "carriles_bloqueados": 0, "carriles_libres": 2}}'::jsonb
),
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0003'),
    'Ambos carriles dirección sur obstruidos. Tráfico desviado.',
    '{"norte": {"total_carriles": 2, "carriles_bloqueados": 0, "carriles_libres": 2}, "sur": {"total_carriles": 2, "carriles_bloqueados": 2, "carriles_libres": 0}}'::jsonb
);

-- ========================================
-- RECURSOS SOLICITADOS
-- ========================================

INSERT INTO recurso_incidente (
    incidente_id,
    tipo_recurso,
    descripcion,
    hora_solicitud,
    hora_llegada,
    observaciones
) VALUES
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0001'),
    'AMBULANCIA',
    'Ambulancia Bomberos Municipales',
    NOW() - INTERVAL '12 minutes',
    NOW() - INTERVAL '8 minutes',
    'Trasladó 2 heridos al Hospital Roosevelt'
),
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0001'),
    'PNC',
    'Patrulla PNC Tránsito',
    NOW() - INTERVAL '10 minutes',
    NOW() - INTERVAL '5 minutes',
    'Levantando acta del accidente'
),
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0003'),
    'BOMBEROS',
    'Bomberos Voluntarios',
    NOW() - INTERVAL '1 hour 50 minutes',
    NOW() - INTERVAL '1 hour 40 minutes',
    'Extrajeron a heridos de vehículos'
),
(
    (SELECT id FROM incidente WHERE numero_reporte = 'INC-2025-0003'),
    'AMBULANCIA',
    'Ambulancia Cruz Roja',
    NOW() - INTERVAL '1 hour 45 minutes',
    NOW() - INTERVAL '1 hour 35 minutes',
    'Trasladó 3 heridos graves al Roosevelt'
);
