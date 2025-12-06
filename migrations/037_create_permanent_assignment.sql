
-- Asignación permanente para brigada01
INSERT INTO brigada_unidad (brigada_id, unidad_id, rol_tripulacion, asignado_por, activo)
VALUES (
    (SELECT id FROM usuario WHERE username = 'brigada01'),
    (SELECT id FROM unidad WHERE codigo = '1104'),
    'PILOTO',
    (SELECT id FROM usuario WHERE username = 'admin'),
    TRUE
)
ON CONFLICT DO NOTHING;
