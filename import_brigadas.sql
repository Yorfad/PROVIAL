-- Importacion de brigadas desde Excel
-- Generated automatically


INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_1012',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Garcia Garcia, Angel Mario',
    '1012',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '40322469',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_1032',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'MAZARIEGOS RODRÍGUEZ, JULIO',
    '1032',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '59497659',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_1006',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Santos Ávila, Marvin, D.',
    '1006',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '56310159',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_1016',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'EDNA MELISA MARCHORRO PAIZ',
    '1016',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '50196758',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_1022',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Adriano Lopez, Manuel de Jesús',
    '1022',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'xx',
    '56774523',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_1048',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'MORALES ROMAN, JOSÈ ADRIÀN',
    '1048',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '47358534',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_3016',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'HERNÀNDEZ GALDÀMEZ, WILNER',
    '3016',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '54110997',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_3018',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'HERRARTE SILVA, GUSTAVO ADOLFO',
    '3018',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '55610149',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_3024',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morales Romero, Griselda',
    '3024',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '59132108',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_3025',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Perdomo Lòpez, Edgar',
    '3025',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '30722880',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_3031',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'RAMIREZ MARROQUIN, SANTIAGO',
    '3031',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '56907317',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_3032',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ramirez Toc, Jorge Mario',
    '3032',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '42538169',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_4001',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'AGUSTIN LOPEZ, ESTEBAN DOMINGO',
    '4001',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '58930713',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_4009',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'CISNEROS ESQUIVEL RICARDO',
    '4009',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '56191872',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_4015',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Fajardo Rodas, Elmer',
    '4015',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '54657949',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_4016',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Fuentes López, Uber',
    '4016',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '42317400',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_4022',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'GUTIERREZ CHACLAN FERNANDO',
    '4022',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '47592325',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_4028',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'LAJ TECU JUAN ANTONIO',
    '4028',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '42512233',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_4046',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'SALAZAR PORTILLO, PEDRO',
    '4046',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '42547133',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_4053',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Vicente Ajtun, Moises',
    '4053',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '34475191',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_4054',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Xitumul Perez, Julio Alberto',
    '4054',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '41265609',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_5000',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Aquino Escobar, Juan',
    '5000',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '54683711',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_5003',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'CUMEZ CHACACH, FREDY',
    '5003',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '42114783',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_5005',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'CRUZ VELIZ OSMAR RAMIRO',
    '5005',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '36971442',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_5006',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'CIFUENTES CU JOSE LUIS',
    '5006',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '42046644',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_5037',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'QUICHÉ VELÁSQUEZ, BARTOLO',
    '5037',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '42489080',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_5041',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'REYES SACUL CUPERTINO',
    '5041',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '55635919',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_6008',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'CAXAJ GIRON JACOB',
    '6008',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'xx',
    '30486404',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_6026',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Mateo Lopez Cesar Everildo',
    '6026',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'xx',
    '47225462',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_6033',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Torres Perez, Denis',
    '6033',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '41636148',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_7006',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Carrillo Hernàndez, Juan Alberto',
    '7006',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '54151836',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_7010',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Marcos Roberto de León Roldán',
    '7010',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A Y M',
    '45501893',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_7012',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'DIAZ DE LEON GUSTAVO ADOLFO',
    '7012',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '44309920',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_7043',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'RAMOS ALFARO, BAYRON YOBANY',
    '7043',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '40880325',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_7045',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'RODAS CARCAMO CESAR JOAQUIN',
    '7045',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '47722394',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_7058',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ramirez Castillo, Remigio',
    '7058',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '59108102',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_8003',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'ARRIVILLAGA OLIVA, EDGAR GEOVANNI',
    '8003',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '42129500',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_8012',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cuxil Xicay, Edwin',
    '8012',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '40389988',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_8031',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pacheco Escobar, Vilma Janeth',
    '8031',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '41087698',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_8043',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Rivas Díaz, Kennedy Josué',
    '8043',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '48792840',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_8044',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'SANTIZO PEREZ, JUAN',
    '8044',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '55754536',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_8047',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Suchite Orellana, Maynor',
    '8047',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '41801030',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_9005',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Quiñonez Hernandez, Edwing',
    '9005',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '54176017',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_9006',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'OLIVA PAIZ, UBALDO',
    '9006',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '50180472',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_9015',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Fuentes Fuentes, Margarito',
    '9015',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '35790672',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_9016',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Jor Max, Ruben Dario',
    '9016',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '41898448',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_9019',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Orellana Paz, David Gerardo',
    '9019',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '42187121',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_9021',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'PEREZ MIRANDA FELICIANO',
    '9021',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '51557307',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_10005',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'CALDERON RODRIGUEZ GERSON NOE',
    '10005',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '47243927',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_10006',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'CARRETO PEREZ WENDY YOMARA',
    '10006',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '51275611',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_10013',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gonzales Cardona, Luis Alberto',
    '10013',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '51019019',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_10021',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'LUC PEREZ, JOSUE',
    '10021',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '54639402',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_10025',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'MONZON MORALES MITSIU YONATHAN',
    '10025',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '58177100',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_10032',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'RAMOS CINTO RODELFI ADELAIDO',
    '10032',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '30311068',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_10033',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'REVOLORIO REVOLORIO SILVERIO ELISEO',
    '10033',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '40645374',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_10034',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'REVOLORIO ORTIZ JHONY MARTIN',
    '10034',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '30414563',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_10041',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'VELASQUEZ PABLO TELESFORO ALBERTO',
    '10041',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '55374940',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_11002',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Albisures García, Juan',
    '11002',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '47226649',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_11004',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Arana Franco, Wagner',
    '11004',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '57094845',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_11006',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Atz Argueta, Jose Vicente',
    '11006',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '55589877',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_11014',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Galicia Galicia, Marcela',
    '11014',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55646131',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_11017',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'GARCIA LIMA EDY REGINALDO',
    '11017',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '47557663',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_11018',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Godinez Velasquez,Kevin',
    '11018',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '37586334',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_11024',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Juarez Sanchez, Edwin A.',
    '11024',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54587080',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_11026',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Lopez Rosales, Marco Luis',
    '11026',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '48156647',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_11034',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'PEREZ GOMEZ BRYAN',
    '11034',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '59725267',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_11035',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Quieza Porras, Chrystian',
    '11035',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '56982408',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_11040',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'TORRES GALVAN LUIS FERNANDO',
    '11040',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '51967507',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_11042',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Xajap Xuya, Jose Wenceslao',
    '11042',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '57124807',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_12002',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Camas Andrade, Edwin',
    '12002',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54208709',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_12003',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Carias Zuñiga, Walfre',
    '12003',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '41070752',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_12005',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Castillo Aguilar, Breder Vidani',
    '12005',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '50442322',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_12010',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Esquivel Herrera, Blas Roosenvelt',
    '12010',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '56372383',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_12014',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Jimenez Cortez David Isaias',
    '12014',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '30626479',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_12018',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Mendoza Zelada, Marvín E.',
    '12018',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '47405191',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_12022',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morataya Rosales, Lizeth',
    '12022',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '42738922',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_12023',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'MOREIRA HERNANDEZ JOSE ADEMIR',
    '12023',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '54938182',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_12024',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Obregón Chinchilla, Jorge Luis',
    '12024',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '55138646',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_12025',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Quevedo Corado, Jeidí Patricia',
    '12025',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '51119882',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_12026',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Quiná Simon, Marvin Dinael',
    '12026',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '58551591',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_12031',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Toj Lopez,  William Edilser',
    '12031',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '57110803',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_13008',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'DUARTE ALAY ROBERTO CARLOS',
    '13008',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M,B',
    '55688629',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_13009',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Garcìa Esquivel, Lester',
    '13009',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '57793598',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_13010',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernandez Pèrez, Josuè Daniel',
    '13010',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '42734647',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_13011',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Juàrez Chen, Edwin Eduardo',
    '13011',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '42769415',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_13012',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'LEIVA RAMOS EVERTH LEMUEL',
    '13012',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B,M',
    '47070282',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_13017',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Melgar Lòpez, Edwin Leonardo',
    '13017',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '41020094',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_13022',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Salgado Kegel, Romeo Alberto',
    '13022',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '47290385',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_13027',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Campos Retana, Aroldo Federico',
    '13027',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46062585',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_13036',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Retana Valladares, Horacio Fabricio',
    '13036',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '48115296',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_13037',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Vasquez Rivera, Luis Miguel',
    '13037',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '54924806',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_14003',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Argueta, Guilver Yònatan',
    '14003',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '52522812',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_14004',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Barrientos Revolorio, Madhelyn Lizbeth',
    '14004',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '56904844',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_14007',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'CABRERA CRUZ, BRYAN JOSE',
    '14007',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '42082318',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_14008',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Charchalac Cox, Victor Raul',
    '14008',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A y M',
    '59671130',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_14013',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Garcia Morales, Edgar Omar',
    '14013',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '55352413',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_14015',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Martinez Anavizca William Estuardo',
    '14015',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '54201646',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_14017',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Monterroso Perez, Mynor Rene',
    '14017',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '37351434',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_14020',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Najarro Moran, Dular',
    '14020',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '31372749',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_14023',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Rodriguez Quiñones, Marvin Alexander',
    '14023',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '59751575',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_14024',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Santos Loy, Hiben Amadiel',
    '14024',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '48288824',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15001',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Adriano Hernández, Adolfo Estuardo',
    '15001',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '57248658',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15002',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Alonzo Morales, Victor Manuel',
    '15002',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41576401',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15003',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ardiano Velásquez, Abdi Abisaí',
    '15003',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55726658',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15004',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Argueta Bernal, Beyker Eduardo',
    '15004',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '57672841',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15005',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Argueta Sandoval, Delmi Odíly',
    '15005',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '37048952',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15006',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Aroche Ucelo, Francisco Jesús',
    '15006',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B,E',
    '37621508',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15007',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Asencio Corado, Alex Omar',
    '15007',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C,M',
    '55444990',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15011',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Barillas Velásquez, Jaime Bernabé',
    '15011',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '54482019',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15012',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Barrera Rodríguez, Félix Daniel',
    '15012',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '59753884',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15014',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Bautista De León, Sergio Rubén',
    '15014',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '51788569',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15015',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Belloso Flores, Carlos Alex',
    '15015',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '47660068',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15017',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cabrera Suchite, Kleiver Josué',
    '15017',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C Y M',
    '42124318',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15018',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cárdenas Argueta, Allan Josué',
    '15018',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41204159',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15019',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Carrillo García, Walter Aristides',
    '15019',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '56484285',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15021',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cermeño Barahona, Wilsson Israel',
    '15021',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '45175358',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15022',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cermeño Barrios, Edgar Alfonso',
    '15022',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '51153005',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15024',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Chinchilla Valenzuela, Kevin Estuardo',
    '15024',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54165584',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15025',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Chú Ichich, Oscar Arnoldo',
    '15025',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '46299360',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15026',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Chub Coc, Salvador',
    '15026',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '33537777',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15027',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Colop Xec, Abelardo Abigaíl',
    '15027',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '41843613',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15028',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Contreras Paau, Jorge Humberto',
    '15028',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B,M',
    '55347855',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15029',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Corado Reynosa, Steeven Omar',
    '15029',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '31837226',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15030',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cortéz Cisneros,Juan Wilberto',
    '15030',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '30888181',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15031',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cruz López, Estuardo',
    '15031',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '49651080',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15036',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Donis Ortíz, Marco Tulio',
    '15036',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B,M',
    '30749674',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15040',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Esteban Estrada, Edras Josué',
    '15040',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '49465251',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15041',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Estrada Morales, Carlos Leonel',
    '15041',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '39916329',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15044',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Fuentes García, Milton Danilo',
    '15044',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '42724292',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15046',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Garcia Castillo, Elmer Candelario',
    '15046',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B,M',
    '30418016',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15047',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'García García, Pedro César',
    '15047',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '42132305',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15049',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'García Pineda, Gelber Alexander',
    '15049',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '36860640',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15050',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Girón Méndez, Miguel Angel',
    '15050',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41589261',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15051',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gómez Aceytuno, Manuel Estuardo',
    '15051',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '32543048',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15052',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gómez González, Wilfido Enrique',
    '15052',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B,M',
    '41630389',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15056',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'González García, Brayan Josué',
    '15056',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54337385',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15058',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gudiel Osorio, Cedín Fernando',
    '15058',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54424016',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15061',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Guzmán Lemus, Erick Randolfo',
    '15061',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '47030750',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15062',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernández Fajardo, Rufino David',
    '15062',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55553685',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15063',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernández y Hernández, Edwin Rolando',
    '15063',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '36505281',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15064',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Isaacs Peñate, Carlos Iván',
    '15064',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55957220',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15065',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Jiménez González, Rafael Estuardo',
    '15065',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '40896679',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15066',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Landaverde Rodriguez Byron Fernando',
    '15066',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '49691007',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15068',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Lima Yanes Jerson Geovani',
    '15068',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '55444975',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15069',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'López Castro, Francel Isaías',
    '15069',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C,M',
    '36326366',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15073',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'MANZANO PEREZ JOSEPH ALEXANDER',
    '15073',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '58118439',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15074',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'MARROQUIN LOPEZ, EDWIN FABIO',
    '15074',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41997206',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15075',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Martinez Brol, Anthony Steven',
    '15075',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B Y M',
    '47484283',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15076',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Martínez Herrera, Miguel Antonio',
    '15076',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41007921',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15079',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Mejía Hernández, Christian Geovanni',
    '15079',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '52705742',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15080',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Méndez García, Wiliam Neftalí',
    '15080',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '52011184',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15081',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Mendoza Belloso, Darvin Enrique',
    '15081',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '44827248',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15082',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Miranda Aguilar, Esaú Emanuel',
    '15082',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '32633590',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15083',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Miranda Barrios, Lester Waldemar',
    '15083',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B,M',
    '54361900',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15086',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'MONTERROSO ARGUETA EDWIN RODOLFO',
    '15086',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B,M',
    '54544144',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15088',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morales Barrientos, Manglio Estiward',
    '15088',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M,C',
    '32457021',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15089',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morales Barrientos, Marta Berenice',
    '15089',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '41504918',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15091',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morales Lemus, Héctor Adulfo',
    '15091',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '47504407',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15094',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morán López, Jayme Josue.',
    '15094',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '56347517',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15095',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'NAJERA MORALES EDVIN ANTONIO',
    '15095',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '58746568',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15096',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Orellana González, Leonel Enrique',
    '15096',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C Y M',
    '55875540',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15097',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ortíz Catalán, Augusto',
    '15097',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B,M',
    '47284594',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15098',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Palencia Morales, Anderson Brenner',
    '15098',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '59755042',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15099',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Peñate Arévalo, Ana Patricia',
    '15099',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '58205081',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15100',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pérez Asencio, Ronal Orlando',
    '15100',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54238581',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15101',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pérez Melgar, José Carlos.',
    '15101',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55270384',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15102',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pérez Morales, Anibal Eliandro',
    '15102',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '47313823',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15103',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pérez Pérez, José Emedardo',
    '15103',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '49417867',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15106',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'PINEDA OSORIO, BRYAN ALEXANDER',
    '15106',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B,M',
    '31248153',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15109',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Quinteros Del Cid, Ervin Edgardo',
    '15109',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '59393778',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15116',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Rivas Regalado, Carlos Dagoberto',
    '15116',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '50087668',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15122',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ruano Corado, Luzbeth Yaneth',
    '15122',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '53595270',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15123',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ruíz Ruíz, José Fabricio Alizardy',
    '15123',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '58720592',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15124',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Salazar Gutiérrez, Angel José',
    '15124',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M,B',
    '30329199',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15125',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Samayoa Dubón, Cristian Omar',
    '15125',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '32159513',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15128',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Santacruz Salazar, Ludbin Obel',
    '15128',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '57392040',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15129',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Santos Pérez, William Michael',
    '15129',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '48668437',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15131',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Sióc Ortíz, Marvyn Gundemaro',
    '15131',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M,B',
    '55880024',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15134',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Valdez Martínez, Cristopher Obed',
    '15134',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '42579200',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15137',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Velásquez Escobar, Roger Wilfredo',
    '15137',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '51299283',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15138',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Yoc Elel, Edson Ernesto',
    '15138',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46010605',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15139',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'ZUÑIGA FERNANDEZ GERMAN DANILO',
    '15139',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '53037204',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16001',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Adquí López Arly Paola',
    '16001',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '48443763',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16002',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Aguilar Castillo, Santos Amilcar',
    '16002',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '5872-3644',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16008',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Belloso Peñate karen Jeannette',
    '16008',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'c',
    '47898728',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16013',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Calderón Hector Oswaldo',
    '16013',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '48358417',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16014',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Calderón López Clara Luz',
    '16014',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '30128498',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16015',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Camó Acoj, Cristhian Geovany',
    '16015',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '36792020',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16016',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cano Boteo Irrael',
    '16016',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '55441699',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16017',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cano Serrano, Gervin Geovany',
    '16017',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '59379949',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16019',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Carrillo Rossell, Kevin Arnaldo',
    '16019',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '31022813',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16020',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Castañon Rodríguez Estuardo Odely',
    '16020',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '56925077',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16023',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Castillo García, Cesar José',
    '16023',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '5206-1540',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16031',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Chén Xuc, José Luis',
    '16031',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '59064424',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16032',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Chiroy Revolorio Kerlin Arturo',
    '16032',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55449389',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16033',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cojom Damian, Emanuel Isaías',
    '16033',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '36138977',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16036',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Corado Corado, Jerzon Anibal',
    '16036',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '39860249',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16037',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Corado Ramírez, Claudia Fabiola',
    '16037',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46604309',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16038',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Córdova González, Junnior Danilo',
    '16038',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '4749-5108',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16040',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cortéz Menéndez, Oscar Anibal',
    '16040',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '5820-0969',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16042',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'De La Rosa Monterroso, Manuel De Jesús',
    '16042',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54686781',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16044',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Del Cid Hernández, Junior Humberto',
    '16044',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '36544718',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16048',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Escobar Beltrán, Marlon Geobany',
    '16048',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '53056974',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16050',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Escobar Cermeño, Marvin Geovani',
    '16050',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '4060-3131',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16052',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Escobar García, Kevin Alfredo',
    '16052',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '5153-6734',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16053',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Escobar Hernández Yeison Humberto',
    '16053',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '42613063',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16057',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Florián Morán, Luis Fernando',
    '16057',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '58003240',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16060',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Franco Sierra Edgar Saray',
    '16060',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C,M',
    '36349977',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16061',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gaitán Cruz, Juan José',
    '16061',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46689465',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16064',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'García Ramirez Elder Alfredo',
    '16064',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '58215477',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16065',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Jimenez Gonzales Rafael Estuardo',
    '16065',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '40896679',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16067',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gómez Elvira Jose Fernando',
    '16067',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '33021341',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16068',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'González Estrada, Marlon Estuardo',
    '16068',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A,M',
    '48058600',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16070',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'González Ríos, Walfred David Alexander',
    '16070',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '45084894',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16074',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gutiérrez Herrera, Edvin Edilson',
    '16074',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '4642-7072',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16075',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernandez Barrera Rufino Dagoberto',
    '16075',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '47101462',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16076',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernández Castañeda Mario José',
    '16076',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '51672492',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16077',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernández Cotill Abner Misael',
    '16077',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '51154302',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16078',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernández Giron Yonathan Alexander',
    '16078',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '42038230',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16079',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernández Juárez, Pablo',
    '16079',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '38142902',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16080',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernández Palencia, Albert Gennady',
    '16080',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '56348289',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16082',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hurtado Asencio, María De Los Ángeles',
    '16082',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '48119114',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16083',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ixchop Corado Efémber José Rodrigo',
    '16083',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '54114853',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16086',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Lima López, Hugo David',
    '16086',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '5759-9210',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16088',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'LINARES CRUZ ESDRAS EFRAIN',
    '16088',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '30947787',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16089',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'López Alonzo, Marcos Daniel',
    '16089',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55633374',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16092',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'López Morales, Mario Samuel',
    '16092',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55329570',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16094',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Lorenzo Yac Anselmo',
    '16094',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54219552',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16095',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Marroquin Argueta, Esleyder Antonio',
    '16095',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '33256271',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16096',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Martínez Anavisca Brian Luis Felipe',
    '16096',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '47235885',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16097',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Martínez Arévalo, Noé De Jesús',
    '16097',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '42178488',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16100',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Menchú Anavisca, Hilmy Julissa',
    '16100',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41866819',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16101',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Mendez Malchic, José Efraín',
    '16101',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '4249-5825',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16102',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Méndez Ortíz, Juan José',
    '16102',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '49184721',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16103',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Miranda Melgar Edson Ariel',
    '16103',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '59324191',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16105',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morales Gómez, Mario Fernando',
    '16105',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '50136789',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16106',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morales Ochoa Selvin Vinicio',
    '16106',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '48206415',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16107',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morán Cazún, Mynor Armando',
    '16107',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '50896070',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16109',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morán Puaque Elmar Rolando',
    '16109',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55640834',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16113',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Orellana Estrada, Jesús Emilio',
    '16113',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41336635',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16114',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Orozco Témaj Byron Armando',
    '16114',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '30744791',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16116',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ortíz Carrillo Kevin Renato',
    '16116',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '58520591',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16117',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ortíz Paz, Luis Carlos',
    '16117',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '53409913',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16119',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pérez Garrido Mailyng Leilani',
    '16119',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '58577312',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16125',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Piox Cadenas Edwin Leonel Enrique',
    '16125',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '42070215',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16126',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Quintana Barrientos, Mario Roberto',
    '16126',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '57394356',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16128',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ramirez Gereda Tayron Alexander',
    '16128',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '58251954',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16130',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ramírez Yanes, Jonyr Rolando',
    '16130',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '39821205',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16131',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Revolorio Arana Brayan Alexander',
    '16131',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C,M',
    '40383555',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16135',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Rodríguez Larios, Pedro Caín',
    '16135',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '39860018',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16139',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Edvin Jose Rodolfo Ruiz Gutierrez',
    '16139',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '43638509',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16143',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Santizo Bojorquez, Alexis Efraín',
    '16143',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '47301837',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16144',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Santos Beltetón, Yonatan Eduardo',
    '16144',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '40666558',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16145',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Santos Turcios, Nelson Bladimiro',
    '16145',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '57489200',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16146',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Sical Manuel, Marlon Estuardo',
    '16146',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '32991378',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16147',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Sifuentes Ávila Kevin Ernesto',
    '16147',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A,M',
    '46669883',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16150',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Solares Carias Jorge',
    '16150',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '49637263',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16151',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Sosa Barrios, Bryan Josue',
    '16151',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '35687342',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16152',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Tecú Raxcaco Victor Manuel',
    '16152',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '59728790',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16153',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Valladares González Hector Noel',
    '16153',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '54565764',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16155',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Virula y Virula, Osiel Antonio',
    '16155',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '41552574',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16156',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Vivas Nimacachi David Amilcar',
    '16156',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '49704618',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16157',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Zepeda Chavez, Axel Ariel',
    '16157',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54832281',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16158',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Zuñiga Godoy José Armando',
    '16158',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '48686690',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17004',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gomez Ramirez Samy Renato',
    '17004',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '51644858',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17005',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'LOPEZ GUILLEN MARIO ROLANDO',
    '17005',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '37895331',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17010',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Peñate Moran Ana Mary',
    '17010',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '33557716',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17012',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Retana Vásquez, José Armando',
    '17012',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'xx',
    '48308921',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17014',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Kenia Estrella Barrientos Mendez',
    '17014',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '33344283',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17015',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Blanco Carias Evelin Maritza',
    '17015',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '4820-4648',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17016',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Campos Cermeño Cesar Eduardo',
    '17016',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'NO',
    '3696-1707',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17017',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Campos Pinelo Edwin Daniel',
    '17017',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C,M',
    '51582605',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17018',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cermeño Pineda Evelin Siomara',
    '17018',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '5945-2380',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17019',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Chol Quiroa Cesar Antonio',
    '17019',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '5867-2668',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17020',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cifuentes Cermeño, Dora Iracema',
    '17020',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'xx',
    '41166486',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17021',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Corado Y Corado Ever Antonio',
    '17021',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'xx',
    '5389-1094',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17034',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morales Ochoa Gerson Augusto',
    '17034',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '58129874',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17022',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Divas Anavisca Carla Yohana',
    '17022',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '56373045',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17023',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Flores Vargas Douglas Waldermar',
    '17023',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '5776-4654',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17027',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Jimenez Castillo Erick Geovanny',
    '17027',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'xx',
    '55971100',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17029',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'López Carranza Sandra Soeveldiny',
    '17029',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'xx',
    '53891094',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17031',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Mayorga Perez Keyner Josue',
    '17031',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41725252',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17032',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Mendez Suchite Roslyn Mariela',
    '17032',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '57749720',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17033',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morales Marroquin Dilan Alexis',
    '17033',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '5111-9301',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17035',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Moran Florian, Astrid Rosmery',
    '17035',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    '0',
    '54460206',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17036',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Najarro Barillas, Elvia Dalila',
    '17036',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'xx',
    '32013360',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17037',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ordoñez Garcia Sindy Carolina',
    '17037',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '4193-6090',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17038',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ortiz Estrada Karla Edith',
    '17038',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C Y M',
    '55369062',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17039',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ortiz Catalán, Geovanny Jose Maria',
    '17039',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '49594379',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17040',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Osorio Echeverria, Alicia Yamilet',
    '17040',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'xx',
    '50471678',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17045',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ramirez Chapas Antony Mateus',
    '17045',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '5300-1326',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17046',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Sagastume Castillo Jose Manuel',
    '17046',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '41509237',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17047',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Sandoval Aguilar, Rubí de los Angeles',
    '17047',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '36792020',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17048',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Santiago Sanchez, Joel Antonio',
    '17048',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '49817555',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17050',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Velasquez Yat Daniel Oswaldo',
    '17050',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '5318-9472',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17051',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Veliz Gereda Yerlin Yesenia',
    '17051',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '4052-6462',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18001',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Jorge Amilcar Aceituno Santos',
    '18001',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '47838040',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18002',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Adriano Hernandez Joshua Emanuel',
    '18002',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '59868180',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18003',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Albizures Ramirez Wilmer Abel',
    '18003',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '56190510',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18004',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Paula Jimena Arévalo Florian',
    '18004',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '37373087',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18005',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Asencio Corado, Ronal Israel',
    '18005',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '57006340',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18006',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Walter Alexander Barrios Blanco',
    '18006',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '54448328',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18007',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Claudia Lucrecia Caal Cucul',
    '18007',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '43520027',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18008',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Astrid Melisa Caal España',
    '18008',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '31479204',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18009',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Edgar Daniel Cal Cal',
    '18009',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '32979123',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18010',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Roni Emilio Campos Gonzales',
    '18010',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54747673',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18011',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Castellanos Perez Yeferson Gerber H.',
    '18011',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '49521621',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18012',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Dony Isidro Castillo Herrera',
    '18012',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '3641 5655',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18013',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Catherin Yanira Chapas Gonzales',
    '18013',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '41196857',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18014',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cristian Abraham Citalán Custodio',
    '18014',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '41617042',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18015',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Coronado Alvarez Keiry Mirella',
    '18015',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '59714504',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18016',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Josseline Anabella Cortez Santay',
    '18016',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41543038',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18017',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cruz Mendez Cristian Alfredo',
    '18017',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '35726577',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18018',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Alberto Josue  Cruz Sarceño',
    '18018',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '57257159',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18019',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'De Leon Alvarado Cesar Alejandro',
    '18019',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '37390746',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18020',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Alexander David De Leon Lopez',
    '18020',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '48250469',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18021',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Josue David Diaz Chan',
    '18021',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '59360072',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18022',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Escobar Peñate Ruben Alejandro',
    '18022',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '46030120',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18023',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Estrada Corominal Walter Isaias',
    '18023',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '42823981',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18024',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Edwin Alexander Figueroa Moran',
    '18024',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '31725727',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18025',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Walter Garcia Garcia',
    '18025',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '31547826',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18026',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Evelyn Nohelí Garrido Trabanino',
    '18026',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '47381737',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18027',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Godinez Martinez Jorge Antonio',
    '18027',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '31847014',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18028',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gomez Mendez Persy Aristidez',
    '18028',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '56169823',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18029',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gudiel Gallardo Angeliz Amordi',
    '18029',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '42123298',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18030',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ahiderson André Hernández Castillo',
    '18030',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54602434',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18031',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernandez Sandoval Helen Emilsa',
    '18031',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '47376019',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18032',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Kimberly Alejandra Jorge López',
    '18032',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '55880519',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18033',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Lopez Lau Rogers Ernesto',
    '18033',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '42635054',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18034',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morales Barrios Anderson Giovani',
    '18034',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '37983449',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18035',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gervin Friceli Morales Gálvez',
    '18035',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '55360212',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18036',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morales Rivas Cristian Francisco',
    '18036',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '39922019',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18037',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cristopher Ricardo Monzon Ramos',
    '18037',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '40541499',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18038',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Osorio Machan Maria Yesenia',
    '18038',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '33690990',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18039',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Elvis Rogelio Peña Lemus',
    '18039',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '53725191',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18040',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Fernando Iván Peñate Rodriguez',
    '18040',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '32023250',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18041',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Melvin Adalberto Pérez Coc',
    '18041',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '47641836',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18042',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Rudy Osmin Pérez Osorio',
    '18042',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '53698064',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18043',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Perez Perez Daminan de Jesus',
    '18043',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '45468305',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18044',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Sandro Emmanuel Ramirez Guerrero',
    '18044',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '47712364',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18045',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ramirez Monroy Wilson Giovany',
    '18045',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '36573894',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18046',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ramirez Pineda Franklin Irael',
    '18046',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '49695719',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18047',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Madelin Ivana Revolorio Orantes',
    '18047',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '39570217',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18048',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Reyes Ortiz Abner Antonio',
    '18048',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '49475403',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18049',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Salazar Ortiz Walter Arturo',
    '18049',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '49013065',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18050',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Sanchez Perez Esteban',
    '18050',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '46680938',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18051',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Santos Belteton, Seleni Yoliza',
    '18051',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '40676028',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18052',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Yulian Ronaldo Santos López',
    '18052',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '44972915',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18053',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Toto Paz Kevin Alberto',
    '18053',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '55959876',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18054',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Velasquez Mejia Yasmin Sorana',
    '18054',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '38305445',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19001',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Aguilar Melgar, Angel Humberto',
    '19001',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '47237665',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19002',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Aguilón Pérez, Juan Orlando',
    '19002',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '35413889',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19003',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Aguirre Palma Luis Angel',
    '19003',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '53846645',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19004',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Agustín Diego Luis Fernando',
    '19004',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '37787290',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19005',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Alvarez Hernandez, Domingo Bayron',
    '19005',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '40115109',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19006',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Alvarez Muñoz Christian René',
    '19006',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C Y M',
    '49182702',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19007',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Arana García, José David',
    '19007',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '49956071',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19008',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Arana Martínez, Pedro Alberto',
    '19008',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46630110',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19009',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Arevalo Herrera Marvín Eduardo',
    '19009',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '32263561',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19010',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Grely Aneth Aviche Carías',
    '19010',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '36139826',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19011',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Bailón Hernández Andy Adalberto',
    '19011',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54272580',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19012',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Barco Galicia Carlos Eduardo',
    '19012',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C Y M',
    '55579519',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19013',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Barrientos Corado, Danis Estid',
    '19013',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '40762926',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19014',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Barrios López, Axel Eberto',
    '19014',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '32931814',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19015',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Batres Hernández, Denilson Ottoniel',
    '19015',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46961592',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19016',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cabrera Alfaro, Carlos Alfonso',
    '19016',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B y M',
    '47236512',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19017',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cal Xona Liliana Beverly',
    '19017',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '39513836',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19018',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Campos Cermeño Miguel Angel',
    '19018',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '59361317',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19019',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Canahuí García, Helen Marisol',
    '19019',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '41709333',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19020',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cardona Coronado Ronald Geremías',
    '19020',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '55785854',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19021',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cardona López, Wilson Adán',
    '19021',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '39632005',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19022',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Carías Castro, Mario Llivinson',
    '19022',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '38791153',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19023',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Carías Godoy Ronald Vinicio',
    '19023',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C Y M',
    '33362082',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19024',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Castillo Godoy, Mario Alejandro',
    '19024',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '40093489',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19025',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cazún Godoy Walter Oswaldo',
    '19025',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46418675',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19026',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cazún Zepeda, María Concepción',
    '19026',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '31797908',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19027',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Chávez Peña, Darwin Ronaél',
    '19027',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '58322058',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19028',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Chinchilla Corado, Darwin Omar',
    '19028',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '31847239',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19029',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cop Galvan Guillermo Eduardo',
    '19029',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '59283222',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19030',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Corado Garza, Estéfany Melisa',
    '19030',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '39124205',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19031',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Corado Morán, Edgar Antonio',
    '19031',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '50543836',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19032',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Corado y Corado José David',
    '19032',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '55649867',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19033',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cortéz Velásquez Alex Adonis',
    '19033',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C Y M',
    '31369180',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19034',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cotto Sanchez, Marcela Judith',
    '19034',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '32168482',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19035',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cutzal García Eddy Obdulio',
    '19035',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41670160',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19036',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Diaz, Luis Angel',
    '19036',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54341454',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19037',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'De Paz Nicolás, Juan Alberto',
    '19037',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54842627',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19038',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'De Páz Santos Breder Alexander',
    '19038',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41539193',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19039',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Dominguez Gaitán, Amalio Rodrigo',
    '19039',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '30972268',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19040',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Juan Antonio Donis Alfaro',
    '19040',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A Y M',
    '41553173',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19041',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Donis Alfaro, María Celeste',
    '19041',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55784641',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19042',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ronald Israel Escobar Echeverría',
    '19042',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B Y M',
    '56273151',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19043',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Esquivel Ramírez Medary',
    '19043',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '53261560',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19044',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Estrada Corominal Mirza Lizette',
    '19044',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55295470',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19045',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Flores Latín Junior Antonio',
    '19045',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '43081175',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19046',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Florián Vásquez, José Manuel',
    '19046',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46319220',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19047',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Florián Vásquez, José Ronaldo',
    '19047',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54902851',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19048',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Franco Herrera, Alma Yaneth',
    '19048',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46931714',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19049',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Fuentes Cruz, Luis Diego',
    '19049',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '47465707',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19050',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Galicia Gomez, Nelson Geovanny',
    '19050',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '49578179',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19051',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Galicia Najarro, Gerson David',
    '19051',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '58669748',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19052',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Galindo Hernández, Osmin Manolo',
    '19052',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54660609',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19053',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'García Asencio Dandis Imanol',
    '19053',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '39931495',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19054',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'García Bertránd Yeison Wilfredo',
    '19054',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '30406366',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19055',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'García Esquivel Cristian Xavier',
    '19055',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'P',
    '42740990',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19056',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'García Granados, Edilson Esaul',
    '19056',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '53692516',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19057',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'García Hernández Luciano',
    '19057',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '58390305',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19058',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Garcia Peréz, Lucas Fernando',
    '19058',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '40716032',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19059',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'García Pineda, Amner Estuardo',
    '19059',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '58407754',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19060',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'García Pineda, Anibal Nicolas',
    '19060',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '51123170',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19061',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gacía Zuñiga Nixozón Rolando',
    '19061',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C Y M',
    '31931213',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19062',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Garza Flores William Armando',
    '19062',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41863321',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19063',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Garza Godoy, Katerin Dalila',
    '19063',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46745040',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19064',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Godoy López Wilson',
    '19064',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '49521621',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19065',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gómez Sales Baudilio',
    '19065',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '57409821',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19066',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gómez Ortíz, Carmen Liliana',
    '19066',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '45639127',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19067',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'González Alfaro, Eddy Rafael',
    '19067',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '35893079',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19068',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'González Alvarado, Lestid Eliazar',
    '19068',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '49113000',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19069',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'González Escobar Leidy Mariela',
    '19069',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '40920473',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19070',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'González Jiménez, Elman Ivan',
    '19070',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '51166933',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19071',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Grijalva Belloso Juan Carlos',
    '19071',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '35778820',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19072',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Gudiel Castillo, Ever Yahir Alexis',
    '19072',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55671479',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19073',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernández Aguilar Angel David',
    '19073',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '56942513',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19074',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernández De León Maria Fernanda De Aquino',
    '19074',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55721054',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19075',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernández López Carlos Alberto',
    '19075',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '58744978',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19076',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernández Salguero, Karen Gemima',
    '19076',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '41837630',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19077',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hurtado Asencio Elvidio De Jesús',
    '19077',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '37206525',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19078',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ichich Choc, Edgar Zaqueo',
    '19078',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '30475421',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19079',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Icó Gómez, Ketherine Rocío',
    '19079',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '56239504',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19080',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Isidro Baltazar Adolfo Angel',
    '19080',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '40206225',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19081',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pineda Jiménez, Cristopher Oswaldo',
    '19081',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '38475603',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19082',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Juárez Alfaro, Gustavo Adolfo',
    '19082',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '37955360',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19083',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Jui Alvarado Hugo Leonel',
    '19083',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '41976194',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19084',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Latin Bernal, Sandy Esperanza',
    '19084',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '59836322',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19085',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Lémus Ramirez Wilmer Samuel',
    '19085',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C Y M',
    '31473840',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19086',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Linares Linares, Anthony Isael',
    '19086',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '30439041',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19087',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'López, Gerber Ottoniel',
    '19087',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '49350665',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19088',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'López Gustavo Adolfo',
    '19088',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54753294',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19089',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'López Alvarez, Lusbin Guadalupe',
    '19089',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '53263568',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19090',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'López Coronado, Fernando',
    '19090',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46808161',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19091',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Lopez Jimenez, Jesfri Omar',
    '19091',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '37483485',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19092',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'López Montero Crúz Armando',
    '19092',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '54880119',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19093',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'López Muñoz Augusto César',
    '19093',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '36020633',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19094',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'López peña, Luis Fernando',
    '19094',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '56995587',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19095',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'López Témaj Jonatan Rolando',
    '19095',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '52049635',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19096',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Maquin Cacao, Cristian Vidal',
    '19096',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '42581836',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19097',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Maradiaga Ramos Otto René',
    '19097',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '33237597',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19098',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Marroquín Argueta Edwin Humberto',
    '19098',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '53685966',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19099',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Marroquín Orellana María Alejandra',
    '19099',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C Y M',
    '33994000',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19100',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Maroquin Orozco, Iris Madai',
    '19100',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '45999364',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19101',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Martinez Melgar, Gloria Francis Amabel',
    '19101',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '37348885',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19102',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Mayorga Pérez Remy Angel Arturo',
    '19102',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '35940504',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19103',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Melgar, Rogelio Raquel',
    '19103',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '36474040',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19104',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Mazariegos Arana Gilma Yolanda',
    '19104',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '33752671',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19105',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Miranda Méndez Mynor',
    '19105',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '32554886',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19106',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Monzón de Paz, Jennifer Vanessa',
    '19106',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '45517897',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19107',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Monzón García, Miguel Angel',
    '19107',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '42247305',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19108',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morales Mejía Beberlyn Alejandra',
    '19108',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '48577050',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19109',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morales Mejía, Yair Alexander',
    '19109',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '48393255',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19110',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Najarro Barillas, Otilia Yesenia',
    '19110',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '37351272',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19111',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Willian Estuardo, Najarro Osorio',
    '19111',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '40511047',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19112',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Navarro Vasquez Nancy Roxana',
    '19112',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '40669538',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19113',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ordoñez Ortega Sergio Estuardo',
    '19113',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '31448745',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19114',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ortíz Jímenez, Esmeralda Idalia',
    '19114',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '35312497',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19115',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pablo Tomás Gricelda Micaela',
    '19115',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '32359804',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19116',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Peñate Colindres, Yeymy Elizabeth',
    '19116',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46380561',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19117',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Peralta Marroquín Jasmine Saraí',
    '19117',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C Y M',
    '41880987',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19118',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pérez Arias, Axel René',
    '19118',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '44983421',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19119',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pérez Arriaza Victor Ovidio',
    '19119',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '50667118',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19120',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pérez Crúz César Adonay',
    '19120',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46376934',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19121',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pérez Pérez Eber José',
    '19121',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '57732087',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19122',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pérez Ramírez Elfido Miguel',
    '19122',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '48823679',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19123',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pérez Velásquez, Gerber Estuardo',
    '19123',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46996483',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19124',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pineda Carías Ivan Alexander',
    '19124',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '47344446',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19125',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ponciano Lázaro Sandra Angélica',
    '19125',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46786797',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19126',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Pop Xé, Maurilio',
    '19126',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '53565742',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19127',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Quiñonez Hernández Rudimán Omar',
    '19127',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '40938453',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19128',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Quiñonez Ramos, Edwin René',
    '19128',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '36062765',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19129',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Rabanales Fuentes César Obdulio',
    '19129',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C Y M',
    '47573826',
    '2024-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19130',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ramírez Herrarte, Jenderly Andrea',
    '19130',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '42620198',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19131',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ramirez Chapas Brandon Omar',
    '19131',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '53351325',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19132',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ramírez Herrera Mynor Anibal',
    '19132',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '50746700',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19133',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ramírez Santos Willian Estuardo',
    '19133',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41755486',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19134',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ramos Godoy Aracely',
    '19134',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '50305703',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19135',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Retana Cardona, Jhonatan Guillermo',
    '19135',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '40861608',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19136',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Retana Mazariegos, Yeni Maritza',
    '19136',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '37348885',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19137',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Revolorio Latín German Oswaldo',
    '19137',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46876848',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19138',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Reyes Ortiz, Victor Daniel',
    '19138',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '37327218',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19139',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Reyna Rivera Walter Alexis',
    '19139',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C Y M',
    '31589395',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19140',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ríos Barrera De Asencio Zoila Virginia',
    '19140',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '30190330',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19141',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Rivera Esquivel Edwin Vinicio',
    '19141',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '48057166',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19142',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Rivera Vásquez Ander Yoel',
    '19142',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '31563395',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19143',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Rivera Vásquez Beverlin Graciela',
    '19143',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54977333',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19144',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Rodríguez Hipólito, Cristian Alexander',
    '19144',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '45222627',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19145',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Rodríguez Orozco Yesica Fabiola',
    '19145',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '50669645',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19146',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ruano Pernillo Vasti Madai',
    '19146',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '47509255',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19147',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Salanic Gómez Marvin Orlando',
    '19147',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '36212034',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19148',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Sales Gómez, Adán Alexander',
    '19148',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '58561301',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19149',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Sales Gómez, Antony Josue',
    '19149',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '35546526',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19150',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Sánchez Ramos Jefrey Samuel',
    '19150',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '57051003',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19151',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Sánchez Tobar Victor Francisco',
    '19151',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41242554',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19152',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Sánchez Vargas, Carlos Humberto',
    '19152',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '36377417',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19153',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Santizo Valdés Angela Noemí',
    '19153',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '42382121',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19154',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Soto Monterroso Freiser Enrique',
    '19154',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '51334314',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19155',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Tagua Zanunzini Frank Antonni',
    '19155',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '45889347',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19156',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Tomás Agustín, Franklin Mayck',
    '19156',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46361594',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19157',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Tomás Cardona Fredy Ovando',
    '19157',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '51950679',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19158',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Tzunux Hernández, Jose Daniel',
    '19158',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55431357',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19159',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Valdéz Herrera Carlos Alberto',
    '19159',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'B',
    '42404615',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19160',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Valenzuela Asencio Lucas David',
    '19160',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'A',
    '54588458',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19161',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Vásquez Domínguez, Omer Naias',
    '19161',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '59551690',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19162',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Vásquez Domínguez, Manolo Exzequiel',
    '19162',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C y M',
    '36002042',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19163',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Vásquez Gonzalez, Edilson Romario',
    '19163',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '50343007',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19164',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Vela Ortíz, Maynor Manuel',
    '19164',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '50576877',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19165',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Velasquez Coronado, Vinicio Efraín',
    '19165',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '46162026',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19166',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Aury Ayendy Velásquez Dominguez',
    '19166',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '54479006',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19167',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Velásquez Latín, Abner Alexis',
    '19167',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '38257890',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19168',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Osbin Audiel Veliz Ramírez',
    '19168',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '55978686',
    '2026-12-31'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19169',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Villanueva Corado, Jerson Alexander',
    '19169',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '59039718',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19170',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Xoná Ajanel, Darwin Abelino',
    '19170',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'M',
    '42561605',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19171',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Zamora Cabrera, José Luis',
    '19171',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'C',
    '41805271',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17000',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Lizardo Gabriel Tash Giron',
    '17000',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    '40411536',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_1',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Araus Velasquez, Kevin Manfredo',
    '1',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_2',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernández Colaj, Josué David',
    '2',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_3',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Ordóñez Tzoc, Erick Alberto',
    '3',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_4',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Godoy Chinchilla, Emeldi Eulalia',
    '4',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_5',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Tuells Agustín, Alisson Mariana',
    '5',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_6',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Quevedo Donis, Helen Paola',
    '6',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_7',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Martinez Carias, Katherin Damaris',
    '7',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_8',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Chú Ichich, Victor Manuel',
    '8',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_9',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Galicia López, Ingrid Noemí',
    '9',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_10',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Juarez Alfaro, Mábel Sofía',
    '10',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_11',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Maldonado Mejía, Ylin Guadalupe',
    '11',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_12',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Lemus Batancourt, Rony Omar',
    '12',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_13',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Miranda Aguilar, Jenner Moisés',
    '13',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_14',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Marroquín Marroquín, Katerine de Jesús',
    '14',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_15',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Munguía Flores, Vivian Guadalupe',
    '15',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_16',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Godinez Matúl, Wilder Neptalí',
    '16',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_17',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cotzajay Sandoval, Joseb Enmanuel',
    '17',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_18',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Garcia Barrios, Jaime Ruben',
    '18',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_19',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Jimenez Muñoz, Josue Donaldo',
    '19',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_20',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Jerónimo Estrada, Jeison Ernesto',
    '20',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_21',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Carrera Torres, Carlos Alberto',
    '21',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_22',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Tobar Mendoza, Wilian Uliser',
    '22',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_23',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cotto Trejo, Manuel Dario',
    '23',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_24',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Cetino Casimiro, Jeremias',
    '24',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_25',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Hernández Palencia, Yasmin María Paola',
    '25',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_26',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'López Cifuentes, Karla Victoria',
    '26',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_27',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Jumique Oliva, Yoyi Natasha',
    '27',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;

INSERT INTO usuario (username, password_hash, nombre_completo, chapa, rol_id, sede_id, licencia_tipo, licencia_numero, licencia_vencimiento, activo)
VALUES (
    'brigada_28',
    '$2b$10$rZ7yJhKx5yKv7KjN2QxXqe7X8Y9ZqW0K5L6M4N8P2Q9R3S4T5U6V7',
    'Morales Barrios, Juan Manuel',
    '28',
    (SELECT id FROM rol WHERE nombre = 'BRIGADA'),
    (SELECT id FROM sede WHERE codigo = 'SEDE-CENTRAL'),
    'nan',
    'nan',
    '2025-01-01'::DATE,
    TRUE
) ON CONFLICT (username) DO NOTHING;
