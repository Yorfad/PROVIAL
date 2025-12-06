-- Migración 021: Sistema de Gestión Manual de Grupos
-- Fecha: 2025-11-30
-- Autor: Antigravity

-- 1. Limpiar calendario futuro (eliminar generación automática)
DELETE FROM calendario_grupo WHERE fecha > CURRENT_DATE;

-- 2. Actualizar función verificar_acceso_app
-- Lógica: Asignación Activa > Calendario Manual > Default (Abierto)
CREATE OR REPLACE FUNCTION verificar_acceso_app(p_usuario_id INT)
RETURNS TABLE (
  tiene_acceso BOOLEAN,
  motivo_bloqueo TEXT
) AS $$
DECLARE
  v_usuario RECORD;
  v_calendario RECORD;
  v_tiene_asignacion BOOLEAN;
BEGIN
  -- Obtener información del usuario
  SELECT * INTO v_usuario
  FROM usuario
  WHERE id = p_usuario_id;

  -- Si el usuario no existe
  IF NOT FOUND THEN
    RETURN QUERY SELECT FALSE, 'Usuario no encontrado';
    RETURN;
  END IF;

  -- Si el usuario no está activo
  IF NOT v_usuario.activo THEN
    RETURN QUERY SELECT FALSE, 'Usuario inactivo';
    RETURN;
  END IF;

  -- Si tiene suspensión individual
  IF NOT v_usuario.acceso_app_activo THEN
    RETURN QUERY SELECT FALSE, 'Acceso suspendido individualmente';
    RETURN;
  END IF;

  -- PRIORIDAD 1: Verificar si tiene asignación activa a una unidad
  -- Si tiene asignación, SIEMPRE tiene acceso (ignora calendario)
  SELECT EXISTS(
    SELECT 1 FROM brigada_unidad
    WHERE brigada_id = p_usuario_id
      AND activo = TRUE
  ) INTO v_tiene_asignacion;

  IF v_tiene_asignacion THEN
    RETURN QUERY SELECT TRUE, NULL::TEXT;
    RETURN;
  END IF;

  -- Si está exento de grupos, tiene acceso
  IF v_usuario.exento_grupos THEN
    RETURN QUERY SELECT TRUE, NULL::TEXT;
    RETURN;
  END IF;

  -- Si no tiene grupo asignado, tiene acceso
  IF v_usuario.grupo IS NULL THEN
    RETURN QUERY SELECT TRUE, NULL::TEXT;
    RETURN;
  END IF;

  -- PRIORIDAD 2: Verificar calendario del grupo
  SELECT * INTO v_calendario
  FROM calendario_grupo
  WHERE grupo = v_usuario.grupo
    AND fecha = CURRENT_DATE;

  -- Si no hay entrada en calendario, tiene acceso (Default: Abierto)
  IF NOT FOUND THEN
    RETURN QUERY SELECT TRUE, NULL::TEXT;
    RETURN;
  END IF;

  -- Si el grupo está de DESCANSO, bloquear
  IF v_calendario.estado = 'DESCANSO' THEN
    RETURN QUERY SELECT FALSE, 'Tu grupo está de descanso hoy';
    RETURN;
  END IF;

  -- Si llegamos aquí (estado TRABAJO), tiene acceso
  RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$$ LANGUAGE plpgsql;

-- 3. Crear vista para dashboard de estado de grupos
CREATE OR REPLACE VIEW v_estado_grupos_detallado AS
SELECT
  g.grupo,
  g.fecha,
  g.estado,
  COUNT(DISTINCT u.id) as total_brigadas,
  COUNT(DISTINCT CASE WHEN bu.id IS NOT NULL THEN u.id END) as brigadas_con_asignacion,
  json_agg(
    DISTINCT jsonb_build_object(
      'brigada_id', u.id,
      'nombre', u.nombre_completo,
      'unidad_id', un.id,
      'unidad_codigo', un.codigo
    )
  ) FILTER (WHERE bu.id IS NOT NULL) as brigadas_asignadas
FROM calendario_grupo g
LEFT JOIN usuario u ON u.grupo = g.grupo AND u.activo = TRUE
LEFT JOIN brigada_unidad bu ON bu.brigada_id = u.id AND bu.activo = TRUE
LEFT JOIN unidad un ON un.id = bu.unidad_id
WHERE g.fecha >= CURRENT_DATE
GROUP BY g.grupo, g.fecha, g.estado
ORDER BY g.fecha, g.grupo;
