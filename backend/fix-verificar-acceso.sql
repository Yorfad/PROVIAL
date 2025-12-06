-- Arreglar función verificar_acceso_app para considerar exento_grupos

CREATE OR REPLACE FUNCTION public.verificar_acceso_app(p_usuario_id integer)
 RETURNS TABLE(tiene_acceso boolean, motivo_bloqueo text)
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_grupo SMALLINT;
    v_acceso_individual BOOLEAN;
    v_exento_grupos BOOLEAN;
    v_grupo_en_descanso BOOLEAN;
    v_control_activo RECORD;
BEGIN
    -- Obtener datos del usuario (AGREGADO: exento_grupos)
    SELECT grupo, COALESCE(acceso_app_activo, TRUE), COALESCE(exento_grupos, FALSE)
    INTO v_grupo, v_acceso_individual, v_exento_grupos
    FROM usuario
    WHERE id = p_usuario_id;

    -- 1. Verificar acceso individual del usuario
    IF v_acceso_individual = FALSE THEN
        RETURN QUERY SELECT FALSE, 'Acceso individual desactivado';
        RETURN;
    END IF;

    -- 2. Verificar si el grupo está en descanso (MODIFICADO: solo si NO es exento)
    IF v_grupo IS NOT NULL AND v_exento_grupos = FALSE THEN
        SELECT NOT COALESCE(esta_de_turno, TRUE)
        INTO v_grupo_en_descanso
        FROM v_estado_grupos_hoy
        WHERE grupo = v_grupo;

        IF v_grupo_en_descanso THEN
            RETURN QUERY SELECT FALSE, 'Grupo en descanso';
            RETURN;
        END IF;
    END IF;

    -- 3. Verificar controles de acceso específicos
    SELECT *
    INTO v_control_activo
    FROM control_acceso_app
    WHERE usuario_id = p_usuario_id
      AND acceso_permitido = FALSE
      AND fecha_inicio <= CURRENT_DATE
      AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE)
    LIMIT 1;

    IF v_control_activo IS NOT NULL THEN
        RETURN QUERY SELECT FALSE, v_control_activo.motivo;
        RETURN;
    END IF;

    -- Si pasó todas las validaciones
    RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$function$;
