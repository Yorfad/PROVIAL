-- Migración 039: Corregir función validar_disponibilidad_brigada
-- El problema: la función retorna 0 filas si el usuario no tiene historial en tripulacion_turno
-- Esto causa que usuarios nuevos no aparezcan en la lista de brigadas disponibles

CREATE OR REPLACE FUNCTION public.validar_disponibilidad_brigada(p_usuario_id integer, p_fecha date)
 RETURNS TABLE(disponible boolean, mensaje text, ultimo_turno_fecha date, dias_descanso integer)
 LANGUAGE plpgsql
AS $function$
DECLARE
    v_count_mismo_dia integer;
    v_ultimo_turno date;
    v_dias_descanso integer;
BEGIN
    -- Contar si tiene asignación para el mismo día
    SELECT COUNT(*) INTO v_count_mismo_dia
    FROM tripulacion_turno tt
    JOIN asignacion_unidad au ON tt.asignacion_id = au.id
    JOIN turno t ON au.turno_id = t.id
    WHERE tt.usuario_id = p_usuario_id
      AND t.fecha = p_fecha;

    -- Obtener último turno (últimos 30 días)
    SELECT MAX(t.fecha) INTO v_ultimo_turno
    FROM tripulacion_turno tt
    JOIN asignacion_unidad au ON tt.asignacion_id = au.id
    JOIN turno t ON au.turno_id = t.id
    WHERE tt.usuario_id = p_usuario_id
      AND t.fecha >= p_fecha - INTERVAL '30 days'
      AND t.fecha < p_fecha;

    -- Calcular días de descanso
    IF v_ultimo_turno IS NOT NULL THEN
        v_dias_descanso := p_fecha - v_ultimo_turno;
    ELSE
        v_dias_descanso := 999;
    END IF;

    -- Retornar resultado
    RETURN QUERY SELECT
        CASE
            WHEN v_count_mismo_dia > 0 THEN FALSE
            WHEN v_dias_descanso < 2 THEN FALSE
            ELSE TRUE
        END,
        CASE
            WHEN v_count_mismo_dia > 0 THEN 'Brigada ya tiene asignación para esta fecha'::text
            WHEN v_dias_descanso = 0 THEN 'Brigada sale el mismo día'::text
            WHEN v_dias_descanso = 1 THEN 'Brigada salió ayer - descanso recomendado'::text
            ELSE 'Brigada disponible'::text
        END,
        v_ultimo_turno,
        v_dias_descanso;
END;
$function$;

-- Confirmar
SELECT 'Migración 039 completada: función validar_disponibilidad_brigada corregida' as resultado;
