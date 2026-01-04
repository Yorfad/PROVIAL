--
-- PostgreSQL database dump
--

\restrict 8SYJfBFTlLw0VAseiS0PpCvs1IoeCWVhh3CFnPY8K8P731DLC4b5ROoMRarSDkd

-- Dumped from database version 16.11
-- Dumped by pg_dump version 18.1

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: SCHEMA public; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA public IS 'Datos de ejemplo de turnos cargados. Ver v_turnos_completos para verificar.';


--
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'B??squedas de texto similares (fuzzy)';


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'Generaci??n de UUIDs';


--
-- Name: estado_alerta; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_alerta AS ENUM (
    'ACTIVA',
    'ATENDIDA',
    'RESUELTA',
    'IGNORADA',
    'EXPIRADA'
);


--
-- Name: estado_persona_accidente; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_persona_accidente AS ENUM (
    'ILESO',
    'HERIDO_LEVE',
    'HERIDO_MODERADO',
    'HERIDO_GRAVE',
    'FALLECIDO'
);


--
-- Name: estado_situacion_persistente; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_situacion_persistente AS ENUM (
    'ACTIVA',
    'EN_PAUSA',
    'FINALIZADA'
);


--
-- Name: estado_ubicacion_brigada; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.estado_ubicacion_brigada AS ENUM (
    'CON_UNIDAD',
    'EN_PUNTO_FIJO',
    'PRESTADO'
);


--
-- Name: severidad_alerta; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.severidad_alerta AS ENUM (
    'BAJA',
    'MEDIA',
    'ALTA',
    'CRITICA'
);


--
-- Name: tipo_accidente; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_accidente AS ENUM (
    'COLISION_FRONTAL',
    'COLISION_LATERAL',
    'COLISION_TRASERA',
    'VOLCADURA',
    'ATROPELLO',
    'CAIDA_DE_MOTO',
    'SALIDA_DE_CARRIL',
    'CHOQUE_OBJETO_FIJO',
    'MULTIPLE',
    'OTRO'
);


--
-- Name: tipo_alerta; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_alerta AS ENUM (
    'EMERGENCIA',
    'UNIDAD_SIN_ACTIVIDAD',
    'INSPECCION_PENDIENTE',
    'BRIGADA_FUERA_ZONA',
    'COMBUSTIBLE_BAJO',
    'MANTENIMIENTO_REQUERIDO',
    'APROBACION_REQUERIDA',
    'SISTEMA',
    'PERSONALIZADA'
);


--
-- Name: tipo_lesion; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_lesion AS ENUM (
    'NINGUNA',
    'CONTUSIONES',
    'LACERACIONES',
    'FRACTURAS',
    'TRAUMA_CRANEAL',
    'TRAUMA_TORACICO',
    'TRAUMA_ABDOMINAL',
    'QUEMADURAS',
    'AMPUTACION',
    'MULTIPLE',
    'OTRO'
);


--
-- Name: tipo_movimiento_brigada; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_movimiento_brigada AS ENUM (
    'PRESTAMO',
    'RETORNO_PRESTAMO',
    'DIVISION',
    'REUNION',
    'CAMBIO_UNIDAD',
    'ASIGNACION_SITUACION',
    'DESASIGNACION_SITUACION'
);


--
-- Name: tipo_vehiculo_accidente; Type: TYPE; Schema: public; Owner: -
--

CREATE TYPE public.tipo_vehiculo_accidente AS ENUM (
    'AUTOMOVIL',
    'PICKUP',
    'CAMION',
    'BUS',
    'MOTOCICLETA',
    'BICICLETA',
    'PEATON',
    'TRAILER',
    'MAQUINARIA',
    'OTRO'
);


--
-- Name: activar_turno_del_dia(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.activar_turno_del_dia() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE turno
    SET estado = 'ACTIVO'
    WHERE fecha = CURRENT_DATE
      AND estado = 'PLANIFICADO';
END;
$$;


--
-- Name: FUNCTION activar_turno_del_dia(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.activar_turno_del_dia() IS 'Activa el turno del d??a actual. Ejecutar con cron a las 00:01';


--
-- Name: actualizar_ruta_activa(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.actualizar_ruta_activa(p_asignacion_id integer, p_nueva_ruta_id integer) RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE asignacion_unidad
    SET
        ruta_activa_id = p_nueva_ruta_id,
        hora_ultima_actualizacion_ruta = NOW()
    WHERE id = p_asignacion_id;
END;
$$;


--
-- Name: FUNCTION actualizar_ruta_activa(p_asignacion_id integer, p_nueva_ruta_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.actualizar_ruta_activa(p_asignacion_id integer, p_nueva_ruta_id integer) IS 'Actualiza la ruta activa de una asignación (se llama en SALIDA_SEDE o CAMBIO_RUTA)';


--
-- Name: aprobar_inspeccion_360(integer, integer, text, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.aprobar_inspeccion_360(p_inspeccion_id integer, p_aprobador_id integer, p_firma text DEFAULT NULL::text, p_observaciones text DEFAULT NULL::text) RETURNS TABLE(success boolean, mensaje text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_inspeccion RECORD;
    v_es_comandante BOOLEAN;
    v_salida_id INT;
BEGIN
    -- Obtener datos de la inspección
    SELECT i.*, s.unidad_id
    INTO v_inspeccion
    FROM inspeccion_360 i
    LEFT JOIN salida_unidad s ON i.salida_id = s.id
    WHERE i.id = p_inspeccion_id;

    IF v_inspeccion IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Inspección no encontrada'::TEXT;
        RETURN;
    END IF;

    IF v_inspeccion.estado != 'PENDIENTE' THEN
        RETURN QUERY SELECT FALSE, ('La inspección ya fue ' || v_inspeccion.estado)::TEXT;
        RETURN;
    END IF;

    -- Verificar que el aprobador sea comandante de la unidad
    SELECT EXISTS (
        SELECT 1 FROM brigada_unidad bu
        WHERE bu.brigada_id = p_aprobador_id
          AND bu.unidad_id = v_inspeccion.unidad_id
          AND bu.activo = TRUE
          AND bu.es_comandante = TRUE
        UNION
        SELECT 1 FROM tripulacion_turno tt
        JOIN asignacion_unidad au ON tt.asignacion_id = au.id
        WHERE tt.usuario_id = p_aprobador_id
          AND au.unidad_id = v_inspeccion.unidad_id
          AND tt.es_comandante = TRUE
    ) INTO v_es_comandante;

    IF NOT v_es_comandante THEN
        RETURN QUERY SELECT FALSE, 'Solo el comandante de la unidad puede aprobar la inspección'::TEXT;
        RETURN;
    END IF;

    -- Aprobar la inspección
    UPDATE inspeccion_360
    SET estado = 'APROBADA',
        aprobado_por = p_aprobador_id,
        fecha_aprobacion = NOW(),
        firma_comandante = COALESCE(p_firma, firma_comandante),
        observaciones_comandante = COALESCE(p_observaciones, observaciones_comandante)
    WHERE id = p_inspeccion_id;

    -- Actualizar la salida con la referencia a la inspección
    IF v_inspeccion.salida_id IS NOT NULL THEN
        UPDATE salida_unidad
        SET inspeccion_360_id = p_inspeccion_id
        WHERE id = v_inspeccion.salida_id;
    END IF;

    RETURN QUERY SELECT TRUE, 'Inspección aprobada exitosamente'::TEXT;
END;
$$;


--
-- Name: FUNCTION aprobar_inspeccion_360(p_inspeccion_id integer, p_aprobador_id integer, p_firma text, p_observaciones text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.aprobar_inspeccion_360(p_inspeccion_id integer, p_aprobador_id integer, p_firma text, p_observaciones text) IS 'Aprueba una inspección 360 (solo comandante)';


--
-- Name: archivar_inspecciones_360_antiguas(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.archivar_inspecciones_360_antiguas() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_count INTEGER := 0;
  v_inspeccion RECORD;
BEGIN
  -- Archivar inspecciones de mas de 90 dias
  FOR v_inspeccion IN
    SELECT id, unidad_id, fecha_realizacion, estado,
           jsonb_build_object(
             'plantilla_id', plantilla_id,
             'realizado_por', realizado_por,
             'aprobado_por', aprobado_por,
             'respuestas', respuestas,
             'observaciones_inspector', observaciones_inspector,
             'observaciones_comandante', observaciones_comandante
           ) as datos
    FROM inspeccion_360
    WHERE fecha_realizacion < CURRENT_DATE - INTERVAL '90 days'
      AND estado IN ('APROBADA', 'RECHAZADA') -- Solo archivamos las cerradas
  LOOP
    -- Insertar en archivo (datos como JSONB comprimido)
    INSERT INTO inspeccion_360_archivo (inspeccion_id, unidad_id, fecha_realizacion, estado, datos_comprimidos)
    VALUES (
      v_inspeccion.id,
      v_inspeccion.unidad_id,
      v_inspeccion.fecha_realizacion,
      v_inspeccion.estado,
      compress(v_inspeccion.datos::text::bytea)
    );
    
    -- Eliminar de tabla principal
    DELETE FROM inspeccion_360 WHERE id = v_inspeccion.id;
    
    v_count := v_count + 1;
  END LOOP;
  
  RETURN v_count;
END;
$$;


--
-- Name: FUNCTION archivar_inspecciones_360_antiguas(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.archivar_inspecciones_360_antiguas() IS 'Archiva inspecciones de mas de 90 dias para mantener la tabla principal ligera';


--
-- Name: atender_alerta(integer, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.atender_alerta(p_alerta_id integer, p_usuario_id integer, p_nota text DEFAULT NULL::text) RETURNS TABLE(success boolean, mensaje text)
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_alerta alerta;
BEGIN
  -- Obtener alerta
  SELECT * INTO v_alerta FROM alerta WHERE id = p_alerta_id;

  IF v_alerta IS NULL THEN
    RETURN QUERY SELECT FALSE, 'Alerta no encontrada'::TEXT;
    RETURN;
  END IF;

  IF v_alerta.estado != 'ACTIVA' THEN
    RETURN QUERY SELECT FALSE, 'La alerta ya no está activa'::TEXT;
    RETURN;
  END IF;

  -- Actualizar alerta
  UPDATE alerta
  SET estado = 'ATENDIDA',
      atendida_por = p_usuario_id,
      fecha_atencion = CURRENT_TIMESTAMP,
      nota_resolucion = p_nota,
      updated_at = CURRENT_TIMESTAMP
  WHERE id = p_alerta_id;

  RETURN QUERY SELECT TRUE, 'Alerta marcada como atendida'::TEXT;
END;
$$;


--
-- Name: FUNCTION atender_alerta(p_alerta_id integer, p_usuario_id integer, p_nota text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.atender_alerta(p_alerta_id integer, p_usuario_id integer, p_nota text) IS 'Marca una alerta como atendida';


--
-- Name: calcular_km_recorridos(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.calcular_km_recorridos() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    km_inicial DECIMAL(6,2);
    km_minimo DECIMAL(6,2);
    km_maximo DECIMAL(6,2);
BEGIN
    -- Obtener km inicial de la asignaci??n
    SELECT a.km_inicio INTO km_inicial
    FROM asignacion_unidad a
    WHERE a.id = NEW.asignacion_id;

    -- Calcular km recorridos basado en reportes horarios
    SELECT
        MIN(rh.km_actual),
        MAX(rh.km_actual)
    INTO km_minimo, km_maximo
    FROM reporte_horario rh
    WHERE rh.asignacion_id = NEW.asignacion_id;

    -- Actualizar km recorridos en la asignaci??n
    UPDATE asignacion_unidad
    SET km_recorridos = COALESCE(ABS(km_maximo - km_minimo), 0)
    WHERE id = NEW.asignacion_id;

    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION calcular_km_recorridos(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.calcular_km_recorridos() IS 'Calcula autom??ticamente los km recorridos al agregar reporte horario';


--
-- Name: cerrar_actividad_anterior(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cerrar_actividad_anterior() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Cerrar cualquier actividad previa abierta de la misma unidad
    UPDATE actividad_unidad
    SET hora_fin = NEW.hora_inicio
    WHERE unidad_id = NEW.unidad_id
      AND hora_fin IS NULL
      AND id != COALESCE(NEW.id, 0);

    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION cerrar_actividad_anterior(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.cerrar_actividad_anterior() IS 'Cierra autom??ticamente la actividad anterior al iniciar una nueva para la misma unidad';


--
-- Name: cerrar_dia_operativo(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cerrar_dia_operativo() RETURNS TABLE(asignaciones_cerradas integer, situaciones_migradas integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_asignaciones_cerradas INT := 0;
    v_situaciones_migradas INT := 0;
    v_turno_ayer INT;
    v_turno_hoy INT;
    v_situacion RECORD;
BEGIN
    -- 1. Obtener turnos de ayer y hoy
    SELECT id INTO v_turno_ayer
    FROM turno
    WHERE fecha = CURRENT_DATE - INTERVAL '1 day';

    SELECT id INTO v_turno_hoy
    FROM turno
    WHERE fecha = CURRENT_DATE;

    -- Si no existe turno de hoy, crearlo autom??ticamente
    IF v_turno_hoy IS NULL THEN
        INSERT INTO turno (fecha, estado, observaciones, creado_por)
        VALUES (
            CURRENT_DATE,
            'ACTIVO',
            'Turno creado autom??ticamente por cierre de d??a',
            1  -- Usuario sistema
        )
        RETURNING id INTO v_turno_hoy;
    END IF;

    -- 2. Cerrar todas las asignaciones del d??a anterior
    UPDATE asignacion_unidad
    SET
        dia_cerrado = TRUE,
        fecha_cierre = NOW(),
        cerrado_por = 1  -- Usuario sistema
    WHERE turno_id = v_turno_ayer
      AND dia_cerrado = FALSE;

    GET DIAGNOSTICS v_asignaciones_cerradas = ROW_COUNT;

    -- 3. Cerrar todos los movimientos activos del d??a anterior
    UPDATE movimiento_brigada
    SET hora_fin = NOW()
    WHERE turno_id = v_turno_ayer
      AND hora_fin IS NULL;

    -- 4. Migrar situaciones activas al nuevo d??a
    FOR v_situacion IN
        SELECT *
        FROM situacion
        WHERE turno_id = v_turno_ayer
          AND estado = 'ACTIVA'
    LOOP
        -- Actualizar turno de la situaci??n
        UPDATE situacion
        SET turno_id = v_turno_hoy
        WHERE id = v_situacion.id;

        v_situaciones_migradas := v_situaciones_migradas + 1;
    END LOOP;

    RETURN QUERY SELECT v_asignaciones_cerradas, v_situaciones_migradas;
END;
$$;


--
-- Name: FUNCTION cerrar_dia_operativo(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.cerrar_dia_operativo() IS 'Cierra el d??a operativo a las 00:00: cierra asignaciones, movimientos y migra situaciones activas';


--
-- Name: cerrar_situaciones_antiguas(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cerrar_situaciones_antiguas(horas_limite integer DEFAULT 24) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    cantidad_cerradas INT;
BEGIN
    WITH cerradas AS (
        UPDATE situacion
        SET
            estado = 'CERRADA',
            actualizado_por = creado_por,
            updated_at = NOW()
        WHERE estado = 'ACTIVA'
          AND created_at < NOW() - (horas_limite || ' hours')::INTERVAL
        RETURNING id
    )
    SELECT COUNT(*) INTO cantidad_cerradas FROM cerradas;

    RETURN cantidad_cerradas;
END;
$$;


--
-- Name: FUNCTION cerrar_situaciones_antiguas(horas_limite integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.cerrar_situaciones_antiguas(horas_limite integer) IS 'Cierra autom??ticamente situaciones activas de m??s de X horas (default 24)';


--
-- Name: cerrar_turno(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.cerrar_turno() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE turno
    SET estado = 'CERRADO'
    WHERE fecha < CURRENT_DATE
      AND estado = 'ACTIVO';
END;
$$;


--
-- Name: FUNCTION cerrar_turno(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.cerrar_turno() IS 'Cierra turnos de d??as anteriores. Ejecutar con cron a las 23:59';


--
-- Name: contar_veces_en_ruta(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.contar_veces_en_ruta(p_usuario_id integer, p_ruta_id integer, p_dias integer DEFAULT 30) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM historial_ruta_brigada
    WHERE usuario_id = p_usuario_id
      AND ruta_id = p_ruta_id
      AND fecha >= CURRENT_DATE - p_dias;

    RETURN v_count;
END;
$$;


--
-- Name: contar_veces_en_situacion(integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.contar_veces_en_situacion(p_usuario_id integer, p_situacion_fija_id integer, p_dias integer DEFAULT 30) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_count INTEGER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM historial_situacion_brigada
    WHERE usuario_id = p_usuario_id
      AND situacion_fija_id = p_situacion_fija_id
      AND fecha >= CURRENT_DATE - p_dias;

    RETURN v_count;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alerta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alerta (
    id integer NOT NULL,
    tipo public.tipo_alerta NOT NULL,
    severidad public.severidad_alerta DEFAULT 'MEDIA'::public.severidad_alerta NOT NULL,
    estado public.estado_alerta DEFAULT 'ACTIVA'::public.estado_alerta NOT NULL,
    titulo character varying(200) NOT NULL,
    mensaje text NOT NULL,
    datos jsonb,
    sede_id integer,
    unidad_id integer,
    brigada_id integer,
    situacion_id integer,
    atendida_por integer,
    fecha_atencion timestamp without time zone,
    nota_resolucion text,
    fecha_expiracion timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE alerta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.alerta IS 'Alertas del sistema PROVIAL';


--
-- Name: crear_alerta(public.tipo_alerta, character varying, text, public.severidad_alerta, jsonb, integer, integer, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crear_alerta(p_tipo public.tipo_alerta, p_titulo character varying, p_mensaje text, p_severidad public.severidad_alerta DEFAULT NULL::public.severidad_alerta, p_datos jsonb DEFAULT NULL::jsonb, p_sede_id integer DEFAULT NULL::integer, p_unidad_id integer DEFAULT NULL::integer, p_brigada_id integer DEFAULT NULL::integer, p_situacion_id integer DEFAULT NULL::integer, p_expira_en_minutos integer DEFAULT NULL::integer) RETURNS public.alerta
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_config configuracion_alerta;
  v_alerta alerta;
  v_fecha_exp TIMESTAMP;
BEGIN
  -- Obtener configuración
  SELECT * INTO v_config FROM configuracion_alerta WHERE tipo = p_tipo;

  -- Si no hay config o está desactivada, no crear alerta
  IF v_config IS NULL OR NOT v_config.activa THEN
    RETURN NULL;
  END IF;

  -- Calcular fecha de expiración
  IF p_expira_en_minutos IS NOT NULL THEN
    v_fecha_exp := CURRENT_TIMESTAMP + (p_expira_en_minutos || ' minutes')::INTERVAL;
  END IF;

  -- Insertar alerta
  INSERT INTO alerta (
    tipo, severidad, titulo, mensaje, datos,
    sede_id, unidad_id, brigada_id, situacion_id,
    fecha_expiracion
  ) VALUES (
    p_tipo,
    COALESCE(p_severidad, v_config.severidad_default),
    p_titulo,
    p_mensaje,
    p_datos,
    p_sede_id,
    p_unidad_id,
    p_brigada_id,
    p_situacion_id,
    v_fecha_exp
  ) RETURNING * INTO v_alerta;

  RETURN v_alerta;
END;
$$;


--
-- Name: FUNCTION crear_alerta(p_tipo public.tipo_alerta, p_titulo character varying, p_mensaje text, p_severidad public.severidad_alerta, p_datos jsonb, p_sede_id integer, p_unidad_id integer, p_brigada_id integer, p_situacion_id integer, p_expira_en_minutos integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.crear_alerta(p_tipo public.tipo_alerta, p_titulo character varying, p_mensaje text, p_severidad public.severidad_alerta, p_datos jsonb, p_sede_id integer, p_unidad_id integer, p_brigada_id integer, p_situacion_id integer, p_expira_en_minutos integer) IS 'Crea una nueva alerta en el sistema';


--
-- Name: crear_aprobacion_tripulacion(integer, character varying, integer, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crear_aprobacion_tripulacion(p_salida_id integer, p_tipo character varying, p_iniciado_por integer, p_inspeccion_360_id integer DEFAULT NULL::integer, p_tiempo_limite integer DEFAULT 30) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_aprobacion_id INTEGER;
    v_unidad_id INTEGER;
    v_tripulante RECORD;
BEGIN
    -- Obtener unidad de la salida
    SELECT unidad_id INTO v_unidad_id
    FROM salida_unidad
    WHERE id = p_salida_id;

    IF v_unidad_id IS NULL THEN
        RAISE EXCEPTION 'Salida no encontrada: %', p_salida_id;
    END IF;

    -- Crear solicitud de aprobacion
    INSERT INTO aprobacion_tripulacion (
        salida_id, unidad_id, tipo, inspeccion_360_id,
        iniciado_por, tiempo_limite_minutos
    ) VALUES (
        p_salida_id, v_unidad_id, p_tipo, p_inspeccion_360_id,
        p_iniciado_por, p_tiempo_limite
    ) RETURNING id INTO v_aprobacion_id;

    -- Crear respuestas pendientes para cada tripulante
    FOR v_tripulante IN (
        SELECT tt.usuario_id
        FROM tripulacion_turno tt
        JOIN salida_unidad su ON su.asignacion_id = tt.asignacion_id
        WHERE su.id = p_salida_id
    ) LOOP
        INSERT INTO aprobacion_respuesta (aprobacion_id, usuario_id, respuesta)
        VALUES (v_aprobacion_id, v_tripulante.usuario_id, 'PENDIENTE');
    END LOOP;

    RETURN v_aprobacion_id;
END;
$$;


--
-- Name: crear_snapshot_bitacora(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.crear_snapshot_bitacora(p_salida_id integer, p_finalizado_por integer) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_salida RECORD;
    v_situaciones JSONB;
    v_ingresos JSONB;
    v_tripulacion JSONB;
    v_contadores RECORD;
    v_bitacora_id BIGINT;
BEGIN
    -- Obtener datos de la salida
    SELECT
        s.*,
        u.id as unidad_id_ref,
        s.fecha_hora_salida::DATE as fecha_jornada
    INTO v_salida
    FROM salida_unidad s
    JOIN unidad u ON s.unidad_id = u.id
    WHERE s.id = p_salida_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Salida no encontrada: %', p_salida_id;
    END IF;

    -- Obtener resumen de situaciones
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', id,
        'tipo', tipo_situacion,
        'km', km,
        'hora', to_char(created_at, 'HH24:MI'),
        'estado', estado,
        'ruta_id', ruta_id
    ) ORDER BY created_at), '[]'::jsonb)
    INTO v_situaciones
    FROM situacion
    WHERE salida_unidad_id = p_salida_id;

    -- Obtener resumen de ingresos
    SELECT COALESCE(jsonb_agg(jsonb_build_object(
        'id', id,
        'tipo', tipo_ingreso,
        'sede_id', sede_id,
        'duracion_min', EXTRACT(EPOCH FROM (COALESCE(fecha_hora_salida, NOW()) - fecha_hora_ingreso))/60,
        'es_final', es_ingreso_final
    ) ORDER BY fecha_hora_ingreso), '[]'::jsonb)
    INTO v_ingresos
    FROM ingreso_sede
    WHERE salida_unidad_id = p_salida_id;

    -- Procesar tripulación - ES UN ARRAY, no un objeto
    -- Formato actual: [{"rol": "PILOTO", "brigada_id": 568, ...}, ...]
    -- Lo convertimos a: [{"usuario_id": X, "rol": "PILOTO"}, ...]
    SELECT COALESCE(
        jsonb_agg(jsonb_build_object(
            'usuario_id', (elem->>'brigada_id')::INTEGER,
            'rol', UPPER(elem->>'rol')
        )) FILTER (WHERE elem->>'brigada_id' IS NOT NULL),
        '[]'::jsonb
    )
    INTO v_tripulacion
    FROM jsonb_array_elements(COALESCE(v_salida.tripulacion, '[]'::jsonb)) elem;

    -- Calcular contadores
    SELECT
        COUNT(*) FILTER (WHERE tipo_situacion = 'INCIDENTE') as incidentes,
        COUNT(*) FILTER (WHERE tipo_situacion = 'ASISTENCIA') as asistencias,
        COUNT(*) FILTER (WHERE tipo_situacion = 'EMERGENCIA') as emergencias,
        COUNT(*) FILTER (WHERE tipo_situacion IN ('REGULACION', 'REGULACION_TRANSITO')) as regulaciones,
        COUNT(*) FILTER (WHERE tipo_situacion = 'PATRULLAJE') as patrullajes,
        COUNT(*) as total
    INTO v_contadores
    FROM situacion
    WHERE salida_unidad_id = p_salida_id;

    -- Insertar en bitacora_historica
    INSERT INTO bitacora_historica (
        fecha,
        unidad_id,
        salida_id,
        sede_origen_id,
        ruta_inicial_id,
        km_inicial,
        km_final,
        km_recorridos,
        combustible_inicial,
        combustible_final,
        hora_inicio,
        hora_fin,
        duracion_minutos,
        tripulacion_ids,
        situaciones_resumen,
        total_situaciones,
        ingresos_resumen,
        total_ingresos,
        total_incidentes,
        total_asistencias,
        total_emergencias,
        total_regulaciones,
        total_patrullajes,
        observaciones_inicio,
        observaciones_fin,
        finalizado_por
    ) VALUES (
        v_salida.fecha_jornada,
        v_salida.unidad_id,
        p_salida_id,
        v_salida.sede_origen_id,
        v_salida.ruta_inicial_id,
        v_salida.km_inicial,
        v_salida.km_final,
        v_salida.km_recorridos,
        v_salida.combustible_inicial,
        v_salida.combustible_final,
        v_salida.fecha_hora_salida,
        v_salida.fecha_hora_regreso,
        EXTRACT(EPOCH FROM (COALESCE(v_salida.fecha_hora_regreso, NOW()) - v_salida.fecha_hora_salida))/60,
        v_tripulacion,
        v_situaciones,
        COALESCE(v_contadores.total, 0),
        v_ingresos,
        (SELECT COUNT(*) FROM ingreso_sede WHERE salida_unidad_id = p_salida_id),
        COALESCE(v_contadores.incidentes, 0),
        COALESCE(v_contadores.asistencias, 0),
        COALESCE(v_contadores.emergencias, 0),
        COALESCE(v_contadores.regulaciones, 0),
        COALESCE(v_contadores.patrullajes, 0),
        v_salida.observaciones_salida,
        v_salida.observaciones_regreso,
        p_finalizado_por
    )
    ON CONFLICT (fecha, unidad_id)
    DO UPDATE SET
        salida_id = EXCLUDED.salida_id,
        km_final = EXCLUDED.km_final,
        km_recorridos = EXCLUDED.km_recorridos,
        combustible_final = EXCLUDED.combustible_final,
        hora_fin = EXCLUDED.hora_fin,
        duracion_minutos = EXCLUDED.duracion_minutos,
        situaciones_resumen = EXCLUDED.situaciones_resumen,
        total_situaciones = EXCLUDED.total_situaciones,
        ingresos_resumen = EXCLUDED.ingresos_resumen,
        total_ingresos = EXCLUDED.total_ingresos,
        total_incidentes = EXCLUDED.total_incidentes,
        total_asistencias = EXCLUDED.total_asistencias,
        total_emergencias = EXCLUDED.total_emergencias,
        total_regulaciones = EXCLUDED.total_regulaciones,
        total_patrullajes = EXCLUDED.total_patrullajes,
        observaciones_fin = EXCLUDED.observaciones_fin,
        finalizado_por = EXCLUDED.finalizado_por
    RETURNING id INTO v_bitacora_id;

    RETURN v_bitacora_id;
END;
$$;


--
-- Name: FUNCTION crear_snapshot_bitacora(p_salida_id integer, p_finalizado_por integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.crear_snapshot_bitacora(p_salida_id integer, p_finalizado_por integer) IS 'Crea un snapshot de la jornada en bitacora_historica antes de limpiar datos operacionales';


--
-- Name: finalizar_jornada_completa(integer, numeric, numeric, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.finalizar_jornada_completa(p_salida_id integer, p_km_final numeric DEFAULT NULL::numeric, p_combustible_final numeric DEFAULT NULL::numeric, p_observaciones text DEFAULT NULL::text, p_finalizada_por integer DEFAULT NULL::integer) RETURNS TABLE(success boolean, bitacora_id bigint, mensaje text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_salida RECORD;
    v_bitacora_id BIGINT;
    v_asignacion_id INTEGER;
    v_turno_id INTEGER;
    v_situaciones_eliminadas INTEGER;
    v_situaciones_persistentes INTEGER;
BEGIN
    -- 1. Verificar que la salida existe y está EN_SALIDA
    SELECT
        s.*,
        u.codigo as unidad_codigo
    INTO v_salida
    FROM salida_unidad s
    JOIN unidad u ON s.unidad_id = u.id
    WHERE s.id = p_salida_id
    AND s.estado = 'EN_SALIDA';

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, NULL::BIGINT, 'Salida no encontrada o ya finalizada'::TEXT;
        RETURN;
    END IF;

    -- 2. Cerrar todos los ingresos activos de esta salida
    UPDATE ingreso_sede SET
        fecha_hora_salida = NOW()
    WHERE salida_unidad_id = p_salida_id
    AND fecha_hora_salida IS NULL;

    -- 3. Actualizar la salida como FINALIZADA
    UPDATE salida_unidad SET
        estado = 'FINALIZADA',
        fecha_hora_regreso = NOW(),
        km_final = p_km_final,
        combustible_final = p_combustible_final,
        km_recorridos = ABS(COALESCE(p_km_final, 0) - COALESCE(km_inicial, 0)),
        observaciones_regreso = p_observaciones,
        finalizada_por = p_finalizada_por,
        updated_at = NOW()
    WHERE id = p_salida_id;

    -- 4. Crear snapshot en bitacora_historica (ANTES de eliminar datos temporales)
    v_bitacora_id := crear_snapshot_bitacora(p_salida_id, p_finalizada_por);

    -- 5. Buscar la asignación relacionada
    SELECT tt.asignacion_id, au.turno_id
    INTO v_asignacion_id, v_turno_id
    FROM tripulacion_turno tt
    JOIN asignacion_unidad au ON tt.asignacion_id = au.id
    JOIN turno t ON au.turno_id = t.id
    WHERE au.unidad_id = v_salida.unidad_id
    AND (
        t.fecha = CURRENT_DATE
        OR t.fecha = CURRENT_DATE - INTERVAL '1 day'
        OR t.fecha = CURRENT_DATE + INTERVAL '1 day'
        OR (t.fecha <= CURRENT_DATE AND COALESCE(t.fecha_fin, t.fecha) >= CURRENT_DATE)
    )
    LIMIT 1;

    -- 6. Limpiar asignación de turno si existe
    IF v_asignacion_id IS NOT NULL THEN
        DELETE FROM tripulacion_turno WHERE asignacion_id = v_asignacion_id;
        DELETE FROM asignacion_unidad WHERE id = v_asignacion_id;
        IF NOT EXISTS (SELECT 1 FROM asignacion_unidad WHERE turno_id = v_turno_id) THEN
            DELETE FROM turno WHERE id = v_turno_id;
        END IF;
    END IF;

    -- 7. ELIMINAR SOLO SITUACIONES TEMPORALES (ya están en bitacora_historica como resumen)
    -- Las situaciones PERSISTENTES se mantienen para análisis de reincidencias
    DELETE FROM situacion
    WHERE salida_unidad_id = p_salida_id
    AND tipo_situacion IN (
        'PATRULLAJE',
        'COMIDA',
        'DESCANSO',
        'PARADA_ESTRATEGICA',
        'CAMBIO_RUTA',
        'REGULACION_TRAFICO',
        'SALIDA_SEDE'
    );
    GET DIAGNOSTICS v_situaciones_eliminadas = ROW_COUNT;

    -- Contar situaciones persistentes que se mantienen
    SELECT COUNT(*) INTO v_situaciones_persistentes
    FROM situacion
    WHERE salida_unidad_id = p_salida_id;

    -- 8. Desvincular situaciones persistentes de la salida (ya no existe)
    -- pero mantenerlas en la BD con referencia a la unidad
    UPDATE situacion SET
        salida_unidad_id = NULL
    WHERE salida_unidad_id = p_salida_id
    AND tipo_situacion IN ('INCIDENTE', 'ASISTENCIA_VEHICULAR', 'OTROS');

    -- 9. Eliminar ingresos y salida
    DELETE FROM ingreso_sede WHERE salida_unidad_id = p_salida_id;
    DELETE FROM salida_unidad WHERE id = p_salida_id;

    -- 10. Retornar éxito
    RETURN QUERY SELECT
        TRUE,
        v_bitacora_id,
        format('Jornada finalizada. Unidad %s liberada. Bitácora #%s. Situaciones eliminadas: %s, persistentes: %s',
               v_salida.unidad_codigo, v_bitacora_id, v_situaciones_eliminadas, v_situaciones_persistentes)::TEXT;
END;
$$;


--
-- Name: FUNCTION finalizar_jornada_completa(p_salida_id integer, p_km_final numeric, p_combustible_final numeric, p_observaciones text, p_finalizada_por integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.finalizar_jornada_completa(p_salida_id integer, p_km_final numeric, p_combustible_final numeric, p_observaciones text, p_finalizada_por integer) IS 'Finaliza jornada: crea bitácora, elimina situaciones temporales (patrullaje, comida, etc.),
mantiene situaciones persistentes (incidentes, asistencias, emergencias) para análisis de reincidencias';


--
-- Name: finalizar_salida_unidad(integer, numeric, numeric, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.finalizar_salida_unidad(p_salida_id integer, p_km_final numeric DEFAULT NULL::numeric, p_combustible_final numeric DEFAULT NULL::numeric, p_observaciones text DEFAULT NULL::text, p_finalizada_por integer DEFAULT NULL::integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_km_inicial DECIMAL;
    v_km_recorridos DECIMAL;
BEGIN
    -- Obtener km inicial
    SELECT km_inicial INTO v_km_inicial
    FROM salida_unidad
    WHERE id = p_salida_id;

    -- Calcular km recorridos
    IF p_km_final IS NOT NULL AND v_km_inicial IS NOT NULL THEN
        v_km_recorridos := ABS(p_km_final - v_km_inicial);
    END IF;

    -- Finalizar salida
    UPDATE salida_unidad
    SET estado = 'FINALIZADA',
        fecha_hora_regreso = NOW(),
        km_final = p_km_final,
        combustible_final = p_combustible_final,
        km_recorridos = v_km_recorridos,
        observaciones_regreso = p_observaciones,
        finalizada_por = p_finalizada_por
    WHERE id = p_salida_id
      AND estado = 'EN_SALIDA';

    RETURN FOUND;
END;
$$;


--
-- Name: FUNCTION finalizar_salida_unidad(p_salida_id integer, p_km_final numeric, p_combustible_final numeric, p_observaciones text, p_finalizada_por integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.finalizar_salida_unidad(p_salida_id integer, p_km_final numeric, p_combustible_final numeric, p_observaciones text, p_finalizada_por integer) IS 'Finaliza una salida activa. Calcula km recorridos autom??ticamente.';


--
-- Name: fn_asignar_encargado(integer, integer, smallint, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_asignar_encargado(p_usuario_id integer, p_sede_id integer, p_grupo smallint, p_asignado_por integer, p_motivo text DEFAULT 'Asignacion de encargado'::text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_encargado_anterior_id INTEGER;
    v_nuevo_id INTEGER;
BEGIN
    -- Verificar que el usuario existe y esta activo
    IF NOT EXISTS (SELECT 1 FROM usuario WHERE id = p_usuario_id AND activo = TRUE) THEN
        RAISE EXCEPTION 'El usuario no existe o no esta activo';
    END IF;

    -- Verificar que la sede existe y esta activa
    IF NOT EXISTS (SELECT 1 FROM sede WHERE id = p_sede_id AND activa = TRUE) THEN
        RAISE EXCEPTION 'La sede no existe o no esta activa';
    END IF;

    -- Cerrar encargado anterior si existe
    UPDATE historial_encargado_sede_grupo
    SET fecha_fin = CURRENT_DATE,
        removido_por = p_asignado_por,
        motivo_remocion = 'Reemplazado por nuevo encargado'
    WHERE sede_id = p_sede_id
      AND grupo = p_grupo
      AND fecha_fin IS NULL
    RETURNING usuario_id INTO v_encargado_anterior_id;

    -- Quitar flag de encargado al anterior (si no tiene otras asignaciones)
    IF v_encargado_anterior_id IS NOT NULL THEN
        IF NOT EXISTS (
            SELECT 1 FROM historial_encargado_sede_grupo
            WHERE usuario_id = v_encargado_anterior_id
              AND fecha_fin IS NULL
              AND id != (SELECT id FROM historial_encargado_sede_grupo
                         WHERE usuario_id = v_encargado_anterior_id
                           AND sede_id = p_sede_id
                           AND grupo = p_grupo
                         ORDER BY id DESC LIMIT 1)
        ) THEN
            UPDATE usuario SET es_encargado_grupo = FALSE WHERE id = v_encargado_anterior_id;
        END IF;
    END IF;

    -- Crear nuevo registro
    INSERT INTO historial_encargado_sede_grupo (
        usuario_id, sede_id, grupo, asignado_por, motivo_asignacion
    )
    VALUES (p_usuario_id, p_sede_id, p_grupo, p_asignado_por, p_motivo)
    RETURNING id INTO v_nuevo_id;

    -- Marcar usuario como encargado
    UPDATE usuario SET es_encargado_grupo = TRUE WHERE id = p_usuario_id;

    RETURN v_nuevo_id;
END;
$$;


--
-- Name: fn_generar_descripcion_obstruccion(boolean, character varying, jsonb, jsonb, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_generar_descripcion_obstruccion(p_hay_vehiculo_fuera boolean, p_tipo_obstruccion character varying, p_sentido_principal jsonb, p_sentido_contrario jsonb, p_sentido_situacion text DEFAULT NULL::text) RETURNS text
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
    v_desc TEXT := '';
    v_carril RECORD;
    v_carriles_afectados TEXT := '';
BEGIN
    -- Veh??culo fuera de v??a
    IF p_hay_vehiculo_fuera THEN
        v_desc := 'Vehiculo fuera de la via';
        IF p_tipo_obstruccion != 'ninguna' THEN
            v_desc := v_desc || '. Ademas, ';
        END IF;
    END IF;

    -- Tipo de obstrucci??n
    CASE p_tipo_obstruccion
        WHEN 'ninguna' THEN
            IF NOT p_hay_vehiculo_fuera THEN
                v_desc := 'Sin obstruccion de via';
            END IF;

        WHEN 'total_sentido' THEN
            v_desc := v_desc || 'Obstruccion total del sentido ' || COALESCE(p_sentido_situacion, 'principal');

        WHEN 'total_ambos' THEN
            v_desc := v_desc || 'Obstruccion total de ambos sentidos (via cerrada)';

        WHEN 'parcial' THEN
            -- Construir descripci??n de carriles afectados
            IF p_sentido_principal IS NOT NULL AND p_sentido_principal->'carriles' IS NOT NULL THEN
                FOR v_carril IN
                    SELECT
                        (value->>'nombre')::TEXT as nombre,
                        (value->>'porcentaje')::INT as porcentaje
                    FROM jsonb_array_elements(p_sentido_principal->'carriles')
                    WHERE (value->>'porcentaje')::INT > 0
                LOOP
                    IF v_carriles_afectados != '' THEN
                        v_carriles_afectados := v_carriles_afectados || ', ';
                    END IF;
                    v_carriles_afectados := v_carriles_afectados || v_carril.nombre || ' (' || v_carril.porcentaje || '%)';
                END LOOP;
            END IF;

            IF v_carriles_afectados != '' THEN
                v_desc := v_desc || 'Obstruccion parcial: ' || v_carriles_afectados;
            ELSE
                v_desc := v_desc || 'Obstruccion parcial sin carriles especificados';
            END IF;
    END CASE;

    RETURN v_desc;
END;
$$;


--
-- Name: FUNCTION fn_generar_descripcion_obstruccion(p_hay_vehiculo_fuera boolean, p_tipo_obstruccion character varying, p_sentido_principal jsonb, p_sentido_contrario jsonb, p_sentido_situacion text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.fn_generar_descripcion_obstruccion(p_hay_vehiculo_fuera boolean, p_tipo_obstruccion character varying, p_sentido_principal jsonb, p_sentido_contrario jsonb, p_sentido_situacion text) IS 'Genera descripci??n autom??tica de obstrucci??n basada en los datos';


--
-- Name: fn_generar_numero_situacion_persistente(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_generar_numero_situacion_persistente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF NEW.numero IS NULL THEN
        NEW.numero := 'SP-' || EXTRACT(YEAR FROM NOW()) || '-' ||
                      LPAD(nextval('seq_situacion_persistente')::TEXT, 4, '0');
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: fn_inicializar_ubicacion_brigada(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_inicializar_ubicacion_brigada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Cuando se agrega un tripulante a una asignación, crear su registro de ubicación
    INSERT INTO ubicacion_brigada (
        usuario_id,
        asignacion_origen_id,
        unidad_origen_id,
        unidad_actual_id,
        asignacion_actual_id,
        estado,
        creado_por
    )
    SELECT
        NEW.usuario_id,
        NEW.asignacion_id,
        a.unidad_id,
        a.unidad_id,
        NEW.asignacion_id,
        'CON_UNIDAD',
        NEW.usuario_id
    FROM asignacion_unidad a
    WHERE a.id = NEW.asignacion_id
    ON CONFLICT DO NOTHING;

    RETURN NEW;
END;
$$;


--
-- Name: fn_nombres_carriles(integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_nombres_carriles(p_cantidad integer, p_sentido text DEFAULT NULL::text) RETURNS text[]
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
    CASE p_cantidad
        WHEN 1 THEN
            RETURN ARRAY['Carril hacia ' || COALESCE(p_sentido, 'el sentido')];
        WHEN 2 THEN
            RETURN ARRAY['Carril izquierdo', 'Carril derecho'];
        WHEN 3 THEN
            RETURN ARRAY['Carril izquierdo', 'Carril central', 'Carril derecho'];
        WHEN 4 THEN
            RETURN ARRAY['Carril izquierdo', 'Carril central izquierdo', 'Carril central derecho', 'Carril derecho'];
        WHEN 5 THEN
            RETURN ARRAY['Carril izquierdo', 'Carril central izquierdo', 'Carril central', 'Carril central derecho', 'Carril derecho'];
        ELSE
            RETURN ARRAY[]::TEXT[];
    END CASE;
END;
$$;


--
-- Name: FUNCTION fn_nombres_carriles(p_cantidad integer, p_sentido text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.fn_nombres_carriles(p_cantidad integer, p_sentido text) IS 'Devuelve array de nombres de carriles seg??n la cantidad (1-5)';


--
-- Name: fn_promover_a_persistente(integer, character varying, integer, character varying, text, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_promover_a_persistente(p_situacion_id integer, p_titulo character varying, p_tipo_emergencia_id integer, p_importancia character varying, p_descripcion text, p_promovido_por integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_situacion RECORD;
    v_nueva_id INTEGER;
    v_numero VARCHAR(20);
BEGIN
    -- Obtener datos de la situacion original
    SELECT s.*, r.codigo as ruta_codigo
    INTO v_situacion
    FROM situacion s
    LEFT JOIN ruta r ON s.ruta_id = r.id
    WHERE s.id = p_situacion_id;

    IF NOT FOUND THEN
        RAISE EXCEPTION 'Situacion no encontrada: %', p_situacion_id;
    END IF;

    -- Verificar que no haya sido promovida antes
    IF EXISTS (
        SELECT 1 FROM situacion_persistente
        WHERE situacion_origen_id = p_situacion_id
    ) THEN
        RAISE EXCEPTION 'Esta situacion ya fue promovida a persistente anteriormente';
    END IF;

    -- Generar numero de situacion persistente
    SELECT 'SP-' || TO_CHAR(NOW(), 'YYYY') || '-' ||
           LPAD((COALESCE(MAX(CAST(SUBSTRING(numero FROM 9) AS INTEGER)), 0) + 1)::TEXT, 4, '0')
    INTO v_numero
    FROM situacion_persistente
    WHERE numero LIKE 'SP-' || TO_CHAR(NOW(), 'YYYY') || '-%';

    -- Crear situacion persistente
    INSERT INTO situacion_persistente (
        numero,
        titulo,
        tipo,
        tipo_emergencia_id,
        importancia,
        ruta_id,
        km_inicio,
        sentido,
        latitud,
        longitud,
        descripcion,
        estado,
        situacion_origen_id,
        es_promocion,
        fecha_promocion,
        promovido_por,
        creado_por,
        fecha_inicio
    ) VALUES (
        v_numero,
        COALESCE(p_titulo, 'Emergencia promovida - ' || COALESCE(v_situacion.ruta_codigo, 'Sin ruta')),
        COALESCE((SELECT codigo FROM tipo_emergencia_vial WHERE id = p_tipo_emergencia_id), 'OTRO'),
        p_tipo_emergencia_id,
        COALESCE(p_importancia, 'ALTA'),
        v_situacion.ruta_id,
        v_situacion.km,
        v_situacion.sentido,
        v_situacion.latitud,
        v_situacion.longitud,
        p_descripcion,
        'ACTIVA',
        p_situacion_id,
        TRUE,
        NOW(),
        p_promovido_por,
        p_promovido_por,
        NOW()
    ) RETURNING id INTO v_nueva_id;

    -- Asignar automaticamente la unidad que reporto la situacion
    IF v_situacion.unidad_id IS NOT NULL THEN
        INSERT INTO asignacion_situacion_persistente (
            situacion_persistente_id,
            unidad_id,
            km_asignacion,
            latitud_asignacion,
            longitud_asignacion,
            asignado_por,
            fecha_hora_asignacion
        ) VALUES (
            v_nueva_id,
            v_situacion.unidad_id,
            v_situacion.km,
            v_situacion.latitud,
            v_situacion.longitud,
            p_promovido_por,
            NOW()
        );
    END IF;

    -- Registrar en actualizaciones
    INSERT INTO actualizacion_situacion_persistente (
        situacion_persistente_id,
        usuario_id,
        unidad_id,
        tipo_actualizacion,
        contenido,
        fecha_hora
    ) VALUES (
        v_nueva_id,
        p_promovido_por,
        v_situacion.unidad_id,
        'CREACION',
        'Situacion promovida desde situacion normal #' || p_situacion_id,
        NOW()
    );

    RETURN v_nueva_id;
END;
$$;


--
-- Name: FUNCTION fn_promover_a_persistente(p_situacion_id integer, p_titulo character varying, p_tipo_emergencia_id integer, p_importancia character varying, p_descripcion text, p_promovido_por integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.fn_promover_a_persistente(p_situacion_id integer, p_titulo character varying, p_tipo_emergencia_id integer, p_importancia character varying, p_descripcion text, p_promovido_por integer) IS 'Promueve una situacion normal a persistente extraordinaria, creando registro vinculado y asignando unidad automaticamente';


--
-- Name: fn_remover_encargado(integer, smallint, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_remover_encargado(p_sede_id integer, p_grupo smallint, p_removido_por integer, p_motivo text DEFAULT 'Removido manualmente'::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_usuario_id INTEGER;
BEGIN
    -- Cerrar asignacion actual
    UPDATE historial_encargado_sede_grupo
    SET fecha_fin = CURRENT_DATE,
        removido_por = p_removido_por,
        motivo_remocion = p_motivo
    WHERE sede_id = p_sede_id
      AND grupo = p_grupo
      AND fecha_fin IS NULL
    RETURNING usuario_id INTO v_usuario_id;

    IF v_usuario_id IS NOT NULL THEN
        -- Verificar si tiene otras asignaciones activas
        IF NOT EXISTS (
            SELECT 1 FROM historial_encargado_sede_grupo
            WHERE usuario_id = v_usuario_id AND fecha_fin IS NULL
        ) THEN
            UPDATE usuario SET es_encargado_grupo = FALSE WHERE id = v_usuario_id;
        END IF;
        RETURN TRUE;
    END IF;

    RETURN FALSE;
END;
$$;


--
-- Name: fn_verificar_acceso_grupo(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.fn_verificar_acceso_grupo(p_usuario_id integer) RETURNS TABLE(tiene_acceso boolean, motivo text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_usuario RECORD;
    v_depto_codigo TEXT;
    v_estado_grupo BOOLEAN;
BEGIN
    -- Obtener datos del usuario
    SELECT u.*, r.nombre AS rol_codigo
    INTO v_usuario
    FROM usuario u
    JOIN rol r ON r.id = u.rol_id
    WHERE u.id = p_usuario_id;

    IF NOT FOUND THEN
        RETURN QUERY SELECT FALSE, 'Usuario no encontrado'::TEXT;
        RETURN;
    END IF;

    -- Verificar si esta activo
    IF NOT v_usuario.activo THEN
        RETURN QUERY SELECT FALSE, 'Usuario desactivado'::TEXT;
        RETURN;
    END IF;

    -- Verificar acceso a app
    IF NOT COALESCE(v_usuario.acceso_app_activo, TRUE) THEN
        RETURN QUERY SELECT FALSE, 'Acceso a app desactivado'::TEXT;
        RETURN;
    END IF;

    -- Si esta exento de grupos, tiene acceso
    IF COALESCE(v_usuario.exento_grupos, FALSE) THEN
        RETURN QUERY SELECT TRUE, 'Exento de sistema de grupos'::TEXT;
        RETURN;
    END IF;

    -- Si no tiene grupo asignado, no tiene acceso
    IF v_usuario.grupo IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Sin grupo asignado'::TEXT;
        RETURN;
    END IF;

    -- Determinar departamento basado en rol
    v_depto_codigo := v_usuario.rol_codigo;

    -- Verificar estado del grupo para este departamento y sede
    SELECT egd.activo INTO v_estado_grupo
    FROM estado_grupo_departamento egd
    JOIN departamento_sistema ds ON ds.id = egd.departamento_id
    WHERE ds.codigo = v_depto_codigo
      AND egd.sede_id = v_usuario.sede_id
      AND egd.grupo = v_usuario.grupo;

    -- Si no hay registro, asumimos activo por defecto
    IF NOT FOUND THEN
        v_estado_grupo := TRUE;
    END IF;

    IF v_estado_grupo THEN
        RETURN QUERY SELECT TRUE, 'Acceso permitido'::TEXT;
    ELSE
        RETURN QUERY SELECT FALSE, 'Grupo desactivado para tu departamento/sede'::TEXT;
    END IF;

    RETURN;
END;
$$;


--
-- Name: generar_calendario_grupos(date, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generar_calendario_grupos(p_fecha_inicio date, p_fecha_fin date) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_fecha DATE;
    v_dias_transcurridos INT;
    v_estado_grupo1 VARCHAR(20);
    v_estado_grupo2 VARCHAR(20);
    v_registros_creados INT := 0;
BEGIN
    v_fecha := p_fecha_inicio;

    WHILE v_fecha <= p_fecha_fin LOOP
        v_dias_transcurridos := v_fecha - DATE '2025-01-01';

        IF MOD(v_dias_transcurridos, 16) < 8 THEN
            v_estado_grupo1 := 'TRABAJO';
            v_estado_grupo2 := 'DESCANSO';
        ELSE
            v_estado_grupo1 := 'DESCANSO';
            v_estado_grupo2 := 'TRABAJO';
        END IF;

        INSERT INTO calendario_grupo (grupo, fecha, estado, creado_por)
        VALUES (1, v_fecha, v_estado_grupo1, 1)
        ON CONFLICT (grupo, fecha) DO NOTHING;

        INSERT INTO calendario_grupo (grupo, fecha, estado, creado_por)
        VALUES (2, v_fecha, v_estado_grupo2, 1)
        ON CONFLICT (grupo, fecha) DO NOTHING;

        v_registros_creados := v_registros_creados + 2;
        v_fecha := v_fecha + INTERVAL '1 day';
    END LOOP;

    RETURN v_registros_creados;
END;
$$;


--
-- Name: FUNCTION generar_calendario_grupos(p_fecha_inicio date, p_fecha_fin date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.generar_calendario_grupos(p_fecha_inicio date, p_fecha_fin date) IS 'Genera calendario de trabajo/descanso para ambos grupos en un rango de fechas';


--
-- Name: generar_mensaje_plantilla(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generar_mensaje_plantilla(p_plantilla_id integer, p_situacion_id integer) RETURNS text
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_plantilla TEXT;
  v_mensaje TEXT;
  v_situacion RECORD;
  v_accidente RECORD;
  v_heridos INTEGER;
  v_fallecidos INTEGER;
  v_vehiculos INTEGER;
BEGIN
  -- Obtener plantilla
  SELECT contenido_plantilla INTO v_plantilla
  FROM plantilla_comunicacion
  WHERE id = p_plantilla_id;

  IF v_plantilla IS NULL THEN
    RETURN NULL;
  END IF;

  -- Obtener datos de la situación
  SELECT
    s.*,
    m.nombre AS municipio_nombre,
    d.nombre AS departamento_nombre
  INTO v_situacion
  FROM situacion s
  LEFT JOIN municipio m ON s.municipio_id = m.id
  LEFT JOIN departamento d ON m.departamento_id = d.id
  WHERE s.id = p_situacion_id;

  -- Obtener datos de accidentología si existe
  SELECT * INTO v_accidente
  FROM hoja_accidentologia
  WHERE situacion_id = p_situacion_id;

  -- Contar personas afectadas
  IF v_accidente IS NOT NULL THEN
    SELECT
      COUNT(*) FILTER (WHERE estado IN ('HERIDO_LEVE', 'HERIDO_MODERADO', 'HERIDO_GRAVE')),
      COUNT(*) FILTER (WHERE estado = 'FALLECIDO'),
      COUNT(DISTINCT vehiculo_accidente_id)
    INTO v_heridos, v_fallecidos, v_vehiculos
    FROM persona_accidente
    WHERE hoja_accidentologia_id = v_accidente.id;
  ELSE
    v_heridos := 0;
    v_fallecidos := 0;
    v_vehiculos := 0;
  END IF;

  -- Reemplazar variables
  v_mensaje := v_plantilla;
  v_mensaje := REPLACE(v_mensaje, '{fecha}', TO_CHAR(v_situacion.created_at, 'DD/MM/YYYY'));
  v_mensaje := REPLACE(v_mensaje, '{hora}', TO_CHAR(v_situacion.created_at, 'HH24:MI'));
  v_mensaje := REPLACE(v_mensaje, '{ubicacion}', COALESCE(CONCAT(v_situacion.km, ' km ', v_situacion.sentido), 'ubicación no especificada'));
  v_mensaje := REPLACE(v_mensaje, '{municipio}', COALESCE(v_situacion.municipio_nombre, ''));
  v_mensaje := REPLACE(v_mensaje, '{departamento}', COALESCE(v_situacion.departamento_nombre, ''));
  v_mensaje := REPLACE(v_mensaje, '{tipo}', v_situacion.tipo_situacion::TEXT);
  v_mensaje := REPLACE(v_mensaje, '{descripcion}', COALESCE(v_situacion.descripcion, ''));
  v_mensaje := REPLACE(v_mensaje, '{heridos}', v_heridos::TEXT);
  v_mensaje := REPLACE(v_mensaje, '{fallecidos}', v_fallecidos::TEXT);
  v_mensaje := REPLACE(v_mensaje, '{vehiculos}', v_vehiculos::TEXT);

  IF v_accidente IS NOT NULL THEN
    v_mensaje := REPLACE(v_mensaje, '{tipo_accidente}', v_accidente.tipo_accidente::TEXT);
    v_mensaje := REPLACE(v_mensaje, '{km}', COALESCE(v_accidente.kilometro::TEXT, ''));
  END IF;

  RETURN v_mensaje;
END;
$$;


--
-- Name: FUNCTION generar_mensaje_plantilla(p_plantilla_id integer, p_situacion_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.generar_mensaje_plantilla(p_plantilla_id integer, p_situacion_id integer) IS 'Genera mensaje de comunicación social desde plantilla';


--
-- Name: generar_numero_reporte(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generar_numero_reporte() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    anio INT;
    secuencia INT;
BEGIN
    -- Obtener a??o del aviso
    anio := EXTRACT(YEAR FROM NEW.fecha_hora_aviso);

    -- Obtener siguiente n??mero secuencial del a??o
    SELECT COALESCE(
        MAX(
            CAST(
                SUBSTRING(numero_reporte FROM 'INC-\d{4}-(\d+)') AS INT
            )
        ), 0
    ) + 1
    INTO secuencia
    FROM incidente
    WHERE EXTRACT(YEAR FROM fecha_hora_aviso) = anio;

    -- Generar n??mero: INC-2025-0001
    NEW.numero_reporte := 'INC-' || anio || '-' || LPAD(secuencia::TEXT, 4, '0');

    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION generar_numero_reporte(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.generar_numero_reporte() IS 'Genera autom??ticamente el n??mero de reporte en formato INC-YYYY-####';


--
-- Name: generar_numero_situacion(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.generar_numero_situacion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    anio INT;
    numero_secuencial INT;
    numero_final VARCHAR(50);
BEGIN
    -- Obtener a??o actual
    anio := EXTRACT(YEAR FROM NOW());

    -- Obtener el siguiente n??mero secuencial del a??o
    SELECT COALESCE(MAX(
        CAST(
            SUBSTRING(numero_situacion FROM 'SIT-[0-9]{4}-([0-9]+)')
            AS INT
        )
    ), 0) + 1
    INTO numero_secuencial
    FROM situacion
    WHERE numero_situacion LIKE 'SIT-' || anio || '-%';

    -- Generar n??mero final con padding
    numero_final := 'SIT-' || anio || '-' || LPAD(numero_secuencial::TEXT, 4, '0');

    NEW.numero_situacion := numero_final;

    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION generar_numero_situacion(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.generar_numero_situacion() IS 'Genera autom??ticamente el n??mero de situaci??n (SIT-YYYY-NNNN)';


--
-- Name: get_motivo_inactividad_actual(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.get_motivo_inactividad_actual(p_usuario_id integer) RETURNS TABLE(motivo_codigo character varying, motivo_nombre character varying, fecha_inicio date, fecha_fin_estimada date, observaciones text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        c.codigo,
        c.nombre,
        ui.fecha_inicio,
        ui.fecha_fin_estimada,
        ui.observaciones
    FROM usuario_inactividad ui
    JOIN catalogo_motivo_inactividad c ON ui.motivo_id = c.id
    WHERE ui.usuario_id = p_usuario_id
      AND ui.fecha_fin_real IS NULL
    ORDER BY ui.fecha_inicio DESC
    LIMIT 1;
END;
$$;


--
-- Name: iniciar_salida_unidad(integer, integer, numeric, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.iniciar_salida_unidad(p_unidad_id integer, p_ruta_inicial_id integer DEFAULT NULL::integer, p_km_inicial numeric DEFAULT NULL::numeric, p_combustible_inicial numeric DEFAULT NULL::numeric, p_observaciones text DEFAULT NULL::text) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_salida_id INT;
    v_tripulacion JSONB;
    v_salida_existente INT;
BEGIN
    -- Verificar que no haya salida activa
    SELECT id INTO v_salida_existente
    FROM salida_unidad
    WHERE unidad_id = p_unidad_id
      AND estado = 'EN_SALIDA';

    IF v_salida_existente IS NOT NULL THEN
        RAISE EXCEPTION 'La unidad ya tiene una salida activa (ID: %)', v_salida_existente;
    END IF;

    -- Obtener tripulación de asignaciones permanentes
    SELECT json_agg(
        json_build_object(
            'brigada_id', u.id,
            'chapa', u.chapa,
            'nombre', u.nombre_completo,
            'rol', bu.rol_tripulacion
        )
        ORDER BY
            CASE bu.rol_tripulacion
                WHEN 'PILOTO' THEN 1
                WHEN 'COPILOTO' THEN 2
                WHEN 'ACOMPAÑANTE' THEN 3
            END
    )
    INTO v_tripulacion
    FROM brigada_unidad bu
    JOIN usuario u ON bu.brigada_id = u.id
    WHERE bu.unidad_id = p_unidad_id
      AND bu.activo = TRUE;

    -- Si no hay tripulación permanente, buscar en turnos
    IF v_tripulacion IS NULL THEN
        SELECT json_agg(
            json_build_object(
                'brigada_id', u.id,
                'chapa', u.chapa,
                'nombre', u.nombre_completo,
                'rol', tt.rol_tripulacion
            )
            ORDER BY
                CASE tt.rol_tripulacion
                    WHEN 'PILOTO' THEN 1
                    WHEN 'COPILOTO' THEN 2
                    WHEN 'ACOMPAÑANTE' THEN 3
                END
        )
        INTO v_tripulacion
        FROM tripulacion_turno tt
        JOIN asignacion_unidad au ON tt.asignacion_id = au.id
        JOIN turno t ON au.turno_id = t.id
        JOIN usuario u ON tt.usuario_id = u.id
        WHERE au.unidad_id = p_unidad_id
          AND (
            t.fecha = CURRENT_DATE
            OR t.fecha = CURRENT_DATE + INTERVAL '1 day'
            OR (t.fecha <= CURRENT_DATE AND COALESCE(t.fecha_fin, t.fecha) >= CURRENT_DATE)
            OR (t.estado IN ('ACTIVO', 'PLANIFICADO') AND t.fecha >= CURRENT_DATE - INTERVAL '1 day')
          );
    END IF;

    -- Crear salida
    INSERT INTO salida_unidad (
        unidad_id,
        ruta_inicial_id,
        km_inicial,
        combustible_inicial,
        tripulacion,
        observaciones_salida,
        estado
    )
    VALUES (
        p_unidad_id,
        p_ruta_inicial_id,
        p_km_inicial,
        p_combustible_inicial,
        v_tripulacion,
        p_observaciones,
        'EN_SALIDA'
    )
    RETURNING id INTO v_salida_id;

    RETURN v_salida_id;
END;
$$;


--
-- Name: limpiar_asignaciones_expiradas(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.limpiar_asignaciones_expiradas() RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_count INTEGER := 0;
    v_asignacion RECORD;
BEGIN
    -- Buscar asignaciones de días anteriores que no tienen salida activa
    FOR v_asignacion IN
        SELECT au.id, au.turno_id
        FROM asignacion_unidad au
        WHERE au.fecha_asignacion < CURRENT_DATE
        AND NOT EXISTS (
            SELECT 1 FROM salida_unidad s
            WHERE s.unidad_id = au.unidad_id
            AND s.estado = 'EN_SALIDA'
        )
    LOOP
        -- Eliminar tripulación
        DELETE FROM tripulacion_turno WHERE asignacion_id = v_asignacion.id;
        -- Eliminar asignación
        DELETE FROM asignacion_unidad WHERE id = v_asignacion.id;
        v_count := v_count + 1;

        -- Eliminar turno si quedó vacío
        IF NOT EXISTS (SELECT 1 FROM asignacion_unidad WHERE turno_id = v_asignacion.turno_id) THEN
            DELETE FROM turno WHERE id = v_asignacion.turno_id;
        END IF;
    END LOOP;

    RETURN v_count;
END;
$$;


--
-- Name: FUNCTION limpiar_asignaciones_expiradas(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.limpiar_asignaciones_expiradas() IS 'Job nocturno para limpiar asignaciones de días anteriores que quedaron huérfanas.
Debería ejecutarse con pg_cron o similar a las 00:00.';


--
-- Name: log_incidente_cambios(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.log_incidente_cambios() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO auditoria_log (
            usuario_id, accion, tabla_afectada, registro_id,
            datos_nuevos, ip_address
        ) VALUES (
            NEW.creado_por, 'INSERT', 'incidente', NEW.id,
            to_jsonb(NEW), inet_client_addr()::TEXT
        );
        RETURN NEW;

    ELSIF (TG_OP = 'UPDATE') THEN
        INSERT INTO auditoria_log (
            usuario_id, accion, tabla_afectada, registro_id,
            datos_anteriores, datos_nuevos, ip_address
        ) VALUES (
            NEW.actualizado_por, 'UPDATE', 'incidente', NEW.id,
            to_jsonb(OLD), to_jsonb(NEW), inet_client_addr()::TEXT
        );
        RETURN NEW;

    ELSIF (TG_OP = 'DELETE') THEN
        INSERT INTO auditoria_log (
            usuario_id, accion, tabla_afectada, registro_id,
            datos_anteriores, ip_address
        ) VALUES (
            OLD.actualizado_por, 'DELETE', 'incidente', OLD.id,
            to_jsonb(OLD), inet_client_addr()::TEXT
        );
        RETURN OLD;
    END IF;
END;
$$;


--
-- Name: FUNCTION log_incidente_cambios(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.log_incidente_cambios() IS 'Registra autom??ticamente cambios en incidentes en el log de auditor??a';


--
-- Name: obtener_comandante_unidad(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.obtener_comandante_unidad(p_unidad_id integer) RETURNS TABLE(usuario_id integer, nombre_completo character varying, chapa character varying, tipo_asignacion character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Primero buscar en asignaciones permanentes
    RETURN QUERY
    SELECT
        u.id,
        u.nombre_completo,
        u.chapa,
        'PERMANENTE'::VARCHAR
    FROM brigada_unidad bu
    JOIN usuario u ON bu.brigada_id = u.id
    WHERE bu.unidad_id = p_unidad_id
      AND bu.activo = TRUE
      AND bu.es_comandante = TRUE
    LIMIT 1;

    IF FOUND THEN
        RETURN;
    END IF;

    -- Si no hay permanente, buscar en turnos activos
    RETURN QUERY
    SELECT
        u.id,
        u.nombre_completo,
        u.chapa,
        'TURNO'::VARCHAR
    FROM tripulacion_turno tt
    JOIN asignacion_unidad au ON tt.asignacion_id = au.id
    JOIN turno t ON au.turno_id = t.id
    JOIN usuario u ON tt.usuario_id = u.id
    WHERE au.unidad_id = p_unidad_id
      AND tt.es_comandante = TRUE
      AND t.estado IN ('ACTIVO', 'PLANIFICADO')
      AND (
          t.fecha = CURRENT_DATE
          OR (t.fecha <= CURRENT_DATE AND COALESCE(t.fecha_fin, t.fecha) >= CURRENT_DATE)
      )
    LIMIT 1;
END;
$$;


--
-- Name: FUNCTION obtener_comandante_unidad(p_unidad_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.obtener_comandante_unidad(p_unidad_id integer) IS 'Obtiene el comandante actual de una unidad';


--
-- Name: obtener_historial_combustible(integer, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.obtener_historial_combustible(p_unidad_id integer, p_fecha date DEFAULT CURRENT_DATE) RETURNS TABLE(hora timestamp with time zone, tipo_situacion character varying, combustible_fraccion character varying, combustible_decimal numeric, consumo numeric, km_recorridos numeric, ubicacion text)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.created_at AS hora,
        s.tipo_situacion,
        s.combustible_fraccion,
        s.combustible AS combustible_decimal,
        s.combustible - LAG(s.combustible) OVER (ORDER BY s.created_at) AS consumo,
        s.kilometraje_unidad - LAG(s.kilometraje_unidad) OVER (ORDER BY s.created_at) AS km_recorridos,
        CONCAT(r.codigo, ' Km ', s.km) AS ubicacion
    FROM situacion s
    LEFT JOIN ruta r ON s.ruta_id = r.id
    LEFT JOIN turno t ON s.turno_id = t.id
    WHERE s.unidad_id = p_unidad_id
      AND t.fecha = p_fecha
      AND s.combustible IS NOT NULL
    ORDER BY s.created_at;
END;
$$;


--
-- Name: FUNCTION obtener_historial_combustible(p_unidad_id integer, p_fecha date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.obtener_historial_combustible(p_unidad_id integer, p_fecha date) IS 'Obtiene el historial de combustible de una unidad para un día específico';


--
-- Name: obtener_plantilla_360(character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.obtener_plantilla_360(p_tipo_unidad character varying) RETURNS TABLE(id integer, tipo_unidad character varying, nombre character varying, descripcion text, version integer, secciones jsonb)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.id,
        p.tipo_unidad,
        p.nombre,
        p.descripcion,
        p.version,
        p.secciones
    FROM plantilla_inspeccion_360 p
    WHERE p.tipo_unidad = p_tipo_unidad
      AND p.activa = TRUE
    LIMIT 1;

    -- Si no hay plantilla específica, buscar DEFAULT
    IF NOT FOUND THEN
        RETURN QUERY
        SELECT
            p.id,
            p.tipo_unidad,
            p.nombre,
            p.descripcion,
            p.version,
            p.secciones
        FROM plantilla_inspeccion_360 p
        WHERE p.tipo_unidad = 'DEFAULT'
          AND p.activa = TRUE
        LIMIT 1;
    END IF;
END;
$$;


--
-- Name: FUNCTION obtener_plantilla_360(p_tipo_unidad character varying); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.obtener_plantilla_360(p_tipo_unidad character varying) IS 'Obtiene la plantilla 360 activa para un tipo de unidad';


--
-- Name: obtener_ruta_activa(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.obtener_ruta_activa(p_asignacion_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_ruta_activa_id INT;
BEGIN
    -- Obtener la ruta activa de la asignación
    SELECT ruta_activa_id INTO v_ruta_activa_id
    FROM asignacion_unidad
    WHERE id = p_asignacion_id;

    -- Si no hay ruta activa, usar la ruta asignada por defecto
    IF v_ruta_activa_id IS NULL THEN
        SELECT ruta_id INTO v_ruta_activa_id
        FROM asignacion_unidad
        WHERE id = p_asignacion_id;
    END IF;

    RETURN v_ruta_activa_id;
END;
$$;


--
-- Name: FUNCTION obtener_ruta_activa(p_asignacion_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.obtener_ruta_activa(p_asignacion_id integer) IS 'Obtiene la ruta activa de una asignación, o la ruta por defecto si no hay activa';


--
-- Name: obtener_sede_efectiva_unidad(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.obtener_sede_efectiva_unidad(p_unidad_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_sede_id INT;
BEGIN
    -- Buscar reasignaci??n activa
    SELECT sede_destino_id INTO v_sede_id
    FROM reasignacion_sede
    WHERE tipo = 'UNIDAD'
      AND recurso_id = p_unidad_id
      AND estado = 'ACTIVA'
      AND fecha_inicio <= CURRENT_DATE
      AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE)
    ORDER BY created_at DESC
    LIMIT 1;

    -- Si no hay reasignaci??n, usar sede original
    IF v_sede_id IS NULL THEN
        SELECT sede_id INTO v_sede_id
        FROM unidad
        WHERE id = p_unidad_id;
    END IF;

    RETURN v_sede_id;
END;
$$;


--
-- Name: obtener_sede_efectiva_usuario(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.obtener_sede_efectiva_usuario(p_usuario_id integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_sede_id INT;
BEGIN
    -- Buscar reasignaci??n activa
    SELECT sede_destino_id INTO v_sede_id
    FROM reasignacion_sede
    WHERE tipo = 'USUARIO'
      AND recurso_id = p_usuario_id
      AND estado = 'ACTIVA'
      AND fecha_inicio <= CURRENT_DATE
      AND (fecha_fin IS NULL OR fecha_fin >= CURRENT_DATE)
    ORDER BY created_at DESC
    LIMIT 1;

    -- Si no hay reasignaci??n, usar sede original
    IF v_sede_id IS NULL THEN
        SELECT sede_id INTO v_sede_id
        FROM usuario
        WHERE id = p_usuario_id;
    END IF;

    RETURN v_sede_id;
END;
$$;


--
-- Name: FUNCTION obtener_sede_efectiva_usuario(p_usuario_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.obtener_sede_efectiva_usuario(p_usuario_id integer) IS 'Retorna la sede efectiva del usuario considerando reasignaciones temporales';


--
-- Name: obtener_tokens_push(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.obtener_tokens_push(p_usuario_id integer) RETURNS TABLE(push_token character varying, plataforma character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT dp.push_token, dp.plataforma
    FROM dispositivo_push dp
    WHERE dp.usuario_id = p_usuario_id
      AND dp.activo = TRUE;
END;
$$;


--
-- Name: obtener_tokens_tripulacion(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.obtener_tokens_tripulacion(p_salida_id integer) RETURNS TABLE(usuario_id integer, push_token character varying, plataforma character varying, nombre_completo character varying)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    SELECT
        tt.usuario_id,
        dp.push_token,
        dp.plataforma,
        u.nombre_completo
    FROM tripulacion_turno tt
    JOIN salida_unidad su ON su.asignacion_id = tt.asignacion_id
    JOIN usuario u ON u.id = tt.usuario_id
    LEFT JOIN dispositivo_push dp ON dp.usuario_id = tt.usuario_id AND dp.activo = TRUE
    WHERE su.id = p_salida_id;
END;
$$;


--
-- Name: puede_iniciar_salida_con_360(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.puede_iniciar_salida_con_360(p_salida_id integer) RETURNS TABLE(puede_iniciar boolean, inspeccion_id integer, estado_inspeccion character varying, mensaje text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_inspeccion RECORD;
BEGIN
    -- Buscar inspección vigente para esta salida
    SELECT i.id, i.estado
    INTO v_inspeccion
    FROM inspeccion_360 i
    WHERE i.salida_id = p_salida_id
      AND i.estado IN ('PENDIENTE', 'APROBADA')
    ORDER BY i.created_at DESC
    LIMIT 1;

    IF v_inspeccion IS NULL THEN
        RETURN QUERY SELECT
            FALSE,
            NULL::INT,
            NULL::VARCHAR,
            'No existe inspección 360 para esta salida'::TEXT;
    ELSIF v_inspeccion.estado = 'PENDIENTE' THEN
        RETURN QUERY SELECT
            FALSE,
            v_inspeccion.id,
            v_inspeccion.estado,
            'La inspección 360 está pendiente de aprobación'::TEXT;
    ELSE
        RETURN QUERY SELECT
            TRUE,
            v_inspeccion.id,
            v_inspeccion.estado,
            'Inspección 360 aprobada'::TEXT;
    END IF;
END;
$$;


--
-- Name: FUNCTION puede_iniciar_salida_con_360(p_salida_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.puede_iniciar_salida_con_360(p_salida_id integer) IS 'Verifica si una salida tiene inspección 360 aprobada';


--
-- Name: rechazar_inspeccion_360(integer, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.rechazar_inspeccion_360(p_inspeccion_id integer, p_aprobador_id integer, p_motivo text) RETURNS TABLE(success boolean, mensaje text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_inspeccion RECORD;
    v_es_comandante BOOLEAN;
BEGIN
    -- Obtener datos de la inspección
    SELECT i.*, s.unidad_id
    INTO v_inspeccion
    FROM inspeccion_360 i
    LEFT JOIN salida_unidad s ON i.salida_id = s.id
    WHERE i.id = p_inspeccion_id;

    IF v_inspeccion IS NULL THEN
        RETURN QUERY SELECT FALSE, 'Inspección no encontrada'::TEXT;
        RETURN;
    END IF;

    IF v_inspeccion.estado != 'PENDIENTE' THEN
        RETURN QUERY SELECT FALSE, ('La inspección ya fue ' || v_inspeccion.estado)::TEXT;
        RETURN;
    END IF;

    -- Verificar que el aprobador sea comandante de la unidad
    SELECT EXISTS (
        SELECT 1 FROM brigada_unidad bu
        WHERE bu.brigada_id = p_aprobador_id
          AND bu.unidad_id = v_inspeccion.unidad_id
          AND bu.activo = TRUE
          AND bu.es_comandante = TRUE
        UNION
        SELECT 1 FROM tripulacion_turno tt
        JOIN asignacion_unidad au ON tt.asignacion_id = au.id
        WHERE tt.usuario_id = p_aprobador_id
          AND au.unidad_id = v_inspeccion.unidad_id
          AND tt.es_comandante = TRUE
    ) INTO v_es_comandante;

    IF NOT v_es_comandante THEN
        RETURN QUERY SELECT FALSE, 'Solo el comandante de la unidad puede rechazar la inspección'::TEXT;
        RETURN;
    END IF;

    -- Rechazar la inspección
    UPDATE inspeccion_360
    SET estado = 'RECHAZADA',
        aprobado_por = p_aprobador_id,
        fecha_aprobacion = NOW(),
        motivo_rechazo = p_motivo
    WHERE id = p_inspeccion_id;

    RETURN QUERY SELECT TRUE, 'Inspección rechazada. El inspector debe corregir y reenviar.'::TEXT;
END;
$$;


--
-- Name: FUNCTION rechazar_inspeccion_360(p_inspeccion_id integer, p_aprobador_id integer, p_motivo text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.rechazar_inspeccion_360(p_inspeccion_id integer, p_aprobador_id integer, p_motivo text) IS 'Rechaza una inspección 360 (solo comandante)';


--
-- Name: refresh_intelligence_views(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.refresh_intelligence_views() RETURNS void
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Refrescar vistas principales con historial completo
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_vehiculo_historial;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_piloto_historial;

    -- Refrescar vistas simplificadas
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_vehiculos_reincidentes;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_pilotos_problematicos;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_puntos_calientes;
    REFRESH MATERIALIZED VIEW CONCURRENTLY mv_tendencias_temporales;
END;
$$;


--
-- Name: FUNCTION refresh_intelligence_views(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.refresh_intelligence_views() IS 'Refresca todas las vistas materializadas de inteligencia (incluyendo mv_vehiculo_historial y mv_piloto_historial)';


--
-- Name: registrar_cambio(character varying, integer, text, integer, jsonb, jsonb, integer, bigint, integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.registrar_cambio(p_tipo_cambio character varying, p_usuario_afectado_id integer, p_motivo text, p_realizado_por integer, p_valores_anteriores jsonb DEFAULT NULL::jsonb, p_valores_nuevos jsonb DEFAULT NULL::jsonb, p_asignacion_id integer DEFAULT NULL::integer, p_situacion_id bigint DEFAULT NULL::bigint, p_unidad_id integer DEFAULT NULL::integer, p_autorizado_por integer DEFAULT NULL::integer) RETURNS bigint
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_cambio_id BIGINT;
BEGIN
    INSERT INTO registro_cambio (
        tipo_cambio,
        usuario_afectado_id,
        motivo,
        realizado_por,
        valores_anteriores,
        valores_nuevos,
        asignacion_id,
        situacion_id,
        unidad_id,
        autorizado_por
    ) VALUES (
        p_tipo_cambio,
        p_usuario_afectado_id,
        p_motivo,
        p_realizado_por,
        p_valores_anteriores,
        p_valores_nuevos,
        p_asignacion_id,
        p_situacion_id,
        p_unidad_id,
        p_autorizado_por
    )
    RETURNING id INTO v_cambio_id;

    RETURN v_cambio_id;
END;
$$;


--
-- Name: FUNCTION registrar_cambio(p_tipo_cambio character varying, p_usuario_afectado_id integer, p_motivo text, p_realizado_por integer, p_valores_anteriores jsonb, p_valores_nuevos jsonb, p_asignacion_id integer, p_situacion_id bigint, p_unidad_id integer, p_autorizado_por integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.registrar_cambio(p_tipo_cambio character varying, p_usuario_afectado_id integer, p_motivo text, p_realizado_por integer, p_valores_anteriores jsonb, p_valores_nuevos jsonb, p_asignacion_id integer, p_situacion_id bigint, p_unidad_id integer, p_autorizado_por integer) IS 'Registra un cambio en el sistema con auditor??a completa';


--
-- Name: registrar_ingreso_sede(integer, integer, character varying, numeric, numeric, text, boolean, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.registrar_ingreso_sede(p_salida_id integer, p_sede_id integer, p_tipo_ingreso character varying, p_km numeric, p_combustible numeric, p_observaciones text, p_es_ingreso_final boolean, p_registrado_por integer) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_ingreso_id INTEGER;
    v_ingreso_activo INTEGER;
    v_result RECORD;
BEGIN
    -- Verificar si ya hay un ingreso activo para esta salida
    SELECT id INTO v_ingreso_activo
    FROM ingreso_sede
    WHERE salida_unidad_id = p_salida_id
    AND fecha_hora_salida IS NULL;

    IF v_ingreso_activo IS NOT NULL THEN
        RAISE EXCEPTION 'Ya existe un ingreso activo (ID: %) para esta salida. Debe registrar salida de sede primero.', v_ingreso_activo;
    END IF;

    -- Insertar el ingreso
    INSERT INTO ingreso_sede (
        salida_unidad_id,
        sede_id,
        tipo_ingreso,
        km_ingreso,
        combustible_ingreso,
        observaciones_ingreso,
        es_ingreso_final,
        registrado_por
    ) VALUES (
        p_salida_id,
        p_sede_id,
        p_tipo_ingreso,
        p_km,
        p_combustible,
        p_observaciones,
        p_es_ingreso_final,
        p_registrado_por
    )
    RETURNING id INTO v_ingreso_id;

    -- Si es ingreso final, llamar a finalizar_jornada_completa
    IF p_es_ingreso_final THEN
        SELECT * INTO v_result
        FROM finalizar_jornada_completa(
            p_salida_id,
            p_km,
            p_combustible,
            p_observaciones,
            p_registrado_por
        );

        IF NOT v_result.success THEN
            RAISE EXCEPTION 'Error al finalizar jornada: %', v_result.mensaje;
        END IF;
    END IF;

    RETURN v_ingreso_id;
END;
$$;


--
-- Name: registrar_salida_de_sede(integer, numeric, numeric, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.registrar_salida_de_sede(p_ingreso_id integer, p_km_salida numeric DEFAULT NULL::numeric, p_combustible_salida numeric DEFAULT NULL::numeric, p_observaciones text DEFAULT NULL::text) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE ingreso_sede
    SET fecha_hora_salida = NOW(),
        km_salida_nueva = p_km_salida,
        combustible_salida_nueva = p_combustible_salida,
        observaciones_salida = p_observaciones
    WHERE id = p_ingreso_id
      AND fecha_hora_salida IS NULL
      AND es_ingreso_final = FALSE; -- No se puede salir de un ingreso final

    RETURN FOUND;
END;
$$;


--
-- Name: FUNCTION registrar_salida_de_sede(p_ingreso_id integer, p_km_salida numeric, p_combustible_salida numeric, p_observaciones text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.registrar_salida_de_sede(p_ingreso_id integer, p_km_salida numeric, p_combustible_salida numeric, p_observaciones text) IS 'Marca que la unidad volvi?? a salir despu??s de un ingreso temporal';


--
-- Name: resolver_alerta(integer, integer, text); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.resolver_alerta(p_alerta_id integer, p_usuario_id integer, p_nota text DEFAULT NULL::text) RETURNS TABLE(success boolean, mensaje text)
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_alerta alerta;
BEGIN
  -- Obtener alerta
  SELECT * INTO v_alerta FROM alerta WHERE id = p_alerta_id;

  IF v_alerta IS NULL THEN
    RETURN QUERY SELECT FALSE, 'Alerta no encontrada'::TEXT;
    RETURN;
  END IF;

  IF v_alerta.estado NOT IN ('ACTIVA', 'ATENDIDA') THEN
    RETURN QUERY SELECT FALSE, 'La alerta ya está cerrada'::TEXT;
    RETURN;
  END IF;

  -- Actualizar alerta
  UPDATE alerta
  SET estado = 'RESUELTA',
      atendida_por = COALESCE(atendida_por, p_usuario_id),
      fecha_atencion = COALESCE(fecha_atencion, CURRENT_TIMESTAMP),
      nota_resolucion = COALESCE(p_nota, nota_resolucion),
      updated_at = CURRENT_TIMESTAMP
  WHERE id = p_alerta_id;

  RETURN QUERY SELECT TRUE, 'Alerta resuelta'::TEXT;
END;
$$;


--
-- Name: FUNCTION resolver_alerta(p_alerta_id integer, p_usuario_id integer, p_nota text); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.resolver_alerta(p_alerta_id integer, p_usuario_id integer, p_nota text) IS 'Marca una alerta como resuelta';


--
-- Name: responder_aprobacion(integer, integer, character varying, text, numeric, numeric); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.responder_aprobacion(p_aprobacion_id integer, p_usuario_id integer, p_respuesta character varying, p_motivo text DEFAULT NULL::text, p_latitud numeric DEFAULT NULL::numeric, p_longitud numeric DEFAULT NULL::numeric) RETURNS jsonb
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_aprobacion RECORD;
    v_total_tripulantes INTEGER;
    v_aprobados INTEGER;
    v_rechazados INTEGER;
    v_pendientes INTEGER;
    v_nuevo_estado VARCHAR;
BEGIN
    -- Verificar que la aprobacion existe y esta pendiente
    SELECT * INTO v_aprobacion
    FROM aprobacion_tripulacion
    WHERE id = p_aprobacion_id;

    IF v_aprobacion IS NULL THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'Aprobacion no encontrada');
    END IF;

    IF v_aprobacion.estado != 'PENDIENTE' THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'La aprobacion ya no esta pendiente');
    END IF;

    -- Registrar respuesta
    UPDATE aprobacion_respuesta
    SET respuesta = p_respuesta,
        fecha_respuesta = NOW(),
        motivo_rechazo = p_motivo,
        latitud = p_latitud,
        longitud = p_longitud
    WHERE aprobacion_id = p_aprobacion_id
      AND usuario_id = p_usuario_id;

    IF NOT FOUND THEN
        RETURN jsonb_build_object('success', FALSE, 'error', 'Usuario no es parte de esta aprobacion');
    END IF;

    -- Contar respuestas
    SELECT
        COUNT(*),
        COUNT(*) FILTER (WHERE respuesta = 'APROBADO'),
        COUNT(*) FILTER (WHERE respuesta = 'RECHAZADO'),
        COUNT(*) FILTER (WHERE respuesta = 'PENDIENTE')
    INTO v_total_tripulantes, v_aprobados, v_rechazados, v_pendientes
    FROM aprobacion_respuesta
    WHERE aprobacion_id = p_aprobacion_id;

    -- Determinar nuevo estado
    v_nuevo_estado := 'PENDIENTE';

    -- Si alguien rechazo y se requiere todos
    IF v_rechazados > 0 AND v_aprobacion.requiere_todos THEN
        v_nuevo_estado := 'RECHAZADA';
    -- Si todos aprobaron
    ELSIF v_aprobados = v_total_tripulantes THEN
        v_nuevo_estado := 'COMPLETADA';
    -- Si no requiere todos y hay suficientes aprobaciones
    ELSIF NOT v_aprobacion.requiere_todos AND v_aprobados >= v_aprobacion.minimo_aprobaciones THEN
        v_nuevo_estado := 'COMPLETADA';
    END IF;

    -- Actualizar estado si cambio
    IF v_nuevo_estado != 'PENDIENTE' THEN
        UPDATE aprobacion_tripulacion
        SET estado = v_nuevo_estado,
            fecha_completada = NOW(),
            updated_at = NOW()
        WHERE id = p_aprobacion_id;
    END IF;

    RETURN jsonb_build_object(
        'success', TRUE,
        'estado', v_nuevo_estado,
        'total', v_total_tripulantes,
        'aprobados', v_aprobados,
        'rechazados', v_rechazados,
        'pendientes', v_pendientes
    );
END;
$$;


--
-- Name: tiene_permiso_sede(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.tiene_permiso_sede(p_usuario_id integer, p_sede_id integer) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_rol VARCHAR(50);
    v_sede_usuario INT;
BEGIN
    -- Obtener rol del usuario
    SELECT r.nombre INTO v_rol
    FROM usuario u
    JOIN rol r ON u.rol_id = r.id
    WHERE u.id = p_usuario_id;

    -- COP tiene acceso a TODAS las sedes
    IF v_rol = 'COP' THEN
        RETURN TRUE;
    END IF;

    -- Otros roles solo tienen acceso a su sede
    v_sede_usuario := obtener_sede_efectiva_usuario(p_usuario_id);

    RETURN v_sede_usuario = p_sede_id;
END;
$$;


--
-- Name: FUNCTION tiene_permiso_sede(p_usuario_id integer, p_sede_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.tiene_permiso_sede(p_usuario_id integer, p_sede_id integer) IS 'Verifica si un usuario tiene permiso para operar en una sede. COP tiene acceso universal.';


--
-- Name: trigger_actualizar_descripcion_obstruccion(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_actualizar_descripcion_obstruccion() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.descripcion_generada := fn_generar_descripcion_obstruccion(
        NEW.hay_vehiculo_fuera_via,
        NEW.tipo_obstruccion,
        NEW.sentido_principal,
        NEW.sentido_contrario,
        NULL -- El sentido se puede obtener de la situaci??n si es necesario
    );
    NEW.updated_at := NOW();
    RETURN NEW;
END;
$$;


--
-- Name: trigger_actualizar_ruta_activa(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_actualizar_ruta_activa() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Si es SALIDA_SEDE o CAMBIO_RUTA, actualizar la ruta activa
    IF NEW.tipo_situacion IN ('SALIDA_SEDE', 'CAMBIO_RUTA') THEN
        IF NEW.ruta_id IS NOT NULL AND NEW.asignacion_id IS NOT NULL THEN
            PERFORM actualizar_ruta_activa(NEW.asignacion_id, NEW.ruta_id);
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: trigger_alerta_emergencia(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_alerta_emergencia() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  -- Solo para situaciones de tipo EMERGENCIA
  IF NEW.tipo = 'EMERGENCIA' THEN
    PERFORM crear_alerta(
      'EMERGENCIA',
      'EMERGENCIA: ' || NEW.tipo,
      'Se ha reportado una emergencia. Ubicación: ' || COALESCE(NEW.ubicacion_texto, 'No especificada'),
      'CRITICA',
      jsonb_build_object(
        'situacion_id', NEW.id,
        'descripcion', NEW.descripcion,
        'ubicacion', NEW.ubicacion_texto,
        'coordenadas', jsonb_build_object('lat', NEW.latitud, 'lng', NEW.longitud)
      ),
      NULL, -- sede_id
      NULL, -- unidad_id
      NULL, -- brigada_id
      NEW.id,
      NULL -- sin expiración
    );
  END IF;

  RETURN NEW;
END;
$$;


--
-- Name: trigger_auditar_cambio_asignacion_cerrada(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_auditar_cambio_asignacion_cerrada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    -- Si el d??a est?? cerrado y se est?? modificando
    IF OLD.dia_cerrado = TRUE THEN
        NEW.modificado_despues_cierre := TRUE;

        -- Si no se proporciona motivo, rechazar
        IF NEW.motivo_modificacion_cierre IS NULL OR NEW.motivo_modificacion_cierre = '' THEN
            RAISE EXCEPTION 'Se requiere motivo para modificar asignaci??n de d??a cerrado';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: trigger_auditar_cambio_situacion_cerrada(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_auditar_cambio_situacion_cerrada() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_asignacion_cerrada BOOLEAN;
BEGIN
    -- Verificar si la asignaci??n est?? cerrada
    SELECT dia_cerrado
    INTO v_asignacion_cerrada
    FROM asignacion_unidad
    WHERE id = OLD.asignacion_id;

    IF v_asignacion_cerrada = TRUE THEN
        NEW.modificado_despues_cierre := TRUE;

        -- Si no se proporciona motivo, rechazar
        IF NEW.motivo_modificacion_cierre IS NULL OR NEW.motivo_modificacion_cierre = '' THEN
            RAISE EXCEPTION 'Se requiere motivo para modificar situaci??n de d??a cerrado';
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: trigger_validar_asignacion_unidad(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_validar_asignacion_unidad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_fecha DATE;
    v_fecha_fin DATE;
    v_validacion RECORD;
BEGIN
    -- Obtener fechas del turno
    SELECT t.fecha, t.fecha_fin INTO v_fecha, v_fecha_fin
    FROM turno t WHERE t.id = NEW.turno_id;

    -- Validar disponibilidad
    SELECT * INTO v_validacion
    FROM validar_disponibilidad_unidad_fecha(
        NEW.unidad_id,
        v_fecha,
        v_fecha_fin,
        CASE WHEN TG_OP = 'UPDATE' THEN OLD.id ELSE NULL END
    );

    IF NOT v_validacion.disponible THEN
        RAISE EXCEPTION 'No se puede asignar la unidad: %', v_validacion.mensaje;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: trigger_validar_suspension_acceso(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.trigger_validar_suspension_acceso() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_validacion RECORD;
BEGIN
    -- Solo validar si se est?? desactivando el acceso
    IF OLD.acceso_app_activo = TRUE AND NEW.acceso_app_activo = FALSE THEN
        SELECT *
        INTO v_validacion
        FROM validar_suspension_acceso(NEW.id);

        IF v_validacion.puede_suspender = FALSE THEN
            RAISE EXCEPTION 'No se puede suspender acceso: %', v_validacion.motivo_rechazo;
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: update_aseguradora_stats(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_aseguradora_stats() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.aseguradora_id IS NOT NULL THEN
        UPDATE aseguradora SET
            total_incidentes = total_incidentes + 1
        WHERE id = NEW.aseguradora_id;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION update_aseguradora_stats(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.update_aseguradora_stats() IS 'Actualiza contadores de incidentes en tabla aseguradora';


--
-- Name: update_combustible_unidad(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_combustible_unidad() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    UPDATE unidad
    SET
        combustible_actual = NEW.combustible_nuevo,
        odometro_actual = COALESCE(NEW.odometro_actual, odometro_actual),
        updated_at = NOW()
    WHERE id = NEW.unidad_id;

    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION update_combustible_unidad(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.update_combustible_unidad() IS 'Actualiza autom??ticamente el combustible actual de la unidad';


--
-- Name: update_config_columnas_updated_at(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_config_columnas_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_evento_persistente_timestamp(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_evento_persistente_timestamp() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: update_grua_stats(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_grua_stats() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE grua SET
            total_servicios = total_servicios + 1,
            ultima_vez_usado = NOW()
        WHERE id = NEW.grua_id;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION update_grua_stats(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.update_grua_stats() IS 'Actualiza contadores de servicios en tabla grua';


--
-- Name: update_piloto_sancion_stats(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_piloto_sancion_stats() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.piloto_id IS NOT NULL THEN
        UPDATE piloto SET
            total_sanciones = total_sanciones + 1
        WHERE id = NEW.piloto_id;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION update_piloto_sancion_stats(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.update_piloto_sancion_stats() IS 'Actualiza contadores de sanciones en tabla piloto';


--
-- Name: update_piloto_stats(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_piloto_stats() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' AND NEW.piloto_id IS NOT NULL THEN
        UPDATE piloto SET
            total_incidentes = total_incidentes + 1,
            ultimo_incidente = NOW(),
            primer_incidente = COALESCE(primer_incidente, NOW())
        WHERE id = NEW.piloto_id;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION update_piloto_stats(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.update_piloto_stats() IS 'Actualiza contadores de incidentes en tabla piloto';


--
-- Name: update_updated_at_column(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_updated_at_column() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION update_updated_at_column(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.update_updated_at_column() IS 'Actualiza autom??ticamente la columna updated_at al modificar un registro';


--
-- Name: update_vehiculo_stats(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.update_vehiculo_stats() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        UPDATE vehiculo SET
            total_incidentes = total_incidentes + 1,
            ultimo_incidente = NOW(),
            primer_incidente = COALESCE(primer_incidente, NOW())
        WHERE id = NEW.vehiculo_id;
    END IF;
    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION update_vehiculo_stats(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.update_vehiculo_stats() IS 'Actualiza contadores de incidentes en tabla vehiculo';


--
-- Name: usuario_tiene_rol(integer, character varying); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.usuario_tiene_rol(p_usuario_id integer, p_rol_nombre character varying) RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN EXISTS (
        SELECT 1
        FROM usuario_rol ur
        JOIN rol r ON ur.rol_id = r.id
        WHERE ur.usuario_id = p_usuario_id
          AND r.nombre = p_rol_nombre
          AND ur.activo = true
    );
END;
$$;


--
-- Name: validar_actividad_incidente(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validar_actividad_incidente() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
    requiere_incidente_val BOOLEAN;
BEGIN
    -- Si la actividad tiene incidente asociado
    IF NEW.incidente_id IS NOT NULL THEN
        -- Verificar que el tipo de actividad requiera incidente
        SELECT requiere_incidente INTO requiere_incidente_val
        FROM tipo_actividad
        WHERE id = NEW.tipo_actividad_id;

        IF requiere_incidente_val = FALSE THEN
            RAISE EXCEPTION 'El tipo de actividad "%" no puede estar asociado a un incidente',
                (SELECT nombre FROM tipo_actividad WHERE id = NEW.tipo_actividad_id);
        END IF;
    END IF;

    RETURN NEW;
END;
$$;


--
-- Name: FUNCTION validar_actividad_incidente(); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.validar_actividad_incidente() IS 'Valida que las actividades asociadas a incidentes tengan tipo correcto';


--
-- Name: validar_disponibilidad_brigada(integer, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validar_disponibilidad_brigada(p_usuario_id integer, p_fecha date) RETURNS TABLE(disponible boolean, mensaje text, ultimo_turno_fecha date, dias_descanso integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_tiene_asignacion_hoy BOOLEAN;
    v_tiene_salida_activa BOOLEAN;
    v_ultima_salida DATE;
    v_dias_descanso INTEGER;
BEGIN
    -- 1. Verificar si tiene asignación activa para esta fecha
    SELECT EXISTS(
        SELECT 1
        FROM tripulacion_turno tt
        JOIN asignacion_unidad au ON tt.asignacion_id = au.id
        JOIN turno t ON au.turno_id = t.id
        WHERE tt.usuario_id = p_usuario_id
          AND t.estado IN ('PLANIFICADO', 'ACTIVO')
          AND (t.fecha = p_fecha OR (t.fecha <= p_fecha AND COALESCE(t.fecha_fin, t.fecha) >= p_fecha))
    ) INTO v_tiene_asignacion_hoy;

    -- 2. Verificar si tiene salida activa (EN_SALIDA)
    SELECT EXISTS(
        SELECT 1
        FROM salida_unidad su
        JOIN tripulacion_turno tt ON su.unidad_id = (
            SELECT au.unidad_id
            FROM asignacion_unidad au
            WHERE au.id = tt.asignacion_id
        )
        WHERE tt.usuario_id = p_usuario_id
          AND su.estado = 'EN_SALIDA'
    ) INTO v_tiene_salida_activa;

    -- 3. Obtener última SALIDA REAL (no asignación) de los últimos 30 días
    -- Busca en salida_unidad donde el usuario fue parte de la tripulación
    SELECT MAX(su.fecha_hora_salida::DATE) INTO v_ultima_salida
    FROM salida_unidad su
    JOIN asignacion_unidad au ON su.unidad_id = au.unidad_id
    JOIN turno t ON au.turno_id = t.id
    JOIN tripulacion_turno tt ON tt.asignacion_id = au.id
    WHERE tt.usuario_id = p_usuario_id
      AND su.fecha_hora_salida >= (p_fecha - INTERVAL '30 days')
      AND su.fecha_hora_salida::DATE < p_fecha
      AND su.estado IN ('EN_SALIDA', 'FINALIZADA', 'CANCELADA');

    -- 4. Calcular días de descanso basado en SALIDAS REALES
    IF v_ultima_salida IS NOT NULL THEN
        v_dias_descanso := p_fecha - v_ultima_salida;
    ELSE
        v_dias_descanso := 999; -- Nunca ha salido o hace más de 30 días
    END IF;

    -- 5. Retornar resultado
    RETURN QUERY SELECT
        CASE
            WHEN v_tiene_salida_activa THEN FALSE
            WHEN v_tiene_asignacion_hoy THEN FALSE
            WHEN v_dias_descanso < 2 THEN FALSE
            ELSE TRUE
        END,
        CASE
            WHEN v_tiene_salida_activa THEN 'Brigada tiene salida activa en este momento'::TEXT
            WHEN v_tiene_asignacion_hoy THEN 'Brigada ya tiene asignación para esta fecha'::TEXT
            WHEN v_dias_descanso = 0 THEN 'Brigada salió hoy - necesita descanso'::TEXT
            WHEN v_dias_descanso = 1 THEN 'Brigada salió ayer - descanso recomendado'::TEXT
            ELSE 'Brigada disponible'::TEXT
        END,
        v_ultima_salida,
        v_dias_descanso;
END;
$$;


--
-- Name: FUNCTION validar_disponibilidad_brigada(p_usuario_id integer, p_fecha date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.validar_disponibilidad_brigada(p_usuario_id integer, p_fecha date) IS 'Valida disponibilidad de brigada basándose en SALIDAS REALES (salida_unidad),
no en asignaciones. Solo cuenta para descanso si realmente salió.';


--
-- Name: validar_disponibilidad_unidad(integer, date); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validar_disponibilidad_unidad(p_unidad_id integer, p_fecha date DEFAULT CURRENT_DATE) RETURNS TABLE(disponible boolean, mensaje text, ultimo_uso_fecha date, dias_descanso integer, combustible_suficiente boolean)
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN QUERY
    WITH asignacion_activa AS (
        -- Cualquier asignación activa (sin importar fecha)
        SELECT au.id, t.fecha, t.estado
        FROM asignacion_unidad au
        JOIN turno t ON au.turno_id = t.id
        WHERE au.unidad_id = p_unidad_id
        AND t.estado IN ('PLANIFICADO', 'ACTIVO')
        LIMIT 1
    ),
    ultimo_uso AS (
        -- Último turno finalizado (para calcular días de descanso)
        SELECT MAX(t.fecha) as fecha
        FROM asignacion_unidad au
        JOIN turno t ON au.turno_id = t.id
        WHERE au.unidad_id = p_unidad_id
        AND t.estado = 'FINALIZADO'
    )
    SELECT
        CASE
            WHEN (SELECT COUNT(*) FROM asignacion_activa) > 0 THEN FALSE
            WHEN un.activa = FALSE THEN FALSE
            WHEN un.combustible_actual < 10 THEN FALSE
            ELSE TRUE
        END AS disponible,

        CASE
            WHEN (SELECT COUNT(*) FROM asignacion_activa) > 0 THEN
                'Unidad ya tiene asignación activa (fecha: ' ||
                (SELECT fecha FROM asignacion_activa)::TEXT || ')'
            WHEN un.activa = FALSE THEN 'Unidad está inactiva'
            WHEN un.combustible_actual < 10 THEN 'Combustible insuficiente (menos de 10L)'
            ELSE 'Unidad disponible'
        END AS mensaje,

        (SELECT fecha FROM ultimo_uso) AS ultimo_uso_fecha,
        COALESCE(p_fecha - (SELECT fecha FROM ultimo_uso), 999) AS dias_descanso,
        COALESCE(un.combustible_actual >= 10, FALSE) AS combustible_suficiente

    FROM unidad un
    WHERE un.id = p_unidad_id;
END;
$$;


--
-- Name: FUNCTION validar_disponibilidad_unidad(p_unidad_id integer, p_fecha date); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.validar_disponibilidad_unidad(p_unidad_id integer, p_fecha date) IS 'Valida si una unidad está disponible para asignación.
Una unidad NO está disponible si:
- Tiene cualquier asignación activa (PLANIFICADO/ACTIVO) sin importar la fecha
- Está inactiva
- Tiene menos de 10L de combustible
La unidad se libera al finalizar jornada o eliminar asignación manualmente.';


--
-- Name: validar_disponibilidad_unidad_fecha(integer, date, date, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validar_disponibilidad_unidad_fecha(p_unidad_id integer, p_fecha_inicio date, p_fecha_fin date DEFAULT NULL::date, p_excluir_asignacion_id integer DEFAULT NULL::integer) RETURNS TABLE(disponible boolean, mensaje text, asignacion_conflicto_id integer, turno_conflicto_fecha date)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_fecha_fin DATE;
    v_conflicto RECORD;
BEGIN
    -- Si no hay fecha_fin, usar fecha_inicio
    v_fecha_fin := COALESCE(p_fecha_fin, p_fecha_inicio);

    -- Buscar conflictos
    SELECT a.id, t.fecha, t.fecha_fin, u.codigo
    INTO v_conflicto
    FROM asignacion_unidad a
    JOIN turno t ON a.turno_id = t.id
    JOIN unidad u ON a.unidad_id = u.id
    WHERE a.unidad_id = p_unidad_id
    AND t.estado IN ('PLANIFICADO', 'ACTIVO')
    AND a.hora_entrada_real IS NULL  -- No ha finalizado
    AND (p_excluir_asignacion_id IS NULL OR a.id <> p_excluir_asignacion_id)
    -- Verificar solapamiento de fechas
    AND (
        -- El rango solicitado se solapa con el rango existente
        (p_fecha_inicio <= COALESCE(t.fecha_fin, t.fecha) AND v_fecha_fin >= t.fecha)
    )
    LIMIT 1;

    IF v_conflicto.id IS NOT NULL THEN
        RETURN QUERY SELECT
            FALSE,
            'La unidad ya está asignada para el ' ||
                CASE
                    WHEN v_conflicto.fecha_fin IS NOT NULL
                    THEN 'período ' || v_conflicto.fecha || ' al ' || v_conflicto.fecha_fin
                    ELSE 'día ' || v_conflicto.fecha
                END,
            v_conflicto.id,
            v_conflicto.fecha;
    ELSE
        RETURN QUERY SELECT
            TRUE,
            'Unidad disponible'::TEXT,
            NULL::INTEGER,
            NULL::DATE;
    END IF;
END;
$$;


--
-- Name: FUNCTION validar_disponibilidad_unidad_fecha(p_unidad_id integer, p_fecha_inicio date, p_fecha_fin date, p_excluir_asignacion_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.validar_disponibilidad_unidad_fecha(p_unidad_id integer, p_fecha_inicio date, p_fecha_fin date, p_excluir_asignacion_id integer) IS 'Valida si una unidad está disponible para un rango de fechas. Evita asignar la misma unidad dos veces en días que se solapan.';


--
-- Name: validar_remocion_asignacion(integer, integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validar_remocion_asignacion(p_usuario_id integer, p_asignacion_id integer) RETURNS TABLE(puede_remover boolean, motivo_rechazo text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_tiene_movimiento_activo BOOLEAN;
    v_es_unico_piloto BOOLEAN;
BEGIN
    -- Verificar movimientos activos en esta asignaci??n
    SELECT EXISTS (
        SELECT 1
        FROM movimiento_brigada
        WHERE usuario_id = p_usuario_id
          AND (origen_asignacion_id = p_asignacion_id OR destino_asignacion_id = p_asignacion_id)
          AND hora_fin IS NULL
    ) INTO v_tiene_movimiento_activo;

    IF v_tiene_movimiento_activo THEN
        RETURN QUERY SELECT FALSE, 'El brigada tiene movimientos activos. Debe finalizarlos primero.';
        RETURN;
    END IF;

    -- Verificar si es el ??nico piloto (no se puede remover)
    SELECT EXISTS (
        SELECT 1
        FROM tripulacion_turno tt
        WHERE tt.asignacion_id = p_asignacion_id
          AND tt.usuario_id = p_usuario_id
          AND tt.rol_tripulacion = 'PILOTO'
          AND (
            SELECT COUNT(*)
            FROM tripulacion_turno
            WHERE asignacion_id = p_asignacion_id
              AND rol_tripulacion = 'PILOTO'
              AND presente = TRUE
          ) = 1
    ) INTO v_es_unico_piloto;

    IF v_es_unico_piloto THEN
        RETURN QUERY SELECT FALSE, 'No se puede remover al ??nico piloto de la unidad. Asignar otro piloto primero.';
        RETURN;
    END IF;

    -- Si pas?? todas las validaciones
    RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$$;


--
-- Name: FUNCTION validar_remocion_asignacion(p_usuario_id integer, p_asignacion_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.validar_remocion_asignacion(p_usuario_id integer, p_asignacion_id integer) IS 'Valida que un brigada pueda ser removido de una asignaci??n';


--
-- Name: validar_suspension_acceso(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.validar_suspension_acceso(p_usuario_id integer) RETURNS TABLE(puede_suspender boolean, motivo_rechazo text)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_tiene_asignacion_activa BOOLEAN;
    v_tiene_movimiento_activo BOOLEAN;
    v_tiene_situacion_activa BOOLEAN;
BEGIN
    -- Verificar asignaci??n activa
    SELECT EXISTS (
        SELECT 1
        FROM tripulacion_turno tt
        JOIN asignacion_unidad au ON tt.asignacion_id = au.id
        JOIN turno t ON au.turno_id = t.id
        WHERE tt.usuario_id = p_usuario_id
          AND t.fecha = CURRENT_DATE
          AND au.dia_cerrado = FALSE
    ) INTO v_tiene_asignacion_activa;

    IF v_tiene_asignacion_activa THEN
        RETURN QUERY SELECT FALSE, 'El usuario tiene una asignaci??n activa. Debe ser removido primero.';
        RETURN;
    END IF;

    -- Verificar movimientos activos
    SELECT EXISTS (
        SELECT 1
        FROM movimiento_brigada
        WHERE usuario_id = p_usuario_id
          AND hora_fin IS NULL
    ) INTO v_tiene_movimiento_activo;

    IF v_tiene_movimiento_activo THEN
        RETURN QUERY SELECT FALSE, 'El usuario tiene movimientos activos. Debe finalizarlos primero.';
        RETURN;
    END IF;

    -- Verificar situaciones activas creadas por ??l
    SELECT EXISTS (
        SELECT 1
        FROM situacion
        WHERE creado_por = p_usuario_id
          AND estado = 'ACTIVA'
    ) INTO v_tiene_situacion_activa;

    IF v_tiene_situacion_activa THEN
        RETURN QUERY SELECT FALSE, 'El usuario tiene situaciones activas. Deben cerrarse primero.';
        RETURN;
    END IF;

    -- Si pas?? todas las validaciones
    RETURN QUERY SELECT TRUE, NULL::TEXT;
END;
$$;


--
-- Name: FUNCTION validar_suspension_acceso(p_usuario_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.validar_suspension_acceso(p_usuario_id integer) IS 'Valida que un usuario pueda tener su acceso suspendido';


--
-- Name: verificar_acceso_app(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verificar_acceso_app(p_usuario_id integer) RETURNS TABLE(tiene_acceso boolean, motivo_bloqueo text)
    LANGUAGE plpgsql
    AS $$
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
$$;


--
-- Name: FUNCTION verificar_acceso_app(p_usuario_id integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.verificar_acceso_app(p_usuario_id integer) IS 'Verifica acceso a la app: exentos siempre pueden, brigadas dependen de grupo y asignaci??n';


--
-- Name: verificar_inspecciones_pendientes(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verificar_inspecciones_pendientes(p_minutos_espera integer DEFAULT 30) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_inspeccion RECORD;
  v_count INTEGER := 0;
  v_alerta_existente BOOLEAN;
BEGIN
  FOR v_inspeccion IN
    SELECT i.id, i.unidad_id, u.codigo AS unidad_codigo, u.sede_id,
           i.fecha_realizacion
    FROM inspeccion_360 i
    JOIN unidad u ON i.unidad_id = u.id
    WHERE i.estado = 'PENDIENTE'
      AND i.fecha_realizacion < CURRENT_TIMESTAMP - (p_minutos_espera || ' minutes')::INTERVAL
  LOOP
    -- Verificar si ya hay alerta activa
    SELECT EXISTS (
      SELECT 1 FROM alerta
      WHERE tipo = 'INSPECCION_PENDIENTE'
        AND datos->>'inspeccion_id' = v_inspeccion.id::TEXT
        AND estado = 'ACTIVA'
    ) INTO v_alerta_existente;

    IF NOT v_alerta_existente THEN
      PERFORM crear_alerta(
        'INSPECCION_PENDIENTE',
        'Inspección 360 pendiente - Unidad ' || v_inspeccion.unidad_codigo,
        'La inspección 360 de la unidad ' || v_inspeccion.unidad_codigo ||
        ' lleva más de ' || p_minutos_espera || ' minutos esperando aprobación.',
        'MEDIA',
        jsonb_build_object(
          'inspeccion_id', v_inspeccion.id,
          'fecha_realizacion', v_inspeccion.fecha_realizacion
        ),
        v_inspeccion.sede_id,
        v_inspeccion.unidad_id,
        NULL,
        NULL,
        60 -- Expira en 1 hora
      );
      v_count := v_count + 1;
    END IF;
  END LOOP;

  RETURN v_count;
END;
$$;


--
-- Name: FUNCTION verificar_inspecciones_pendientes(p_minutos_espera integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.verificar_inspecciones_pendientes(p_minutos_espera integer) IS 'Verifica inspecciones pendientes y crea alertas';


--
-- Name: verificar_multimedia_completa(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verificar_multimedia_completa(p_situacion_id integer) RETURNS TABLE(fotos_subidas integer, fotos_requeridas integer, video_subido boolean, video_requerido boolean, multimedia_completa boolean)
    LANGUAGE plpgsql
    AS $$
DECLARE
    v_tipo_situacion VARCHAR(50);
    v_fotos INTEGER;
    v_tiene_video BOOLEAN;
BEGIN
    -- Obtener tipo de situación
    SELECT tipo_situacion INTO v_tipo_situacion
    FROM situacion WHERE id = p_situacion_id;

    -- Contar fotos y videos
    SELECT
        COUNT(*) FILTER (WHERE tipo = 'FOTO'),
        BOOL_OR(tipo = 'VIDEO')
    INTO v_fotos, v_tiene_video
    FROM situacion_multimedia
    WHERE situacion_id = p_situacion_id;

    v_tiene_video := COALESCE(v_tiene_video, false);

    -- Determinar requerimientos según tipo
    -- INCIDENTE, ASISTENCIA_VEHICULAR, EMERGENCIA requieren 3 fotos + 1 video
    IF v_tipo_situacion IN ('INCIDENTE', 'ASISTENCIA_VEHICULAR', 'EMERGENCIA') THEN
        RETURN QUERY SELECT
            v_fotos,
            3,
            v_tiene_video,
            true,
            (v_fotos >= 3 AND v_tiene_video);
    ELSE
        -- Otros tipos no requieren multimedia obligatoria
        RETURN QUERY SELECT
            v_fotos,
            0,
            v_tiene_video,
            false,
            true;
    END IF;
END;
$$;


--
-- Name: verificar_unidades_inactivas(integer); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.verificar_unidades_inactivas(p_minutos_inactividad integer DEFAULT 60) RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_unidad RECORD;
  v_count INTEGER := 0;
  v_alerta_existente BOOLEAN;
BEGIN
  FOR v_unidad IN
    SELECT u.id, u.codigo, u.sede_id, su.fecha_hora_salida, su.id AS salida_id
    FROM unidad u
    JOIN salida_unidad su ON u.id = su.unidad_id
    WHERE su.fecha_hora_salida IS NOT NULL
      AND su.fecha_hora_ingreso IS NULL
      AND su.fecha_hora_salida < CURRENT_TIMESTAMP - (p_minutos_inactividad || ' minutes')::INTERVAL
      -- Sin situaciones recientes
      AND NOT EXISTS (
        SELECT 1 FROM situacion s
        WHERE s.salida_id = su.id
          AND s.fecha_hora_reporte > CURRENT_TIMESTAMP - (p_minutos_inactividad || ' minutes')::INTERVAL
      )
  LOOP
    -- Verificar si ya hay alerta activa para esta unidad
    SELECT EXISTS (
      SELECT 1 FROM alerta
      WHERE tipo = 'UNIDAD_SIN_ACTIVIDAD'
        AND unidad_id = v_unidad.id
        AND estado = 'ACTIVA'
    ) INTO v_alerta_existente;

    IF NOT v_alerta_existente THEN
      PERFORM crear_alerta(
        'UNIDAD_SIN_ACTIVIDAD',
        'Unidad ' || v_unidad.codigo || ' sin actividad',
        'La unidad ' || v_unidad.codigo || ' lleva más de ' || p_minutos_inactividad ||
        ' minutos sin reportar actividad desde que salió.',
        'MEDIA',
        jsonb_build_object(
          'salida_id', v_unidad.salida_id,
          'ultima_salida', v_unidad.fecha_hora_salida
        ),
        v_unidad.sede_id,
        v_unidad.id,
        NULL,
        NULL,
        120 -- Expira en 2 horas
      );
      v_count := v_count + 1;
    END IF;
  END LOOP;

  RETURN v_count;
END;
$$;


--
-- Name: FUNCTION verificar_unidades_inactivas(p_minutos_inactividad integer); Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON FUNCTION public.verificar_unidades_inactivas(p_minutos_inactividad integer) IS 'Verifica unidades sin actividad y crea alertas';


--
-- Name: actividad_unidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actividad_unidad (
    id bigint NOT NULL,
    unidad_id integer NOT NULL,
    tipo_actividad_id integer NOT NULL,
    incidente_id bigint,
    ruta_id integer,
    km numeric(6,2),
    sentido character varying(30),
    hora_inicio timestamp with time zone NOT NULL,
    hora_fin timestamp with time zone,
    observaciones text,
    registrado_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    asignacion_id integer,
    CONSTRAINT actividad_unidad_sentido_check CHECK (((sentido)::text = ANY (ARRAY[('NORTE'::character varying)::text, ('SUR'::character varying)::text, ('ESTE'::character varying)::text, ('OESTE'::character varying)::text, ('ASCENDENTE'::character varying)::text, ('DESCENDENTE'::character varying)::text]))),
    CONSTRAINT chk_actividad_tiempos CHECK (((hora_fin IS NULL) OR (hora_fin >= hora_inicio)))
);


--
-- Name: TABLE actividad_unidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.actividad_unidad IS 'Actividades que realizan las unidades durante el d??a';


--
-- Name: COLUMN actividad_unidad.hora_fin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.actividad_unidad.hora_fin IS 'NULL si la actividad est?? en curso';


--
-- Name: COLUMN actividad_unidad.asignacion_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.actividad_unidad.asignacion_id IS 'Asignaci??n durante la cual se realiz?? esta actividad';


--
-- Name: actividad_unidad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.actividad_unidad_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actividad_unidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.actividad_unidad_id_seq OWNED BY public.actividad_unidad.id;


--
-- Name: actualizacion_situacion_persistente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.actualizacion_situacion_persistente (
    id integer NOT NULL,
    situacion_persistente_id integer NOT NULL,
    usuario_id integer NOT NULL,
    unidad_id integer NOT NULL,
    asignacion_situacion_id integer,
    tipo_actualizacion character varying(50) NOT NULL,
    contenido text,
    datos_adicionales jsonb,
    archivos jsonb,
    fecha_hora timestamp with time zone DEFAULT now() NOT NULL,
    editado boolean DEFAULT false,
    fecha_ultima_edicion timestamp with time zone,
    editado_por integer,
    puede_editarse boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE actualizacion_situacion_persistente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.actualizacion_situacion_persistente IS 'Información agregada por unidades a situaciones persistentes.';


--
-- Name: actualizacion_situacion_persistente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.actualizacion_situacion_persistente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: actualizacion_situacion_persistente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.actualizacion_situacion_persistente_id_seq OWNED BY public.actualizacion_situacion_persistente.id;


--
-- Name: ajustador_involucrado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ajustador_involucrado (
    id integer NOT NULL,
    incidente_id integer,
    vehiculo_asignado_id integer,
    nombre character varying(255),
    empresa character varying(255),
    vehiculo_tipo character varying(100),
    vehiculo_placa character varying(20),
    vehiculo_color character varying(100),
    vehiculo_marca character varying(100),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: ajustador_involucrado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ajustador_involucrado_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ajustador_involucrado_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ajustador_involucrado_id_seq OWNED BY public.ajustador_involucrado.id;


--
-- Name: alerta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alerta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alerta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alerta_id_seq OWNED BY public.alerta.id;


--
-- Name: alerta_leida; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alerta_leida (
    id integer NOT NULL,
    alerta_id integer NOT NULL,
    usuario_id integer NOT NULL,
    leida_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE alerta_leida; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.alerta_leida IS 'Registro de alertas leídas por usuario';


--
-- Name: alerta_leida_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.alerta_leida_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: alerta_leida_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.alerta_leida_id_seq OWNED BY public.alerta_leida.id;


--
-- Name: aprobacion_respuesta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aprobacion_respuesta (
    id integer NOT NULL,
    aprobacion_id integer NOT NULL,
    usuario_id integer NOT NULL,
    respuesta character varying(20),
    fecha_respuesta timestamp with time zone,
    motivo_rechazo text,
    latitud numeric(10,8),
    longitud numeric(11,8),
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT aprobacion_respuesta_respuesta_check CHECK (((respuesta)::text = ANY ((ARRAY['APROBADO'::character varying, 'RECHAZADO'::character varying, 'PENDIENTE'::character varying])::text[])))
);


--
-- Name: TABLE aprobacion_respuesta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.aprobacion_respuesta IS 'Respuestas individuales de cada tripulante a solicitudes de aprobacion';


--
-- Name: aprobacion_respuesta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.aprobacion_respuesta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aprobacion_respuesta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.aprobacion_respuesta_id_seq OWNED BY public.aprobacion_respuesta.id;


--
-- Name: aprobacion_tripulacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aprobacion_tripulacion (
    id integer NOT NULL,
    salida_id integer,
    unidad_id integer NOT NULL,
    tipo character varying(30) NOT NULL,
    inspeccion_360_id integer,
    estado character varying(20) DEFAULT 'PENDIENTE'::character varying NOT NULL,
    requiere_todos boolean DEFAULT true,
    minimo_aprobaciones integer DEFAULT 1,
    tiempo_limite_minutos integer DEFAULT 30,
    iniciado_por integer,
    fecha_inicio timestamp with time zone DEFAULT now(),
    fecha_completada timestamp with time zone,
    observaciones text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT aprobacion_tripulacion_estado_check CHECK (((estado)::text = ANY ((ARRAY['PENDIENTE'::character varying, 'COMPLETADA'::character varying, 'RECHAZADA'::character varying, 'CANCELADA'::character varying, 'EXPIRADA'::character varying])::text[]))),
    CONSTRAINT aprobacion_tripulacion_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['CONFIRMAR_PRESENCIA'::character varying, 'APROBAR_FIN_JORNADA'::character varying, 'APROBAR_360'::character varying])::text[])))
);


--
-- Name: TABLE aprobacion_tripulacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.aprobacion_tripulacion IS 'Solicitudes de aprobacion que requieren consenso de tripulacion';


--
-- Name: aprobacion_tripulacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.aprobacion_tripulacion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aprobacion_tripulacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.aprobacion_tripulacion_id_seq OWNED BY public.aprobacion_tripulacion.id;


--
-- Name: articulo_sancion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.articulo_sancion (
    id integer NOT NULL,
    numero character varying(20) NOT NULL,
    descripcion text NOT NULL,
    monto_multa numeric(10,2),
    puntos_licencia integer DEFAULT 0,
    activo boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE articulo_sancion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.articulo_sancion IS 'Cat??logo de art??culos de ley de tr??nsito para sanciones';


--
-- Name: articulo_sancion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.articulo_sancion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: articulo_sancion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.articulo_sancion_id_seq OWNED BY public.articulo_sancion.id;


--
-- Name: aseguradora; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aseguradora (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    codigo character varying(20),
    telefono character varying(50),
    email character varying(100),
    total_incidentes integer DEFAULT 0,
    activa boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE aseguradora; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.aseguradora IS 'Tabla maestra de aseguradoras. Cat??logo reutilizable.';


--
-- Name: aseguradora_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.aseguradora_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aseguradora_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.aseguradora_id_seq OWNED BY public.aseguradora.id;


--
-- Name: asignacion_situacion_persistente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asignacion_situacion_persistente (
    id integer NOT NULL,
    situacion_persistente_id integer NOT NULL,
    unidad_id integer NOT NULL,
    asignacion_unidad_id integer,
    fecha_hora_asignacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_hora_desasignacion timestamp with time zone,
    km_asignacion numeric(6,2),
    latitud_asignacion numeric(10,8),
    longitud_asignacion numeric(11,8),
    observaciones_asignacion text,
    observaciones_desasignacion text,
    asignado_por integer NOT NULL,
    desasignado_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE asignacion_situacion_persistente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.asignacion_situacion_persistente IS 'Rastrea qué unidades están/estuvieron asignadas a situaciones persistentes.';


--
-- Name: asignacion_situacion_persistente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.asignacion_situacion_persistente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asignacion_situacion_persistente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.asignacion_situacion_persistente_id_seq OWNED BY public.asignacion_situacion_persistente.id;


--
-- Name: asignacion_unidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.asignacion_unidad (
    id integer NOT NULL,
    turno_id integer NOT NULL,
    unidad_id integer,
    ruta_id integer,
    km_inicio numeric(10,2),
    km_final numeric(10,2),
    sentido character varying(30),
    acciones text,
    combustible_inicial numeric(5,2),
    combustible_asignado numeric(5,2),
    hora_salida time without time zone,
    hora_entrada_estimada time without time zone,
    hora_salida_real timestamp with time zone,
    hora_entrada_real timestamp with time zone,
    combustible_final numeric(5,2),
    km_recorridos numeric(10,2),
    observaciones_finales text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    dia_cerrado boolean DEFAULT false,
    fecha_cierre timestamp with time zone,
    cerrado_por integer,
    modificado_despues_cierre boolean DEFAULT false,
    motivo_modificacion_cierre text,
    ruta_activa_id integer,
    hora_ultima_actualizacion_ruta timestamp with time zone,
    notificacion_enviada boolean DEFAULT false,
    fecha_notificacion timestamp with time zone,
    es_reaccion boolean DEFAULT false,
    situacion_fija_id integer,
    acciones_formato text,
    tipo_asignacion character varying(50) DEFAULT 'PATRULLA'::character varying,
    CONSTRAINT asignacion_unidad_sentido_check CHECK (((sentido)::text = ANY ((ARRAY['NORTE'::character varying, 'SUR'::character varying, 'ORIENTE'::character varying, 'OCCIDENTE'::character varying])::text[])))
);


--
-- Name: TABLE asignacion_unidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.asignacion_unidad IS 'Asignaci??n de unidades a rutas/zonas por turno';


--
-- Name: COLUMN asignacion_unidad.sentido; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.asignacion_unidad.sentido IS 'Sentido de recorrido: NORTE, SUR, ORIENTE, OCCIDENTE';


--
-- Name: COLUMN asignacion_unidad.acciones; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.asignacion_unidad.acciones IS 'Instrucciones espec??ficas para la unidad en este turno';


--
-- Name: COLUMN asignacion_unidad.km_recorridos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.asignacion_unidad.km_recorridos IS 'Kilometraje recorrido durante el turno';


--
-- Name: COLUMN asignacion_unidad.dia_cerrado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.asignacion_unidad.dia_cerrado IS 'True si el d??a operativo de esta asignaci??n ya fue cerrado';


--
-- Name: COLUMN asignacion_unidad.fecha_cierre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.asignacion_unidad.fecha_cierre IS 'Timestamp de cu??ndo se cerr?? el d??a';


--
-- Name: COLUMN asignacion_unidad.cerrado_por; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.asignacion_unidad.cerrado_por IS 'Usuario que cerr?? el d??a (autom??tico o manual)';


--
-- Name: COLUMN asignacion_unidad.modificado_despues_cierre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.asignacion_unidad.modificado_despues_cierre IS 'True si fue modificado despu??s de que el d??a fue cerrado';


--
-- Name: COLUMN asignacion_unidad.motivo_modificacion_cierre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.asignacion_unidad.motivo_modificacion_cierre IS 'Motivo de la modificaci??n post-cierre';


--
-- Name: COLUMN asignacion_unidad.ruta_activa_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.asignacion_unidad.ruta_activa_id IS 'Ruta actualmente activa para esta asignación (se define en SALIDA_SEDE o CAMBIO_RUTA)';


--
-- Name: COLUMN asignacion_unidad.hora_ultima_actualizacion_ruta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.asignacion_unidad.hora_ultima_actualizacion_ruta IS 'Última vez que se actualizó la ruta activa';


--
-- Name: COLUMN asignacion_unidad.notificacion_enviada; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.asignacion_unidad.notificacion_enviada IS 'Si ya se notific?? a la tripulaci??n de esta asignaci??n';


--
-- Name: COLUMN asignacion_unidad.es_reaccion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.asignacion_unidad.es_reaccion IS 'Indica si la unidad es de reaccion (sin ruta fija inicial)';


--
-- Name: COLUMN asignacion_unidad.acciones_formato; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.asignacion_unidad.acciones_formato IS 'Acciones con formato HTML básico (negrita, colores)';


--
-- Name: asignacion_unidad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.asignacion_unidad_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: asignacion_unidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.asignacion_unidad_id_seq OWNED BY public.asignacion_unidad.id;


--
-- Name: auditoria_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.auditoria_log (
    id bigint NOT NULL,
    usuario_id integer,
    accion character varying(50) NOT NULL,
    tabla_afectada character varying(100),
    registro_id bigint,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    ip_address character varying(45),
    user_agent text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT auditoria_log_accion_check CHECK (((accion)::text = ANY (ARRAY[('INSERT'::character varying)::text, ('UPDATE'::character varying)::text, ('DELETE'::character varying)::text, ('LOGIN'::character varying)::text, ('LOGOUT'::character varying)::text, ('EXPORT'::character varying)::text, ('OTHER'::character varying)::text])))
);


--
-- Name: TABLE auditoria_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.auditoria_log IS 'Log de auditor??a de todas las acciones importantes del sistema';


--
-- Name: COLUMN auditoria_log.datos_anteriores; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auditoria_log.datos_anteriores IS 'Estado del registro antes del cambio';


--
-- Name: COLUMN auditoria_log.datos_nuevos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.auditoria_log.datos_nuevos IS 'Estado del registro despu??s del cambio';


--
-- Name: auditoria_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.auditoria_log_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: auditoria_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.auditoria_log_id_seq OWNED BY public.auditoria_log.id;


--
-- Name: autoridad_situacion_persistente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.autoridad_situacion_persistente (
    id integer NOT NULL,
    situacion_persistente_id integer NOT NULL,
    tipo_autoridad character varying(50) NOT NULL,
    hora_llegada time without time zone,
    nip_chapa character varying(50),
    numero_unidad character varying(50),
    nombre_comandante character varying(150),
    cantidad_elementos integer,
    subestacion character varying(100),
    cantidad_unidades integer,
    observaciones text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE autoridad_situacion_persistente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.autoridad_situacion_persistente IS 'Autoridades presentes en situaciones persistentes (PMT, PNC, DGT, etc.)';


--
-- Name: autoridad_situacion_persistente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.autoridad_situacion_persistente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: autoridad_situacion_persistente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.autoridad_situacion_persistente_id_seq OWNED BY public.autoridad_situacion_persistente.id;


--
-- Name: aviso_asignacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.aviso_asignacion (
    id integer NOT NULL,
    asignacion_id integer NOT NULL,
    tipo character varying(30) NOT NULL,
    mensaje text NOT NULL,
    color character varying(7) DEFAULT '#f59e0b'::character varying,
    creado_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE aviso_asignacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.aviso_asignacion IS 'Avisos/advertencias especiales en asignaciones';


--
-- Name: aviso_asignacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.aviso_asignacion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: aviso_asignacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.aviso_asignacion_id_seq OWNED BY public.aviso_asignacion.id;


--
-- Name: bitacora_historica; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bitacora_historica (
    id bigint NOT NULL,
    fecha date NOT NULL,
    unidad_id integer NOT NULL,
    salida_id integer,
    sede_origen_id integer,
    ruta_inicial_id integer,
    km_inicial numeric(10,2),
    km_final numeric(10,2),
    km_recorridos numeric(10,2),
    combustible_inicial numeric(5,2),
    combustible_final numeric(5,2),
    hora_inicio timestamp with time zone NOT NULL,
    hora_fin timestamp with time zone,
    duracion_minutos integer,
    tripulacion_ids jsonb DEFAULT '[]'::jsonb NOT NULL,
    situaciones_resumen jsonb DEFAULT '[]'::jsonb NOT NULL,
    total_situaciones integer DEFAULT 0,
    ingresos_resumen jsonb DEFAULT '[]'::jsonb NOT NULL,
    total_ingresos integer DEFAULT 0,
    total_incidentes integer DEFAULT 0,
    total_asistencias integer DEFAULT 0,
    total_emergencias integer DEFAULT 0,
    total_regulaciones integer DEFAULT 0,
    total_patrullajes integer DEFAULT 0,
    observaciones_inicio text,
    observaciones_fin text,
    finalizado_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
)
PARTITION BY RANGE (fecha);


--
-- Name: TABLE bitacora_historica; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.bitacora_historica IS 'Tabla histórica optimizada para almacenar años de jornadas laborales finalizadas';


--
-- Name: COLUMN bitacora_historica.tripulacion_ids; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bitacora_historica.tripulacion_ids IS 'Array de referencias a usuarios, formato: [{"usuario_id": X, "rol": "PILOTO"}]';


--
-- Name: COLUMN bitacora_historica.situaciones_resumen; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bitacora_historica.situaciones_resumen IS 'Resumen compacto de situaciones del día, solo IDs y datos esenciales';


--
-- Name: COLUMN bitacora_historica.ingresos_resumen; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.bitacora_historica.ingresos_resumen IS 'Resumen compacto de ingresos a sede del día';


--
-- Name: bitacora_historica_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bitacora_historica_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bitacora_historica_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bitacora_historica_id_seq OWNED BY public.bitacora_historica.id;


--
-- Name: bitacora_historica_2024; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bitacora_historica_2024 (
    id bigint DEFAULT nextval('public.bitacora_historica_id_seq'::regclass) NOT NULL,
    fecha date NOT NULL,
    unidad_id integer NOT NULL,
    salida_id integer,
    sede_origen_id integer,
    ruta_inicial_id integer,
    km_inicial numeric(10,2),
    km_final numeric(10,2),
    km_recorridos numeric(10,2),
    combustible_inicial numeric(5,2),
    combustible_final numeric(5,2),
    hora_inicio timestamp with time zone NOT NULL,
    hora_fin timestamp with time zone,
    duracion_minutos integer,
    tripulacion_ids jsonb DEFAULT '[]'::jsonb NOT NULL,
    situaciones_resumen jsonb DEFAULT '[]'::jsonb NOT NULL,
    total_situaciones integer DEFAULT 0,
    ingresos_resumen jsonb DEFAULT '[]'::jsonb NOT NULL,
    total_ingresos integer DEFAULT 0,
    total_incidentes integer DEFAULT 0,
    total_asistencias integer DEFAULT 0,
    total_emergencias integer DEFAULT 0,
    total_regulaciones integer DEFAULT 0,
    total_patrullajes integer DEFAULT 0,
    observaciones_inicio text,
    observaciones_fin text,
    finalizado_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: bitacora_historica_2025; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bitacora_historica_2025 (
    id bigint DEFAULT nextval('public.bitacora_historica_id_seq'::regclass) NOT NULL,
    fecha date NOT NULL,
    unidad_id integer NOT NULL,
    salida_id integer,
    sede_origen_id integer,
    ruta_inicial_id integer,
    km_inicial numeric(10,2),
    km_final numeric(10,2),
    km_recorridos numeric(10,2),
    combustible_inicial numeric(5,2),
    combustible_final numeric(5,2),
    hora_inicio timestamp with time zone NOT NULL,
    hora_fin timestamp with time zone,
    duracion_minutos integer,
    tripulacion_ids jsonb DEFAULT '[]'::jsonb NOT NULL,
    situaciones_resumen jsonb DEFAULT '[]'::jsonb NOT NULL,
    total_situaciones integer DEFAULT 0,
    ingresos_resumen jsonb DEFAULT '[]'::jsonb NOT NULL,
    total_ingresos integer DEFAULT 0,
    total_incidentes integer DEFAULT 0,
    total_asistencias integer DEFAULT 0,
    total_emergencias integer DEFAULT 0,
    total_regulaciones integer DEFAULT 0,
    total_patrullajes integer DEFAULT 0,
    observaciones_inicio text,
    observaciones_fin text,
    finalizado_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: bitacora_historica_2026; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bitacora_historica_2026 (
    id bigint DEFAULT nextval('public.bitacora_historica_id_seq'::regclass) NOT NULL,
    fecha date NOT NULL,
    unidad_id integer NOT NULL,
    salida_id integer,
    sede_origen_id integer,
    ruta_inicial_id integer,
    km_inicial numeric(10,2),
    km_final numeric(10,2),
    km_recorridos numeric(10,2),
    combustible_inicial numeric(5,2),
    combustible_final numeric(5,2),
    hora_inicio timestamp with time zone NOT NULL,
    hora_fin timestamp with time zone,
    duracion_minutos integer,
    tripulacion_ids jsonb DEFAULT '[]'::jsonb NOT NULL,
    situaciones_resumen jsonb DEFAULT '[]'::jsonb NOT NULL,
    total_situaciones integer DEFAULT 0,
    ingresos_resumen jsonb DEFAULT '[]'::jsonb NOT NULL,
    total_ingresos integer DEFAULT 0,
    total_incidentes integer DEFAULT 0,
    total_asistencias integer DEFAULT 0,
    total_emergencias integer DEFAULT 0,
    total_regulaciones integer DEFAULT 0,
    total_patrullajes integer DEFAULT 0,
    observaciones_inicio text,
    observaciones_fin text,
    finalizado_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: brigada; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.brigada (
    id integer NOT NULL,
    codigo character varying(20) NOT NULL,
    nombre character varying(100) NOT NULL,
    sede_id integer NOT NULL,
    activa boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    fecha_nacimiento date,
    licencia_tipo character varying(5),
    licencia_numero character varying(30),
    licencia_vencimiento date,
    telefono character varying(20),
    email character varying(100),
    direccion text,
    contacto_emergencia character varying(150),
    telefono_emergencia character varying(20),
    usuario_id integer
);


--
-- Name: TABLE brigada; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.brigada IS 'Brigadas de trabajo';


--
-- Name: brigada_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.brigada_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brigada_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.brigada_id_seq OWNED BY public.brigada.id;


--
-- Name: brigada_unidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.brigada_unidad (
    id integer NOT NULL,
    brigada_id integer NOT NULL,
    unidad_id integer NOT NULL,
    rol_tripulacion character varying(30) NOT NULL,
    fecha_asignacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_fin timestamp with time zone,
    activo boolean DEFAULT true NOT NULL,
    observaciones text,
    asignado_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    es_comandante boolean DEFAULT false NOT NULL,
    CONSTRAINT brigada_unidad_rol_tripulacion_check CHECK (((rol_tripulacion)::text = ANY (ARRAY[('PILOTO'::character varying)::text, ('COPILOTO'::character varying)::text, ('ACOMPA??ANTE'::character varying)::text])))
);


--
-- Name: TABLE brigada_unidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.brigada_unidad IS 'Asignaciones permanentes de brigadistas a unidades';


--
-- Name: COLUMN brigada_unidad.fecha_fin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.brigada_unidad.fecha_fin IS 'Fecha en que finaliz?? la asignaci??n (por reasignaci??n, baja, etc.)';


--
-- Name: COLUMN brigada_unidad.activo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.brigada_unidad.activo IS 'TRUE = asignaci??n vigente, FALSE = terminada';


--
-- Name: COLUMN brigada_unidad.es_comandante; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.brigada_unidad.es_comandante IS 'TRUE = es el comandante responsable de la unidad';


--
-- Name: brigada_unidad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.brigada_unidad_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: brigada_unidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.brigada_unidad_id_seq OWNED BY public.brigada_unidad.id;


--
-- Name: bus; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bus (
    id integer NOT NULL,
    vehiculo_id integer NOT NULL,
    empresa character varying(255),
    ruta_bus character varying(100),
    numero_unidad character varying(50),
    capacidad_pasajeros integer,
    fecha_registro timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE bus; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.bus IS 'Datos de buses extraurbanos vinculados a veh??culos';


--
-- Name: bus_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bus_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bus_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bus_id_seq OWNED BY public.bus.id;


--
-- Name: calendario_grupo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calendario_grupo (
    id integer NOT NULL,
    grupo smallint NOT NULL,
    fecha date NOT NULL,
    estado character varying(20) NOT NULL,
    observaciones text,
    creado_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT calendario_grupo_estado_check CHECK (((estado)::text = ANY (ARRAY[('TRABAJO'::character varying)::text, ('DESCANSO'::character varying)::text]))),
    CONSTRAINT calendario_grupo_grupo_check CHECK ((grupo = ANY (ARRAY[1, 2])))
);


--
-- Name: TABLE calendario_grupo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.calendario_grupo IS 'Calendario de trabajo/descanso por grupo de brigadas';


--
-- Name: COLUMN calendario_grupo.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.calendario_grupo.estado IS 'TRABAJO: Grupo de turno | DESCANSO: Grupo descansando';


--
-- Name: calendario_grupo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.calendario_grupo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: calendario_grupo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.calendario_grupo_id_seq OWNED BY public.calendario_grupo.id;


--
-- Name: campo_personalizado; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.campo_personalizado (
    id integer NOT NULL,
    tabla_destino character varying(50) NOT NULL,
    clave character varying(50) NOT NULL,
    etiqueta character varying(100) NOT NULL,
    tipo character varying(20) DEFAULT 'text'::character varying,
    opciones jsonb,
    orden integer DEFAULT 0,
    activo boolean DEFAULT true,
    creado_por integer,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: campo_personalizado_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.campo_personalizado_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: campo_personalizado_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.campo_personalizado_id_seq OWNED BY public.campo_personalizado.id;


--
-- Name: catalogo_motivo_inactividad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.catalogo_motivo_inactividad (
    id integer NOT NULL,
    codigo character varying(50) NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    requiere_fecha_fin boolean DEFAULT false,
    activo boolean DEFAULT true,
    orden integer DEFAULT 0
);


--
-- Name: TABLE catalogo_motivo_inactividad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.catalogo_motivo_inactividad IS 'Catálogo de motivos de inactividad/desactivación';


--
-- Name: catalogo_motivo_inactividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.catalogo_motivo_inactividad_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: catalogo_motivo_inactividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.catalogo_motivo_inactividad_id_seq OWNED BY public.catalogo_motivo_inactividad.id;


--
-- Name: combustible_registro; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.combustible_registro (
    id bigint NOT NULL,
    unidad_id integer NOT NULL,
    asignacion_id integer,
    turno_id integer,
    tipo character varying(30) NOT NULL,
    combustible_anterior numeric(6,2) NOT NULL,
    combustible_agregado numeric(6,2) DEFAULT 0,
    combustible_nuevo numeric(6,2) NOT NULL,
    combustible_consumido numeric(6,2),
    odometro_anterior numeric(10,2),
    odometro_actual numeric(10,2),
    km_recorridos numeric(8,2),
    rendimiento_km_litro numeric(6,2),
    observaciones text,
    registrado_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT combustible_registro_tipo_check CHECK (((tipo)::text = ANY (ARRAY[('INICIAL'::character varying)::text, ('RECARGA'::character varying)::text, ('FINAL'::character varying)::text, ('AJUSTE'::character varying)::text])))
);


--
-- Name: TABLE combustible_registro; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.combustible_registro IS 'Historial detallado de combustible por unidad y turno';


--
-- Name: COLUMN combustible_registro.tipo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.combustible_registro.tipo IS 'INICIAL: al iniciar turno | RECARGA: durante turno | FINAL: al terminar turno | AJUSTE: correcci??n manual';


--
-- Name: COLUMN combustible_registro.rendimiento_km_litro; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.combustible_registro.rendimiento_km_litro IS 'Rendimiento calculado (km_recorridos / combustible_consumido)';


--
-- Name: combustible_registro_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.combustible_registro_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: combustible_registro_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.combustible_registro_id_seq OWNED BY public.combustible_registro.id;


--
-- Name: configuracion_alerta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configuracion_alerta (
    id integer NOT NULL,
    tipo public.tipo_alerta NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    severidad_default public.severidad_alerta DEFAULT 'MEDIA'::public.severidad_alerta,
    activa boolean DEFAULT true,
    tiempo_inactividad_minutos integer DEFAULT 60,
    umbral_combustible numeric(5,2) DEFAULT 20.00,
    umbral_km integer DEFAULT 5000,
    notificar_push boolean DEFAULT true,
    notificar_email boolean DEFAULT false,
    notificar_sms boolean DEFAULT false,
    roles_destino text[] DEFAULT ARRAY['COP'::text, 'OPERACIONES'::text, 'ADMIN'::text],
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE configuracion_alerta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.configuracion_alerta IS 'Configuración de tipos de alerta';


--
-- Name: configuracion_alerta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.configuracion_alerta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configuracion_alerta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.configuracion_alerta_id_seq OWNED BY public.configuracion_alerta.id;


--
-- Name: configuracion_columnas_tabla; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configuracion_columnas_tabla (
    id integer NOT NULL,
    sede_id integer,
    tabla_nombre character varying(50) NOT NULL,
    columnas_visibles jsonb DEFAULT '[]'::jsonb NOT NULL,
    orden_columnas text[] DEFAULT '{}'::text[],
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    creado_por integer
);


--
-- Name: TABLE configuracion_columnas_tabla; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.configuracion_columnas_tabla IS 'Configuracion de columnas visibles por sede para tablas de brigadas y unidades.

COLUMNAS DISPONIBLES BRIGADAS:
- chapa: Numero de identificacion
- nombre: Nombre completo
- rol_brigada: Rol (PILOTO, COPILOTO, ACOMPANANTE)
- grupo: Grupo de trabajo (0, 1, 2)
- sede: Sede asignada
- telefono: Numero de telefono
- email: Correo electronico
- estado: Activo/Inactivo
- created_at: Fecha de creacion
- ultimo_acceso: Ultimo acceso al sistema

COLUMNAS DISPONIBLES UNIDADES:
- codigo: Codigo de la unidad
- tipo_unidad: Tipo (MOTORIZADA, PICKUP, etc.)
- marca: Marca del vehiculo
- modelo: Modelo del vehiculo
- anio: Anio del vehiculo
- placa: Numero de placa
- sede: Sede asignada
- estado: Activo/Inactivo
- created_at: Fecha de creacion
';


--
-- Name: configuracion_columnas_tabla_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.configuracion_columnas_tabla_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configuracion_columnas_tabla_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.configuracion_columnas_tabla_id_seq OWNED BY public.configuracion_columnas_tabla.id;


--
-- Name: configuracion_sistema; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configuracion_sistema (
    id integer NOT NULL,
    clave character varying(100) NOT NULL,
    valor text,
    tipo character varying(20) DEFAULT 'string'::character varying,
    descripcion text,
    categoria character varying(50) DEFAULT 'general'::character varying,
    modificado_por integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: configuracion_sistema_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.configuracion_sistema_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configuracion_sistema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.configuracion_sistema_id_seq OWNED BY public.configuracion_sistema.id;


--
-- Name: configuracion_visual_sede; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.configuracion_visual_sede (
    id integer NOT NULL,
    sede_id integer NOT NULL,
    color_fondo character varying(7) DEFAULT '#ffffff'::character varying,
    color_fondo_header character varying(7) DEFAULT '#f3f4f6'::character varying,
    color_texto character varying(7) DEFAULT '#1f2937'::character varying,
    color_acento character varying(7) DEFAULT '#3b82f6'::character varying,
    fuente character varying(50) DEFAULT 'Inter'::character varying,
    tamano_fuente character varying(10) DEFAULT 'normal'::character varying,
    alerta_rotacion_rutas_activa boolean DEFAULT true,
    umbral_rotacion_rutas integer DEFAULT 3,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    requiere_tripulacion boolean DEFAULT true
);


--
-- Name: TABLE configuracion_visual_sede; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.configuracion_visual_sede IS 'Personalización visual del dashboard por sede';


--
-- Name: configuracion_visual_sede_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.configuracion_visual_sede_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: configuracion_visual_sede_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.configuracion_visual_sede_id_seq OWNED BY public.configuracion_visual_sede.id;


--
-- Name: contenedor; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.contenedor (
    id integer NOT NULL,
    vehiculo_id integer NOT NULL,
    numero_contenedor character varying(50),
    linea_naviera character varying(100),
    tipo_contenedor character varying(50),
    fecha_registro timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE contenedor; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.contenedor IS 'Datos de contenedores/remolques vinculados a veh??culos';


--
-- Name: contenedor_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.contenedor_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: contenedor_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.contenedor_id_seq OWNED BY public.contenedor.id;


--
-- Name: control_acceso_app; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.control_acceso_app (
    id integer NOT NULL,
    usuario_id integer,
    grupo smallint,
    unidad_id integer,
    sede_id integer,
    acceso_permitido boolean DEFAULT true NOT NULL,
    motivo text,
    fecha_inicio date NOT NULL,
    fecha_fin date,
    creado_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT control_acceso_app_check CHECK (((usuario_id IS NOT NULL) OR (grupo IS NOT NULL) OR (unidad_id IS NOT NULL) OR (sede_id IS NOT NULL))),
    CONSTRAINT control_acceso_app_grupo_check CHECK ((grupo = ANY (ARRAY[1, 2])))
);


--
-- Name: control_acceso_app_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.control_acceso_app_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: control_acceso_app_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.control_acceso_app_id_seq OWNED BY public.control_acceso_app.id;


--
-- Name: departamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departamento (
    id integer NOT NULL,
    codigo character varying(2) NOT NULL,
    nombre character varying(100) NOT NULL,
    nombre_completo character varying(150),
    region character varying(50),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE departamento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.departamento IS 'Departamentos de Guatemala (22 total)';


--
-- Name: COLUMN departamento.codigo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.departamento.codigo IS 'C??digo oficial del departamento (01-22)';


--
-- Name: COLUMN departamento.region; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.departamento.region IS 'Regi??n geogr??fica a la que pertenece';


--
-- Name: departamento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.departamento_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: departamento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.departamento_id_seq OWNED BY public.departamento.id;


--
-- Name: departamento_sistema; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.departamento_sistema (
    id integer NOT NULL,
    codigo character varying(30) NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    usa_sistema_grupos boolean DEFAULT true,
    orden integer DEFAULT 0,
    activo boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: departamento_sistema_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.departamento_sistema_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: departamento_sistema_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.departamento_sistema_id_seq OWNED BY public.departamento_sistema.id;


--
-- Name: detalle_situacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.detalle_situacion (
    id bigint NOT NULL,
    situacion_id bigint NOT NULL,
    tipo_detalle character varying(50) NOT NULL,
    datos jsonb NOT NULL,
    creado_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT detalle_situacion_tipo_detalle_check CHECK (((tipo_detalle)::text = ANY (ARRAY['VEHICULO'::text, 'AUTORIDAD'::text, 'RECURSO'::text, 'VICTIMA'::text, 'GRUA'::text, 'ASEGURADORA'::text, 'AJUSTADOR'::text, 'TESTIGO'::text, 'EVIDENCIA'::text, 'OBSTRUCCION'::text, 'AUTORIDADES_SOCORRO'::text, 'DANIOS'::text, 'SUBTIPO'::text, 'OTROS'::text])))
);


--
-- Name: TABLE detalle_situacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.detalle_situacion IS 'Detalles espec??ficos de situaciones (veh??culos, autoridades, recursos, etc.)';


--
-- Name: COLUMN detalle_situacion.tipo_detalle; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.detalle_situacion.tipo_detalle IS 'Tipo de detalle asociado a la situaci??n';


--
-- Name: COLUMN detalle_situacion.datos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.detalle_situacion.datos IS 'Datos flexibles en JSON seg??n el tipo de detalle';


--
-- Name: detalle_situacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.detalle_situacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: detalle_situacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.detalle_situacion_id_seq OWNED BY public.detalle_situacion.id;


--
-- Name: dispositivo_push; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dispositivo_push (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    push_token character varying(255) NOT NULL,
    plataforma character varying(20) NOT NULL,
    modelo_dispositivo character varying(100),
    version_app character varying(20),
    activo boolean DEFAULT true,
    ultimo_uso timestamp with time zone DEFAULT now(),
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now(),
    CONSTRAINT dispositivo_push_plataforma_check CHECK (((plataforma)::text = ANY ((ARRAY['ios'::character varying, 'android'::character varying, 'web'::character varying])::text[])))
);


--
-- Name: TABLE dispositivo_push; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.dispositivo_push IS 'Tokens de dispositivos para notificaciones push (Expo Push Notifications)';


--
-- Name: dispositivo_push_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dispositivo_push_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dispositivo_push_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dispositivo_push_id_seq OWNED BY public.dispositivo_push.id;


--
-- Name: estado_grupo_departamento; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.estado_grupo_departamento (
    id integer NOT NULL,
    departamento_id integer NOT NULL,
    sede_id integer,
    grupo smallint NOT NULL,
    activo boolean DEFAULT true,
    modificado_por integer,
    fecha_modificacion timestamp with time zone DEFAULT now(),
    observaciones text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT estado_grupo_departamento_grupo_check CHECK ((grupo = ANY (ARRAY[0, 1, 2])))
);


--
-- Name: estado_grupo_departamento_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.estado_grupo_departamento_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: estado_grupo_departamento_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.estado_grupo_departamento_id_seq OWNED BY public.estado_grupo_departamento.id;


--
-- Name: evento_persistente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.evento_persistente (
    id integer NOT NULL,
    titulo character varying(200) NOT NULL,
    descripcion text,
    tipo character varying(50) DEFAULT 'OTRO'::character varying NOT NULL,
    importancia character varying(20) DEFAULT 'MEDIA'::character varying NOT NULL,
    estado character varying(20) DEFAULT 'ACTIVO'::character varying NOT NULL,
    ruta_id integer,
    km_inicio numeric(10,2),
    km_fin numeric(10,2),
    latitud numeric(10,6),
    longitud numeric(10,6),
    punto_referencia text,
    fecha_inicio timestamp with time zone DEFAULT now(),
    fecha_fin_estimada timestamp with time zone,
    fecha_resolucion timestamp with time zone,
    creado_por integer,
    resuelto_por integer,
    observaciones text,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: TABLE evento_persistente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.evento_persistente IS 'Eventos de larga duración que requieren seguimiento continuo';


--
-- Name: COLUMN evento_persistente.importancia; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.evento_persistente.importancia IS 'Nivel de importancia: BAJA, MEDIA, ALTA, CRITICA';


--
-- Name: COLUMN evento_persistente.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.evento_persistente.estado IS 'Estado del evento: ACTIVO, RESUELTO, CANCELADO';


--
-- Name: evento_persistente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.evento_persistente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: evento_persistente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.evento_persistente_id_seq OWNED BY public.evento_persistente.id;


--
-- Name: grua; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grua (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    placa character varying(20),
    telefono character varying(50),
    empresa character varying(255),
    nit bigint,
    total_servicios integer DEFAULT 0,
    ultima_vez_usado timestamp with time zone,
    activa boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE grua; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.grua IS 'Tabla maestra de gr??as. Cat??logo reutilizable.';


--
-- Name: grua_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grua_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grua_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.grua_id_seq OWNED BY public.grua.id;


--
-- Name: grua_involucrada; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.grua_involucrada (
    id integer NOT NULL,
    incidente_id integer,
    vehiculo_asignado_id integer,
    tipo character varying(100),
    placa character varying(20),
    empresa character varying(255),
    piloto character varying(255),
    color character varying(100),
    marca character varying(100),
    traslado boolean DEFAULT false,
    traslado_a character varying(255),
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: grua_involucrada_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.grua_involucrada_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: grua_involucrada_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.grua_involucrada_id_seq OWNED BY public.grua_involucrada.id;


--
-- Name: historial_encargado_sede_grupo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.historial_encargado_sede_grupo (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    sede_id integer NOT NULL,
    grupo smallint NOT NULL,
    fecha_inicio date DEFAULT CURRENT_DATE NOT NULL,
    fecha_fin date,
    asignado_por integer,
    removido_por integer,
    motivo_asignacion text,
    motivo_remocion text,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT historial_encargado_sede_grupo_grupo_check CHECK ((grupo = ANY (ARRAY[0, 1, 2])))
);


--
-- Name: historial_encargado_sede_grupo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.historial_encargado_sede_grupo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: historial_encargado_sede_grupo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.historial_encargado_sede_grupo_id_seq OWNED BY public.historial_encargado_sede_grupo.id;


--
-- Name: historial_ruta_brigada; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.historial_ruta_brigada (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    ruta_id integer NOT NULL,
    fecha date NOT NULL,
    turno_id integer,
    asignacion_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE historial_ruta_brigada; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.historial_ruta_brigada IS 'Historial para alertas de rotación de rutas';


--
-- Name: historial_ruta_brigada_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.historial_ruta_brigada_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: historial_ruta_brigada_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.historial_ruta_brigada_id_seq OWNED BY public.historial_ruta_brigada.id;


--
-- Name: historial_situacion_brigada; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.historial_situacion_brigada (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    situacion_fija_id integer NOT NULL,
    fecha date NOT NULL,
    turno_id integer,
    asignacion_id integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE historial_situacion_brigada; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.historial_situacion_brigada IS 'Historial para alertas de rotación de situaciones';


--
-- Name: historial_situacion_brigada_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.historial_situacion_brigada_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: historial_situacion_brigada_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.historial_situacion_brigada_id_seq OWNED BY public.historial_situacion_brigada.id;


--
-- Name: hoja_accidentologia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.hoja_accidentologia (
    id integer NOT NULL,
    situacion_id integer NOT NULL,
    tipo_accidente public.tipo_accidente NOT NULL,
    descripcion_accidente text,
    condiciones_climaticas character varying(50),
    condiciones_via character varying(50),
    iluminacion character varying(30),
    visibilidad character varying(30),
    kilometro numeric(10,2),
    referencia_ubicacion text,
    sentido_via character varying(50),
    tipo_zona character varying(30),
    causa_principal text,
    causas_contribuyentes text[],
    pnc_presente boolean DEFAULT false,
    pnc_agente character varying(100),
    bomberos_presente boolean DEFAULT false,
    bomberos_unidad character varying(50),
    mp_presente boolean DEFAULT false,
    mp_fiscal character varying(100),
    otras_autoridades text,
    requiere_peritaje boolean DEFAULT false,
    numero_caso_pnc character varying(50),
    numero_caso_mp character varying(50),
    elaborado_por integer,
    revisado_por integer,
    fecha_elaboracion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    estado character varying(20) DEFAULT 'BORRADOR'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE hoja_accidentologia; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.hoja_accidentologia IS 'Hoja de accidentología con datos completos del accidente';


--
-- Name: hoja_accidentologia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.hoja_accidentologia_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: hoja_accidentologia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.hoja_accidentologia_id_seq OWNED BY public.hoja_accidentologia.id;


--
-- Name: incidente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incidente (
    id bigint NOT NULL,
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    numero_reporte character varying(50),
    origen character varying(30) NOT NULL,
    estado character varying(30) DEFAULT 'REPORTADO'::character varying NOT NULL,
    tipo_hecho_id integer NOT NULL,
    subtipo_hecho_id integer,
    ruta_id integer NOT NULL,
    km numeric(6,2) NOT NULL,
    sentido character varying(30),
    referencia_ubicacion text,
    latitud numeric(10,8),
    longitud numeric(11,8),
    unidad_id integer,
    brigada_id integer,
    fecha_hora_aviso timestamp with time zone NOT NULL,
    fecha_hora_asignacion timestamp with time zone,
    fecha_hora_llegada timestamp with time zone,
    fecha_hora_estabilizacion timestamp with time zone,
    fecha_hora_finalizacion timestamp with time zone,
    hay_heridos boolean DEFAULT false NOT NULL,
    cantidad_heridos integer DEFAULT 0 NOT NULL,
    hay_fallecidos boolean DEFAULT false NOT NULL,
    cantidad_fallecidos integer DEFAULT 0 NOT NULL,
    requiere_bomberos boolean DEFAULT false NOT NULL,
    requiere_pnc boolean DEFAULT false NOT NULL,
    requiere_ambulancia boolean DEFAULT false NOT NULL,
    observaciones_iniciales text,
    observaciones_finales text,
    condiciones_climaticas character varying(50),
    tipo_pavimento character varying(50),
    iluminacion character varying(50),
    senalizacion character varying(50),
    visibilidad character varying(50),
    causa_probable text,
    reportado_por_nombre character varying(150),
    reportado_por_telefono character varying(20),
    reportado_por_email character varying(100),
    foto_url text,
    creado_por integer NOT NULL,
    actualizado_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    asignacion_id integer,
    departamento_id integer,
    municipio_id integer,
    jurisdiccion character varying(255),
    direccion_detallada text,
    obstruccion_detalle jsonb,
    danios_infraestructura_desc text,
    danios_materiales boolean DEFAULT false,
    danios_infraestructura boolean DEFAULT false,
    obstruccion_data jsonb,
    CONSTRAINT chk_fallecidos CHECK ((((hay_fallecidos = false) AND (cantidad_fallecidos = 0)) OR ((hay_fallecidos = true) AND (cantidad_fallecidos > 0)))),
    CONSTRAINT chk_fechas_cronologicas CHECK ((((fecha_hora_llegada IS NULL) OR (fecha_hora_llegada >= fecha_hora_aviso)) AND ((fecha_hora_finalizacion IS NULL) OR (fecha_hora_finalizacion >= fecha_hora_aviso)))),
    CONSTRAINT chk_heridos CHECK ((((hay_heridos = false) AND (cantidad_heridos = 0)) OR ((hay_heridos = true) AND (cantidad_heridos > 0)))),
    CONSTRAINT incidente_estado_check CHECK (((estado)::text = ANY (ARRAY[('REPORTADO'::character varying)::text, ('EN_ATENCION'::character varying)::text, ('REGULACION'::character varying)::text, ('CERRADO'::character varying)::text, ('NO_ATENDIDO'::character varying)::text]))),
    CONSTRAINT incidente_origen_check CHECK (((origen)::text = ANY (ARRAY[('BRIGADA'::character varying)::text, ('USUARIO_PUBLICO'::character varying)::text, ('CENTRO_CONTROL'::character varying)::text]))),
    CONSTRAINT incidente_sentido_check CHECK (((sentido)::text = ANY (ARRAY[('NORTE'::character varying)::text, ('SUR'::character varying)::text, ('ESTE'::character varying)::text, ('OESTE'::character varying)::text, ('ASCENDENTE'::character varying)::text, ('DESCENDENTE'::character varying)::text])))
);


--
-- Name: TABLE incidente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.incidente IS 'Tabla principal de incidentes/hechos viales';


--
-- Name: COLUMN incidente.numero_reporte; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.incidente.numero_reporte IS 'N??mero ??nico legible (ej: INC-2025-0001)';


--
-- Name: COLUMN incidente.origen; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.incidente.origen IS 'Qui??n report?? el incidente';


--
-- Name: COLUMN incidente.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.incidente.estado IS 'Estado actual del incidente';


--
-- Name: COLUMN incidente.asignacion_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.incidente.asignacion_id IS 'Asignaci??n de la unidad que atendi?? (si aplica)';


--
-- Name: COLUMN incidente.departamento_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.incidente.departamento_id IS 'Departamento donde ocurri?? el incidente';


--
-- Name: COLUMN incidente.municipio_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.incidente.municipio_id IS 'Municipio donde ocurri?? el incidente';


--
-- Name: COLUMN incidente.obstruccion_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.incidente.obstruccion_data IS 'Datos de obstrucci??n en formato JSON v2';


--
-- Name: incidente_grua; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incidente_grua (
    id integer NOT NULL,
    incidente_id integer NOT NULL,
    grua_id integer NOT NULL,
    hora_llamada time without time zone,
    hora_llegada time without time zone,
    destino text,
    costo numeric(10,2),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE incidente_grua; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.incidente_grua IS 'Relaci??n many-to-many entre incidentes y gr??as';


--
-- Name: incidente_grua_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incidente_grua_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incidente_grua_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incidente_grua_id_seq OWNED BY public.incidente_grua.id;


--
-- Name: incidente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incidente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incidente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incidente_id_seq OWNED BY public.incidente.id;


--
-- Name: incidente_no_atendido; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incidente_no_atendido (
    id bigint NOT NULL,
    incidente_id bigint NOT NULL,
    motivo_id integer NOT NULL,
    observaciones text,
    registrado_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE incidente_no_atendido; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.incidente_no_atendido IS 'Informaci??n de incidentes que no fueron atendidos (relaci??n 1:1)';


--
-- Name: incidente_no_atendido_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incidente_no_atendido_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incidente_no_atendido_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incidente_no_atendido_id_seq OWNED BY public.incidente_no_atendido.id;


--
-- Name: incidente_vehiculo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.incidente_vehiculo (
    id integer NOT NULL,
    incidente_id integer NOT NULL,
    vehiculo_id integer NOT NULL,
    piloto_id integer,
    estado_piloto character varying(50),
    personas_asistidas integer DEFAULT 0,
    aseguradora_id integer,
    numero_poliza character varying(100),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE incidente_vehiculo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.incidente_vehiculo IS 'Relaci??n many-to-many entre incidentes y veh??culos';


--
-- Name: incidente_vehiculo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.incidente_vehiculo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incidente_vehiculo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.incidente_vehiculo_id_seq OWNED BY public.incidente_vehiculo.id;


--
-- Name: ingreso_sede; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ingreso_sede (
    id integer NOT NULL,
    salida_unidad_id integer NOT NULL,
    sede_id integer NOT NULL,
    fecha_hora_ingreso timestamp with time zone DEFAULT now() NOT NULL,
    fecha_hora_salida timestamp with time zone,
    tipo_ingreso character varying(30) NOT NULL,
    km_ingreso integer,
    combustible_ingreso numeric(5,2),
    km_salida_nueva integer,
    combustible_salida_nueva numeric(5,2),
    observaciones_ingreso text,
    observaciones_salida text,
    es_ingreso_final boolean DEFAULT false NOT NULL,
    registrado_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ingreso_sede_tipo_ingreso_check CHECK (((tipo_ingreso)::text = ANY ((ARRAY['COMBUSTIBLE'::character varying, 'COMISION'::character varying, 'APOYO'::character varying, 'ALMUERZO'::character varying, 'MANTENIMIENTO'::character varying, 'FINALIZACION'::character varying, 'FINALIZAR_JORNADA'::character varying, 'FINALIZACION_JORNADA'::character varying, 'INGRESO_TEMPORAL'::character varying])::text[])))
);


--
-- Name: TABLE ingreso_sede; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ingreso_sede IS 'Ingresos de unidades a sedes durante una salida. Puede haber m??ltiples ingresos por salida.';


--
-- Name: COLUMN ingreso_sede.fecha_hora_salida; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingreso_sede.fecha_hora_salida IS 'NULL si todav??a est?? ingresado, timestamp si volvi?? a salir';


--
-- Name: COLUMN ingreso_sede.tipo_ingreso; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingreso_sede.tipo_ingreso IS 'Motivo del ingreso a sede';


--
-- Name: COLUMN ingreso_sede.es_ingreso_final; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ingreso_sede.es_ingreso_final IS 'TRUE si es el ingreso que finaliza la jornada laboral';


--
-- Name: ingreso_sede_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ingreso_sede_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ingreso_sede_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ingreso_sede_id_seq OWNED BY public.ingreso_sede.id;


--
-- Name: inspeccion_360; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inspeccion_360 (
    id integer NOT NULL,
    salida_id integer,
    unidad_id integer NOT NULL,
    plantilla_id integer NOT NULL,
    realizado_por integer NOT NULL,
    aprobado_por integer,
    estado character varying(20) DEFAULT 'PENDIENTE'::character varying NOT NULL,
    fecha_realizacion timestamp with time zone DEFAULT now() NOT NULL,
    fecha_aprobacion timestamp with time zone,
    respuestas jsonb NOT NULL,
    observaciones_inspector text,
    observaciones_comandante text,
    motivo_rechazo text,
    firma_inspector text,
    firma_comandante text,
    fotos jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT inspeccion_360_estado_check CHECK (((estado)::text = ANY ((ARRAY['PENDIENTE'::character varying, 'APROBADA'::character varying, 'RECHAZADA'::character varying])::text[])))
);


--
-- Name: TABLE inspeccion_360; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.inspeccion_360 IS 'Registro de inspecciones 360 realizadas. Cada salida requiere una inspección aprobada.';


--
-- Name: COLUMN inspeccion_360.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inspeccion_360.estado IS 'PENDIENTE = esperando aprobación | APROBADA = comandante aprobó | RECHAZADA = comandante rechazó';


--
-- Name: COLUMN inspeccion_360.respuestas; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.inspeccion_360.respuestas IS 'Respuestas a cada item del formulario';


--
-- Name: inspeccion_360_archivo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.inspeccion_360_archivo (
    id integer NOT NULL,
    inspeccion_id integer NOT NULL,
    unidad_id integer NOT NULL,
    fecha_realizacion timestamp with time zone NOT NULL,
    estado character varying(20) NOT NULL,
    datos_comprimidos bytea NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: TABLE inspeccion_360_archivo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.inspeccion_360_archivo IS 'Archivo de inspecciones 360 antiguas (>90 dias) comprimidas';


--
-- Name: inspeccion_360_archivo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inspeccion_360_archivo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inspeccion_360_archivo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inspeccion_360_archivo_id_seq OWNED BY public.inspeccion_360_archivo.id;


--
-- Name: inspeccion_360_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.inspeccion_360_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: inspeccion_360_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.inspeccion_360_id_seq OWNED BY public.inspeccion_360.id;


--
-- Name: intelligence_refresh_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.intelligence_refresh_log (
    id integer NOT NULL,
    view_name character varying(100) NOT NULL,
    refreshed_at timestamp with time zone DEFAULT now() NOT NULL,
    duration_ms integer,
    rows_affected integer
);


--
-- Name: TABLE intelligence_refresh_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.intelligence_refresh_log IS 'Log de refrescos de vistas materializadas';


--
-- Name: intelligence_refresh_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.intelligence_refresh_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: intelligence_refresh_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.intelligence_refresh_log_id_seq OWNED BY public.intelligence_refresh_log.id;


--
-- Name: log_administracion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.log_administracion (
    id integer NOT NULL,
    accion character varying(50) NOT NULL,
    tabla_afectada character varying(50),
    registro_id integer,
    usuario_afectado_id integer,
    datos_anteriores jsonb,
    datos_nuevos jsonb,
    realizado_por integer NOT NULL,
    ip_address character varying(45),
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: log_administracion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.log_administracion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: log_administracion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.log_administracion_id_seq OWNED BY public.log_administracion.id;


--
-- Name: marca; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marca (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    activa boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: TABLE marca; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.marca IS 'Catálogo de marcas de vehículos';


--
-- Name: marca_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.marca_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: marca_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.marca_id_seq OWNED BY public.marca.id;


--
-- Name: marca_vehiculo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.marca_vehiculo (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE marca_vehiculo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.marca_vehiculo IS 'Marcas de veh??culos';


--
-- Name: marca_vehiculo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.marca_vehiculo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: marca_vehiculo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.marca_vehiculo_id_seq OWNED BY public.marca_vehiculo.id;


--
-- Name: motivo_no_atendido; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.motivo_no_atendido (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    requiere_observaciones boolean DEFAULT false NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE motivo_no_atendido; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.motivo_no_atendido IS 'Motivos por los que un incidente no fue atendido';


--
-- Name: motivo_no_atendido_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.motivo_no_atendido_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: motivo_no_atendido_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.motivo_no_atendido_id_seq OWNED BY public.motivo_no_atendido.id;


--
-- Name: movimiento_brigada; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.movimiento_brigada (
    id bigint NOT NULL,
    usuario_id integer NOT NULL,
    turno_id integer,
    origen_asignacion_id integer,
    origen_unidad_id integer,
    destino_asignacion_id integer,
    destino_unidad_id integer,
    tipo_movimiento character varying(30) NOT NULL,
    ruta_id integer,
    km numeric(6,2),
    latitud numeric(10,8),
    longitud numeric(11,8),
    hora_inicio timestamp with time zone DEFAULT now() NOT NULL,
    hora_fin timestamp with time zone,
    motivo text,
    rol_en_destino character varying(30),
    creado_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT movimiento_brigada_tipo_movimiento_check CHECK (((tipo_movimiento)::text = ANY (ARRAY[('CAMBIO_UNIDAD'::character varying)::text, ('PRESTAMO'::character varying)::text, ('DIVISION_FUERZA'::character varying)::text, ('RELEVO'::character varying)::text, ('RETIRO'::character varying)::text, ('APOYO_TEMPORAL'::character varying)::text])))
);


--
-- Name: TABLE movimiento_brigada; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.movimiento_brigada IS 'Historial de todos los movimientos de brigadas entre unidades.';


--
-- Name: COLUMN movimiento_brigada.tipo_movimiento; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.movimiento_brigada.tipo_movimiento IS 'Tipo de movimiento realizado';


--
-- Name: COLUMN movimiento_brigada.hora_fin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.movimiento_brigada.hora_fin IS 'NULL si el movimiento a??n est?? activo';


--
-- Name: COLUMN movimiento_brigada.motivo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.movimiento_brigada.motivo IS 'Raz??n del movimiento';


--
-- Name: movimiento_brigada_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.movimiento_brigada_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: movimiento_brigada_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.movimiento_brigada_id_seq OWNED BY public.movimiento_brigada.id;


--
-- Name: multimedia_situacion_persistente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.multimedia_situacion_persistente (
    id integer NOT NULL,
    situacion_persistente_id integer NOT NULL,
    tipo character varying(20) NOT NULL,
    url text NOT NULL,
    url_thumbnail text,
    nombre_archivo character varying(255),
    mime_type character varying(100),
    tamanio_bytes bigint,
    ancho integer,
    alto integer,
    duracion_segundos integer,
    orden integer DEFAULT 0,
    latitud numeric(10,8),
    longitud numeric(11,8),
    descripcion text,
    subido_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT multimedia_situacion_persistente_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['foto'::character varying, 'video'::character varying])::text[])))
);


--
-- Name: TABLE multimedia_situacion_persistente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.multimedia_situacion_persistente IS 'Fotos y videos de situaciones persistentes (3 fotos + 1 video requeridos)';


--
-- Name: multimedia_situacion_persistente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.multimedia_situacion_persistente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: multimedia_situacion_persistente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.multimedia_situacion_persistente_id_seq OWNED BY public.multimedia_situacion_persistente.id;


--
-- Name: municipio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.municipio (
    id integer NOT NULL,
    departamento_id integer NOT NULL,
    codigo character varying(4) NOT NULL,
    nombre character varying(100) NOT NULL,
    nombre_completo character varying(150),
    cabecera_municipal character varying(100),
    poblacion integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE municipio; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.municipio IS 'Municipios de Guatemala (340 total)';


--
-- Name: COLUMN municipio.codigo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.municipio.codigo IS 'C??digo oficial del municipio (formato DDMM)';


--
-- Name: COLUMN municipio.cabecera_municipal; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.municipio.cabecera_municipal IS 'Nombre de la cabecera municipal';


--
-- Name: municipio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.municipio_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: municipio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.municipio_id_seq OWNED BY public.municipio.id;


--
-- Name: ruta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ruta (
    id integer NOT NULL,
    codigo character varying(20) NOT NULL,
    nombre character varying(150) NOT NULL,
    tipo_ruta character varying(30),
    km_inicial numeric(6,2),
    km_final numeric(6,2),
    activa boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE ruta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ruta IS 'Cat??logo de rutas/carreteras';


--
-- Name: COLUMN ruta.tipo_ruta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.ruta.tipo_ruta IS 'CARRETERA, AUTOPISTA, BOULEVARD';


--
-- Name: tipo_hecho; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tipo_hecho (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    icono character varying(50),
    color character varying(7),
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE tipo_hecho; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tipo_hecho IS 'Tipos principales de hechos/incidentes';


--
-- Name: COLUMN tipo_hecho.icono; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tipo_hecho.icono IS 'Nombre del icono para UI (ej: accident, warning, etc.)';


--
-- Name: COLUMN tipo_hecho.color; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tipo_hecho.color IS 'Color hexadecimal para mapas';


--
-- Name: mv_estadisticas_diarias; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mv_estadisticas_diarias AS
 SELECT date(i.fecha_hora_aviso) AS fecha,
    i.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    i.tipo_hecho_id,
    th.nombre AS tipo_hecho,
    i.origen,
    i.estado,
    count(*) AS total_incidentes,
    sum(i.cantidad_heridos) AS total_heridos,
    sum(i.cantidad_fallecidos) AS total_fallecidos,
    avg((EXTRACT(epoch FROM (i.fecha_hora_llegada - i.fecha_hora_aviso)) / (60)::numeric)) AS tiempo_respuesta_promedio_min,
    avg((EXTRACT(epoch FROM (i.fecha_hora_finalizacion - i.fecha_hora_llegada)) / (60)::numeric)) AS tiempo_atencion_promedio_min,
    count(*) FILTER (WHERE ((i.estado)::text = 'CERRADO'::text)) AS total_cerrados,
    count(*) FILTER (WHERE ((i.estado)::text = 'NO_ATENDIDO'::text)) AS total_no_atendidos,
    count(*) FILTER (WHERE (i.hay_heridos = true)) AS incidentes_con_heridos,
    count(*) FILTER (WHERE (i.hay_fallecidos = true)) AS incidentes_con_fallecidos
   FROM ((public.incidente i
     JOIN public.ruta r ON ((i.ruta_id = r.id)))
     JOIN public.tipo_hecho th ON ((i.tipo_hecho_id = th.id)))
  WHERE (i.fecha_hora_aviso >= (CURRENT_DATE - '90 days'::interval))
  GROUP BY (date(i.fecha_hora_aviso)), i.ruta_id, r.codigo, r.nombre, i.tipo_hecho_id, th.nombre, i.origen, i.estado
  WITH NO DATA;


--
-- Name: MATERIALIZED VIEW mv_estadisticas_diarias; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON MATERIALIZED VIEW public.mv_estadisticas_diarias IS 'Estad??sticas diarias de incidentes (??ltimos 90 d??as). Refrescar nightly.';


--
-- Name: sede; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sede (
    id integer NOT NULL,
    codigo character varying(20) NOT NULL,
    nombre character varying(100) NOT NULL,
    departamento character varying(50),
    municipio character varying(50),
    direccion text,
    telefono character varying(20),
    activa boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    departamento_id integer,
    municipio_id integer,
    es_sede_central boolean DEFAULT false NOT NULL,
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: TABLE sede; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.sede IS 'Sedes de PROVIAL distribuidas por el pa??s';


--
-- Name: COLUMN sede.activa; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sede.activa IS 'FALSE si la sede fue cerrada o est?? inactiva';


--
-- Name: COLUMN sede.departamento_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sede.departamento_id IS 'Departamento donde se ubica la sede';


--
-- Name: COLUMN sede.municipio_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sede.municipio_id IS 'Municipio donde se ubica la sede';


--
-- Name: unidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.unidad (
    id integer NOT NULL,
    codigo character varying(20) NOT NULL,
    tipo_unidad character varying(50) NOT NULL,
    marca character varying(50),
    modelo character varying(50),
    anio integer,
    placa character varying(20),
    sede_id integer NOT NULL,
    activa boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    combustible_actual numeric(6,2) DEFAULT 0,
    capacidad_combustible numeric(6,2),
    odometro_actual numeric(10,2) DEFAULT 0,
    custom_fields jsonb DEFAULT '{}'::jsonb
);


--
-- Name: TABLE unidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.unidad IS 'Veh??culos/unidades operativas';


--
-- Name: COLUMN unidad.tipo_unidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.unidad.tipo_unidad IS 'MOTORIZADA, PICKUP, PATRULLA, etc.';


--
-- Name: COLUMN unidad.sede_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.unidad.sede_id IS 'Sede base de la unidad';


--
-- Name: COLUMN unidad.combustible_actual; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.unidad.combustible_actual IS 'Combustible actual en litros (actualizado por brigadas)';


--
-- Name: COLUMN unidad.capacidad_combustible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.unidad.capacidad_combustible IS 'Capacidad total del tanque en litros';


--
-- Name: COLUMN unidad.odometro_actual; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.unidad.odometro_actual IS 'Kilometraje total del veh??culo';


--
-- Name: mv_no_atendidos_por_motivo; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mv_no_atendidos_por_motivo AS
 SELECT date_trunc('month'::text, i.fecha_hora_aviso) AS mes,
    m.id AS motivo_id,
    m.nombre AS motivo,
    r.id AS ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.id AS sede_id,
    s.nombre AS sede_nombre,
    count(*) AS total,
    round((((count(*))::numeric * 100.0) / sum(count(*)) OVER (PARTITION BY (date_trunc('month'::text, i.fecha_hora_aviso)))), 2) AS porcentaje_del_mes
   FROM (((((public.incidente i
     JOIN public.incidente_no_atendido ina ON ((i.id = ina.incidente_id)))
     JOIN public.motivo_no_atendido m ON ((ina.motivo_id = m.id)))
     JOIN public.ruta r ON ((i.ruta_id = r.id)))
     LEFT JOIN public.unidad u ON ((i.unidad_id = u.id)))
     LEFT JOIN public.sede s ON ((u.sede_id = s.id)))
  WHERE (((i.estado)::text = 'NO_ATENDIDO'::text) AND (i.fecha_hora_aviso >= (CURRENT_DATE - '1 year'::interval)))
  GROUP BY (date_trunc('month'::text, i.fecha_hora_aviso)), m.id, m.nombre, r.id, r.codigo, r.nombre, s.id, s.nombre
  WITH NO DATA;


--
-- Name: MATERIALIZED VIEW mv_no_atendidos_por_motivo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON MATERIALIZED VIEW public.mv_no_atendidos_por_motivo IS 'M??tricas de incidentes no atendidos por motivo (??ltimos 12 meses)';


--
-- Name: piloto; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.piloto (
    id integer NOT NULL,
    nombre character varying(255) NOT NULL,
    licencia_tipo character varying(1),
    licencia_numero bigint NOT NULL,
    licencia_vencimiento date,
    licencia_antiguedad integer,
    fecha_nacimiento date,
    etnia character varying(50),
    total_incidentes integer DEFAULT 0,
    total_sanciones integer DEFAULT 0,
    primer_incidente timestamp with time zone,
    ultimo_incidente timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT piloto_licencia_tipo_check CHECK (((licencia_tipo)::text = ANY (ARRAY[('A'::character varying)::text, ('B'::character varying)::text, ('C'::character varying)::text, ('M'::character varying)::text, ('E'::character varying)::text])))
);


--
-- Name: TABLE piloto; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.piloto IS 'Tabla maestra de pilotos. Un registro por licencia ??nica.';


--
-- Name: COLUMN piloto.licencia_tipo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.piloto.licencia_tipo IS 'Tipo de licencia: A=Moto, B=Liviano, C=Pesado, M=Maquinaria, E=Especial';


--
-- Name: COLUMN piloto.total_incidentes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.piloto.total_incidentes IS 'Contador de incidentes (actualizado por trigger)';


--
-- Name: COLUMN piloto.total_sanciones; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.piloto.total_sanciones IS 'Contador de sanciones (actualizado por trigger)';


--
-- Name: mv_pilotos_problematicos; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mv_pilotos_problematicos AS
 SELECT id,
    nombre,
    licencia_tipo,
    licencia_numero,
    licencia_vencimiento,
    total_incidentes,
    total_sanciones,
    primer_incidente,
    ultimo_incidente,
        CASE
            WHEN (fecha_nacimiento IS NOT NULL) THEN EXTRACT(year FROM age((fecha_nacimiento)::timestamp with time zone))
            ELSE NULL::numeric
        END AS edad,
        CASE
            WHEN ((licencia_vencimiento IS NOT NULL) AND (licencia_vencimiento < now())) THEN true
            ELSE false
        END AS licencia_vencida,
        CASE
            WHEN (licencia_vencimiento IS NOT NULL) THEN (licencia_vencimiento - (now())::date)
            ELSE NULL::integer
        END AS dias_hasta_vencimiento,
        CASE
            WHEN ((total_sanciones >= 5) OR (total_incidentes >= 5)) THEN 5
            WHEN ((total_sanciones >= 3) OR (total_incidentes >= 4)) THEN 4
            WHEN ((total_sanciones >= 2) OR (total_incidentes >= 3)) THEN 3
            WHEN ((total_sanciones >= 1) OR (total_incidentes >= 2)) THEN 2
            ELSE 1
        END AS nivel_riesgo
   FROM public.piloto p
  WHERE ((total_incidentes >= 1) OR (total_sanciones >= 1))
  ORDER BY (total_incidentes + total_sanciones) DESC, ultimo_incidente DESC
  WITH NO DATA;


--
-- Name: MATERIALIZED VIEW mv_pilotos_problematicos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON MATERIALIZED VIEW public.mv_pilotos_problematicos IS 'Pilotos con incidentes/sanciones y su nivel de riesgo';


--
-- Name: mv_puntos_calientes; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mv_puntos_calientes AS
 SELECT row_number() OVER (ORDER BY (count(*)) DESC) AS id,
    COALESCE(r.codigo, 'SIN_RUTA'::character varying) AS ruta_codigo,
    COALESCE(r.nombre, 'Sin ruta asignada'::character varying) AS ruta_nombre,
    i.municipio_id AS municipio_codigo,
    m.nombre AS municipio_nombre,
    i.km AS kilometro,
    count(*) AS total_incidentes,
    count(*) AS total_accidentes,
    0 AS total_asistencias,
    0 AS total_emergencias,
    COALESCE(sum(i.cantidad_heridos), (0)::bigint) AS total_heridos,
    COALESCE(sum(i.cantidad_fallecidos), (0)::bigint) AS total_fallecidos,
    min(i.created_at) AS primer_incidente,
    max(i.created_at) AS ultimo_incidente,
    ((count(*))::numeric / GREATEST((1)::numeric, (EXTRACT(epoch FROM (max(i.created_at) - min(i.created_at))) / ((((30 * 24) * 60) * 60))::numeric))) AS frecuencia_mensual,
        CASE
            WHEN ((count(*) >= 10) OR (sum(i.cantidad_fallecidos) >= 3)) THEN 5
            WHEN ((count(*) >= 7) OR (sum(i.cantidad_fallecidos) >= 2)) THEN 4
            WHEN ((count(*) >= 5) OR (sum(i.cantidad_heridos) >= 5)) THEN 3
            WHEN ((count(*) >= 3) OR (sum(i.cantidad_heridos) >= 2)) THEN 2
            ELSE 1
        END AS nivel_peligrosidad,
    avg(i.latitud) AS latitud_promedio,
    avg(i.longitud) AS longitud_promedio
   FROM ((public.incidente i
     LEFT JOIN public.ruta r ON ((i.ruta_id = r.id)))
     LEFT JOIN public.municipio m ON ((i.municipio_id = m.id)))
  WHERE ((i.estado)::text = ANY (ARRAY[('REGISTRADO'::character varying)::text, ('CERRADO'::character varying)::text]))
  GROUP BY r.codigo, r.nombre, i.municipio_id, m.nombre, i.km
 HAVING (count(*) >= 2)
  ORDER BY (count(*)) DESC, COALESCE(sum(i.cantidad_fallecidos), (0)::bigint) DESC, COALESCE(sum(i.cantidad_heridos), (0)::bigint) DESC
  WITH NO DATA;


--
-- Name: MATERIALIZED VIEW mv_puntos_calientes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON MATERIALIZED VIEW public.mv_puntos_calientes IS 'Puntos geogr??ficos con alta concentraci??n de incidentes';


--
-- Name: mv_tendencias_temporales; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mv_tendencias_temporales AS
 SELECT date(created_at) AS fecha,
    (EXTRACT(year FROM created_at))::integer AS anio,
    (EXTRACT(month FROM created_at))::integer AS mes,
    (EXTRACT(dow FROM created_at))::integer AS dia_semana,
    (EXTRACT(hour FROM created_at))::integer AS hora,
        CASE (EXTRACT(dow FROM created_at))::integer
            WHEN 0 THEN 'Domingo'::text
            WHEN 1 THEN 'Lunes'::text
            WHEN 2 THEN 'Martes'::text
            WHEN 3 THEN 'Mi??rcoles'::text
            WHEN 4 THEN 'Jueves'::text
            WHEN 5 THEN 'Viernes'::text
            WHEN 6 THEN 'S??bado'::text
            ELSE NULL::text
        END AS nombre_dia,
        CASE
            WHEN ((EXTRACT(dow FROM created_at))::integer = ANY (ARRAY[0, 6])) THEN 'Fin de semana'::text
            ELSE 'Entre semana'::text
        END AS tipo_dia,
        CASE
            WHEN (((EXTRACT(hour FROM created_at))::integer >= 0) AND ((EXTRACT(hour FROM created_at))::integer <= 5)) THEN 'Madrugada (00:00-05:59)'::text
            WHEN (((EXTRACT(hour FROM created_at))::integer >= 6) AND ((EXTRACT(hour FROM created_at))::integer <= 11)) THEN 'Ma??ana (06:00-11:59)'::text
            WHEN (((EXTRACT(hour FROM created_at))::integer >= 12) AND ((EXTRACT(hour FROM created_at))::integer <= 17)) THEN 'Tarde (12:00-17:59)'::text
            ELSE 'Noche (18:00-23:59)'::text
        END AS franja_horaria,
    count(*) AS total_incidentes,
    count(*) AS total_accidentes,
    0 AS total_asistencias,
    0 AS total_emergencias,
    COALESCE(sum(cantidad_heridos), (0)::bigint) AS total_heridos,
    COALESCE(sum(cantidad_fallecidos), (0)::bigint) AS total_fallecidos
   FROM public.incidente i
  WHERE ((estado)::text = ANY (ARRAY[('REGISTRADO'::character varying)::text, ('CERRADO'::character varying)::text]))
  GROUP BY (date(created_at)), ((EXTRACT(year FROM created_at))::integer), ((EXTRACT(month FROM created_at))::integer), ((EXTRACT(dow FROM created_at))::integer), ((EXTRACT(hour FROM created_at))::integer),
        CASE (EXTRACT(dow FROM created_at))::integer
            WHEN 0 THEN 'Domingo'::text
            WHEN 1 THEN 'Lunes'::text
            WHEN 2 THEN 'Martes'::text
            WHEN 3 THEN 'Mi??rcoles'::text
            WHEN 4 THEN 'Jueves'::text
            WHEN 5 THEN 'Viernes'::text
            WHEN 6 THEN 'S??bado'::text
            ELSE NULL::text
        END,
        CASE
            WHEN ((EXTRACT(dow FROM created_at))::integer = ANY (ARRAY[0, 6])) THEN 'Fin de semana'::text
            ELSE 'Entre semana'::text
        END,
        CASE
            WHEN (((EXTRACT(hour FROM created_at))::integer >= 0) AND ((EXTRACT(hour FROM created_at))::integer <= 5)) THEN 'Madrugada (00:00-05:59)'::text
            WHEN (((EXTRACT(hour FROM created_at))::integer >= 6) AND ((EXTRACT(hour FROM created_at))::integer <= 11)) THEN 'Ma??ana (06:00-11:59)'::text
            WHEN (((EXTRACT(hour FROM created_at))::integer >= 12) AND ((EXTRACT(hour FROM created_at))::integer <= 17)) THEN 'Tarde (12:00-17:59)'::text
            ELSE 'Noche (18:00-23:59)'::text
        END
  ORDER BY (date(created_at)) DESC, ((EXTRACT(hour FROM created_at))::integer) DESC
  WITH NO DATA;


--
-- Name: MATERIALIZED VIEW mv_tendencias_temporales; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON MATERIALIZED VIEW public.mv_tendencias_temporales IS 'An??lisis temporal de incidentes por fecha, hora y d??a de la semana';


--
-- Name: tipo_vehiculo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tipo_vehiculo (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    categoria character varying(30),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE tipo_vehiculo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tipo_vehiculo IS 'Catálogo de tipos de vehículos';


--
-- Name: COLUMN tipo_vehiculo.categoria; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tipo_vehiculo.categoria IS 'LIVIANO, PESADO, MOTO';


--
-- Name: vehiculo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehiculo (
    id integer NOT NULL,
    placa character varying(20) NOT NULL,
    es_extranjero boolean DEFAULT false,
    tipo_vehiculo_id integer,
    color character varying(100),
    marca_id integer,
    cargado boolean DEFAULT false,
    tipo_carga character varying(100),
    total_incidentes integer DEFAULT 0,
    primer_incidente timestamp with time zone,
    ultimo_incidente timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE vehiculo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.vehiculo IS 'Tabla maestra de veh??culos. Un registro por placa ??nica.';


--
-- Name: COLUMN vehiculo.placa; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vehiculo.placa IS 'Placa del veh??culo (formato Guatemala: L###LLL)';


--
-- Name: COLUMN vehiculo.es_extranjero; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vehiculo.es_extranjero IS 'TRUE si es placa extranjera (sin validaci??n de formato)';


--
-- Name: COLUMN vehiculo.total_incidentes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.vehiculo.total_incidentes IS 'Contador de incidentes (actualizado por trigger)';


--
-- Name: mv_vehiculos_reincidentes; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mv_vehiculos_reincidentes AS
 SELECT v.id,
    v.placa,
    v.es_extranjero,
    tv.nombre AS tipo_vehiculo,
    m.nombre AS marca,
    v.color,
    v.total_incidentes,
    v.primer_incidente,
    v.ultimo_incidente,
        CASE
            WHEN (v.primer_incidente IS NOT NULL) THEN (EXTRACT(day FROM (now() - v.primer_incidente)))::integer
            ELSE NULL::integer
        END AS dias_desde_primer_incidente,
        CASE
            WHEN (v.ultimo_incidente IS NOT NULL) THEN (EXTRACT(day FROM (now() - v.ultimo_incidente)))::integer
            ELSE NULL::integer
        END AS dias_desde_ultimo_incidente,
        CASE
            WHEN ((v.primer_incidente IS NOT NULL) AND (v.ultimo_incidente IS NOT NULL)) THEN ((v.total_incidentes)::numeric / GREATEST((1)::numeric, (EXTRACT(epoch FROM (v.ultimo_incidente - v.primer_incidente)) / ((((30 * 24) * 60) * 60))::numeric)))
            ELSE (0)::numeric
        END AS frecuencia_mensual,
        CASE
            WHEN (v.total_incidentes >= 5) THEN 5
            WHEN (v.total_incidentes >= 4) THEN 4
            WHEN (v.total_incidentes >= 3) THEN 3
            WHEN (v.total_incidentes >= 2) THEN 2
            ELSE 1
        END AS nivel_riesgo
   FROM ((public.vehiculo v
     LEFT JOIN public.tipo_vehiculo tv ON ((v.tipo_vehiculo_id = tv.id)))
     LEFT JOIN public.marca_vehiculo m ON ((v.marca_id = m.id)))
  WHERE (v.total_incidentes >= 2)
  ORDER BY v.total_incidentes DESC, v.ultimo_incidente DESC
  WITH NO DATA;


--
-- Name: MATERIALIZED VIEW mv_vehiculos_reincidentes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON MATERIALIZED VIEW public.mv_vehiculos_reincidentes IS 'Veh??culos con m??ltiples incidentes y su nivel de riesgo';


--
-- Name: notificacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notificacion (
    id integer NOT NULL,
    usuario_id integer,
    tipo character varying(50) NOT NULL,
    titulo character varying(200) NOT NULL,
    mensaje text NOT NULL,
    datos jsonb DEFAULT '{}'::jsonb,
    enviada boolean DEFAULT false,
    fecha_envio timestamp with time zone,
    error_envio text,
    leida boolean DEFAULT false,
    fecha_lectura timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: TABLE notificacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.notificacion IS 'Historial de notificaciones enviadas a usuarios';


--
-- Name: notificacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notificacion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notificacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notificacion_id_seq OWNED BY public.notificacion.id;


--
-- Name: obstruccion_incidente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.obstruccion_incidente (
    id bigint NOT NULL,
    incidente_id bigint NOT NULL,
    descripcion_generada text,
    datos_carriles_json jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE obstruccion_incidente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.obstruccion_incidente IS 'Informaci??n de obstrucci??n de carriles (relaci??n 1:1 con incidente)';


--
-- Name: COLUMN obstruccion_incidente.descripcion_generada; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.obstruccion_incidente.descripcion_generada IS 'Texto auto-generado legible de la obstrucci??n';


--
-- Name: COLUMN obstruccion_incidente.datos_carriles_json; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.obstruccion_incidente.datos_carriles_json IS 'Estado detallado de carriles por direcci??n';


--
-- Name: obstruccion_incidente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.obstruccion_incidente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: obstruccion_incidente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.obstruccion_incidente_id_seq OWNED BY public.obstruccion_incidente.id;


--
-- Name: obstruccion_situacion_persistente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.obstruccion_situacion_persistente (
    id integer NOT NULL,
    situacion_persistente_id integer NOT NULL,
    hay_vehiculo_fuera_via boolean DEFAULT false NOT NULL,
    tipo_obstruccion character varying(20) DEFAULT 'ninguna'::character varying NOT NULL,
    sentido_principal jsonb DEFAULT '{"carriles": [], "cantidad_carriles": 2}'::jsonb,
    sentido_contrario jsonb,
    descripcion_generada text,
    descripcion_manual text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT obstruccion_situacion_persistente_tipo_obstruccion_check CHECK (((tipo_obstruccion)::text = ANY ((ARRAY['ninguna'::character varying, 'total_sentido'::character varying, 'total_ambos'::character varying, 'parcial'::character varying])::text[])))
);


--
-- Name: TABLE obstruccion_situacion_persistente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.obstruccion_situacion_persistente IS 'Datos de obstrucci??n de v??a para situaciones persistentes - modelo v2';


--
-- Name: COLUMN obstruccion_situacion_persistente.hay_vehiculo_fuera_via; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.obstruccion_situacion_persistente.hay_vehiculo_fuera_via IS 'Indica si hay veh??culo fuera de la v??a (puede ser TRUE junto con obstrucci??n parcial)';


--
-- Name: COLUMN obstruccion_situacion_persistente.tipo_obstruccion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.obstruccion_situacion_persistente.tipo_obstruccion IS 'ninguna=solo fuera de v??a, total_sentido=todo el sentido, total_ambos=ambos sentidos, parcial=por carril';


--
-- Name: COLUMN obstruccion_situacion_persistente.sentido_principal; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.obstruccion_situacion_persistente.sentido_principal IS 'JSON con cantidad_carriles y array de carriles [{nombre, porcentaje}]';


--
-- Name: COLUMN obstruccion_situacion_persistente.sentido_contrario; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.obstruccion_situacion_persistente.sentido_contrario IS 'JSON con carriles del sentido contrario (null = 0% obstrucci??n)';


--
-- Name: obstruccion_situacion_persistente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.obstruccion_situacion_persistente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: obstruccion_situacion_persistente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.obstruccion_situacion_persistente_id_seq OWNED BY public.obstruccion_situacion_persistente.id;


--
-- Name: password_reset_log; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.password_reset_log (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    habilitado_por integer,
    fecha_habilitacion timestamp without time zone NOT NULL,
    fecha_completado timestamp without time zone,
    ip_completado character varying(45),
    metodo character varying(20) DEFAULT 'APP'::character varying,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE password_reset_log; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.password_reset_log IS 'Historial de restablecimientos de contraseña para auditoría';


--
-- Name: password_reset_log_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.password_reset_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: password_reset_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.password_reset_log_id_seq OWNED BY public.password_reset_log.id;


--
-- Name: permiso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.permiso (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    modulo character varying(50),
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: permiso_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.permiso_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: permiso_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.permiso_id_seq OWNED BY public.permiso.id;


--
-- Name: persona_accidente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.persona_accidente (
    id integer NOT NULL,
    hoja_accidentologia_id integer NOT NULL,
    vehiculo_accidente_id integer,
    tipo_persona character varying(20) NOT NULL,
    nombre_completo character varying(150),
    dpi character varying(20),
    edad integer,
    genero character varying(10),
    telefono character varying(20),
    direccion text,
    estado public.estado_persona_accidente NOT NULL,
    tipo_lesion public.tipo_lesion,
    descripcion_lesiones text,
    requirio_atencion boolean DEFAULT false,
    hospital_trasladado character varying(100),
    ambulancia_unidad character varying(50),
    hora_traslado time without time zone,
    hora_fallecimiento time without time zone,
    lugar_fallecimiento character varying(100),
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE persona_accidente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.persona_accidente IS 'Personas afectadas en accidente';


--
-- Name: persona_accidente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.persona_accidente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: persona_accidente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.persona_accidente_id_seq OWNED BY public.persona_accidente.id;


--
-- Name: persona_involucrada; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.persona_involucrada (
    id integer NOT NULL,
    incidente_id integer,
    vehiculo_id integer,
    tipo character varying(50) NOT NULL,
    nombre character varying(255),
    genero character varying(20),
    edad integer,
    estado character varying(50),
    trasladado boolean DEFAULT false,
    lugar_traslado character varying(255),
    consignado boolean DEFAULT false,
    lugar_consignacion character varying(255),
    observaciones text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: persona_involucrada_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.persona_involucrada_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: persona_involucrada_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.persona_involucrada_id_seq OWNED BY public.persona_involucrada.id;


--
-- Name: piloto_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.piloto_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: piloto_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.piloto_id_seq OWNED BY public.piloto.id;


--
-- Name: plantilla_comunicacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plantilla_comunicacion (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    tipo_situacion character varying(50),
    tipo_accidente public.tipo_accidente,
    contenido_plantilla text NOT NULL,
    activa boolean DEFAULT true,
    es_predefinida boolean DEFAULT false,
    hashtags text[],
    creado_por integer,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE plantilla_comunicacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.plantilla_comunicacion IS 'Plantillas/machotes para mensajes de redes sociales';


--
-- Name: plantilla_comunicacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plantilla_comunicacion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plantilla_comunicacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plantilla_comunicacion_id_seq OWNED BY public.plantilla_comunicacion.id;


--
-- Name: plantilla_inspeccion_360; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.plantilla_inspeccion_360 (
    id integer NOT NULL,
    tipo_unidad character varying(50) NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    version integer DEFAULT 1 NOT NULL,
    secciones jsonb NOT NULL,
    activa boolean DEFAULT true NOT NULL,
    creado_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE plantilla_inspeccion_360; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.plantilla_inspeccion_360 IS 'Plantillas dinámicas de inspección 360 por tipo de unidad. Los SUPER_ADMIN pueden crear/editar plantillas.';


--
-- Name: COLUMN plantilla_inspeccion_360.secciones; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.plantilla_inspeccion_360.secciones IS 'Estructura JSON con secciones e items del formulario';


--
-- Name: plantilla_inspeccion_360_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.plantilla_inspeccion_360_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: plantilla_inspeccion_360_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.plantilla_inspeccion_360_id_seq OWNED BY public.plantilla_inspeccion_360.id;


--
-- Name: publicacion_social; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.publicacion_social (
    id integer NOT NULL,
    situacion_id integer,
    hoja_accidentologia_id integer,
    plantilla_id integer,
    contenido_texto text NOT NULL,
    contenido_editado text,
    hashtags text[],
    fotos_urls text[],
    publicado_facebook boolean DEFAULT false,
    publicado_twitter boolean DEFAULT false,
    publicado_instagram boolean DEFAULT false,
    publicado_whatsapp boolean DEFAULT false,
    publicado_threads boolean DEFAULT false,
    fecha_publicacion timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    publicado_por integer,
    estado character varying(20) DEFAULT 'BORRADOR'::character varying,
    fecha_programada timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE publicacion_social; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.publicacion_social IS 'Registro de publicaciones realizadas en redes sociales';


--
-- Name: publicacion_social_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.publicacion_social_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: publicacion_social_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.publicacion_social_id_seq OWNED BY public.publicacion_social.id;


--
-- Name: reasignacion_sede; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reasignacion_sede (
    id integer NOT NULL,
    tipo character varying(20) NOT NULL,
    recurso_id integer NOT NULL,
    sede_origen_id integer NOT NULL,
    sede_destino_id integer NOT NULL,
    fecha_inicio date NOT NULL,
    fecha_fin date,
    es_permanente boolean DEFAULT false NOT NULL,
    motivo text,
    estado character varying(20) DEFAULT 'ACTIVA'::character varying NOT NULL,
    autorizado_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT reasignacion_sede_estado_check CHECK (((estado)::text = ANY (ARRAY[('ACTIVA'::character varying)::text, ('FINALIZADA'::character varying)::text, ('CANCELADA'::character varying)::text]))),
    CONSTRAINT reasignacion_sede_tipo_check CHECK (((tipo)::text = ANY (ARRAY[('USUARIO'::character varying)::text, ('UNIDAD'::character varying)::text])))
);


--
-- Name: TABLE reasignacion_sede; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.reasignacion_sede IS 'Reasignaciones temporales o permanentes de personal/unidades entre sedes';


--
-- Name: COLUMN reasignacion_sede.tipo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reasignacion_sede.tipo IS 'USUARIO: brigadista | UNIDAD: veh??culo';


--
-- Name: COLUMN reasignacion_sede.recurso_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.reasignacion_sede.recurso_id IS 'ID del usuario o unidad reasignado';


--
-- Name: reasignacion_sede_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reasignacion_sede_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reasignacion_sede_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reasignacion_sede_id_seq OWNED BY public.reasignacion_sede.id;


--
-- Name: recurso_incidente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.recurso_incidente (
    id bigint NOT NULL,
    incidente_id bigint NOT NULL,
    tipo_recurso character varying(50) NOT NULL,
    descripcion text,
    hora_solicitud timestamp with time zone,
    hora_llegada timestamp with time zone,
    observaciones text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT recurso_incidente_tipo_recurso_check CHECK (((tipo_recurso)::text = ANY (ARRAY[('GRUA'::character varying)::text, ('BOMBEROS'::character varying)::text, ('PNC'::character varying)::text, ('AMBULANCIA'::character varying)::text, ('AJUSTADOR'::character varying)::text, ('OTRO'::character varying)::text])))
);


--
-- Name: TABLE recurso_incidente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.recurso_incidente IS 'Recursos externos solicitados para un incidente';


--
-- Name: recurso_incidente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.recurso_incidente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: recurso_incidente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.recurso_incidente_id_seq OWNED BY public.recurso_incidente.id;


--
-- Name: registro_cambio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.registro_cambio (
    id bigint NOT NULL,
    tipo_cambio character varying(50) NOT NULL,
    usuario_afectado_id integer,
    asignacion_id integer,
    situacion_id bigint,
    unidad_id integer,
    valores_anteriores jsonb,
    valores_nuevos jsonb,
    motivo text NOT NULL,
    realizado_por integer NOT NULL,
    autorizado_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT registro_cambio_tipo_cambio_check CHECK (((tipo_cambio)::text = ANY (ARRAY[('CAMBIO_BRIGADA'::character varying)::text, ('CAMBIO_UNIDAD'::character varying)::text, ('REMOCION_ASIGNACION'::character varying)::text, ('SUSPENSION_ACCESO'::character varying)::text, ('REACTIVACION_ACCESO'::character varying)::text, ('CAMBIO_GRUPO'::character varying)::text, ('EDICION_SITUACION'::character varying)::text, ('EDICION_ASIGNACION'::character varying)::text, ('OTRO'::character varying)::text])))
);


--
-- Name: TABLE registro_cambio; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.registro_cambio IS 'Registro de auditor??a de todos los cambios realizados en el sistema';


--
-- Name: COLUMN registro_cambio.valores_anteriores; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.registro_cambio.valores_anteriores IS 'Estado anterior en JSON';


--
-- Name: COLUMN registro_cambio.valores_nuevos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.registro_cambio.valores_nuevos IS 'Estado nuevo en JSON';


--
-- Name: COLUMN registro_cambio.motivo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.registro_cambio.motivo IS 'Motivo obligatorio para el cambio (ej: "Brigada enfermo", "Unidad con falla mec??nica")';


--
-- Name: registro_cambio_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.registro_cambio_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: registro_cambio_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.registro_cambio_id_seq OWNED BY public.registro_cambio.id;


--
-- Name: relevo; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.relevo (
    id integer NOT NULL,
    situacion_id integer,
    tipo_relevo character varying(30) NOT NULL,
    unidad_saliente_id integer NOT NULL,
    unidad_entrante_id integer NOT NULL,
    brigadistas_salientes jsonb,
    brigadistas_entrantes jsonb,
    fecha_hora timestamp with time zone DEFAULT now() NOT NULL,
    observaciones text,
    registrado_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT relevo_tipo_relevo_check CHECK (((tipo_relevo)::text = ANY (ARRAY[('UNIDAD_COMPLETA'::character varying)::text, ('CRUZADO'::character varying)::text])))
);


--
-- Name: TABLE relevo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.relevo IS 'Registro de relevos entre unidades/tripulaciones';


--
-- Name: COLUMN relevo.tipo_relevo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.relevo.tipo_relevo IS 'UNIDAD_COMPLETA: 016 se va, 015 llega | CRUZADO: tripulaci??n 016 se queda con unidad 015';


--
-- Name: relevo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.relevo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: relevo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.relevo_id_seq OWNED BY public.relevo.id;


--
-- Name: reporte_horario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.reporte_horario (
    id bigint NOT NULL,
    asignacion_id integer NOT NULL,
    km_actual numeric(6,2) NOT NULL,
    sentido_actual character varying(30),
    latitud numeric(10,8),
    longitud numeric(11,8),
    novedad text,
    reportado_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT reporte_horario_sentido_actual_check CHECK (((sentido_actual)::text = ANY (ARRAY[('NORTE'::character varying)::text, ('SUR'::character varying)::text, ('ESTE'::character varying)::text, ('OESTE'::character varying)::text, ('ASCENDENTE'::character varying)::text, ('DESCENDENTE'::character varying)::text])))
);


--
-- Name: TABLE reporte_horario; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.reporte_horario IS 'Reportes horarios de posici??n de unidades (para COP y secuencia de radio)';


--
-- Name: reporte_horario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.reporte_horario_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: reporte_horario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.reporte_horario_id_seq OWNED BY public.reporte_horario.id;


--
-- Name: rol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rol (
    id integer NOT NULL,
    nombre character varying(50) NOT NULL,
    descripcion text,
    permisos jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE rol; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.rol IS 'Roles del sistema con permisos';


--
-- Name: COLUMN rol.permisos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.rol.permisos IS 'JSON con permisos espec??ficos del rol';


--
-- Name: rol_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rol_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rol_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rol_id_seq OWNED BY public.rol.id;


--
-- Name: rol_permiso; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rol_permiso (
    rol_id integer NOT NULL,
    permiso_id integer NOT NULL
);


--
-- Name: ruta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ruta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ruta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ruta_id_seq OWNED BY public.ruta.id;


--
-- Name: salida_unidad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.salida_unidad (
    id integer NOT NULL,
    unidad_id integer NOT NULL,
    fecha_hora_salida timestamp with time zone DEFAULT now() NOT NULL,
    fecha_hora_regreso timestamp with time zone,
    estado character varying(30) DEFAULT 'EN_SALIDA'::character varying NOT NULL,
    ruta_inicial_id integer,
    km_inicial numeric(10,2),
    combustible_inicial numeric(5,2),
    km_final integer,
    combustible_final numeric(5,2),
    km_recorridos numeric(10,2),
    tripulacion jsonb,
    finalizada_por integer,
    observaciones_salida text,
    observaciones_regreso text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    sede_origen_id integer,
    inspeccion_360_id integer,
    CONSTRAINT salida_unidad_estado_check CHECK (((estado)::text = ANY (ARRAY[('EN_SALIDA'::character varying)::text, ('FINALIZADA'::character varying)::text, ('CANCELADA'::character varying)::text])))
);


--
-- Name: TABLE salida_unidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.salida_unidad IS 'Registro de salidas de unidades. Puede durar horas o d??as sin l??mite.';


--
-- Name: COLUMN salida_unidad.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.salida_unidad.estado IS 'EN_SALIDA: activa | FINALIZADA: regres?? a sede | CANCELADA: cancelada';


--
-- Name: COLUMN salida_unidad.km_inicial; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.salida_unidad.km_inicial IS 'Odómetro al iniciar salida (km, sin decimales)';


--
-- Name: COLUMN salida_unidad.km_final; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.salida_unidad.km_final IS 'Odómetro al finalizar salida (km, sin decimales)';


--
-- Name: COLUMN salida_unidad.tripulacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.salida_unidad.tripulacion IS 'Brigadistas que salieron en esta salida (snapshot al momento de salir)';


--
-- Name: COLUMN salida_unidad.finalizada_por; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.salida_unidad.finalizada_por IS 'Usuario que marc?? el regreso (puede ser brigadista, COP, Ops, Admin)';


--
-- Name: COLUMN salida_unidad.sede_origen_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.salida_unidad.sede_origen_id IS 'Sede desde donde sali?? la unidad';


--
-- Name: COLUMN salida_unidad.inspeccion_360_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.salida_unidad.inspeccion_360_id IS 'Inspección 360 aprobada para esta salida';


--
-- Name: salida_unidad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.salida_unidad_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: salida_unidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.salida_unidad_id_seq OWNED BY public.salida_unidad.id;


--
-- Name: sancion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sancion (
    id integer NOT NULL,
    incidente_id integer NOT NULL,
    vehiculo_id integer NOT NULL,
    piloto_id integer,
    articulo_sancion_id integer,
    descripcion text,
    monto numeric(10,2),
    pagada boolean DEFAULT false,
    fecha_pago date,
    aplicada_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE sancion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.sancion IS 'Sanciones aplicadas en incidentes a veh??culos/pilotos';


--
-- Name: sancion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sancion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sancion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sancion_id_seq OWNED BY public.sancion.id;


--
-- Name: sede_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sede_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sede_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sede_id_seq OWNED BY public.sede.id;


--
-- Name: seq_situacion_persistente; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.seq_situacion_persistente
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: situacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.situacion (
    id bigint NOT NULL,
    uuid uuid DEFAULT gen_random_uuid() NOT NULL,
    numero_situacion character varying(50),
    tipo_situacion character varying(50) NOT NULL,
    estado character varying(20) DEFAULT 'ACTIVA'::character varying,
    asignacion_id integer,
    unidad_id integer NOT NULL,
    turno_id integer,
    ruta_id integer,
    km numeric(6,2),
    sentido character varying(30),
    latitud numeric(10,8),
    longitud numeric(11,8),
    ubicacion_manual boolean DEFAULT false,
    combustible numeric(5,2),
    kilometraje_unidad numeric(8,1),
    tripulacion_confirmada jsonb,
    descripcion text,
    observaciones text,
    incidente_id integer,
    creado_por integer NOT NULL,
    actualizado_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    departamento_id integer,
    municipio_id integer,
    modificado_despues_cierre boolean DEFAULT false,
    motivo_modificacion_cierre text,
    combustible_fraccion character varying(10),
    salida_unidad_id integer,
    evento_persistente_id integer,
    obstruccion_data jsonb,
    CONSTRAINT situacion_estado_check CHECK (((estado)::text = ANY (ARRAY[('ACTIVA'::character varying)::text, ('CERRADA'::character varying)::text, ('CANCELADA'::character varying)::text]))),
    CONSTRAINT situacion_sentido_check CHECK (((sentido)::text = ANY ((ARRAY['NORTE'::character varying, 'SUR'::character varying, 'ESTE'::character varying, 'OESTE'::character varying, 'ORIENTE'::character varying, 'OCCIDENTE'::character varying, 'ASCENDENTE'::character varying, 'DESCENDENTE'::character varying, 'AMBOS'::character varying])::text[]))),
    CONSTRAINT situacion_tipo_situacion_check CHECK (((tipo_situacion)::text = ANY (ARRAY[('SALIDA_SEDE'::character varying)::text, ('PATRULLAJE'::character varying)::text, ('CAMBIO_RUTA'::character varying)::text, ('PARADA_ESTRATEGICA'::character varying)::text, ('COMIDA'::character varying)::text, ('DESCANSO'::character varying)::text, ('INCIDENTE'::character varying)::text, ('REGULACION_TRAFICO'::character varying)::text, ('ASISTENCIA_VEHICULAR'::character varying)::text, ('OTROS'::character varying)::text])))
);


--
-- Name: TABLE situacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.situacion IS 'Situaciones operativas de unidades (salidas, patrullajes, incidentes, etc.)';


--
-- Name: COLUMN situacion.tipo_situacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion.tipo_situacion IS 'Tipo de situaci??n operativa reportada';


--
-- Name: COLUMN situacion.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion.estado IS 'ACTIVA: en curso | CERRADA: finalizada | CANCELADA: cancelada';


--
-- Name: COLUMN situacion.ubicacion_manual; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion.ubicacion_manual IS 'True si la ubicaci??n fue ingresada manualmente (modo demo)';


--
-- Name: COLUMN situacion.combustible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion.combustible IS 'Nivel de combustible como decimal (0.0 a 1.0)';


--
-- Name: COLUMN situacion.kilometraje_unidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion.kilometraje_unidad IS 'Odómetro del vehículo (km, sin decimales)';


--
-- Name: COLUMN situacion.tripulacion_confirmada; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion.tripulacion_confirmada IS 'Tripulaci??n confirmada al momento de crear la situaci??n (JSON array)';


--
-- Name: COLUMN situacion.departamento_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion.departamento_id IS 'Departamento de la situaci??n';


--
-- Name: COLUMN situacion.municipio_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion.municipio_id IS 'Municipio de la situaci??n';


--
-- Name: COLUMN situacion.modificado_despues_cierre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion.modificado_despues_cierre IS 'True si fue modificado despu??s de cerrar el d??a';


--
-- Name: COLUMN situacion.motivo_modificacion_cierre; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion.motivo_modificacion_cierre IS 'Motivo de la modificaci??n post-cierre';


--
-- Name: COLUMN situacion.combustible_fraccion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion.combustible_fraccion IS 'Fracción de combustible legible (ej: 1/2, 3/4, 7/8, LLENO)';


--
-- Name: COLUMN situacion.salida_unidad_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion.salida_unidad_id IS 'Salida durante la cual se registr?? esta situaci??n';


--
-- Name: COLUMN situacion.obstruccion_data; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion.obstruccion_data IS 'Datos de obstrucci??n en formato JSON v2';


--
-- Name: situacion_fija; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.situacion_fija (
    id integer NOT NULL,
    sede_id integer NOT NULL,
    titulo character varying(150) NOT NULL,
    descripcion text,
    tipo character varying(50) NOT NULL,
    ruta_id integer,
    km_inicio numeric(10,2),
    km_fin numeric(10,2),
    punto_referencia text,
    hora_inicio time without time zone,
    hora_fin time without time zone,
    dias_semana character varying(20)[],
    fecha_inicio date NOT NULL,
    fecha_fin date,
    activa boolean DEFAULT true,
    observaciones text,
    puntos_destacar text,
    requiere_unidad_especifica boolean DEFAULT false,
    unidad_tipo_requerido character varying(50),
    creado_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE situacion_fija; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.situacion_fija IS 'Situaciones recurrentes que se asignan frecuentemente (ej: ampliación de carril)';


--
-- Name: situacion_fija_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.situacion_fija_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: situacion_fija_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.situacion_fija_id_seq OWNED BY public.situacion_fija.id;


--
-- Name: situacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.situacion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: situacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.situacion_id_seq OWNED BY public.situacion.id;


--
-- Name: situacion_multimedia; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.situacion_multimedia (
    id integer NOT NULL,
    situacion_id integer NOT NULL,
    tipo character varying(10) NOT NULL,
    orden integer,
    url_original character varying(500) NOT NULL,
    url_thumbnail character varying(500),
    nombre_archivo character varying(255) NOT NULL,
    mime_type character varying(50) NOT NULL,
    tamanio_bytes integer NOT NULL,
    ancho integer,
    alto integer,
    duracion_segundos integer,
    latitud numeric(10,8),
    longitud numeric(11,8),
    subido_por integer NOT NULL,
    created_at timestamp with time zone DEFAULT now(),
    CONSTRAINT situacion_multimedia_orden_check CHECK (((orden >= 1) AND (orden <= 3))),
    CONSTRAINT situacion_multimedia_tipo_check CHECK (((tipo)::text = ANY ((ARRAY['FOTO'::character varying, 'VIDEO'::character varying])::text[])))
);


--
-- Name: TABLE situacion_multimedia; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.situacion_multimedia IS 'Almacena referencias a fotos y videos de situaciones';


--
-- Name: COLUMN situacion_multimedia.orden; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion_multimedia.orden IS 'Orden de la foto (1-3), NULL para videos';


--
-- Name: COLUMN situacion_multimedia.url_original; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion_multimedia.url_original IS 'URL del archivo comprimido pero en calidad completa';


--
-- Name: COLUMN situacion_multimedia.url_thumbnail; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.situacion_multimedia.url_thumbnail IS 'URL del thumbnail (200x200) para previews rápidos';


--
-- Name: situacion_multimedia_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.situacion_multimedia_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: situacion_multimedia_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.situacion_multimedia_id_seq OWNED BY public.situacion_multimedia.id;


--
-- Name: situacion_persistente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.situacion_persistente (
    id integer NOT NULL,
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    numero character varying(50),
    titulo character varying(200) NOT NULL,
    tipo character varying(100) NOT NULL,
    subtipo character varying(100),
    estado public.estado_situacion_persistente DEFAULT 'ACTIVA'::public.estado_situacion_persistente NOT NULL,
    importancia character varying(20) DEFAULT 'NORMAL'::character varying,
    ruta_id integer,
    km_inicio numeric(6,2),
    km_fin numeric(6,2),
    sentido character varying(30),
    latitud numeric(10,8),
    longitud numeric(11,8),
    direccion_referencia text,
    descripcion text,
    observaciones_generales text,
    fecha_inicio timestamp with time zone DEFAULT now() NOT NULL,
    fecha_fin_estimada timestamp with time zone,
    fecha_fin_real timestamp with time zone,
    creado_por integer NOT NULL,
    cerrado_por integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    tipo_emergencia_id integer,
    situacion_origen_id integer,
    es_promocion boolean DEFAULT false,
    fecha_promocion timestamp with time zone,
    promovido_por integer,
    jurisdiccion text
);


--
-- Name: TABLE situacion_persistente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.situacion_persistente IS 'Situaciones de larga duración (días/semanas) como derrumbes, obras, etc.';


--
-- Name: situacion_persistente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.situacion_persistente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: situacion_persistente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.situacion_persistente_id_seq OWNED BY public.situacion_persistente.id;


--
-- Name: socorro_situacion_persistente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.socorro_situacion_persistente (
    id integer NOT NULL,
    situacion_persistente_id integer NOT NULL,
    tipo_socorro character varying(50) NOT NULL,
    hora_llegada time without time zone,
    nip_chapa character varying(50),
    numero_unidad character varying(50),
    nombre_comandante character varying(150),
    cantidad_elementos integer,
    subestacion character varying(100),
    cantidad_unidades integer,
    observaciones text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE socorro_situacion_persistente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.socorro_situacion_persistente IS 'Unidades de socorro en situaciones persistentes (Bomberos, Cruz Roja, CONRED)';


--
-- Name: socorro_situacion_persistente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.socorro_situacion_persistente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: socorro_situacion_persistente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.socorro_situacion_persistente_id_seq OWNED BY public.socorro_situacion_persistente.id;


--
-- Name: sub_rol_cop; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sub_rol_cop (
    id integer NOT NULL,
    codigo character varying(30) NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    puede_crear_persistentes boolean DEFAULT false NOT NULL,
    puede_cerrar_persistentes boolean DEFAULT false NOT NULL,
    puede_promover_situaciones boolean DEFAULT false NOT NULL,
    puede_asignar_unidades boolean DEFAULT true NOT NULL,
    solo_lectura boolean DEFAULT false NOT NULL,
    permisos jsonb DEFAULT '{}'::jsonb,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    puede_gestionar_usuarios boolean DEFAULT false,
    puede_gestionar_grupos boolean DEFAULT false,
    puede_ver_todos_departamentos boolean DEFAULT false
);


--
-- Name: TABLE sub_rol_cop; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.sub_rol_cop IS 'Sub-roles para usuarios COP: adminCOP, encargado_isla, sub_encargado_isla, operador';


--
-- Name: COLUMN sub_rol_cop.puede_crear_persistentes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sub_rol_cop.puede_crear_persistentes IS 'Puede crear situaciones persistentes extraordinarias';


--
-- Name: COLUMN sub_rol_cop.puede_promover_situaciones; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sub_rol_cop.puede_promover_situaciones IS 'Puede promover una situacion normal a persistente';


--
-- Name: COLUMN sub_rol_cop.solo_lectura; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.sub_rol_cop.solo_lectura IS 'Solo puede visualizar, no puede realizar acciones';


--
-- Name: sub_rol_cop_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sub_rol_cop_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sub_rol_cop_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sub_rol_cop_id_seq OWNED BY public.sub_rol_cop.id;


--
-- Name: subtipo_hecho; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.subtipo_hecho (
    id integer NOT NULL,
    tipo_hecho_id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    activo boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE subtipo_hecho; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.subtipo_hecho IS 'Subtipos espec??ficos de cada tipo de hecho';


--
-- Name: subtipo_hecho_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.subtipo_hecho_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: subtipo_hecho_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.subtipo_hecho_id_seq OWNED BY public.subtipo_hecho.id;


--
-- Name: suscripcion_alerta; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.suscripcion_alerta (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    tipo_alerta public.tipo_alerta NOT NULL,
    activa boolean DEFAULT true,
    solo_sede_id integer,
    severidad_minima public.severidad_alerta DEFAULT 'BAJA'::public.severidad_alerta,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE suscripcion_alerta; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.suscripcion_alerta IS 'Suscripciones de usuarios a tipos de alerta';


--
-- Name: suscripcion_alerta_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.suscripcion_alerta_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: suscripcion_alerta_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.suscripcion_alerta_id_seq OWNED BY public.suscripcion_alerta.id;


--
-- Name: tarjeta_circulacion; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tarjeta_circulacion (
    id integer NOT NULL,
    vehiculo_id integer NOT NULL,
    numero bigint NOT NULL,
    nit bigint,
    direccion_propietario text,
    nombre_propietario character varying(255),
    modelo integer,
    fecha_registro timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE tarjeta_circulacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tarjeta_circulacion IS 'Datos de tarjetas de circulaci??n vinculadas a veh??culos';


--
-- Name: COLUMN tarjeta_circulacion.numero; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tarjeta_circulacion.numero IS 'N??mero de tarjeta de circulaci??n';


--
-- Name: COLUMN tarjeta_circulacion.nit; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tarjeta_circulacion.nit IS 'NIT del propietario';


--
-- Name: tarjeta_circulacion_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tarjeta_circulacion_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tarjeta_circulacion_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tarjeta_circulacion_id_seq OWNED BY public.tarjeta_circulacion.id;


--
-- Name: tipo_actividad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tipo_actividad (
    id integer NOT NULL,
    nombre character varying(100) NOT NULL,
    requiere_incidente boolean DEFAULT false NOT NULL,
    color character varying(7),
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE tipo_actividad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tipo_actividad IS 'Tipos de actividades que realizan las unidades';


--
-- Name: COLUMN tipo_actividad.requiere_incidente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tipo_actividad.requiere_incidente IS 'Si la actividad debe estar asociada a un incidente';


--
-- Name: tipo_actividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tipo_actividad_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tipo_actividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tipo_actividad_id_seq OWNED BY public.tipo_actividad.id;


--
-- Name: tipo_emergencia_vial; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tipo_emergencia_vial (
    id integer NOT NULL,
    codigo character varying(50) NOT NULL,
    nombre character varying(100) NOT NULL,
    descripcion text,
    icono character varying(50),
    color character varying(20) DEFAULT '#EF4444'::character varying,
    activo boolean DEFAULT true,
    orden integer DEFAULT 0,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE tipo_emergencia_vial; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tipo_emergencia_vial IS 'Catalogo de tipos de emergencias viales para situaciones persistentes';


--
-- Name: tipo_emergencia_vial_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tipo_emergencia_vial_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tipo_emergencia_vial_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tipo_emergencia_vial_id_seq OWNED BY public.tipo_emergencia_vial.id;


--
-- Name: tipo_hecho_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tipo_hecho_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tipo_hecho_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tipo_hecho_id_seq OWNED BY public.tipo_hecho.id;


--
-- Name: tipo_vehiculo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tipo_vehiculo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tipo_vehiculo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tipo_vehiculo_id_seq OWNED BY public.tipo_vehiculo.id;


--
-- Name: tripulacion_turno; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tripulacion_turno (
    id integer NOT NULL,
    asignacion_id integer NOT NULL,
    usuario_id integer NOT NULL,
    rol_tripulacion character varying(30) NOT NULL,
    presente boolean DEFAULT true,
    observaciones text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    telefono_contacto character varying(20),
    es_comandante boolean DEFAULT false NOT NULL,
    CONSTRAINT tripulacion_turno_rol_tripulacion_check CHECK (((rol_tripulacion)::text = ANY ((ARRAY['PILOTO'::character varying, 'COPILOTO'::character varying, 'ACOMPANANTE'::character varying, 'ACOMPAÑANTE'::character varying])::text[])))
);


--
-- Name: TABLE tripulacion_turno; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.tripulacion_turno IS 'Tripulaci??n asignada a cada unidad por turno';


--
-- Name: COLUMN tripulacion_turno.rol_tripulacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tripulacion_turno.rol_tripulacion IS 'Rol del brigadista en la unidad para este turno';


--
-- Name: COLUMN tripulacion_turno.presente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tripulacion_turno.presente IS 'Si el brigadista se present?? al turno';


--
-- Name: COLUMN tripulacion_turno.telefono_contacto; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tripulacion_turno.telefono_contacto IS 'Tel??fono de contacto para este turno espec??fico (puede diferir del usuario)';


--
-- Name: COLUMN tripulacion_turno.es_comandante; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.tripulacion_turno.es_comandante IS 'TRUE = es el comandante responsable de la unidad en este turno';


--
-- Name: tripulacion_turno_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tripulacion_turno_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tripulacion_turno_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tripulacion_turno_id_seq OWNED BY public.tripulacion_turno.id;


--
-- Name: turno; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.turno (
    id integer NOT NULL,
    fecha date NOT NULL,
    estado character varying(30) DEFAULT 'PLANIFICADO'::character varying NOT NULL,
    observaciones text,
    creado_por integer NOT NULL,
    aprobado_por integer,
    fecha_aprobacion timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    fecha_fin date,
    publicado boolean DEFAULT false,
    fecha_publicacion timestamp with time zone,
    publicado_por integer,
    sede_id integer,
    CONSTRAINT turno_estado_check CHECK (((estado)::text = ANY (ARRAY[('PLANIFICADO'::character varying)::text, ('ACTIVO'::character varying)::text, ('CERRADO'::character varying)::text])))
);


--
-- Name: TABLE turno; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.turno IS 'Turnos de trabajo por d??a (planificaci??n de Operaciones)';


--
-- Name: COLUMN turno.estado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.turno.estado IS 'PLANIFICADO: creado pero no iniciado | ACTIVO: en curso | CERRADO: finalizado';


--
-- Name: COLUMN turno.fecha_fin; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.turno.fecha_fin IS 'Fecha de fin del turno. Si es NULL, el turno es de un solo día (fecha)';


--
-- Name: COLUMN turno.publicado; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.turno.publicado IS 'Si false, la asignación está en borrador y no es visible para brigadas';


--
-- Name: turno_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.turno_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: turno_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.turno_id_seq OWNED BY public.turno.id;


--
-- Name: ubicacion_brigada; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ubicacion_brigada (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    asignacion_origen_id integer NOT NULL,
    unidad_origen_id integer NOT NULL,
    unidad_actual_id integer,
    asignacion_actual_id integer,
    estado public.estado_ubicacion_brigada DEFAULT 'CON_UNIDAD'::public.estado_ubicacion_brigada NOT NULL,
    punto_fijo_km numeric(6,2),
    punto_fijo_sentido character varying(30),
    punto_fijo_ruta_id integer,
    punto_fijo_latitud numeric(10,8),
    punto_fijo_longitud numeric(11,8),
    punto_fijo_descripcion text,
    situacion_persistente_id integer,
    inicio_ubicacion timestamp with time zone DEFAULT now() NOT NULL,
    fin_ubicacion timestamp with time zone,
    creado_por integer,
    motivo text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


--
-- Name: TABLE ubicacion_brigada; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.ubicacion_brigada IS 'Rastrea la ubicación física actual de cada brigada. Permite préstamos, divisiones y cambios de unidad.';


--
-- Name: ubicacion_brigada_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ubicacion_brigada_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ubicacion_brigada_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ubicacion_brigada_id_seq OWNED BY public.ubicacion_brigada.id;


--
-- Name: unidad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.unidad_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: unidad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.unidad_id_seq OWNED BY public.unidad.id;


--
-- Name: usuario; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario (
    id integer NOT NULL,
    uuid uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    username character varying(50) NOT NULL,
    password_hash character varying(255) NOT NULL,
    nombre_completo character varying(150) NOT NULL,
    email character varying(100),
    telefono character varying(20),
    rol_id integer NOT NULL,
    sede_id integer,
    activo boolean DEFAULT true NOT NULL,
    ultimo_acceso timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    grupo smallint,
    fecha_inicio_ciclo date,
    acceso_app_activo boolean DEFAULT true,
    exento_grupos boolean DEFAULT false,
    chapa character varying(20),
    rol_brigada character varying(20),
    puede_ver_todas_sedes boolean DEFAULT false,
    genero character varying(20),
    sub_rol_cop_id integer,
    es_encargado_grupo boolean DEFAULT false,
    password_reset_required boolean DEFAULT false,
    password_last_reset timestamp without time zone,
    password_reset_by integer,
    password_reset_enabled_at timestamp without time zone,
    custom_fields jsonb DEFAULT '{}'::jsonb,
    reset_password_enabled boolean DEFAULT false NOT NULL,
    CONSTRAINT usuario_grupo_check CHECK (((grupo IS NULL) OR (grupo = ANY (ARRAY[0, 1, 2])))),
    CONSTRAINT usuario_rol_brigada_check CHECK (((rol_brigada)::text = ANY (ARRAY[('PILOTO'::character varying)::text, ('COPILOTO'::character varying)::text, ('ACOMPA??ANTE'::character varying)::text])))
);


--
-- Name: TABLE usuario; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.usuario IS 'Usuarios del sistema';


--
-- Name: COLUMN usuario.password_hash; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.password_hash IS 'Hash bcrypt de la contrase??a';


--
-- Name: COLUMN usuario.sede_id; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.sede_id IS 'Sede a la que pertenece el usuario. NULL = acceso a todas (COP)';


--
-- Name: COLUMN usuario.grupo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.grupo IS 'Grupo de trabajo: 1 o 2 (8 d??as trabajo, 8 d??as descanso)';


--
-- Name: COLUMN usuario.fecha_inicio_ciclo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.fecha_inicio_ciclo IS 'Fecha de inicio del ciclo actual (para calcular turnos)';


--
-- Name: COLUMN usuario.acceso_app_activo; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.acceso_app_activo IS 'Si el usuario tiene acceso activo a la app (controlado por COP)';


--
-- Name: COLUMN usuario.exento_grupos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.exento_grupos IS 'True si el usuario est?? exento del sistema de grupos (admins, jefes)';


--
-- Name: COLUMN usuario.chapa; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.chapa IS 'NÃºmero de chapa/identificaciÃ³n del agente';


--
-- Name: COLUMN usuario.rol_brigada; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.rol_brigada IS 'Rol espec??fico del brigadista: PILOTO, COPILOTO, ACOMPA??ANTE';


--
-- Name: COLUMN usuario.puede_ver_todas_sedes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.puede_ver_todas_sedes IS 'Si true, el usuario puede ver asignaciones de todas las sedes (solo lectura)';


--
-- Name: COLUMN usuario.genero; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.genero IS 'GÃ©nero del usuario (M/F)';


--
-- Name: COLUMN usuario.password_reset_required; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.password_reset_required IS 'Indica si el usuario debe cambiar su contraseña en el próximo login';


--
-- Name: COLUMN usuario.password_last_reset; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.password_last_reset IS 'Fecha del último cambio de contraseña';


--
-- Name: COLUMN usuario.password_reset_by; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.password_reset_by IS 'ID del admin que habilitó el reset';


--
-- Name: COLUMN usuario.password_reset_enabled_at; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON COLUMN public.usuario.password_reset_enabled_at IS 'Fecha en que se habilitó el reset';


--
-- Name: usuario_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuario_id_seq OWNED BY public.usuario.id;


--
-- Name: usuario_inactividad; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario_inactividad (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    motivo_id integer NOT NULL,
    fecha_inicio date DEFAULT CURRENT_DATE NOT NULL,
    fecha_fin_estimada date,
    fecha_fin_real date,
    observaciones text,
    registrado_por integer,
    reactivado_por integer,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


--
-- Name: TABLE usuario_inactividad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.usuario_inactividad IS 'Historial de periodos de inactividad de usuarios con motivos';


--
-- Name: usuario_inactividad_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_inactividad_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario_inactividad_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuario_inactividad_id_seq OWNED BY public.usuario_inactividad.id;


--
-- Name: usuario_rol; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.usuario_rol (
    id integer NOT NULL,
    usuario_id integer NOT NULL,
    rol_id integer NOT NULL,
    sede_id integer,
    es_rol_principal boolean DEFAULT false,
    activo boolean DEFAULT true,
    asignado_por integer,
    fecha_asignacion timestamp with time zone DEFAULT now(),
    fecha_revocacion timestamp with time zone,
    created_at timestamp with time zone DEFAULT now()
);


--
-- Name: TABLE usuario_rol; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.usuario_rol IS 'Asignación de múltiples roles a usuarios, con soporte para roles por sede';


--
-- Name: usuario_rol_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.usuario_rol_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: usuario_rol_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.usuario_rol_id_seq OWNED BY public.usuario_rol.id;


--
-- Name: v_actividades_completas; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_actividades_completas AS
 SELECT a.id,
    a.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.nombre AS sede_nombre,
    ta.nombre AS tipo_actividad,
    ta.color AS tipo_actividad_color,
    a.hora_inicio,
    a.hora_fin,
    (EXTRACT(epoch FROM (COALESCE(a.hora_fin, now()) - a.hora_inicio)) / (60)::numeric) AS duracion_min,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km,
    a.sentido,
    a.incidente_id,
    i.numero_reporte AS incidente_numero,
    usr.nombre_completo AS registrado_por_nombre,
    a.observaciones,
    a.created_at
   FROM ((((((public.actividad_unidad a
     JOIN public.unidad u ON ((a.unidad_id = u.id)))
     JOIN public.sede s ON ((u.sede_id = s.id)))
     JOIN public.tipo_actividad ta ON ((a.tipo_actividad_id = ta.id)))
     LEFT JOIN public.ruta r ON ((a.ruta_id = r.id)))
     LEFT JOIN public.incidente i ON ((a.incidente_id = i.id)))
     JOIN public.usuario usr ON ((a.registrado_por = usr.id)));


--
-- Name: v_alertas_activas; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_alertas_activas AS
 SELECT a.id,
    a.tipo,
    a.severidad,
    a.estado,
    a.titulo,
    a.mensaje,
    a.datos,
    a.sede_id,
    a.unidad_id,
    a.brigada_id,
    a.situacion_id,
    a.atendida_por,
    a.fecha_atencion,
    a.nota_resolucion,
    a.fecha_expiracion,
    a.created_at,
    a.updated_at,
    s.nombre AS sede_nombre,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    b.nombre AS brigada_nombre,
    b.codigo AS brigada_chapa,
    aten.nombre_completo AS atendida_por_nombre,
    (EXTRACT(epoch FROM (CURRENT_TIMESTAMP - (a.created_at)::timestamp with time zone)) / (60)::numeric) AS minutos_activa
   FROM ((((public.alerta a
     LEFT JOIN public.sede s ON ((a.sede_id = s.id)))
     LEFT JOIN public.unidad u ON ((a.unidad_id = u.id)))
     LEFT JOIN public.brigada b ON ((a.brigada_id = b.id)))
     LEFT JOIN public.usuario aten ON ((a.atendida_por = aten.id)))
  WHERE ((a.estado = 'ACTIVA'::public.estado_alerta) AND ((a.fecha_expiracion IS NULL) OR (a.fecha_expiracion > CURRENT_TIMESTAMP)))
  ORDER BY
        CASE a.severidad
            WHEN 'CRITICA'::public.severidad_alerta THEN 1
            WHEN 'ALTA'::public.severidad_alerta THEN 2
            WHEN 'MEDIA'::public.severidad_alerta THEN 3
            ELSE 4
        END, a.created_at DESC;


--
-- Name: v_asignaciones_completas; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_asignaciones_completas AS
 SELECT au.id,
    au.turno_id,
    t.fecha AS fecha_programada,
    au.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    au.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    au.km_inicio,
    au.km_final,
    au.sentido,
    au.acciones,
    au.hora_salida,
    au.hora_entrada_estimada,
    au.es_reaccion,
        CASE
            WHEN (au.hora_entrada_real IS NOT NULL) THEN 'FINALIZADA'::text
            WHEN (au.hora_salida_real IS NOT NULL) THEN 'EN_CURSO'::text
            ELSE 'PROGRAMADA'::text
        END AS estado,
    au.hora_salida_real,
    au.hora_entrada_real,
    ( SELECT json_agg(json_build_object('usuario_id', tt.usuario_id, 'nombre', mu.nombre_completo, 'rol', tt.rol_tripulacion, 'presente', tt.presente)) AS json_agg
           FROM (public.tripulacion_turno tt
             JOIN public.usuario mu ON ((tt.usuario_id = mu.id)))
          WHERE (tt.asignacion_id = au.id)) AS tripulacion
   FROM (((public.asignacion_unidad au
     JOIN public.turno t ON ((au.turno_id = t.id)))
     JOIN public.unidad u ON ((au.unidad_id = u.id)))
     LEFT JOIN public.ruta r ON ((au.ruta_id = r.id)));


--
-- Name: v_asignaciones_pendientes; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_asignaciones_pendientes AS
 SELECT t.id AS turno_id,
    t.fecha,
    t.fecha_fin,
    t.estado AS turno_estado,
    t.sede_id,
    a.id AS asignacion_id,
    a.id,
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    r.id AS ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.hora_salida,
    a.hora_entrada_estimada,
    a.hora_salida_real,
    a.acciones,
        CASE
            WHEN (t.fecha = CURRENT_DATE) THEN 'HOY'::text
            WHEN (t.fecha = (CURRENT_DATE + 1)) THEN 'MAÑANA'::text
            WHEN (t.fecha < CURRENT_DATE) THEN (('PENDIENTE ('::text || t.fecha) || ')'::text)
            ELSE (t.fecha)::text
        END AS dia_salida,
    ( SELECT json_agg(json_build_object('usuario_id', usr.id, 'nombre_completo', usr.nombre_completo, 'nombre', usr.nombre_completo, 'chapa', usr.chapa, 'telefono', usr.telefono, 'rol_tripulacion', tc.rol_tripulacion, 'rol', tc.rol_tripulacion) ORDER BY
                CASE tc.rol_tripulacion
                    WHEN 'PILOTO'::text THEN 1
                    WHEN 'COPILOTO'::text THEN 2
                    WHEN 'ACOMPAÑANTE'::text THEN 3
                    ELSE 4
                END) AS json_agg
           FROM (public.tripulacion_turno tc
             JOIN public.usuario usr ON ((tc.usuario_id = usr.id)))
          WHERE (tc.asignacion_id = a.id)) AS tripulacion
   FROM (((public.turno t
     JOIN public.asignacion_unidad a ON ((t.id = a.turno_id)))
     JOIN public.unidad u ON ((a.unidad_id = u.id)))
     LEFT JOIN public.ruta r ON ((a.ruta_id = r.id)))
  WHERE ((t.estado)::text = ANY ((ARRAY['PLANIFICADO'::character varying, 'ACTIVO'::character varying])::text[]))
  ORDER BY t.fecha, a.hora_salida;


--
-- Name: VIEW v_asignaciones_pendientes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_asignaciones_pendientes IS 'Muestra TODAS las asignaciones activas (PLANIFICADO/ACTIVO) sin importar la fecha.
Las asignaciones permanecen visibles hasta que se finalice la jornada o se eliminen manualmente.';


--
-- Name: v_asignaciones_por_sede; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_asignaciones_por_sede AS
 SELECT t.id AS turno_id,
    t.fecha,
    t.estado AS turno_estado,
    t.publicado,
    t.fecha_publicacion,
    t.sede_id,
    s.nombre AS sede_nombre,
    s.codigo AS sede_codigo,
    t.creado_por,
    uc.nombre_completo AS creado_por_nombre,
    cv.color_fondo,
    cv.color_fondo_header,
    cv.color_texto,
    cv.color_acento,
    cv.fuente,
    cv.tamano_fuente,
    cv.alerta_rotacion_rutas_activa,
    cv.umbral_rotacion_rutas,
    au.id AS asignacion_id,
    au.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    u.placa AS unidad_placa,
    au.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    au.km_inicio,
    au.km_final,
    au.sentido,
    au.acciones,
    au.acciones_formato,
    au.hora_salida,
    au.situacion_fija_id,
    sf.titulo AS situacion_fija_titulo,
    sf.tipo AS situacion_fija_tipo,
        CASE
            WHEN ((su.estado)::text = 'EN_SALIDA'::text) THEN true
            ELSE false
        END AS en_ruta,
    su.estado AS salida_estado,
    au.created_at AS asignacion_created_at
   FROM ((((((((public.turno t
     LEFT JOIN public.sede s ON ((t.sede_id = s.id)))
     LEFT JOIN public.usuario uc ON ((t.creado_por = uc.id)))
     LEFT JOIN public.configuracion_visual_sede cv ON ((t.sede_id = cv.sede_id)))
     LEFT JOIN public.asignacion_unidad au ON ((t.id = au.turno_id)))
     LEFT JOIN public.unidad u ON ((au.unidad_id = u.id)))
     LEFT JOIN public.ruta r ON ((au.ruta_id = r.id)))
     LEFT JOIN public.situacion_fija sf ON ((au.situacion_fija_id = sf.id)))
     LEFT JOIN public.salida_unidad su ON (((au.unidad_id = su.unidad_id) AND ((su.estado)::text = 'EN_SALIDA'::text) AND (date(su.fecha_hora_salida) = t.fecha))))
  ORDER BY t.sede_id, au.hora_salida;


--
-- Name: v_bitacora_historica_detalle; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_bitacora_historica_detalle AS
 SELECT b.id,
    b.fecha,
    b.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    u.placa AS unidad_placa,
    b.sede_origen_id,
    s.nombre AS sede_nombre,
    b.ruta_inicial_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    b.km_inicial,
    b.km_final,
    b.km_recorridos,
    b.combustible_inicial,
    b.combustible_final,
    b.hora_inicio,
    b.hora_fin,
    b.duracion_minutos,
    ( SELECT jsonb_agg(jsonb_build_object('usuario_id', ((t.value ->> 'usuario_id'::text))::integer, 'rol', (t.value ->> 'rol'::text), 'nombre', usr.nombre_completo, 'chapa', usr.chapa)) AS jsonb_agg
           FROM (jsonb_array_elements(b.tripulacion_ids) t(value)
             LEFT JOIN public.usuario usr ON ((((t.value ->> 'usuario_id'::text))::integer = usr.id)))) AS tripulacion_detalle,
    b.situaciones_resumen,
    b.total_situaciones,
    b.ingresos_resumen,
    b.total_ingresos,
    b.total_incidentes,
    b.total_asistencias,
    b.total_emergencias,
    b.total_regulaciones,
    b.total_patrullajes,
    b.observaciones_inicio,
    b.observaciones_fin,
    b.finalizado_por,
    fin.nombre_completo AS finalizado_por_nombre,
    b.created_at
   FROM ((((public.bitacora_historica b
     JOIN public.unidad u ON ((b.unidad_id = u.id)))
     LEFT JOIN public.sede s ON ((b.sede_origen_id = s.id)))
     LEFT JOIN public.ruta r ON ((b.ruta_inicial_id = r.id)))
     LEFT JOIN public.usuario fin ON ((b.finalizado_por = fin.id)));


--
-- Name: v_situaciones_completas; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_situaciones_completas AS
 SELECT s.id,
    s.uuid,
    s.numero_situacion,
    s.tipo_situacion,
    s.estado,
    s.salida_unidad_id,
    s.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km,
    s.sentido,
    s.latitud,
    s.longitud,
    s.ubicacion_manual,
    s.combustible,
    s.kilometraje_unidad,
    s.descripcion,
    s.observaciones,
    s.tripulacion_confirmada,
    s.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    u.sede_id,
    se.nombre AS sede_nombre,
    s.turno_id,
    t.fecha AS turno_fecha,
    s.asignacion_id,
    s.incidente_id,
    i.numero_reporte AS incidente_numero,
    s.creado_por,
    uc.nombre_completo AS creado_por_nombre,
    s.actualizado_por,
    ua.nombre_completo AS actualizado_por_nombre,
    s.created_at,
    s.updated_at,
    ( SELECT json_agg(json_build_object('id', d.id, 'tipo_detalle', d.tipo_detalle, 'datos', d.datos, 'created_at', d.created_at) ORDER BY d.created_at) AS json_agg
           FROM public.detalle_situacion d
          WHERE (d.situacion_id = s.id)) AS detalles
   FROM (((((((public.situacion s
     LEFT JOIN public.ruta r ON ((s.ruta_id = r.id)))
     LEFT JOIN public.unidad u ON ((s.unidad_id = u.id)))
     LEFT JOIN public.sede se ON ((u.sede_id = se.id)))
     LEFT JOIN public.turno t ON ((s.turno_id = t.id)))
     LEFT JOIN public.incidente i ON ((s.incidente_id = i.id)))
     LEFT JOIN public.usuario uc ON ((s.creado_por = uc.id)))
     LEFT JOIN public.usuario ua ON ((s.actualizado_por = ua.id)))
  ORDER BY s.created_at DESC;


--
-- Name: v_bitacora_unidad; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_bitacora_unidad AS
 SELECT s.id,
    s.uuid,
    s.numero_situacion,
    s.unidad_id,
    u.codigo AS unidad_codigo,
    s.tipo_situacion,
    s.estado,
    s.salida_unidad_id,
    s.ruta_codigo,
    s.km,
    s.sentido,
    s.latitud,
    s.longitud,
    s.descripcion,
    s.observaciones,
    s.created_at AS fecha_hora,
    s.creado_por_nombre AS reportado_por,
    s.turno_fecha,
    s.sede_id,
    s.sede_nombre,
        CASE
            WHEN ((s.estado)::text = 'CERRADA'::text) THEN (EXTRACT(epoch FROM (s.updated_at - s.created_at)) / (60)::numeric)
            ELSE NULL::numeric
        END AS duracion_minutos,
        CASE
            WHEN (s.detalles IS NOT NULL) THEN true
            ELSE false
        END AS tiene_detalles,
    ( SELECT json_object_agg(detalles_count.tipo_detalle, detalles_count.cantidad) AS json_object_agg
           FROM ( SELECT d.tipo_detalle,
                    count(*) AS cantidad
                   FROM public.detalle_situacion d
                  WHERE (d.situacion_id = s.id)
                  GROUP BY d.tipo_detalle) detalles_count) AS resumen_detalles
   FROM (public.v_situaciones_completas s
     JOIN public.unidad u ON ((s.unidad_id = u.id)))
  ORDER BY s.unidad_id, s.created_at DESC;


--
-- Name: v_brigadas_activas_ahora; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_brigadas_activas_ahora AS
 SELECT DISTINCT u.id AS usuario_id,
    u.nombre_completo,
    u.grupo,
    m.turno_id,
    m.destino_asignacion_id AS asignacion_actual,
    m.destino_unidad_id AS unidad_actual,
    un.codigo AS unidad_codigo,
    m.tipo_movimiento,
    m.rol_en_destino,
    m.motivo,
    m.hora_inicio,
    (EXTRACT(epoch FROM (now() - m.hora_inicio)) / (3600)::numeric) AS horas_en_posicion
   FROM ((public.movimiento_brigada m
     JOIN public.usuario u ON ((m.usuario_id = u.id)))
     LEFT JOIN public.unidad un ON ((m.destino_unidad_id = un.id)))
  WHERE ((m.hora_fin IS NULL) AND (date(m.hora_inicio) = CURRENT_DATE))
  ORDER BY u.nombre_completo;


--
-- Name: VIEW v_brigadas_activas_ahora; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_brigadas_activas_ahora IS 'Brigadas actualmente en servicio con su ubicaci??n actual';


--
-- Name: v_brigadas_con_asignaciones_activas; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_brigadas_con_asignaciones_activas AS
 SELECT u.id AS usuario_id,
    u.nombre_completo,
    u.grupo,
    t.id AS turno_id,
    t.fecha AS turno_fecha,
    au.id AS asignacion_id,
    un.codigo AS unidad_codigo,
    tt.rol_tripulacion,
    tt.presente,
    au.dia_cerrado
   FROM ((((public.usuario u
     JOIN public.tripulacion_turno tt ON ((u.id = tt.usuario_id)))
     JOIN public.asignacion_unidad au ON ((tt.asignacion_id = au.id)))
     JOIN public.turno t ON ((au.turno_id = t.id)))
     JOIN public.unidad un ON ((au.unidad_id = un.id)))
  WHERE ((t.fecha = CURRENT_DATE) AND (au.dia_cerrado = false))
  ORDER BY un.codigo, tt.rol_tripulacion;


--
-- Name: VIEW v_brigadas_con_asignaciones_activas; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_brigadas_con_asignaciones_activas IS 'Brigadas que tienen asignaciones activas hoy';


--
-- Name: v_composicion_unidades_ahora; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_composicion_unidades_ahora AS
 SELECT un.id AS unidad_id,
    un.codigo AS unidad_codigo,
    json_agg(json_build_object('usuario_id', u.id, 'nombre', u.nombre_completo, 'rol', m.rol_en_destino, 'tipo_movimiento', m.tipo_movimiento, 'desde', m.hora_inicio, 'motivo', m.motivo) ORDER BY
        CASE m.rol_en_destino
            WHEN 'PILOTO'::text THEN 1
            WHEN 'COPILOTO'::text THEN 2
            WHEN 'ACOMPA??ANTE'::text THEN 3
            ELSE 4
        END) AS tripulacion_actual,
    count(*) AS total_brigadas
   FROM ((public.movimiento_brigada m
     JOIN public.usuario u ON ((m.usuario_id = u.id)))
     JOIN public.unidad un ON ((m.destino_unidad_id = un.id)))
  WHERE ((m.hora_fin IS NULL) AND (date(m.hora_inicio) = CURRENT_DATE))
  GROUP BY un.id, un.codigo
  ORDER BY un.codigo;


--
-- Name: VIEW v_composicion_unidades_ahora; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_composicion_unidades_ahora IS 'Tripulaci??n actual de cada unidad en tiempo real';


--
-- Name: v_disponibilidad_recursos; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_disponibilidad_recursos AS
 SELECT s.id AS sede_id,
    s.nombre AS sede_nombre,
    count(DISTINCT u.id) FILTER (WHERE (((r.nombre)::text = 'BRIGADA'::text) AND (u.activo = true))) AS total_brigadas_activas,
    count(DISTINCT tt.usuario_id) FILTER (WHERE ((t.fecha = CURRENT_DATE) AND ((r.nombre)::text = 'BRIGADA'::text) AND (u.activo = true))) AS brigadas_en_turno_hoy,
    count(DISTINCT un.id) FILTER (WHERE (un.activa = true)) AS total_unidades_activas,
    count(DISTINCT au.unidad_id) FILTER (WHERE (t.fecha = CURRENT_DATE)) AS unidades_en_turno_hoy,
    count(DISTINCT u.id) FILTER (WHERE (((r.nombre)::text = 'BRIGADA'::text) AND (u.activo = true) AND (NOT (u.id IN ( SELECT tt2.usuario_id
           FROM ((public.tripulacion_turno tt2
             JOIN public.asignacion_unidad au2 ON ((tt2.asignacion_id = au2.id)))
             JOIN public.turno t2 ON ((au2.turno_id = t2.id)))
          WHERE (t2.fecha = CURRENT_DATE)))))) AS brigadas_disponibles_hoy,
    count(DISTINCT un.id) FILTER (WHERE ((un.activa = true) AND (NOT (un.id IN ( SELECT au3.unidad_id
           FROM (public.asignacion_unidad au3
             JOIN public.turno t3 ON ((au3.turno_id = t3.id)))
          WHERE (t3.fecha = CURRENT_DATE)))))) AS unidades_disponibles_hoy
   FROM ((((((public.sede s
     LEFT JOIN public.usuario u ON ((s.id = u.sede_id)))
     LEFT JOIN public.rol r ON ((u.rol_id = r.id)))
     LEFT JOIN public.unidad un ON ((s.id = un.sede_id)))
     LEFT JOIN public.tripulacion_turno tt ON ((u.id = tt.usuario_id)))
     LEFT JOIN public.asignacion_unidad au ON (((tt.asignacion_id = au.id) AND (un.id = au.unidad_id))))
     LEFT JOIN public.turno t ON ((au.turno_id = t.id)))
  GROUP BY s.id, s.nombre;


--
-- Name: v_encargados_actuales; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_encargados_actuales AS
 SELECT h.id AS asignacion_id,
    h.usuario_id,
    u.nombre_completo,
    u.chapa,
    u.telefono,
    u.email,
    h.sede_id,
    s.codigo AS sede_codigo,
    s.nombre AS sede_nombre,
    h.grupo,
        CASE h.grupo
            WHEN 0 THEN 'Normal (L-V)'::text
            WHEN 1 THEN 'Grupo 1'::text
            WHEN 2 THEN 'Grupo 2'::text
            ELSE NULL::text
        END AS grupo_nombre,
    h.fecha_inicio,
    h.motivo_asignacion,
    ua.nombre_completo AS asignado_por_nombre,
    h.created_at
   FROM (((public.historial_encargado_sede_grupo h
     JOIN public.usuario u ON ((u.id = h.usuario_id)))
     JOIN public.sede s ON ((s.id = h.sede_id)))
     LEFT JOIN public.usuario ua ON ((ua.id = h.asignado_por)))
  WHERE (h.fecha_fin IS NULL);


--
-- Name: v_estadisticas_brigadas; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_estadisticas_brigadas AS
 SELECT u.id AS usuario_id,
    u.nombre_completo,
    u.chapa,
    u.telefono,
    u.sede_id,
    s.nombre AS sede_nombre,
    r.nombre AS rol_nombre,
    count(DISTINCT t.id) FILTER (WHERE (t.fecha >= (CURRENT_DATE - '30 days'::interval))) AS turnos_ultimo_mes,
    count(DISTINCT t.id) FILTER (WHERE (t.fecha >= (CURRENT_DATE - '90 days'::interval))) AS turnos_ultimo_trimestre,
    max(t.fecha) AS ultimo_turno_fecha,
    (CURRENT_DATE - max(t.fecha)) AS dias_desde_ultimo_turno,
    min(t.fecha) FILTER (WHERE (t.fecha >= CURRENT_DATE)) AS proximo_turno_fecha,
    mode() WITHIN GROUP (ORDER BY tt.rol_tripulacion) AS rol_tripulacion_frecuente,
    u.activo
   FROM (((((public.usuario u
     JOIN public.sede s ON ((u.sede_id = s.id)))
     JOIN public.rol r ON ((u.rol_id = r.id)))
     LEFT JOIN public.tripulacion_turno tt ON ((u.id = tt.usuario_id)))
     LEFT JOIN public.asignacion_unidad au ON ((tt.asignacion_id = au.id)))
     LEFT JOIN public.turno t ON ((au.turno_id = t.id)))
  WHERE ((r.nombre)::text = 'BRIGADA'::text)
  GROUP BY u.id, u.nombre_completo, u.chapa, u.telefono, u.sede_id, s.nombre, r.nombre, u.activo;


--
-- Name: v_estadisticas_unidades; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_estadisticas_unidades AS
SELECT
    NULL::integer AS unidad_id,
    NULL::character varying(20) AS unidad_codigo,
    NULL::character varying(50) AS tipo_unidad,
    NULL::character varying(50) AS marca,
    NULL::character varying(50) AS modelo,
    NULL::integer AS sede_id,
    NULL::character varying(100) AS sede_nombre,
    NULL::boolean AS activa,
    NULL::numeric(6,2) AS combustible_actual,
    NULL::numeric(6,2) AS capacidad_combustible,
    NULL::numeric(10,2) AS odometro_actual,
    NULL::bigint AS turnos_ultimo_mes,
    NULL::bigint AS turnos_ultimo_trimestre,
    NULL::date AS ultimo_turno_fecha,
    NULL::integer AS dias_desde_ultimo_uso,
    NULL::date AS proximo_turno_fecha,
    NULL::numeric AS consumo_promedio_diario,
    NULL::numeric AS rendimiento_promedio,
    NULL::numeric AS km_ultimo_mes;


--
-- Name: v_estado_actual_unidades; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_estado_actual_unidades AS
 SELECT DISTINCT ON (u.id) u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.nombre AS sede_nombre,
    u.activa,
    ta.nombre AS actividad_actual,
    ta.color AS actividad_color,
    a.hora_inicio AS desde,
    r.codigo AS ruta_codigo,
    a.km,
    a.sentido,
    a.observaciones,
    i.numero_reporte AS incidente_numero,
    i.estado AS incidente_estado
   FROM (((((public.unidad u
     JOIN public.sede s ON ((u.sede_id = s.id)))
     LEFT JOIN LATERAL ( SELECT au.id,
            au.unidad_id,
            au.tipo_actividad_id,
            au.incidente_id,
            au.ruta_id,
            au.km,
            au.sentido,
            au.hora_inicio,
            au.hora_fin,
            au.observaciones,
            au.registrado_por,
            au.created_at,
            au.updated_at,
            au.asignacion_id
           FROM public.actividad_unidad au
          WHERE ((au.unidad_id = u.id) AND (au.hora_fin IS NULL))
          ORDER BY au.hora_inicio DESC
         LIMIT 1) a ON (true))
     LEFT JOIN public.tipo_actividad ta ON ((a.tipo_actividad_id = ta.id)))
     LEFT JOIN public.ruta r ON ((a.ruta_id = r.id)))
     LEFT JOIN public.incidente i ON ((a.incidente_id = i.id)))
  ORDER BY u.id;


--
-- Name: v_estado_grupos_actual; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_estado_grupos_actual AS
 SELECT ds.id AS departamento_id,
    ds.codigo AS departamento_codigo,
    ds.nombre AS departamento_nombre,
    s.id AS sede_id,
    s.codigo AS sede_codigo,
    s.nombre AS sede_nombre,
    egd.grupo,
        CASE egd.grupo
            WHEN 0 THEN 'Normal (L-V)'::text
            WHEN 1 THEN 'Grupo 1'::text
            WHEN 2 THEN 'Grupo 2'::text
            ELSE NULL::text
        END AS grupo_nombre,
    COALESCE(egd.activo, true) AS activo,
    egd.fecha_modificacion,
    egd.observaciones,
    u.nombre_completo AS modificado_por_nombre
   FROM ((((public.departamento_sistema ds
     CROSS JOIN public.sede s)
     CROSS JOIN ( SELECT 0 AS grupo
        UNION
         SELECT 1
        UNION
         SELECT 2) g)
     LEFT JOIN public.estado_grupo_departamento egd ON (((egd.departamento_id = ds.id) AND (egd.sede_id = s.id) AND (egd.grupo = g.grupo))))
     LEFT JOIN public.usuario u ON ((u.id = egd.modificado_por)))
  WHERE ((ds.usa_sistema_grupos = true) AND (ds.activo = true) AND (s.activa = true));


--
-- Name: v_estado_grupos_detallado; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_estado_grupos_detallado AS
 SELECT g.grupo,
    g.fecha,
    g.estado,
    count(DISTINCT u.id) AS total_brigadas,
    count(DISTINCT
        CASE
            WHEN (bu.id IS NOT NULL) THEN u.id
            ELSE NULL::integer
        END) AS brigadas_con_asignacion,
    json_agg(DISTINCT jsonb_build_object('brigada_id', u.id, 'nombre', u.nombre_completo, 'unidad_id', un.id, 'unidad_codigo', un.codigo)) FILTER (WHERE (bu.id IS NOT NULL)) AS brigadas_asignadas
   FROM (((public.calendario_grupo g
     LEFT JOIN public.usuario u ON (((u.grupo = g.grupo) AND (u.activo = true))))
     LEFT JOIN public.brigada_unidad bu ON (((bu.brigada_id = u.id) AND (bu.activo = true))))
     LEFT JOIN public.unidad un ON ((un.id = bu.unidad_id)))
  WHERE (g.fecha >= CURRENT_DATE)
  GROUP BY g.grupo, g.fecha, g.estado
  ORDER BY g.fecha, g.grupo;


--
-- Name: v_estado_grupos_hoy; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_estado_grupos_hoy AS
 SELECT grupo,
    estado,
        CASE
            WHEN ((estado)::text = 'TRABAJO'::text) THEN true
            ELSE false
        END AS esta_de_turno
   FROM public.calendario_grupo
  WHERE (fecha = CURRENT_DATE);


--
-- Name: VIEW v_estado_grupos_hoy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_estado_grupos_hoy IS 'Estado actual de cada grupo (TRABAJO o DESCANSO)';


--
-- Name: v_historial_cambios_usuario; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_historial_cambios_usuario AS
 SELECT rc.id,
    rc.tipo_cambio,
    rc.usuario_afectado_id,
    u_afectado.nombre_completo AS usuario_afectado,
    rc.motivo,
    rc.valores_anteriores,
    rc.valores_nuevos,
    rc.realizado_por,
    u_realizado.nombre_completo AS realizado_por_nombre,
    rc.autorizado_por,
    u_autorizado.nombre_completo AS autorizado_por_nombre,
    rc.created_at
   FROM (((public.registro_cambio rc
     LEFT JOIN public.usuario u_afectado ON ((rc.usuario_afectado_id = u_afectado.id)))
     LEFT JOIN public.usuario u_realizado ON ((rc.realizado_por = u_realizado.id)))
     LEFT JOIN public.usuario u_autorizado ON ((rc.autorizado_por = u_autorizado.id)))
  ORDER BY rc.created_at DESC;


--
-- Name: VIEW v_historial_cambios_usuario; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_historial_cambios_usuario IS 'Historial completo de cambios con informaci??n de usuarios';


--
-- Name: v_historial_inspecciones_360; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_historial_inspecciones_360 AS
 SELECT i.id AS inspeccion_id,
    i.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    i.salida_id,
    i.fecha_realizacion,
    i.fecha_aprobacion,
    i.estado,
    insp.nombre_completo AS inspector_nombre,
    insp.chapa AS inspector_chapa,
    apr.nombre_completo AS aprobador_nombre,
    apr.chapa AS aprobador_chapa,
    i.observaciones_inspector,
    i.observaciones_comandante,
    i.motivo_rechazo,
    p.nombre AS plantilla_nombre
   FROM ((((public.inspeccion_360 i
     JOIN public.unidad u ON ((i.unidad_id = u.id)))
     JOIN public.usuario insp ON ((i.realizado_por = insp.id)))
     LEFT JOIN public.usuario apr ON ((i.aprobado_por = apr.id)))
     JOIN public.plantilla_inspeccion_360 p ON ((i.plantilla_id = p.id)))
  ORDER BY i.fecha_realizacion DESC;


--
-- Name: VIEW v_historial_inspecciones_360; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_historial_inspecciones_360 IS 'Historial completo de inspecciones 360';


--
-- Name: v_historial_movimientos; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_historial_movimientos AS
 SELECT m.id,
    m.usuario_id,
    u.nombre_completo,
    m.turno_id,
    t.fecha AS turno_fecha,
    m.tipo_movimiento,
    m.origen_unidad_id,
    uo.codigo AS origen_unidad_codigo,
    m.destino_unidad_id,
    ud.codigo AS destino_unidad_codigo,
    m.hora_inicio,
    m.hora_fin,
        CASE
            WHEN (m.hora_fin IS NOT NULL) THEN (EXTRACT(epoch FROM (m.hora_fin - m.hora_inicio)) / (3600)::numeric)
            ELSE (EXTRACT(epoch FROM (now() - m.hora_inicio)) / (3600)::numeric)
        END AS duracion_horas,
    m.motivo,
    m.rol_en_destino,
    m.created_at
   FROM ((((public.movimiento_brigada m
     JOIN public.usuario u ON ((m.usuario_id = u.id)))
     LEFT JOIN public.turno t ON ((m.turno_id = t.id)))
     LEFT JOIN public.unidad uo ON ((m.origen_unidad_id = uo.id)))
     LEFT JOIN public.unidad ud ON ((m.destino_unidad_id = ud.id)))
  ORDER BY m.created_at DESC;


--
-- Name: VIEW v_historial_movimientos; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_historial_movimientos IS 'Historial completo de movimientos de brigadas';


--
-- Name: v_incidentes_completos; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_incidentes_completos AS
 SELECT i.id,
    i.uuid,
    i.numero_reporte,
    i.origen,
    i.estado,
    i.tipo_hecho_id,
    i.subtipo_hecho_id,
    i.ruta_id,
    i.km,
    i.sentido,
    i.referencia_ubicacion,
    i.latitud,
    i.longitud,
    i.unidad_id,
    i.brigada_id,
    i.fecha_hora_aviso,
    i.fecha_hora_asignacion,
    i.fecha_hora_llegada,
    i.fecha_hora_estabilizacion,
    i.fecha_hora_finalizacion,
    i.hay_heridos,
    i.cantidad_heridos,
    i.hay_fallecidos,
    i.cantidad_fallecidos,
    i.requiere_bomberos,
    i.requiere_pnc,
    i.requiere_ambulancia,
    i.observaciones_iniciales,
    i.observaciones_finales,
    i.condiciones_climaticas,
    i.tipo_pavimento,
    i.iluminacion,
    i.senalizacion,
    i.visibilidad,
    i.causa_probable,
    i.reportado_por_nombre,
    i.reportado_por_telefono,
    i.reportado_por_email,
    i.foto_url,
    i.creado_por,
    i.actualizado_por,
    i.created_at,
    i.updated_at,
    i.asignacion_id,
    i.departamento_id,
    i.municipio_id,
    i.jurisdiccion,
    i.direccion_detallada,
    i.obstruccion_detalle,
    i.danios_infraestructura_desc,
    i.danios_materiales,
    i.danios_infraestructura,
    th.nombre AS tipo_hecho,
    th.color AS tipo_hecho_color,
    th.icono AS tipo_hecho_icono,
    sth.nombre AS subtipo_hecho,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    u.codigo AS unidad_codigo,
    b.nombre_completo AS brigada_nombre,
    c.nombre_completo AS creado_por_nombre
   FROM ((((((public.incidente i
     JOIN public.tipo_hecho th ON ((i.tipo_hecho_id = th.id)))
     LEFT JOIN public.subtipo_hecho sth ON ((i.subtipo_hecho_id = sth.id)))
     JOIN public.ruta r ON ((i.ruta_id = r.id)))
     LEFT JOIN public.unidad u ON ((i.unidad_id = u.id)))
     LEFT JOIN public.usuario b ON ((i.brigada_id = b.id)))
     JOIN public.usuario c ON ((i.creado_por = c.id)));


--
-- Name: v_inspecciones_360_pendientes; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_inspecciones_360_pendientes AS
 SELECT i.id AS inspeccion_id,
    i.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    i.salida_id,
    i.fecha_realizacion,
    i.estado,
    insp.id AS inspector_id,
    insp.nombre_completo AS inspector_nombre,
    insp.chapa AS inspector_chapa,
    cmd.usuario_id AS comandante_id,
    cmd.nombre_completo AS comandante_nombre,
    cmd.chapa AS comandante_chapa,
    p.nombre AS plantilla_nombre,
    p.version AS plantilla_version,
    (EXTRACT(epoch FROM (now() - i.fecha_realizacion)) / (60)::numeric) AS minutos_esperando
   FROM ((((public.inspeccion_360 i
     JOIN public.unidad u ON ((i.unidad_id = u.id)))
     JOIN public.usuario insp ON ((i.realizado_por = insp.id)))
     JOIN public.plantilla_inspeccion_360 p ON ((i.plantilla_id = p.id)))
     LEFT JOIN LATERAL public.obtener_comandante_unidad(i.unidad_id) cmd(usuario_id, nombre_completo, chapa, tipo_asignacion) ON (true))
  WHERE ((i.estado)::text = 'PENDIENTE'::text)
  ORDER BY i.fecha_realizacion;


--
-- Name: VIEW v_inspecciones_360_pendientes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_inspecciones_360_pendientes IS 'Inspecciones 360 pendientes de aprobación';


--
-- Name: v_mi_asignacion_hoy; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_mi_asignacion_hoy AS
 SELECT usr.id AS usuario_id,
    usr.nombre_completo,
    t.id AS turno_id,
    t.fecha,
    t.fecha_fin,
    t.estado AS turno_estado,
    a.id AS asignacion_id,
    u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    tc.rol_tripulacion AS mi_rol,
    r.id AS ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.acciones,
        CASE
            WHEN ((a.km_inicio IS NOT NULL) AND (a.km_final IS NOT NULL)) THEN ((('Km '::text || a.km_inicio) || ' - Km '::text) || a.km_final)
            WHEN (a.km_inicio IS NOT NULL) THEN ('Desde Km '::text || a.km_inicio)
            WHEN (a.km_final IS NOT NULL) THEN ('Hasta Km '::text || a.km_final)
            ELSE NULL::text
        END AS recorrido_permitido,
    a.hora_salida,
    a.hora_entrada_estimada,
    a.hora_salida_real,
        CASE
            WHEN (t.fecha = CURRENT_DATE) THEN 0
            ELSE (t.fecha - CURRENT_DATE)
        END AS dias_para_salida,
    ( SELECT json_agg(json_build_object('usuario_id', u2.id, 'nombre', u2.nombre_completo, 'chapa', u2.chapa, 'rol', tc2.rol_tripulacion, 'telefono', u2.telefono) ORDER BY
                CASE tc2.rol_tripulacion
                    WHEN 'PILOTO'::text THEN 1
                    WHEN 'COPILOTO'::text THEN 2
                    WHEN 'ACOMPANANTE'::text THEN 3
                    ELSE 4
                END) AS json_agg
           FROM (public.tripulacion_turno tc2
             JOIN public.usuario u2 ON ((tc2.usuario_id = u2.id)))
          WHERE ((tc2.asignacion_id = a.id) AND (tc2.usuario_id <> usr.id))) AS companeros
   FROM (((((public.usuario usr
     JOIN public.tripulacion_turno tc ON ((usr.id = tc.usuario_id)))
     JOIN public.asignacion_unidad a ON ((tc.asignacion_id = a.id)))
     JOIN public.turno t ON ((a.turno_id = t.id)))
     JOIN public.unidad u ON ((a.unidad_id = u.id)))
     LEFT JOIN public.ruta r ON ((a.ruta_id = r.id)))
  WHERE (((t.fecha >= CURRENT_DATE) OR ((t.fecha_fin IS NOT NULL) AND (t.fecha_fin >= CURRENT_DATE))) AND ((t.estado)::text = ANY ((ARRAY['PLANIFICADO'::character varying, 'ACTIVO'::character varying])::text[])) AND (a.hora_entrada_real IS NULL));


--
-- Name: VIEW v_mi_asignacion_hoy; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_mi_asignacion_hoy IS 'Muestra la proxima asignacion del brigada (hoy o futura). Incluye ruta_id, companeros y detalles.';


--
-- Name: v_mi_salida_activa; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_mi_salida_activa AS
 SELECT u.id AS brigada_id,
    u.chapa,
    u.nombre_completo,
    s.id AS salida_id,
    s.unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    s.estado,
    s.fecha_hora_salida,
    s.fecha_hora_regreso,
    (EXTRACT(epoch FROM (COALESCE(s.fecha_hora_regreso, now()) - s.fecha_hora_salida)) / (3600)::numeric) AS horas_salida,
    s.ruta_inicial_id AS ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km_inicial,
    s.combustible_inicial,
    s.tripulacion,
    'PERMANENTE'::text AS tipo_asignacion,
    bu.rol_tripulacion AS mi_rol,
    ( SELECT json_build_object('id', sit.id, 'tipo', sit.tipo_situacion, 'fecha_hora', sit.created_at) AS json_build_object
           FROM public.situacion sit
          WHERE (sit.salida_unidad_id = s.id)
          ORDER BY sit.created_at
         LIMIT 1) AS primera_situacion
   FROM ((((public.usuario u
     JOIN public.brigada_unidad bu ON (((u.id = bu.brigada_id) AND (bu.activo = true))))
     JOIN public.unidad un ON ((bu.unidad_id = un.id)))
     JOIN public.salida_unidad s ON (((un.id = s.unidad_id) AND ((s.estado)::text = 'EN_SALIDA'::text))))
     LEFT JOIN public.ruta r ON ((s.ruta_inicial_id = r.id)))
UNION ALL
 SELECT u.id AS brigada_id,
    u.chapa,
    u.nombre_completo,
    s.id AS salida_id,
    s.unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    s.estado,
    s.fecha_hora_salida,
    s.fecha_hora_regreso,
    (EXTRACT(epoch FROM (COALESCE(s.fecha_hora_regreso, now()) - s.fecha_hora_salida)) / (3600)::numeric) AS horas_salida,
    s.ruta_inicial_id AS ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km_inicial,
    s.combustible_inicial,
    s.tripulacion,
    'TURNO'::text AS tipo_asignacion,
    tt.rol_tripulacion AS mi_rol,
    ( SELECT json_build_object('id', sit.id, 'tipo', sit.tipo_situacion, 'fecha_hora', sit.created_at) AS json_build_object
           FROM public.situacion sit
          WHERE (sit.salida_unidad_id = s.id)
          ORDER BY sit.created_at
         LIMIT 1) AS primera_situacion
   FROM ((((((public.usuario u
     JOIN public.tripulacion_turno tt ON ((u.id = tt.usuario_id)))
     JOIN public.asignacion_unidad au ON ((tt.asignacion_id = au.id)))
     JOIN public.turno t ON ((au.turno_id = t.id)))
     JOIN public.unidad un ON ((au.unidad_id = un.id)))
     JOIN public.salida_unidad s ON (((un.id = s.unidad_id) AND ((s.estado)::text = 'EN_SALIDA'::text))))
     LEFT JOIN public.ruta r ON ((s.ruta_inicial_id = r.id)))
  WHERE (((t.estado)::text = ANY (ARRAY[('PLANIFICADO'::character varying)::text, ('ACTIVO'::character varying)::text])) AND (date(s.fecha_hora_salida) = CURRENT_DATE));


--
-- Name: v_mi_unidad_asignada; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_mi_unidad_asignada AS
 SELECT u.id AS brigada_id,
    u.username,
    u.chapa,
    u.nombre_completo,
    bu.id AS asignacion_id,
    bu.unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    bu.rol_tripulacion AS mi_rol,
    bu.fecha_asignacion,
    bu.activo,
    ( SELECT json_agg(json_build_object('brigada_id', u2.id, 'chapa', u2.chapa, 'nombre', u2.nombre_completo, 'rol', bu2.rol_tripulacion) ORDER BY
                CASE bu2.rol_tripulacion
                    WHEN 'PILOTO'::text THEN 1
                    WHEN 'COPILOTO'::text THEN 2
                    WHEN 'ACOMPA??ANTE'::text THEN 3
                    ELSE NULL::integer
                END) AS json_agg
           FROM (public.brigada_unidad bu2
             JOIN public.usuario u2 ON ((bu2.brigada_id = u2.id)))
          WHERE ((bu2.unidad_id = bu.unidad_id) AND (bu2.activo = true) AND (bu2.brigada_id <> u.id))) AS companeros
   FROM ((public.usuario u
     JOIN public.brigada_unidad bu ON ((u.id = bu.brigada_id)))
     JOIN public.unidad un ON ((bu.unidad_id = un.id)))
  WHERE (bu.activo = true);


--
-- Name: v_mis_alertas_no_leidas; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_mis_alertas_no_leidas AS
 SELECT a.id,
    a.tipo,
    a.severidad,
    a.estado,
    a.titulo,
    a.mensaje,
    a.datos,
    a.sede_id,
    a.unidad_id,
    a.brigada_id,
    a.situacion_id,
    a.atendida_por,
    a.fecha_atencion,
    a.nota_resolucion,
    a.fecha_expiracion,
    a.created_at,
    a.updated_at,
    s.nombre AS sede_nombre,
    u.codigo AS unidad_codigo,
    b.nombre AS brigada_nombre
   FROM (((public.alerta a
     LEFT JOIN public.sede s ON ((a.sede_id = s.id)))
     LEFT JOIN public.unidad u ON ((a.unidad_id = u.id)))
     LEFT JOIN public.brigada b ON ((a.brigada_id = b.id)))
  WHERE ((a.estado = 'ACTIVA'::public.estado_alerta) AND ((a.fecha_expiracion IS NULL) OR (a.fecha_expiracion > CURRENT_TIMESTAMP)));


--
-- Name: v_mis_aprobaciones_pendientes; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_mis_aprobaciones_pendientes AS
 SELECT at.id AS aprobacion_id,
    at.tipo,
    at.estado AS estado_aprobacion,
    at.fecha_inicio,
    at.tiempo_limite_minutos,
    at.observaciones,
    ar.usuario_id,
    ar.respuesta,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    su.id AS salida_id,
    (EXTRACT(epoch FROM ((at.fecha_inicio + ((at.tiempo_limite_minutos || ' minutes'::text))::interval) - now())) / (60)::numeric) AS minutos_restantes,
    ui.nombre_completo AS iniciado_por_nombre
   FROM ((((public.aprobacion_respuesta ar
     JOIN public.aprobacion_tripulacion at ON ((at.id = ar.aprobacion_id)))
     JOIN public.unidad u ON ((u.id = at.unidad_id)))
     LEFT JOIN public.salida_unidad su ON ((su.id = at.salida_id)))
     LEFT JOIN public.usuario ui ON ((ui.id = at.iniciado_por)))
  WHERE (((at.estado)::text = 'PENDIENTE'::text) AND ((ar.respuesta)::text = 'PENDIENTE'::text));


--
-- Name: VIEW v_mis_aprobaciones_pendientes; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_mis_aprobaciones_pendientes IS 'Aprobaciones pendientes de respuesta por usuario';


--
-- Name: vehiculo_accidente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehiculo_accidente (
    id integer NOT NULL,
    hoja_accidentologia_id integer NOT NULL,
    numero_vehiculo integer NOT NULL,
    tipo_vehiculo public.tipo_vehiculo_accidente NOT NULL,
    placa character varying(20),
    marca character varying(50),
    linea character varying(50),
    modelo_anio integer,
    color character varying(30),
    numero_chasis character varying(50),
    numero_motor character varying(50),
    danos_descripcion text,
    danos_estimados numeric(12,2),
    posicion_final text,
    propietario_nombre character varying(150),
    propietario_dpi character varying(20),
    propietario_telefono character varying(20),
    propietario_direccion text,
    conductor_nombre character varying(150),
    conductor_dpi character varying(20),
    conductor_licencia_tipo character varying(10),
    conductor_licencia_numero character varying(30),
    conductor_telefono character varying(20),
    conductor_direccion text,
    conductor_estado public.estado_persona_accidente,
    tiene_seguro boolean DEFAULT false,
    aseguradora character varying(100),
    numero_poliza character varying(50),
    fotos text[],
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);


--
-- Name: TABLE vehiculo_accidente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.vehiculo_accidente IS 'Vehículos involucrados en accidente';


--
-- Name: v_resumen_accidentologia; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_resumen_accidentologia AS
 SELECT ha.id,
    ha.situacion_id,
    s.created_at AS fecha_hora_reporte,
    ha.tipo_accidente,
    ha.descripcion_accidente,
    concat(s.km, ' km, ', s.sentido) AS ubicacion_texto,
    m.nombre AS municipio,
    d.nombre AS departamento,
    ha.estado,
    ( SELECT count(*) AS count
           FROM public.vehiculo_accidente
          WHERE (vehiculo_accidente.hoja_accidentologia_id = ha.id)) AS total_vehiculos,
    ( SELECT count(*) AS count
           FROM public.persona_accidente
          WHERE (persona_accidente.hoja_accidentologia_id = ha.id)) AS total_personas,
    ( SELECT count(*) AS count
           FROM public.persona_accidente
          WHERE ((persona_accidente.hoja_accidentologia_id = ha.id) AND (persona_accidente.estado = ANY (ARRAY['HERIDO_LEVE'::public.estado_persona_accidente, 'HERIDO_MODERADO'::public.estado_persona_accidente, 'HERIDO_GRAVE'::public.estado_persona_accidente])))) AS total_heridos,
    ( SELECT count(*) AS count
           FROM public.persona_accidente
          WHERE ((persona_accidente.hoja_accidentologia_id = ha.id) AND (persona_accidente.estado = 'FALLECIDO'::public.estado_persona_accidente))) AS total_fallecidos,
    u.nombre_completo AS elaborado_por_nombre,
    ha.created_at
   FROM ((((public.hoja_accidentologia ha
     JOIN public.situacion s ON ((ha.situacion_id = s.id)))
     LEFT JOIN public.municipio m ON ((s.municipio_id = m.id)))
     LEFT JOIN public.departamento d ON ((m.departamento_id = d.id)))
     LEFT JOIN public.usuario u ON ((ha.elaborado_por = u.id)))
  ORDER BY ha.created_at DESC;


--
-- Name: v_situacion_multimedia_resumen; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_situacion_multimedia_resumen AS
 SELECT s.id AS situacion_id,
    s.numero_situacion,
    s.tipo_situacion,
    count(sm.id) FILTER (WHERE ((sm.tipo)::text = 'FOTO'::text)) AS total_fotos,
    count(sm.id) FILTER (WHERE ((sm.tipo)::text = 'VIDEO'::text)) AS total_videos,
    bool_or(((sm.tipo)::text = 'VIDEO'::text)) AS tiene_video,
    array_agg(sm.url_thumbnail ORDER BY sm.orden) FILTER (WHERE (((sm.tipo)::text = 'FOTO'::text) AND (sm.url_thumbnail IS NOT NULL))) AS thumbnails,
    ( SELECT situacion_multimedia.url_thumbnail
           FROM public.situacion_multimedia
          WHERE ((situacion_multimedia.situacion_id = s.id) AND ((situacion_multimedia.tipo)::text = 'FOTO'::text))
          ORDER BY situacion_multimedia.orden
         LIMIT 1) AS preview_url
   FROM (public.situacion s
     LEFT JOIN public.situacion_multimedia sm ON ((s.id = sm.situacion_id)))
  GROUP BY s.id, s.numero_situacion, s.tipo_situacion;


--
-- Name: v_situaciones_con_combustible; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_situaciones_con_combustible AS
 SELECT s.id,
    s.uuid,
    s.numero_situacion,
    s.tipo_situacion,
    s.estado,
    s.unidad_id,
    u.codigo AS unidad_codigo,
    s.ruta_id,
    r.codigo AS ruta_codigo,
    s.combustible,
    s.combustible_fraccion,
    s.kilometraje_unidad,
    s.created_at,
    lag(s.combustible) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at) AS combustible_anterior,
    (s.combustible - lag(s.combustible) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at)) AS consumo,
    (s.kilometraje_unidad - lag(s.kilometraje_unidad) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at)) AS km_recorridos,
    (EXTRACT(epoch FROM (s.created_at - lag(s.created_at) OVER (PARTITION BY s.unidad_id, s.turno_id ORDER BY s.created_at))) / (60)::numeric) AS minutos_desde_anterior,
    s.turno_id,
    t.fecha AS turno_fecha
   FROM (((public.situacion s
     LEFT JOIN public.unidad u ON ((s.unidad_id = u.id)))
     LEFT JOIN public.ruta r ON ((s.ruta_id = r.id)))
     LEFT JOIN public.turno t ON ((s.turno_id = t.id)))
  WHERE (s.combustible IS NOT NULL)
  ORDER BY s.unidad_id, s.created_at;


--
-- Name: VIEW v_situaciones_con_combustible; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_situaciones_con_combustible IS 'Vista de situaciones con análisis de consumo de combustible y km recorridos';


--
-- Name: v_situaciones_persistentes_completas; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_situaciones_persistentes_completas AS
 SELECT sp.id,
    sp.uuid,
    sp.numero,
    sp.titulo,
    sp.tipo,
    sp.subtipo,
    sp.estado,
    sp.importancia,
    sp.ruta_id,
    sp.km_inicio,
    sp.km_fin,
    sp.sentido,
    sp.latitud,
    sp.longitud,
    sp.direccion_referencia,
    sp.descripcion,
    sp.observaciones_generales,
    sp.fecha_inicio,
    sp.fecha_fin_estimada,
    sp.fecha_fin_real,
    sp.creado_por,
    sp.cerrado_por,
    sp.created_at,
    sp.updated_at,
    sp.tipo_emergencia_id,
    sp.situacion_origen_id,
    sp.es_promocion,
    sp.fecha_promocion,
    sp.promovido_por,
    sp.jurisdiccion,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    tev.nombre AS tipo_emergencia_nombre,
    tev.codigo AS tipo_emergencia_codigo,
    tev.color AS tipo_emergencia_color,
    uc.nombre_completo AS creado_por_nombre,
    ucerr.nombre_completo AS cerrado_por_nombre,
    uprom.nombre_completo AS promovido_por_nombre,
    so.uuid AS situacion_origen_uuid,
    so.numero_situacion AS situacion_origen_numero,
    ( SELECT count(*) AS count
           FROM public.asignacion_situacion_persistente asp
          WHERE ((asp.situacion_persistente_id = sp.id) AND (asp.fecha_hora_desasignacion IS NULL))) AS unidades_asignadas_count,
    ( SELECT json_agg(json_build_object('unidad_id', u.id, 'unidad_codigo', u.codigo, 'tipo_unidad', u.tipo_unidad, 'fecha_asignacion', asp.fecha_hora_asignacion)) AS json_agg
           FROM (public.asignacion_situacion_persistente asp
             JOIN public.unidad u ON ((asp.unidad_id = u.id)))
          WHERE ((asp.situacion_persistente_id = sp.id) AND (asp.fecha_hora_desasignacion IS NULL))) AS unidades_asignadas,
    ( SELECT json_build_object('id', osp.id, 'hay_vehiculo_fuera_via', osp.hay_vehiculo_fuera_via, 'tipo_obstruccion', osp.tipo_obstruccion, 'sentido_principal', osp.sentido_principal, 'sentido_contrario', osp.sentido_contrario, 'descripcion', COALESCE(osp.descripcion_manual, osp.descripcion_generada)) AS json_build_object
           FROM public.obstruccion_situacion_persistente osp
          WHERE (osp.situacion_persistente_id = sp.id)
         LIMIT 1) AS obstruccion,
    ( SELECT json_agg(json_build_object('id', asp.id, 'tipo', asp.tipo_autoridad, 'hora_llegada', asp.hora_llegada, 'nip_chapa', asp.nip_chapa, 'numero_unidad', asp.numero_unidad, 'nombre_comandante', asp.nombre_comandante, 'cantidad_elementos', asp.cantidad_elementos, 'cantidad_unidades', asp.cantidad_unidades)) AS json_agg
           FROM public.autoridad_situacion_persistente asp
          WHERE (asp.situacion_persistente_id = sp.id)) AS autoridades,
    ( SELECT json_agg(json_build_object('id', ssp.id, 'tipo', ssp.tipo_socorro, 'hora_llegada', ssp.hora_llegada, 'nip_chapa', ssp.nip_chapa, 'numero_unidad', ssp.numero_unidad, 'nombre_comandante', ssp.nombre_comandante, 'cantidad_elementos', ssp.cantidad_elementos, 'cantidad_unidades', ssp.cantidad_unidades)) AS json_agg
           FROM public.socorro_situacion_persistente ssp
          WHERE (ssp.situacion_persistente_id = sp.id)) AS socorro,
    ( SELECT count(*) AS count
           FROM public.multimedia_situacion_persistente msp
          WHERE ((msp.situacion_persistente_id = sp.id) AND ((msp.tipo)::text = 'foto'::text))) AS cantidad_fotos,
    ( SELECT count(*) AS count
           FROM public.multimedia_situacion_persistente msp
          WHERE ((msp.situacion_persistente_id = sp.id) AND ((msp.tipo)::text = 'video'::text))) AS cantidad_videos,
    ( SELECT json_agg(json_build_object('id', msp.id, 'tipo', msp.tipo, 'url', msp.url, 'url_thumbnail', msp.url_thumbnail, 'nombre_archivo', msp.nombre_archivo, 'orden', msp.orden) ORDER BY msp.tipo, msp.orden) AS json_agg
           FROM public.multimedia_situacion_persistente msp
          WHERE (msp.situacion_persistente_id = sp.id)) AS multimedia
   FROM ((((((public.situacion_persistente sp
     LEFT JOIN public.ruta r ON ((sp.ruta_id = r.id)))
     LEFT JOIN public.tipo_emergencia_vial tev ON ((sp.tipo_emergencia_id = tev.id)))
     LEFT JOIN public.usuario uc ON ((sp.creado_por = uc.id)))
     LEFT JOIN public.usuario ucerr ON ((sp.cerrado_por = ucerr.id)))
     LEFT JOIN public.usuario uprom ON ((sp.promovido_por = uprom.id)))
     LEFT JOIN public.situacion so ON ((sp.situacion_origen_id = so.id)));


--
-- Name: VIEW v_situaciones_persistentes_completas; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON VIEW public.v_situaciones_persistentes_completas IS 'Vista completa de situaciones persistentes con obstrucci??n v2';


--
-- Name: v_turnos_completos; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_turnos_completos AS
 SELECT t.id AS turno_id,
    t.fecha,
    t.estado AS turno_estado,
    a.id AS asignacion_id,
    a.id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    a.km_inicio,
    a.km_final,
    a.sentido,
    a.acciones,
    a.combustible_inicial,
    a.combustible_asignado,
    a.hora_salida,
    a.hora_entrada_estimada,
    a.hora_salida_real,
    a.hora_entrada_real,
    ( SELECT json_agg(json_build_object('usuario_id', usr.id, 'nombre_completo', usr.nombre_completo, 'chapa', usr.username, 'rol_tripulacion', tc.rol_tripulacion, 'presente', tc.presente) ORDER BY
                CASE tc.rol_tripulacion
                    WHEN 'PILOTO'::text THEN 1
                    WHEN 'COPILOTO'::text THEN 2
                    WHEN 'ACOMPANANTE'::text THEN 3
                    ELSE 4
                END) AS json_agg
           FROM (public.tripulacion_turno tc
             JOIN public.usuario usr ON ((tc.usuario_id = usr.id)))
          WHERE (tc.asignacion_id = a.id)) AS tripulacion,
    a.created_at
   FROM (((public.turno t
     JOIN public.asignacion_unidad a ON ((t.id = a.turno_id)))
     JOIN public.unidad u ON ((a.unidad_id = u.id)))
     LEFT JOIN public.ruta r ON ((a.ruta_id = r.id)));


--
-- Name: v_ubicacion_actual_brigada; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_ubicacion_actual_brigada AS
 SELECT ub.usuario_id,
    u.nombre_completo,
    u.username,
    ub.estado,
    ub.unidad_actual_id,
    ua.codigo AS unidad_actual_codigo,
    ub.unidad_origen_id,
    uo.codigo AS unidad_origen_codigo,
    ub.punto_fijo_km,
    ub.punto_fijo_sentido,
    ub.punto_fijo_ruta_id,
    r.codigo AS punto_fijo_ruta_codigo,
    ub.punto_fijo_latitud,
    ub.punto_fijo_longitud,
    ub.punto_fijo_descripcion,
    ub.situacion_persistente_id,
    sp.titulo AS situacion_persistente_titulo,
    sp.tipo AS situacion_persistente_tipo,
    ub.inicio_ubicacion,
    ub.motivo,
    ub.created_at
   FROM (((((public.ubicacion_brigada ub
     JOIN public.usuario u ON ((ub.usuario_id = u.id)))
     LEFT JOIN public.unidad ua ON ((ub.unidad_actual_id = ua.id)))
     LEFT JOIN public.unidad uo ON ((ub.unidad_origen_id = uo.id)))
     LEFT JOIN public.ruta r ON ((ub.punto_fijo_ruta_id = r.id)))
     LEFT JOIN public.situacion_persistente sp ON ((ub.situacion_persistente_id = sp.id)))
  WHERE (ub.fin_ubicacion IS NULL);


--
-- Name: v_ultima_situacion_unidad; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_ultima_situacion_unidad AS
 SELECT DISTINCT ON (s.unidad_id) s.unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.id AS situacion_id,
    s.uuid AS situacion_uuid,
    s.tipo_situacion,
    s.estado,
    s.ruta_id,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km,
    s.sentido,
    s.latitud,
    s.longitud,
    s.combustible,
    s.combustible_fraccion,
    s.kilometraje_unidad,
    s.descripcion,
    s.created_at AS situacion_fecha,
    s.turno_id,
    t.fecha AS turno_fecha
   FROM (((public.situacion s
     JOIN public.unidad u ON ((s.unidad_id = u.id)))
     LEFT JOIN public.ruta r ON ((s.ruta_id = r.id)))
     LEFT JOIN public.turno t ON ((s.turno_id = t.id)))
  WHERE ((s.estado)::text = 'ACTIVA'::text)
  ORDER BY s.unidad_id, s.created_at DESC;


--
-- Name: v_unidades_en_salida; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_unidades_en_salida AS
 SELECT u.id AS unidad_id,
    u.codigo AS unidad_codigo,
    u.tipo_unidad,
    s.id AS salida_id,
    s.fecha_hora_salida,
    (EXTRACT(epoch FROM (now() - s.fecha_hora_salida)) / (3600)::numeric) AS horas_en_salida,
    r.codigo AS ruta_codigo,
    r.nombre AS ruta_nombre,
    s.km_inicial,
    s.tripulacion,
    ( SELECT count(*) AS count
           FROM public.situacion sit
          WHERE (sit.salida_unidad_id = s.id)) AS total_situaciones,
    ( SELECT json_build_object('id', sit.id, 'tipo', sit.tipo_situacion, 'km', sit.km, 'fecha_hora', sit.created_at) AS json_build_object
           FROM public.situacion sit
          WHERE (sit.salida_unidad_id = s.id)
          ORDER BY sit.created_at DESC
         LIMIT 1) AS ultima_situacion
   FROM ((public.unidad u
     JOIN public.salida_unidad s ON (((u.id = s.unidad_id) AND ((s.estado)::text = 'EN_SALIDA'::text))))
     LEFT JOIN public.ruta r ON ((s.ruta_inicial_id = r.id)))
  ORDER BY s.fecha_hora_salida DESC;


--
-- Name: v_usuario_roles; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_usuario_roles AS
 SELECT u.id AS usuario_id,
    u.username,
    u.nombre_completo,
    u.sede_id AS sede_principal_id,
    sp.nombre AS sede_principal_nombre,
    ur.rol_id,
    r.nombre AS rol_nombre,
    ur.sede_id AS rol_sede_id,
    sr.nombre AS rol_sede_nombre,
    ur.es_rol_principal,
    ur.activo AS rol_activo,
    ur.fecha_asignacion
   FROM ((((public.usuario u
     JOIN public.usuario_rol ur ON ((u.id = ur.usuario_id)))
     JOIN public.rol r ON ((ur.rol_id = r.id)))
     LEFT JOIN public.sede sp ON ((u.sede_id = sp.id)))
     LEFT JOIN public.sede sr ON ((ur.sede_id = sr.id)))
  WHERE (ur.activo = true);


--
-- Name: v_usuarios_admin; Type: VIEW; Schema: public; Owner: -
--

CREATE VIEW public.v_usuarios_admin AS
 SELECT u.id,
    u.uuid,
    u.username,
    u.nombre_completo,
    u.chapa,
    u.email,
    u.telefono,
    u.activo,
    u.acceso_app_activo,
    u.grupo,
        CASE u.grupo
            WHEN 0 THEN 'Normal (L-V)'::text
            WHEN 1 THEN 'Grupo 1'::text
            WHEN 2 THEN 'Grupo 2'::text
            ELSE 'Sin asignar'::text
        END AS grupo_nombre,
    u.exento_grupos,
    u.es_encargado_grupo,
    r.nombre AS rol_codigo,
    r.nombre AS rol_nombre,
    s.id AS sede_id,
    s.codigo AS sede_codigo,
    s.nombre AS sede_nombre,
    src.codigo AS sub_rol_cop_codigo,
    src.nombre AS sub_rol_cop_nombre,
    u.ultimo_acceso,
    u.created_at
   FROM (((public.usuario u
     JOIN public.rol r ON ((r.id = u.rol_id)))
     LEFT JOIN public.sede s ON ((s.id = u.sede_id)))
     LEFT JOIN public.sub_rol_cop src ON ((src.id = u.sub_rol_cop_id)))
  ORDER BY u.nombre_completo;


--
-- Name: vehiculo_accidente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehiculo_accidente_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehiculo_accidente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehiculo_accidente_id_seq OWNED BY public.vehiculo_accidente.id;


--
-- Name: vehiculo_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehiculo_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehiculo_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehiculo_id_seq OWNED BY public.vehiculo.id;


--
-- Name: vehiculo_incidente; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.vehiculo_incidente (
    id bigint NOT NULL,
    incidente_id bigint NOT NULL,
    tipo_vehiculo_id integer,
    marca_id integer,
    modelo character varying(50),
    anio integer,
    color character varying(30),
    placa character varying(20),
    estado_piloto character varying(30),
    nombre_piloto character varying(150),
    licencia_piloto character varying(50),
    heridos_en_vehiculo integer DEFAULT 0 NOT NULL,
    fallecidos_en_vehiculo integer DEFAULT 0 NOT NULL,
    danos_estimados character varying(50),
    observaciones text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    marca character varying(100),
    tarjeta_circulacion character varying(100),
    nit character varying(50),
    direccion_propietario text,
    nombre_propietario character varying(255),
    licencia_tipo character varying(50),
    licencia_numero character varying(50),
    licencia_vencimiento date,
    licencia_antiguedad integer,
    piloto_nacimiento date,
    piloto_etnia character varying(50),
    piloto_edad integer,
    piloto_sexo character varying(20),
    cargado boolean DEFAULT false,
    carga_tipo character varying(255),
    carga_detalle jsonb,
    contenedor boolean DEFAULT false,
    doble_remolque boolean DEFAULT false,
    contenedor_detalle jsonb,
    bus_extraurbano boolean DEFAULT false,
    bus_detalle jsonb,
    sancion boolean DEFAULT false,
    sancion_detalle jsonb,
    personas_asistidas integer DEFAULT 0,
    CONSTRAINT vehiculo_incidente_danos_estimados_check CHECK (((danos_estimados)::text = ANY (ARRAY[('LEVE'::character varying)::text, ('MODERADO'::character varying)::text, ('GRAVE'::character varying)::text, ('PERDIDA_TOTAL'::character varying)::text]))),
    CONSTRAINT vehiculo_incidente_estado_piloto_check CHECK (((estado_piloto)::text = ANY (ARRAY[('ILESO'::character varying)::text, ('HERIDO'::character varying)::text, ('FALLECIDO'::character varying)::text, ('TRASLADADO'::character varying)::text, ('HUYO'::character varying)::text])))
);


--
-- Name: TABLE vehiculo_incidente; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE public.vehiculo_incidente IS 'Veh??culos involucrados en un incidente';


--
-- Name: vehiculo_incidente_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.vehiculo_incidente_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: vehiculo_incidente_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.vehiculo_incidente_id_seq OWNED BY public.vehiculo_incidente.id;


--
-- Name: bitacora_historica_2024; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bitacora_historica ATTACH PARTITION public.bitacora_historica_2024 FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');


--
-- Name: bitacora_historica_2025; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bitacora_historica ATTACH PARTITION public.bitacora_historica_2025 FOR VALUES FROM ('2025-01-01') TO ('2026-01-01');


--
-- Name: bitacora_historica_2026; Type: TABLE ATTACH; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bitacora_historica ATTACH PARTITION public.bitacora_historica_2026 FOR VALUES FROM ('2026-01-01') TO ('2027-01-01');


--
-- Name: actividad_unidad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actividad_unidad ALTER COLUMN id SET DEFAULT nextval('public.actividad_unidad_id_seq'::regclass);


--
-- Name: actualizacion_situacion_persistente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actualizacion_situacion_persistente ALTER COLUMN id SET DEFAULT nextval('public.actualizacion_situacion_persistente_id_seq'::regclass);


--
-- Name: ajustador_involucrado id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ajustador_involucrado ALTER COLUMN id SET DEFAULT nextval('public.ajustador_involucrado_id_seq'::regclass);


--
-- Name: alerta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta ALTER COLUMN id SET DEFAULT nextval('public.alerta_id_seq'::regclass);


--
-- Name: alerta_leida id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta_leida ALTER COLUMN id SET DEFAULT nextval('public.alerta_leida_id_seq'::regclass);


--
-- Name: aprobacion_respuesta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aprobacion_respuesta ALTER COLUMN id SET DEFAULT nextval('public.aprobacion_respuesta_id_seq'::regclass);


--
-- Name: aprobacion_tripulacion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aprobacion_tripulacion ALTER COLUMN id SET DEFAULT nextval('public.aprobacion_tripulacion_id_seq'::regclass);


--
-- Name: articulo_sancion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articulo_sancion ALTER COLUMN id SET DEFAULT nextval('public.articulo_sancion_id_seq'::regclass);


--
-- Name: aseguradora id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aseguradora ALTER COLUMN id SET DEFAULT nextval('public.aseguradora_id_seq'::regclass);


--
-- Name: asignacion_situacion_persistente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_situacion_persistente ALTER COLUMN id SET DEFAULT nextval('public.asignacion_situacion_persistente_id_seq'::regclass);


--
-- Name: asignacion_unidad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_unidad ALTER COLUMN id SET DEFAULT nextval('public.asignacion_unidad_id_seq'::regclass);


--
-- Name: auditoria_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_log ALTER COLUMN id SET DEFAULT nextval('public.auditoria_log_id_seq'::regclass);


--
-- Name: autoridad_situacion_persistente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autoridad_situacion_persistente ALTER COLUMN id SET DEFAULT nextval('public.autoridad_situacion_persistente_id_seq'::regclass);


--
-- Name: aviso_asignacion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aviso_asignacion ALTER COLUMN id SET DEFAULT nextval('public.aviso_asignacion_id_seq'::regclass);


--
-- Name: bitacora_historica id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bitacora_historica ALTER COLUMN id SET DEFAULT nextval('public.bitacora_historica_id_seq'::regclass);


--
-- Name: brigada id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brigada ALTER COLUMN id SET DEFAULT nextval('public.brigada_id_seq'::regclass);


--
-- Name: brigada_unidad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brigada_unidad ALTER COLUMN id SET DEFAULT nextval('public.brigada_unidad_id_seq'::regclass);


--
-- Name: bus id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bus ALTER COLUMN id SET DEFAULT nextval('public.bus_id_seq'::regclass);


--
-- Name: calendario_grupo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendario_grupo ALTER COLUMN id SET DEFAULT nextval('public.calendario_grupo_id_seq'::regclass);


--
-- Name: campo_personalizado id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campo_personalizado ALTER COLUMN id SET DEFAULT nextval('public.campo_personalizado_id_seq'::regclass);


--
-- Name: catalogo_motivo_inactividad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalogo_motivo_inactividad ALTER COLUMN id SET DEFAULT nextval('public.catalogo_motivo_inactividad_id_seq'::regclass);


--
-- Name: combustible_registro id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.combustible_registro ALTER COLUMN id SET DEFAULT nextval('public.combustible_registro_id_seq'::regclass);


--
-- Name: configuracion_alerta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_alerta ALTER COLUMN id SET DEFAULT nextval('public.configuracion_alerta_id_seq'::regclass);


--
-- Name: configuracion_columnas_tabla id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_columnas_tabla ALTER COLUMN id SET DEFAULT nextval('public.configuracion_columnas_tabla_id_seq'::regclass);


--
-- Name: configuracion_sistema id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_sistema ALTER COLUMN id SET DEFAULT nextval('public.configuracion_sistema_id_seq'::regclass);


--
-- Name: configuracion_visual_sede id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_visual_sede ALTER COLUMN id SET DEFAULT nextval('public.configuracion_visual_sede_id_seq'::regclass);


--
-- Name: contenedor id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contenedor ALTER COLUMN id SET DEFAULT nextval('public.contenedor_id_seq'::regclass);


--
-- Name: control_acceso_app id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_acceso_app ALTER COLUMN id SET DEFAULT nextval('public.control_acceso_app_id_seq'::regclass);


--
-- Name: departamento id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamento ALTER COLUMN id SET DEFAULT nextval('public.departamento_id_seq'::regclass);


--
-- Name: departamento_sistema id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamento_sistema ALTER COLUMN id SET DEFAULT nextval('public.departamento_sistema_id_seq'::regclass);


--
-- Name: detalle_situacion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_situacion ALTER COLUMN id SET DEFAULT nextval('public.detalle_situacion_id_seq'::regclass);


--
-- Name: dispositivo_push id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispositivo_push ALTER COLUMN id SET DEFAULT nextval('public.dispositivo_push_id_seq'::regclass);


--
-- Name: estado_grupo_departamento id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estado_grupo_departamento ALTER COLUMN id SET DEFAULT nextval('public.estado_grupo_departamento_id_seq'::regclass);


--
-- Name: evento_persistente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evento_persistente ALTER COLUMN id SET DEFAULT nextval('public.evento_persistente_id_seq'::regclass);


--
-- Name: grua id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grua ALTER COLUMN id SET DEFAULT nextval('public.grua_id_seq'::regclass);


--
-- Name: grua_involucrada id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grua_involucrada ALTER COLUMN id SET DEFAULT nextval('public.grua_involucrada_id_seq'::regclass);


--
-- Name: historial_encargado_sede_grupo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_encargado_sede_grupo ALTER COLUMN id SET DEFAULT nextval('public.historial_encargado_sede_grupo_id_seq'::regclass);


--
-- Name: historial_ruta_brigada id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_ruta_brigada ALTER COLUMN id SET DEFAULT nextval('public.historial_ruta_brigada_id_seq'::regclass);


--
-- Name: historial_situacion_brigada id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_situacion_brigada ALTER COLUMN id SET DEFAULT nextval('public.historial_situacion_brigada_id_seq'::regclass);


--
-- Name: hoja_accidentologia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hoja_accidentologia ALTER COLUMN id SET DEFAULT nextval('public.hoja_accidentologia_id_seq'::regclass);


--
-- Name: incidente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente ALTER COLUMN id SET DEFAULT nextval('public.incidente_id_seq'::regclass);


--
-- Name: incidente_grua id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_grua ALTER COLUMN id SET DEFAULT nextval('public.incidente_grua_id_seq'::regclass);


--
-- Name: incidente_no_atendido id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_no_atendido ALTER COLUMN id SET DEFAULT nextval('public.incidente_no_atendido_id_seq'::regclass);


--
-- Name: incidente_vehiculo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_vehiculo ALTER COLUMN id SET DEFAULT nextval('public.incidente_vehiculo_id_seq'::regclass);


--
-- Name: ingreso_sede id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingreso_sede ALTER COLUMN id SET DEFAULT nextval('public.ingreso_sede_id_seq'::regclass);


--
-- Name: inspeccion_360 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspeccion_360 ALTER COLUMN id SET DEFAULT nextval('public.inspeccion_360_id_seq'::regclass);


--
-- Name: inspeccion_360_archivo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspeccion_360_archivo ALTER COLUMN id SET DEFAULT nextval('public.inspeccion_360_archivo_id_seq'::regclass);


--
-- Name: intelligence_refresh_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intelligence_refresh_log ALTER COLUMN id SET DEFAULT nextval('public.intelligence_refresh_log_id_seq'::regclass);


--
-- Name: log_administracion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_administracion ALTER COLUMN id SET DEFAULT nextval('public.log_administracion_id_seq'::regclass);


--
-- Name: marca id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marca ALTER COLUMN id SET DEFAULT nextval('public.marca_id_seq'::regclass);


--
-- Name: marca_vehiculo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marca_vehiculo ALTER COLUMN id SET DEFAULT nextval('public.marca_vehiculo_id_seq'::regclass);


--
-- Name: motivo_no_atendido id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.motivo_no_atendido ALTER COLUMN id SET DEFAULT nextval('public.motivo_no_atendido_id_seq'::regclass);


--
-- Name: movimiento_brigada id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimiento_brigada ALTER COLUMN id SET DEFAULT nextval('public.movimiento_brigada_id_seq'::regclass);


--
-- Name: multimedia_situacion_persistente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.multimedia_situacion_persistente ALTER COLUMN id SET DEFAULT nextval('public.multimedia_situacion_persistente_id_seq'::regclass);


--
-- Name: municipio id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.municipio ALTER COLUMN id SET DEFAULT nextval('public.municipio_id_seq'::regclass);


--
-- Name: notificacion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notificacion ALTER COLUMN id SET DEFAULT nextval('public.notificacion_id_seq'::regclass);


--
-- Name: obstruccion_incidente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obstruccion_incidente ALTER COLUMN id SET DEFAULT nextval('public.obstruccion_incidente_id_seq'::regclass);


--
-- Name: obstruccion_situacion_persistente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obstruccion_situacion_persistente ALTER COLUMN id SET DEFAULT nextval('public.obstruccion_situacion_persistente_id_seq'::regclass);


--
-- Name: password_reset_log id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_log ALTER COLUMN id SET DEFAULT nextval('public.password_reset_log_id_seq'::regclass);


--
-- Name: permiso id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permiso ALTER COLUMN id SET DEFAULT nextval('public.permiso_id_seq'::regclass);


--
-- Name: persona_accidente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persona_accidente ALTER COLUMN id SET DEFAULT nextval('public.persona_accidente_id_seq'::regclass);


--
-- Name: persona_involucrada id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persona_involucrada ALTER COLUMN id SET DEFAULT nextval('public.persona_involucrada_id_seq'::regclass);


--
-- Name: piloto id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piloto ALTER COLUMN id SET DEFAULT nextval('public.piloto_id_seq'::regclass);


--
-- Name: plantilla_comunicacion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plantilla_comunicacion ALTER COLUMN id SET DEFAULT nextval('public.plantilla_comunicacion_id_seq'::regclass);


--
-- Name: plantilla_inspeccion_360 id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plantilla_inspeccion_360 ALTER COLUMN id SET DEFAULT nextval('public.plantilla_inspeccion_360_id_seq'::regclass);


--
-- Name: publicacion_social id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicacion_social ALTER COLUMN id SET DEFAULT nextval('public.publicacion_social_id_seq'::regclass);


--
-- Name: reasignacion_sede id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reasignacion_sede ALTER COLUMN id SET DEFAULT nextval('public.reasignacion_sede_id_seq'::regclass);


--
-- Name: recurso_incidente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurso_incidente ALTER COLUMN id SET DEFAULT nextval('public.recurso_incidente_id_seq'::regclass);


--
-- Name: registro_cambio id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registro_cambio ALTER COLUMN id SET DEFAULT nextval('public.registro_cambio_id_seq'::regclass);


--
-- Name: relevo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relevo ALTER COLUMN id SET DEFAULT nextval('public.relevo_id_seq'::regclass);


--
-- Name: reporte_horario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reporte_horario ALTER COLUMN id SET DEFAULT nextval('public.reporte_horario_id_seq'::regclass);


--
-- Name: rol id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rol ALTER COLUMN id SET DEFAULT nextval('public.rol_id_seq'::regclass);


--
-- Name: ruta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruta ALTER COLUMN id SET DEFAULT nextval('public.ruta_id_seq'::regclass);


--
-- Name: salida_unidad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salida_unidad ALTER COLUMN id SET DEFAULT nextval('public.salida_unidad_id_seq'::regclass);


--
-- Name: sancion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sancion ALTER COLUMN id SET DEFAULT nextval('public.sancion_id_seq'::regclass);


--
-- Name: sede id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sede ALTER COLUMN id SET DEFAULT nextval('public.sede_id_seq'::regclass);


--
-- Name: situacion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion ALTER COLUMN id SET DEFAULT nextval('public.situacion_id_seq'::regclass);


--
-- Name: situacion_fija id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_fija ALTER COLUMN id SET DEFAULT nextval('public.situacion_fija_id_seq'::regclass);


--
-- Name: situacion_multimedia id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_multimedia ALTER COLUMN id SET DEFAULT nextval('public.situacion_multimedia_id_seq'::regclass);


--
-- Name: situacion_persistente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_persistente ALTER COLUMN id SET DEFAULT nextval('public.situacion_persistente_id_seq'::regclass);


--
-- Name: socorro_situacion_persistente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.socorro_situacion_persistente ALTER COLUMN id SET DEFAULT nextval('public.socorro_situacion_persistente_id_seq'::regclass);


--
-- Name: sub_rol_cop id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_rol_cop ALTER COLUMN id SET DEFAULT nextval('public.sub_rol_cop_id_seq'::regclass);


--
-- Name: subtipo_hecho id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subtipo_hecho ALTER COLUMN id SET DEFAULT nextval('public.subtipo_hecho_id_seq'::regclass);


--
-- Name: suscripcion_alerta id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suscripcion_alerta ALTER COLUMN id SET DEFAULT nextval('public.suscripcion_alerta_id_seq'::regclass);


--
-- Name: tarjeta_circulacion id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tarjeta_circulacion ALTER COLUMN id SET DEFAULT nextval('public.tarjeta_circulacion_id_seq'::regclass);


--
-- Name: tipo_actividad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_actividad ALTER COLUMN id SET DEFAULT nextval('public.tipo_actividad_id_seq'::regclass);


--
-- Name: tipo_emergencia_vial id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_emergencia_vial ALTER COLUMN id SET DEFAULT nextval('public.tipo_emergencia_vial_id_seq'::regclass);


--
-- Name: tipo_hecho id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_hecho ALTER COLUMN id SET DEFAULT nextval('public.tipo_hecho_id_seq'::regclass);


--
-- Name: tipo_vehiculo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_vehiculo ALTER COLUMN id SET DEFAULT nextval('public.tipo_vehiculo_id_seq'::regclass);


--
-- Name: tripulacion_turno id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tripulacion_turno ALTER COLUMN id SET DEFAULT nextval('public.tripulacion_turno_id_seq'::regclass);


--
-- Name: turno id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turno ALTER COLUMN id SET DEFAULT nextval('public.turno_id_seq'::regclass);


--
-- Name: ubicacion_brigada id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubicacion_brigada ALTER COLUMN id SET DEFAULT nextval('public.ubicacion_brigada_id_seq'::regclass);


--
-- Name: unidad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unidad ALTER COLUMN id SET DEFAULT nextval('public.unidad_id_seq'::regclass);


--
-- Name: usuario id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario ALTER COLUMN id SET DEFAULT nextval('public.usuario_id_seq'::regclass);


--
-- Name: usuario_inactividad id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_inactividad ALTER COLUMN id SET DEFAULT nextval('public.usuario_inactividad_id_seq'::regclass);


--
-- Name: usuario_rol id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_rol ALTER COLUMN id SET DEFAULT nextval('public.usuario_rol_id_seq'::regclass);


--
-- Name: vehiculo id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo ALTER COLUMN id SET DEFAULT nextval('public.vehiculo_id_seq'::regclass);


--
-- Name: vehiculo_accidente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo_accidente ALTER COLUMN id SET DEFAULT nextval('public.vehiculo_accidente_id_seq'::regclass);


--
-- Name: vehiculo_incidente id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo_incidente ALTER COLUMN id SET DEFAULT nextval('public.vehiculo_incidente_id_seq'::regclass);


--
-- Data for Name: actividad_unidad; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.actividad_unidad (id, unidad_id, tipo_actividad_id, incidente_id, ruta_id, km, sentido, hora_inicio, hora_fin, observaciones, registrado_por, created_at, updated_at, asignacion_id) FROM stdin;
\.


--
-- Data for Name: actualizacion_situacion_persistente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.actualizacion_situacion_persistente (id, situacion_persistente_id, usuario_id, unidad_id, asignacion_situacion_id, tipo_actualizacion, contenido, datos_adicionales, archivos, fecha_hora, editado, fecha_ultima_edicion, editado_por, puede_editarse, created_at, updated_at) FROM stdin;
1	3	306	406	\N	CREACION	Situacion promovida desde situacion normal #38	\N	\N	2025-12-30 23:58:50.865874+00	f	\N	\N	t	2025-12-30 23:58:50.865874+00	2025-12-30 23:58:50.865874+00
2	5	568	341	2	NOVEDAD	Equipo de maquinaria pesada llegando al lugar	\N	\N	2025-12-31 00:51:05.322003+00	f	\N	\N	t	2025-12-31 00:51:05.322003+00	2025-12-31 00:51:05.322003+00
3	5	568	341	2	NOVEDAD	Equipo de maquinaria pesada llegando al lugar	\N	\N	2025-12-31 00:51:55.590714+00	f	\N	\N	t	2025-12-31 00:51:55.590714+00	2025-12-31 00:51:55.590714+00
4	5	568	341	2	NOVEDAD	Cambio de tripulacion: Piloto 1 -> Piloto 2 por fatiga (EDITADO)	\N	\N	2025-12-31 00:54:32.468796+00	t	2025-12-31 00:54:32.488098+00	568	t	2025-12-31 00:54:32.468796+00	2025-12-31 00:54:32.488098+00
\.


--
-- Data for Name: ajustador_involucrado; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ajustador_involucrado (id, incidente_id, vehiculo_asignado_id, nombre, empresa, vehiculo_tipo, vehiculo_placa, vehiculo_color, vehiculo_marca, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: alerta; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alerta (id, tipo, severidad, estado, titulo, mensaje, datos, sede_id, unidad_id, brigada_id, situacion_id, atendida_por, fecha_atencion, nota_resolucion, fecha_expiracion, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: alerta_leida; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alerta_leida (id, alerta_id, usuario_id, leida_at) FROM stdin;
\.


--
-- Data for Name: aprobacion_respuesta; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.aprobacion_respuesta (id, aprobacion_id, usuario_id, respuesta, fecha_respuesta, motivo_rechazo, latitud, longitud, created_at) FROM stdin;
\.


--
-- Data for Name: aprobacion_tripulacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.aprobacion_tripulacion (id, salida_id, unidad_id, tipo, inspeccion_360_id, estado, requiere_todos, minimo_aprobaciones, tiempo_limite_minutos, iniciado_por, fecha_inicio, fecha_completada, observaciones, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: articulo_sancion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.articulo_sancion (id, numero, descripcion, monto_multa, puntos_licencia, activo, created_at) FROM stdin;
1	Art. 145	Conducir sin licencia	500.00	0	t	2025-12-07 06:28:58.672914+00
2	Art. 146	Exceso de velocidad	300.00	3	t	2025-12-07 06:28:58.672914+00
3	Art. 147	Conducir en estado de ebriedad	1000.00	5	t	2025-12-07 06:28:58.672914+00
4	Art. 148	No respetar se??al de alto	250.00	2	t	2025-12-07 06:28:58.672914+00
5	Art. 149	Conducir sin cintur??n de seguridad	100.00	1	t	2025-12-07 06:28:58.672914+00
\.


--
-- Data for Name: aseguradora; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.aseguradora (id, nombre, codigo, telefono, email, total_incidentes, activa, created_at) FROM stdin;
\.


--
-- Data for Name: asignacion_situacion_persistente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.asignacion_situacion_persistente (id, situacion_persistente_id, unidad_id, asignacion_unidad_id, fecha_hora_asignacion, fecha_hora_desasignacion, km_asignacion, latitud_asignacion, longitud_asignacion, observaciones_asignacion, observaciones_desasignacion, asignado_por, desasignado_por, created_at, updated_at) FROM stdin;
1	3	406	\N	2025-12-30 23:58:50.865874+00	\N	58.20	14.64070000	-90.51330000	\N	\N	306	\N	2025-12-30 23:58:50.865874+00	2025-12-30 23:58:50.865874+00
2	5	341	\N	2025-12-31 00:51:05.207146+00	\N	\N	\N	\N	\N	\N	568	\N	2025-12-31 00:51:05.207146+00	2025-12-31 00:51:05.207146+00
4	5	343	\N	2025-12-31 00:51:05.237582+00	\N	\N	\N	\N	\N	\N	568	\N	2025-12-31 00:51:05.237582+00	2025-12-31 00:51:05.237582+00
3	5	342	\N	2025-12-31 00:51:05.224861+00	2025-12-31 00:51:05.272878+00	\N	\N	\N	\N	\N	568	568	2025-12-31 00:51:05.224861+00	2025-12-31 00:51:05.272878+00
6	10	341	\N	2025-12-31 00:51:05.31151+00	\N	\N	\N	\N	\N	\N	568	\N	2025-12-31 00:51:05.31151+00	2025-12-31 00:51:05.31151+00
7	5	345	\N	2025-12-31 00:51:05.462135+00	\N	\N	\N	\N	\N	\N	143	\N	2025-12-31 00:51:05.462135+00	2025-12-31 00:51:05.462135+00
5	5	342	\N	2025-12-31 00:51:05.291889+00	2025-12-31 00:51:55.538424+00	\N	\N	\N	\N	\N	568	568	2025-12-31 00:51:05.291889+00	2025-12-31 00:51:55.538424+00
8	5	342	\N	2025-12-31 00:51:55.561411+00	\N	\N	\N	\N	\N	\N	568	\N	2025-12-31 00:51:55.561411+00	2025-12-31 00:51:55.561411+00
\.


--
-- Data for Name: asignacion_unidad; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.asignacion_unidad (id, turno_id, unidad_id, ruta_id, km_inicio, km_final, sentido, acciones, combustible_inicial, combustible_asignado, hora_salida, hora_entrada_estimada, hora_salida_real, hora_entrada_real, combustible_final, km_recorridos, observaciones_finales, created_at, updated_at, dia_cerrado, fecha_cierre, cerrado_por, modificado_despues_cierre, motivo_modificacion_cierre, ruta_activa_id, hora_ultima_actualizacion_ruta, notificacion_enviada, fecha_notificacion, es_reaccion, situacion_fija_id, acciones_formato, tipo_asignacion) FROM stdin;
38	27	406	84	6.00	60.00	NORTE	Patrullar la ca-9 norte y conificar sanarateYork	\N	\N	04:30:00	21:00:00	2025-12-15 18:56:02.104795+00	\N	\N	\N	\N	2025-12-15 18:52:52.4022+00	2025-12-15 18:56:02.104795+00	f	\N	\N	f	\N	\N	\N	f	\N	f	\N	\N	PATRULLA
39	28	340	73	10.00	60.00	NORTE	patrullar y conificar sanarate	\N	\N	04:30:00	21:00:00	2025-12-17 15:46:28.952682+00	\N	\N	\N	\N	2025-12-17 15:46:01.043934+00	2025-12-17 15:46:28.952682+00	f	\N	\N	f	\N	\N	\N	f	\N	f	\N	\N	PATRULLA
40	30	406	70	45.00	120.00	NORTE	\N	\N	\N	06:00:00	\N	\N	\N	\N	\N	\N	2025-12-29 19:00:04.462774+00	2025-12-29 19:00:04.462774+00	f	\N	\N	f	\N	\N	\N	f	\N	f	\N	\N	PATRULLA
41	32	341	70	0.00	120.00	\N	\N	\N	\N	08:00:00	\N	2025-12-29 20:00:32.667284+00	\N	\N	\N	\N	2025-12-29 19:53:38.417735+00	2025-12-29 20:00:32.667284+00	f	\N	\N	f	\N	70	2025-12-29 19:57:11.857233+00	f	\N	f	\N	\N	PATRULLA
34	27	377	74	10.00	60.00	NORTE	patrullar en palin	\N	\N	04:30:00	21:00:00	\N	\N	\N	\N	\N	2025-12-15 06:40:45.640361+00	2025-12-15 06:40:45.640361+00	f	\N	\N	f	\N	\N	\N	f	\N	f	\N	\N	PATRULLA
\.


--
-- Data for Name: auditoria_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.auditoria_log (id, usuario_id, accion, tabla_afectada, registro_id, datos_anteriores, datos_nuevos, ip_address, user_agent, created_at) FROM stdin;
6	568	INSERT	incidente	16	\N	{"id": 16, "km": 50.00, "uuid": "ab134939-32c1-4401-8c56-6052abde3e7b", "estado": "REPORTADO", "origen": "BRIGADA", "latitud": 14.63490000, "ruta_id": 73, "sentido": "NORTE", "foto_url": null, "longitud": -90.50690000, "unidad_id": 335, "brigada_id": 568, "creado_por": 568, "created_at": "2025-12-11T16:22:21.061686+00:00", "updated_at": "2025-12-11T16:22:21.061686+00:00", "hay_heridos": false, "iluminacion": null, "visibilidad": null, "jurisdiccion": "Sangrante, El Progreso", "municipio_id": null, "requiere_pnc": false, "senalizacion": null, "asignacion_id": null, "tipo_hecho_id": 8, "causa_probable": null, "hay_fallecidos": false, "numero_reporte": "INC-2025-0001", "tipo_pavimento": null, "actualizado_por": null, "departamento_id": null, "cantidad_heridos": 0, "fecha_hora_aviso": "2025-12-11T16:22:21.053+00:00", "subtipo_hecho_id": null, "danios_materiales": false, "requiere_bomberos": false, "fecha_hora_llegada": null, "cantidad_fallecidos": 0, "direccion_detallada": "Frente a la gasolinera", "obstruccion_detalle": null, "reportado_por_email": null, "requiere_ambulancia": false, "referencia_ubicacion": null, "reportado_por_nombre": null, "fecha_hora_asignacion": null, "observaciones_finales": null, "condiciones_climaticas": null, "danios_infraestructura": false, "reportado_por_telefono": null, "fecha_hora_finalizacion": null, "observaciones_iniciales": null, "fecha_hora_estabilizacion": null, "danios_infraestructura_desc": null}	172.18.0.1/32	\N	2025-12-11 16:22:21.061686+00
7	568	UPDATE	incidente	16	{"id": 16, "km": 50.00, "uuid": "ab134939-32c1-4401-8c56-6052abde3e7b", "estado": "REPORTADO", "origen": "BRIGADA", "latitud": 14.63490000, "ruta_id": 73, "sentido": "NORTE", "foto_url": null, "longitud": -90.50690000, "unidad_id": 335, "brigada_id": 568, "creado_por": 568, "created_at": "2025-12-11T16:22:21.061686+00:00", "updated_at": "2025-12-11T16:22:21.061686+00:00", "hay_heridos": false, "iluminacion": null, "visibilidad": null, "jurisdiccion": "Sangrante, El Progreso", "municipio_id": null, "requiere_pnc": false, "senalizacion": null, "asignacion_id": null, "tipo_hecho_id": 8, "causa_probable": null, "hay_fallecidos": false, "numero_reporte": "INC-2025-0001", "tipo_pavimento": null, "actualizado_por": null, "departamento_id": null, "cantidad_heridos": 0, "fecha_hora_aviso": "2025-12-11T16:22:21.053+00:00", "subtipo_hecho_id": null, "danios_materiales": false, "requiere_bomberos": false, "fecha_hora_llegada": null, "cantidad_fallecidos": 0, "direccion_detallada": "Frente a la gasolinera", "obstruccion_detalle": null, "reportado_por_email": null, "requiere_ambulancia": false, "referencia_ubicacion": null, "reportado_por_nombre": null, "fecha_hora_asignacion": null, "observaciones_finales": null, "condiciones_climaticas": null, "danios_infraestructura": false, "reportado_por_telefono": null, "fecha_hora_finalizacion": null, "observaciones_iniciales": null, "fecha_hora_estabilizacion": null, "danios_infraestructura_desc": null}	{"id": 16, "km": 50.00, "uuid": "ab134939-32c1-4401-8c56-6052abde3e7b", "estado": "REPORTADO", "origen": "BRIGADA", "latitud": 14.63490000, "ruta_id": 73, "sentido": "NORTE", "foto_url": null, "longitud": -90.50690000, "unidad_id": 335, "brigada_id": 568, "creado_por": 568, "created_at": "2025-12-11T16:22:21.061686+00:00", "updated_at": "2025-12-11T16:22:21.176356+00:00", "hay_heridos": false, "iluminacion": null, "visibilidad": null, "jurisdiccion": "Sangrante, El Progreso", "municipio_id": null, "requiere_pnc": false, "senalizacion": null, "asignacion_id": null, "tipo_hecho_id": 8, "causa_probable": null, "hay_fallecidos": false, "numero_reporte": "INC-2025-0001", "tipo_pavimento": null, "actualizado_por": 568, "departamento_id": null, "cantidad_heridos": 0, "fecha_hora_aviso": "2025-12-11T16:22:21.053+00:00", "subtipo_hecho_id": null, "danios_materiales": false, "requiere_bomberos": false, "fecha_hora_llegada": null, "cantidad_fallecidos": 0, "direccion_detallada": "Frente a la gasolinera", "obstruccion_detalle": null, "reportado_por_email": null, "requiere_ambulancia": false, "referencia_ubicacion": null, "reportado_por_nombre": null, "fecha_hora_asignacion": null, "observaciones_finales": null, "condiciones_climaticas": null, "danios_infraestructura": false, "reportado_por_telefono": null, "fecha_hora_finalizacion": null, "observaciones_iniciales": null, "fecha_hora_estabilizacion": null, "danios_infraestructura_desc": null}	172.18.0.1/32	\N	2025-12-11 16:22:21.176356+00
8	568	INSERT	incidente	17	\N	{"id": 17, "km": 52.00, "uuid": "902e6e17-0c26-4829-b1e3-4efe6f91a236", "estado": "REPORTADO", "origen": "BRIGADA", "latitud": 14.63490000, "ruta_id": 73, "sentido": "SUR", "foto_url": null, "longitud": -90.50690000, "unidad_id": 406, "brigada_id": 568, "creado_por": 568, "created_at": "2025-12-11T19:06:18.387943+00:00", "updated_at": "2025-12-11T19:06:18.387943+00:00", "hay_heridos": false, "iluminacion": null, "visibilidad": null, "jurisdiccion": "Sangrante, El Progreso", "municipio_id": null, "requiere_pnc": false, "senalizacion": null, "asignacion_id": null, "tipo_hecho_id": 8, "causa_probable": null, "hay_fallecidos": false, "numero_reporte": "INC-2025-0002", "tipo_pavimento": null, "actualizado_por": null, "departamento_id": null, "cantidad_heridos": 0, "fecha_hora_aviso": "2025-12-11T19:06:18.384+00:00", "subtipo_hecho_id": null, "danios_materiales": false, "requiere_bomberos": false, "fecha_hora_llegada": null, "cantidad_fallecidos": 0, "direccion_detallada": "Frente a la gasolinera", "obstruccion_detalle": null, "reportado_por_email": null, "requiere_ambulancia": false, "referencia_ubicacion": null, "reportado_por_nombre": null, "fecha_hora_asignacion": null, "observaciones_finales": null, "condiciones_climaticas": null, "danios_infraestructura": false, "reportado_por_telefono": null, "fecha_hora_finalizacion": null, "observaciones_iniciales": "Se regula el tránsito mientras el piloto se recompone", "fecha_hora_estabilizacion": null, "danios_infraestructura_desc": null}	172.18.0.1/32	\N	2025-12-11 19:06:18.387943+00
9	568	UPDATE	incidente	17	{"id": 17, "km": 52.00, "uuid": "902e6e17-0c26-4829-b1e3-4efe6f91a236", "estado": "REPORTADO", "origen": "BRIGADA", "latitud": 14.63490000, "ruta_id": 73, "sentido": "SUR", "foto_url": null, "longitud": -90.50690000, "unidad_id": 406, "brigada_id": 568, "creado_por": 568, "created_at": "2025-12-11T19:06:18.387943+00:00", "updated_at": "2025-12-11T19:06:18.387943+00:00", "hay_heridos": false, "iluminacion": null, "visibilidad": null, "jurisdiccion": "Sangrante, El Progreso", "municipio_id": null, "requiere_pnc": false, "senalizacion": null, "asignacion_id": null, "tipo_hecho_id": 8, "causa_probable": null, "hay_fallecidos": false, "numero_reporte": "INC-2025-0002", "tipo_pavimento": null, "actualizado_por": null, "departamento_id": null, "cantidad_heridos": 0, "fecha_hora_aviso": "2025-12-11T19:06:18.384+00:00", "subtipo_hecho_id": null, "danios_materiales": false, "requiere_bomberos": false, "fecha_hora_llegada": null, "cantidad_fallecidos": 0, "direccion_detallada": "Frente a la gasolinera", "obstruccion_detalle": null, "reportado_por_email": null, "requiere_ambulancia": false, "referencia_ubicacion": null, "reportado_por_nombre": null, "fecha_hora_asignacion": null, "observaciones_finales": null, "condiciones_climaticas": null, "danios_infraestructura": false, "reportado_por_telefono": null, "fecha_hora_finalizacion": null, "observaciones_iniciales": "Se regula el tránsito mientras el piloto se recompone", "fecha_hora_estabilizacion": null, "danios_infraestructura_desc": null}	{"id": 17, "km": 52.00, "uuid": "902e6e17-0c26-4829-b1e3-4efe6f91a236", "estado": "REPORTADO", "origen": "BRIGADA", "latitud": 14.63490000, "ruta_id": 73, "sentido": "SUR", "foto_url": null, "longitud": -90.50690000, "unidad_id": 406, "brigada_id": 568, "creado_por": 568, "created_at": "2025-12-11T19:06:18.387943+00:00", "updated_at": "2025-12-11T19:06:18.441754+00:00", "hay_heridos": false, "iluminacion": null, "visibilidad": null, "jurisdiccion": "Sangrante, El Progreso", "municipio_id": null, "requiere_pnc": false, "senalizacion": null, "asignacion_id": null, "tipo_hecho_id": 8, "causa_probable": null, "hay_fallecidos": false, "numero_reporte": "INC-2025-0002", "tipo_pavimento": null, "actualizado_por": 568, "departamento_id": null, "cantidad_heridos": 0, "fecha_hora_aviso": "2025-12-11T19:06:18.384+00:00", "subtipo_hecho_id": null, "danios_materiales": false, "requiere_bomberos": false, "fecha_hora_llegada": null, "cantidad_fallecidos": 0, "direccion_detallada": "Frente a la gasolinera", "obstruccion_detalle": null, "reportado_por_email": null, "requiere_ambulancia": false, "referencia_ubicacion": null, "reportado_por_nombre": null, "fecha_hora_asignacion": null, "observaciones_finales": null, "condiciones_climaticas": null, "danios_infraestructura": false, "reportado_por_telefono": null, "fecha_hora_finalizacion": null, "observaciones_iniciales": "Se regula el tránsito mientras el piloto se recompone", "fecha_hora_estabilizacion": null, "danios_infraestructura_desc": null}	172.18.0.1/32	\N	2025-12-11 19:06:18.441754+00
10	568	DELETE	incidente	16	{"id": 16, "km": 50.00, "uuid": "ab134939-32c1-4401-8c56-6052abde3e7b", "estado": "REPORTADO", "origen": "BRIGADA", "latitud": 14.63490000, "ruta_id": 73, "sentido": "NORTE", "foto_url": null, "longitud": -90.50690000, "unidad_id": 335, "brigada_id": 568, "creado_por": 568, "created_at": "2025-12-11T16:22:21.061686+00:00", "updated_at": "2025-12-11T16:22:21.176356+00:00", "hay_heridos": false, "iluminacion": null, "visibilidad": null, "jurisdiccion": "Sangrante, El Progreso", "municipio_id": null, "requiere_pnc": false, "senalizacion": null, "asignacion_id": null, "tipo_hecho_id": 8, "causa_probable": null, "hay_fallecidos": false, "numero_reporte": "INC-2025-0001", "tipo_pavimento": null, "actualizado_por": 568, "departamento_id": null, "cantidad_heridos": 0, "fecha_hora_aviso": "2025-12-11T16:22:21.053+00:00", "subtipo_hecho_id": null, "danios_materiales": false, "requiere_bomberos": false, "fecha_hora_llegada": null, "cantidad_fallecidos": 0, "direccion_detallada": "Frente a la gasolinera", "obstruccion_detalle": null, "reportado_por_email": null, "requiere_ambulancia": false, "referencia_ubicacion": null, "reportado_por_nombre": null, "fecha_hora_asignacion": null, "observaciones_finales": null, "condiciones_climaticas": null, "danios_infraestructura": false, "reportado_por_telefono": null, "fecha_hora_finalizacion": null, "observaciones_iniciales": null, "fecha_hora_estabilizacion": null, "danios_infraestructura_desc": null}	\N	\N	\N	2025-12-29 17:50:48.281234+00
11	568	DELETE	incidente	17	{"id": 17, "km": 52.00, "uuid": "902e6e17-0c26-4829-b1e3-4efe6f91a236", "estado": "REPORTADO", "origen": "BRIGADA", "latitud": 14.63490000, "ruta_id": 73, "sentido": "SUR", "foto_url": null, "longitud": -90.50690000, "unidad_id": 406, "brigada_id": 568, "creado_por": 568, "created_at": "2025-12-11T19:06:18.387943+00:00", "updated_at": "2025-12-11T19:06:18.441754+00:00", "hay_heridos": false, "iluminacion": null, "visibilidad": null, "jurisdiccion": "Sangrante, El Progreso", "municipio_id": null, "requiere_pnc": false, "senalizacion": null, "asignacion_id": null, "tipo_hecho_id": 8, "causa_probable": null, "hay_fallecidos": false, "numero_reporte": "INC-2025-0002", "tipo_pavimento": null, "actualizado_por": 568, "departamento_id": null, "cantidad_heridos": 0, "fecha_hora_aviso": "2025-12-11T19:06:18.384+00:00", "subtipo_hecho_id": null, "danios_materiales": false, "requiere_bomberos": false, "fecha_hora_llegada": null, "cantidad_fallecidos": 0, "direccion_detallada": "Frente a la gasolinera", "obstruccion_detalle": null, "reportado_por_email": null, "requiere_ambulancia": false, "referencia_ubicacion": null, "reportado_por_nombre": null, "fecha_hora_asignacion": null, "observaciones_finales": null, "condiciones_climaticas": null, "danios_infraestructura": false, "reportado_por_telefono": null, "fecha_hora_finalizacion": null, "observaciones_iniciales": "Se regula el tránsito mientras el piloto se recompone", "fecha_hora_estabilizacion": null, "danios_infraestructura_desc": null}	\N	\N	\N	2025-12-29 17:50:48.281234+00
\.


--
-- Data for Name: autoridad_situacion_persistente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.autoridad_situacion_persistente (id, situacion_persistente_id, tipo_autoridad, hora_llegada, nip_chapa, numero_unidad, nombre_comandante, cantidad_elementos, subestacion, cantidad_unidades, observaciones, created_at, updated_at) FROM stdin;
1	2	PMT	10:30:00	\N	\N	\N	3	\N	\N	\N	2025-12-30 23:57:33.833463+00	2025-12-30 23:57:33.833463+00
2	5	PNC	14:30:00	\N	\N	\N	4	\N	\N	\N	2025-12-31 00:47:15.404975+00	2025-12-31 00:47:15.404975+00
3	5	PMT	14:45:00	\N	\N	\N	\N	\N	2	\N	2025-12-31 00:47:15.404975+00	2025-12-31 00:47:15.404975+00
\.


--
-- Data for Name: aviso_asignacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.aviso_asignacion (id, asignacion_id, tipo, mensaje, color, creado_por, created_at) FROM stdin;
\.


--
-- Data for Name: bitacora_historica_2024; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bitacora_historica_2024 (id, fecha, unidad_id, salida_id, sede_origen_id, ruta_inicial_id, km_inicial, km_final, km_recorridos, combustible_inicial, combustible_final, hora_inicio, hora_fin, duracion_minutos, tripulacion_ids, situaciones_resumen, total_situaciones, ingresos_resumen, total_ingresos, total_incidentes, total_asistencias, total_emergencias, total_regulaciones, total_patrullajes, observaciones_inicio, observaciones_fin, finalizado_por, created_at) FROM stdin;
\.


--
-- Data for Name: bitacora_historica_2025; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bitacora_historica_2025 (id, fecha, unidad_id, salida_id, sede_origen_id, ruta_inicial_id, km_inicial, km_final, km_recorridos, combustible_inicial, combustible_final, hora_inicio, hora_fin, duracion_minutos, tripulacion_ids, situaciones_resumen, total_situaciones, ingresos_resumen, total_ingresos, total_incidentes, total_asistencias, total_emergencias, total_regulaciones, total_patrullajes, observaciones_inicio, observaciones_fin, finalizado_por, created_at) FROM stdin;
3	2025-12-10	406	21	\N	70	\N	123457.00	123457.00	\N	0.13	2025-12-10 21:49:24.585566+00	2025-12-10 22:02:36.8493+00	13	[{"rol": "PILOTO", "usuario_id": 568}]	[]	0	[{"id": 22, "tipo": "FINALIZACION_JORNADA", "sede_id": 1, "es_final": true, "duracion_min": 0.00000000000000000000}]	1	0	0	0	0	0	\N	\N	568	2025-12-10 22:02:36.8493+00
6	2025-12-11	340	24	\N	73	123456.00	123457.00	1.00	0.50	0.38	2025-12-11 14:37:38.993681+00	2025-12-11 14:59:38.790721+00	22	[{"rol": "PILOTO", "usuario_id": 568}]	[{"id": 23, "km": 10.00, "hora": "14:56", "tipo": "PATRULLAJE", "estado": "CERRADA", "ruta_id": null}]	1	[{"id": 25, "tipo": "FINALIZACION_JORNADA", "sede_id": 1, "es_final": false, "duracion_min": 0.56687850000000000000}]	1	0	0	0	0	1	\N	Jornada finalizada	568	2025-12-11 14:59:38.790721+00
7	2025-12-11	335	26	\N	73	123456.00	123457.00	1.00	0.50	0.38	2025-12-11 15:39:43.493618+00	2025-12-11 17:06:23.716107+00	3	[{"rol": "PILOTO", "usuario_id": 568}]	[{"id": 25, "km": null, "hora": "17:03", "tipo": "PATRULLAJE", "estado": "CERRADA", "ruta_id": null}, {"id": 26, "km": 31.00, "hora": "17:04", "tipo": "PARADA_ESTRATEGICA", "estado": "CERRADA", "ruta_id": null}]	2	[{"id": 27, "tipo": "FINALIZACION_JORNADA", "sede_id": 1, "es_final": false, "duracion_min": 1.2721811500000000}]	1	0	0	0	0	1	\N	Jornada finalizada	568	2025-12-11 16:59:22.065432+00
4	2025-12-11	406	28	\N	73	\N	123457.00	1.00	\N	0.38	2025-12-11 02:33:12.371506+00	2025-12-11 18:24:52.198037+00	2	[{"rol": "PILOTO", "usuario_id": 568}]	[]	0	[{"id": 29, "tipo": "FINALIZACION_JORNADA", "sede_id": 1, "es_final": false, "duracion_min": 0.46069226666666666667}]	1	0	0	0	0	0	\N	Jornada finalizada	568	2025-12-11 02:44:45.976457+00
\.


--
-- Data for Name: bitacora_historica_2026; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bitacora_historica_2026 (id, fecha, unidad_id, salida_id, sede_origen_id, ruta_inicial_id, km_inicial, km_final, km_recorridos, combustible_inicial, combustible_final, hora_inicio, hora_fin, duracion_minutos, tripulacion_ids, situaciones_resumen, total_situaciones, ingresos_resumen, total_ingresos, total_incidentes, total_asistencias, total_emergencias, total_regulaciones, total_patrullajes, observaciones_inicio, observaciones_fin, finalizado_por, created_at) FROM stdin;
\.


--
-- Data for Name: brigada; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.brigada (id, codigo, nombre, sede_id, activa, created_at, fecha_nacimiento, licencia_tipo, licencia_numero, licencia_vencimiento, telefono, email, direccion, contacto_emergencia, telefono_emergencia, usuario_id) FROM stdin;
82	15101	P??rez Melgar, Jos?? Carlos.	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	181
83	15103	P??rez P??rez, Jos?? Emedardo	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	183
84	16023	Castillo Garc??a, Cesar Jos??	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	208
85	16061	Gait??n Cruz, Juan Jos??	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	224
86	16158	Z????iga Godoy Jos?? Armando	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	279
87	17012	Retana V??squez, Jos?? Armando	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	283
88	19007	Arana Garc??a, Jos?? David	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	372
89	19032	Corado y Corado Jos?? David	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	397
90	19121	P??rez P??rez Eber Jos??	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	486
91	19171	Zamora Cabrera, Jos?? Luis	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	536
92	19097	Maradiaga Ramos Otto Ren??	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	462
93	19118	P??rez Arias, Axel Ren??	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	483
94	19128	Qui????nez Ramos, Edwin Ren??	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	493
95	19006	Alvarez Mu??oz Christian Ren??	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	371
96	19093	L??pez Mu??oz Augusto C??sar	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	458
97	19	Jimenez Mu??oz, Josue Donaldo	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	556
98	15099	Pe??ate Ar??valo, Ana Patricia	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	179
99	16008	Belloso Pe??ate karen Jeannette	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	200
100	17010	Pe??ate Moran Ana Mary	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	282
101	18022	Escobar Pe??ate Ruben Alejandro	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	333
102	18039	Elvis Rogelio Pe??a Lemus	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	350
103	19116	Pe??ate Colindres, Yeymy Elizabeth	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	481
104	15052	G??mez Gonz??lez, Wilfido Enrique	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	150
105	15056	Gonz??lez Garc??a, Brayan Josu??	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	151
106	15096	Orellana Gonz??lez, Leonel Enrique	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	176
107	15064	Isaacs Pe??ate, Carlos Iv??n	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	156
108	18040	Fernando Iv??n Pe??ate Rodriguez	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	351
109	15065	Jim??nez Gonz??lez, Rafael Estuardo	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	157
110	15124	Salazar Guti??rrez, Angel Jos??	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	189
111	16031	Chan Xuc, Jos?? Luis	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	209
112	16038	C??rdova Gonz??lez, Junnior Danilo	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	214
113	16076	Hern??ndez Casta??eda Mario Jos??	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	232
114	16083	Ixchop Corado Efamber Jos?? Rodrigo	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	238
115	16101	Mendez Malchic, Jos?? Efra??n	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	248
116	16102	M??ndez Ortiz, Juan Jos??	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	249
117	15123	Ruiz Ruiz, Jos?? Fabricio Alizardy	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	188
118	16068	Gonz??lez Estrada, Marlon Estuardo	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	228
119	16070	Gonz??lez R??os, Walfred David Alexander	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	229
120	16153	Valladares Gonz??lez Hector Noel	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	275
121	19067	Gonz??lez Alfaro, Eddy Rafael	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	432
122	19068	Gonz??lez Alvarado, Lestid Eliazar	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	433
123	19069	Gonz??lez Escobar Leidy Mariela	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	434
124	16013	Calder??n Hector Oswaldo	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	201
125	16014	Calder??n L??pez Clara Luz	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	202
126	18026	Evelyn Nohelia Garrido Trabanino	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	337
127	19004	Agust??n Diego Luis Fernando	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	369
128	19156	Tom??s Agust??n, Franklin Mayck	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	521
129	5	Tuells Agust??n, Alisson Mariana	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	542
130	18030	Ahiderson Andr?? Hern??ndez Castillo	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	341
131	19027	Ch??vez Pe??a, Darwin Ronald	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	392
132	19038	De Paz Santos Breder Alexander	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	403
133	16040	Cortez Men??ndez, Oscar Anibal	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	215
134	19026	Caz??n Zepeda, Mar??a Concepci??n	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	391
135	19070	Gonz??lez Jim??nez, Elman Ivan	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	435
136	19046	Flori??n V??squez, Jos?? Manuel	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	411
137	19047	Flori??n V??squez, Jos?? Ronaldo	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	412
138	16057	Flori??n Mor??n, Luis Fernando	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	222
139	25	Hern??ndez Palencia, Yasmin Mar??a Paola	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	562
140	19114	Ortiz Jim??nez, Esmeralda Idalia	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	479
141	19164	Vela Ortiz, Maynor Manuel	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	529
142	19117	Peralta Marroqu??n Jasmine Sara??	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	482
143	19126	Pop Xa, Maurilio	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	491
144	19153	Santizo Valdez Angela Noem??	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	518
145	19159	Valdez Herrera Carlos Alberto	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	524
146	19170	Xona Ajanel, Darwin Abelino	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	535
147	16150	Solares Carias Jorge	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	272
148	3016	HERNANDEZ GALDAMEZ, WILNER	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	22
149	19029	Cop Galvan Guillermo Eduardo	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	394
150	13011	Ju??rez Chen, Edwin Eduardo	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	100
151	1048	MORALES ROMAN, JOS?? ADRI??N	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	21
152	12026	Quina Simon, Marvin Dinael	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	95
316	19041	Donis Alfaro, Mar??a Celeste	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	406
381	4001	AGUSTIN LOPEZ, ESTEBAN DOMINGO	7	t	2025-12-09 01:50:04.602659+00	\N			\N			\N	\N	\N	28
177	19134	Ramos Godoy Aracely	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	499
153	00001	Agente Brigada 01	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	brigada01@provial.gob.gt	\N	\N	\N	15
154	12002	Camas Andrade, Edwin	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	85
155	1032	MAZARIEGOS RODR??GUEZ, JULIO	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	17
156	1012	Garcia Garcia, Angel Mario	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	16
157	1006	Santos ??vila, Marvin, D.	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	18
158	5037	QUICH?? VEL??SQUEZ, BARTOLO	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	41
159	7006	Carrillo Hern??ndez, Juan Alberto	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	46
160	7010	Marcos Roberto de Le??n Rold??n	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	47
161	8043	Rivas D??az, Kennedy Josu??	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	55
162	9005	Qui????nez Hernandez, Edwing	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	58
163	11002	Albisures Garc??a, Juan	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	73
164	4028	LAJ TECU JUAN ANTONIO	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	33
165	12003	Carias Z????iga, Walfre	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	86
166	12018	Mendoza Zelada, Marvin E.	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	90
322	19092	L??pez Montero Cruz Armando	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	457
167	12024	Obreg??n Chinchilla, Jorge Luis	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	93
168	12025	Quevedo Corado, Jeid?? Patricia	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	94
169	13009	Garc??a Esquivel, Lester	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	98
170	27	Jumique Oliva, Yoyi Natasha	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	564
171	13010	Hernandez P??rez, Josu?? Daniel	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	99
172	13017	Melgar L??pez, Edwin Leonardo	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	102
173	14003	Argueta, Guilver Y??natan	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	107
174	14023	Rodriguez Qui??ones, Marvin Alexander	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	115
175	15001	Adriano Hern??ndez, Adolfo Estuardo	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	117
176	15003	Ardiano Vel??squez, Abdi Abisa??	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	119
178	15005	Argueta Sandoval, Delmi Odal??	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	121
179	15006	Aroche Ucelo, Francisco Jes??s	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	122
180	15011	Barillas Vel??squez, Jaime Bernab??	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	124
181	15012	Barrera Rodr??guez, F??lix Daniel	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	125
182	15014	Bautista De Le??n, Sergio Rub??n	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	126
183	15017	Cabrera Suchite, Kleiver Josu??	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	128
184	15018	C??rdenas Argueta, Allan Josu??	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	129
185	15019	Carrillo Garc??a, Walter Aristides	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	130
186	15021	Cerme??o Barahona, Wilsson Israel	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	131
187	15022	Cerme??o Barrios, Edgar Alfonso	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	132
188	15025	Ch?? Ichich, Oscar Arnoldo	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	134
189	15027	Colop Xec, Abelardo Abiga??l	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	136
190	15031	Cruz L??pez, Estuardo	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	140
191	15040	Esteban Estrada, Edras Josu??	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	142
192	15044	Fuentes Garc??a, Milton Danilo	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	144
193	15047	Garc??a Garc??a, Pedro C??sar	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	146
194	15049	Garc??a Pineda, Gelber Alexander	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	147
195	15050	Gir??n M??ndez, Miguel Angel	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	148
196	15051	G??mez Aceytuno, Manuel Estuardo	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	149
197	15061	Guzm??n Lemus, Erick Randolfo	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	153
198	15062	Hern??ndez Fajardo, Rufino David	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	154
199	15063	Hern??ndez y Hern??ndez, Edwin Rolando	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	155
200	15069	L??pez Castro, Francel Isa??as	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	160
201	15076	Mart??nez Herrera, Miguel Antonio	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	164
202	15079	Mej??a Hern??ndez, Christian Geovanni	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	165
203	15080	M??ndez Garc??a, Wiliam Neftal??	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	166
204	15030	Cortez Cisneros,Juan Wilberto	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	139
205	15058	Gudiel Osorio, Ced??n Fernando	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	152
206	15082	Miranda Aguilar, Esa?? Emanuel	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	168
207	15097	Ortiz Catal??n, Augusto	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	177
208	15036	Donis Ortiz, Marco Tulio	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	141
209	15094	Mor??n L??pez, Jayme Josue.	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	174
210	15100	P??rez Asencio, Ronal Orlando	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	180
211	15102	P??rez Morales, Anibal Eliandro	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	182
212	15129	Santos P??rez, William Michael	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	192
213	15134	Valdez Mart??nez, Cristopher Obed	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	194
214	15137	Vel??squez Escobar, Roger Wilfredo	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	195
215	15139	Z????IGA FERNANDEZ GERMAN DANILO	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	197
216	16020	Casta??on Rodr??guez Estuardo Odely	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	207
217	16033	Cojom Damian, Emanuel Isa??as	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	211
218	16037	Corado Ram??rez, Claudia Fabiola	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	213
219	16042	De La Rosa Monterroso, Manuel De Jes??s	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	216
220	16044	Del Cid Hern??ndez, Junior Humberto	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	217
221	16048	Escobar Beltr??n, Marlon Geobany	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	218
222	16050	Escobar Cerme??o, Marvin Geovani	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	219
223	16052	Escobar Garc??a, Kevin Alfredo	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	220
224	16053	Escobar Hern??ndez Yeison Humberto	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	221
225	16064	Garc??a Ramirez Elder Alfredo	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	225
226	16067	G??mez Elvira Jose Fernando	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	227
227	16001	Adqui L??pez Arly Paola	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	198
228	16015	Cama Acoj, Cristhian Geovany	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	203
229	15091	Morales Lemus, H??ctor Adulfo	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	173
230	15125	Samayoa Dub??n, Cristian Omar	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	190
231	15131	Siac Ortiz, Marvyn Gundemaro	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	193
232	16077	Hern??ndez Cotill Abner Misael	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	233
233	16078	Hern??ndez Giron Yonathan Alexander	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	234
234	16080	Hern??ndez Palencia, Albert Gennady	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	236
235	16086	Lima L??pez, Hugo David	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	239
236	16089	L??pez Alonzo, Marcos Daniel	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	241
237	16092	L??pez Morales, Mario Samuel	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	242
238	16096	Mart??nez Anavisca Brian Luis Felipe	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	245
239	16097	Mart??nez Ar??valo, No?? De Jes??s	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	246
240	16105	Morales G??mez, Mario Fernando	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	251
241	16109	Mor??n Puaque Elmar Rolando	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	254
242	16113	Orellana Estrada, Jes??s Emilio	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	255
243	16114	Orozco T??maj Byron Armando	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	256
244	16119	P??rez Garrido Mailyng Leilani	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	259
245	16130	Ram??rez Yanes, Jonyr Rolando	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	263
246	16135	Rodr??guez Larios, Pedro Ca??n	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	265
247	16147	Sifuentes ??vila Kevin Ernesto	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	271
248	17016	Campos Cerme??o Cesar Eduardo	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	286
249	17018	Cerme??o Pineda Evelin Siomara	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	288
250	17020	Cifuentes Cerme??o, Dora Iracema	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	290
251	17029	L??pez Carranza Sandra Soeveldiny	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	296
252	17037	Ordo??ez Garcia Sindy Carolina	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	302
253	17039	Ortiz Catal??n, Geovanny Jose Maria	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	304
254	16107	Mor??n Caz??n, Mynor Armando	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	253
255	16152	Teca Raxcaco Victor Manuel	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	274
256	16074	Guti??rrez Herrera, Edvin Edilson	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	230
257	16079	Hern??ndez Ju??rez, Pablo	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	235
258	16082	Hurtado Asencio, Mar??a De Los ??ngeles	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	237
259	16100	Mencha Anavisca, Hilmy Julissa	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	247
260	16143	Santizo Bojorquez, Alexis Efra??n	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	267
261	16116	Ortiz Carrillo Kevin Renato	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	257
262	16117	Ortiz Paz, Luis Carlos	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	258
263	16144	Santos Beltet??n, Yonatan Eduardo	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	268
264	18004	Paula Jimena Ar??valo Florian	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	315
265	18008	Astrid Melisa Caal Espa??a	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	319
266	18018	Alberto Josue  Cruz Sarce??o	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	329
267	18032	Kimberly Alejandra Jorge L??pez	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	343
268	18035	Gervin Friceli Morales G??lvez	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	346
269	18041	Melvin Adalberto P??rez Coc	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	352
270	18042	Rudy Osmin P??rez Osorio	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	353
271	18052	Yulian Ronaldo Santos L??pez	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	363
272	19008	Arana Mart??nez, Pedro Alberto	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	373
273	19009	Arevalo Herrera Marvin Eduardo	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	374
274	19010	Grely Aneth Aviche Car??as	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	375
275	19014	Barrios L??pez, Axel Eberto	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	379
276	19015	Batres Hern??ndez, Denilson Ottoniel	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	380
277	19018	Campos Cerme??o Miguel Angel	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	383
278	19020	Cardona Coronado Ronald Gerem??as	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	385
279	19022	Car??as Castro, Mario Llivinson	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	387
280	19023	Car??as Godoy Ronald Vinicio	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	388
281	19030	Corado Garza, Est??fany Melisa	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	395
282	19035	Cutzal Garc??a Eddy Obdulio	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	400
283	19011	Bail??n Hern??ndez Andy Adalberto	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	376
284	19031	Corado Mor??n, Edgar Antonio	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	396
285	19025	Caz??n Godoy Walter Oswaldo	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	390
286	19033	Cortez Vel??squez Alex Adonis	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	398
287	19021	Cardona L??pez, Wilson Ad??n	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	386
288	19037	De Paz Nicol??s, Juan Alberto	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	402
289	19002	Aguilar P??rez, Juan Orlando	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	367
290	18014	Cristian Abraham Citalin Custodio	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	325
291	19019	Canahua Garc??a, Helen Marisol	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	384
292	17047	Sandoval Aguilar, Rub?? de los Angeles	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	308
293	19039	Dominguez Gait??n, Amalio Rodrigo	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	404
294	19042	Ronald Israel Escobar Echeverr??a	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	407
295	19043	Esquivel Ram??rez Medary	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	408
296	19052	Galindo Hern??ndez, Osmin Manolo	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	417
297	19053	Garc??a Asencio Dandis Imanol	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	418
298	19055	Garc??a Esquivel Cristian Xavier	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	420
299	19056	Garc??a Granados, Edilson Esaul	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	421
300	19057	Garc??a Hern??ndez Luciano	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	422
301	19059	Garc??a Pineda, Amner Estuardo	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	424
302	19060	Garc??a Pineda, Anibal Nicolas	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	425
303	19064	Godoy L??pez Wilson	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	429
304	19065	G??mez Sales Baudilio	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	430
305	19073	Hern??ndez Aguilar Angel David	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	438
306	19074	Hern??ndez De Le??n Maria Fernanda De Aquino	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	439
307	19075	Hern??ndez L??pez Carlos Alberto	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	440
308	19076	Hern??ndez Salguero, Karen Gemima	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	441
309	19077	Hurtado Asencio Elvidio De Jes??s	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	442
310	19085	L??mus Ramirez Wilmer Samuel	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	450
311	19087	L??pez, Gerber Ottoniel	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	452
312	19088	L??pez Gustavo Adolfo	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	453
313	19089	L??pez Alvarez, Lusbin Guadalupe	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	454
314	19090	L??pez Coronado, Fernando	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	455
315	19045	Flores Lat??n Junior Antonio	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	410
317	19058	Garcia P??rez, Lucas Fernando	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	423
318	19054	Garc??a Bertrand Yeison Wilfredo	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	419
319	19081	Pineda Jim??nez, Cristopher Oswaldo	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	446
320	19061	Gac??a Z????iga Nixozan Rolando	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	426
321	19082	Ju??rez Alfaro, Gustavo Adolfo	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	447
323	19079	Ica G??mez, Ketherine Roc??o	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	444
324	19066	G??mez Ortiz, Carmen Liliana	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	431
325	19094	L??pez pe??a, Luis Fernando	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	459
326	19095	L??pez T??maj Jonatan Rolando	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	460
327	19102	Mayorga P??rez Remy Angel Arturo	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	467
328	19105	Miranda M??ndez Mynor	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	470
329	19108	Morales Mej??a Beberlyn Alejandra	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	473
331	19113	Ordo??ez Ortega Sergio Estuardo	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	478
332	19115	Pablo Tom??s Gricelda Micaela	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	480
333	19119	P??rez Arriaza Victor Ovidio	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	484
334	19122	P??rez Ram??rez Elfido Miguel	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	487
335	19123	P??rez Vel??squez, Gerber Estuardo	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	488
336	19124	Pineda Car??as Ivan Alexander	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	489
337	19125	Ponciano L??zaro Sandra Ang??lica	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	490
338	19127	Qui????nez Hern??ndez Rudim??n Omar	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	492
339	19129	Rabanales Fuentes C??sar Obdulio	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	494
340	19130	Ram??rez Herrarte, Jenderly Andrea	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	495
341	19132	Ram??rez Herrera Mynor Anibal	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	497
342	19133	Ram??rez Santos Willian Estuardo	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	498
343	19140	R??os Barrera De Asencio Zoila Virginia	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	505
344	19142	Rivera V??squez Ander Yoel	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	507
345	19143	Rivera V??squez Beverlin Graciela	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	508
346	19144	Rodr??guez Hip??lito, Cristian Alexander	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	509
347	19145	Rodr??guez Orozco Yesica Fabiola	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	510
348	19147	Salanic G??mez Marvin Orlando	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	512
349	19149	Sales G??mez, Antony Josue	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	514
350	19137	Revolorio Lat??n German Oswaldo	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	502
351	19148	Sales G??mez, Ad??n Alexander	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	513
352	19120	P??rez Cruz C??sar Adonay	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	485
353	19098	Marroqu??n Argueta Edwin Humberto	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	463
354	19099	Marroqu??n Orellana Mar??a Alejandra	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	464
355	19106	Monz??n de Paz, Jennifer Vanessa	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	471
356	19107	Monz??n Garc??a, Miguel Angel	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	472
357	19150	S??nchez Ramos Jefrey Samuel	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	515
358	19151	S??nchez Tobar Victor Francisco	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	516
359	19152	S??nchez Vargas, Carlos Humberto	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	517
360	19157	Tom??s Cardona Fredy Ovando	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	522
361	19158	Tzunux Hern??ndez, Jose Daniel	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	523
362	19161	V??squez Dom??nguez, Omer Naias	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	526
363	19162	V??squez Dom??nguez, Manolo Exzequiel	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	527
364	19163	V??squez Gonzalez, Edilson Romario	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	528
365	19166	Aury Ayendy Vel??squez Dominguez	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	531
366	19168	Osbin Audiel Veliz Ram??rez	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	533
367	2	Hern??ndez Colaj, Josu?? David	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	539
368	15	Mungu??a Flores, Vivian Guadalupe	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	552
369	20	Jer??nimo Estrada, Jeison Ernesto	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	557
370	8	Ch?? Ichich, Victor Manuel	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	545
371	10	Juarez Alfaro, M??bel Sof??a	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	547
372	11	Maldonado Mej??a, Ylin Guadalupe	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	548
373	1022	Adriano Lopez, Manuel de Jes??s	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	20
374	3025	Perdomo L??pez, Edgar	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	25
375	4016	Fuentes L??pez, Uber	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	31
376	1016	EDNA MELISA MARCHORRO PAIZ	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	19
377	3018	HERRARTE SILVA, GUSTAVO ADOLFO	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	23
378	3024	Morales Romero, Griselda	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	24
379	3031	RAMIREZ MARROQUIN, SANTIAGO	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	26
380	3032	Ramirez Toc, Jorge Mario	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	27
382	19167	Vel??squez Lat??n, Abner Alexis	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	532
383	9	Galicia L??pez, Ingrid Noem??	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	546
384	14	Marroqu??n Marroqu??n, Katerine de Jes??s	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	551
385	16	Godinez Matal, Wilder Neptal??	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	553
386	19165	Velasquez Coronado, Vinicio Efra??n	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	530
387	13	Miranda Aguilar, Jenner Mois??s	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	550
388	3	Ord????ez Tzoc, Erick Alberto	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	540
389	4009	CISNEROS ESQUIVEL RICARDO	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	29
390	4015	Fajardo Rodas, Elmer	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	30
391	4022	GUTIERREZ CHACLAN FERNANDO	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	32
392	4046	SALAZAR PORTILLO, PEDRO	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	34
393	4053	Vicente Ajtun, Moises	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	35
394	4054	Xitumul Perez, Julio Alberto	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	36
395	5000	Aquino Escobar, Juan	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	37
396	5003	CUMEZ CHACACH, FREDY	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	38
397	5005	CRUZ VELIZ OSMAR RAMIRO	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	39
398	5006	CIFUENTES CU JOSE LUIS	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	40
399	5041	REYES SACUL CUPERTINO	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	42
400	6008	CAXAJ GIRON JACOB	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	43
401	6026	Mateo Lopez Cesar Everildo	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	44
402	6033	Torres Perez, Denis	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	45
403	7012	DIAZ DE LEON GUSTAVO ADOLFO	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	48
404	7043	RAMOS ALFARO, BAYRON YOBANY	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	49
405	7045	RODAS CARCAMO CESAR JOAQUIN	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	50
406	7058	Ramirez Castillo, Remigio	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	51
407	8003	ARRIVILLAGA OLIVA, EDGAR GEOVANNI	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	52
408	8012	Cuxil Xicay, Edwin	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	53
409	8031	Pacheco Escobar, Vilma Janeth	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	54
410	8044	SANTIZO PEREZ, JUAN	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	56
411	8047	Suchite Orellana, Maynor	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	57
412	9006	OLIVA PAIZ, UBALDO	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	59
413	9015	Fuentes Fuentes, Margarito	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	60
414	9016	Jor Max, Ruben Dario	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	61
415	9019	Orellana Paz, David Gerardo	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	62
416	9021	PEREZ MIRANDA FELICIANO	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	63
417	16103	Miranda Melgar Edson Ariel	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	250
418	10005	CALDERON RODRIGUEZ GERSON NOE	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	64
419	10006	CARRETO PEREZ WENDY YOMARA	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	65
420	10013	Gonzales Cardona, Luis Alberto	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	66
421	10021	LUC PEREZ, JOSUE	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	67
422	10025	MONZON MORALES MITSIU YONATHAN	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	68
423	10032	RAMOS CINTO RODELFI ADELAIDO	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	69
424	10033	REVOLORIO REVOLORIO SILVERIO ELISEO	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	70
425	10034	REVOLORIO ORTIZ JHONY MARTIN	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	71
426	10041	VELASQUEZ PABLO TELESFORO ALBERTO	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	72
427	11004	Arana Franco, Wagner	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	74
428	11006	Atz Argueta, Jose Vicente	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	75
429	11014	Galicia Galicia, Marcela	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	76
430	11017	GARCIA LIMA EDY REGINALDO	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	77
431	11018	Godinez Velasquez,Kevin	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	78
432	11024	Juarez Sanchez, Edwin A.	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	79
433	11026	Lopez Rosales, Marco Luis	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	80
434	11034	PEREZ GOMEZ BRYAN	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	81
435	11035	Quieza Porras, Chrystian	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	82
436	11040	TORRES GALVAN LUIS FERNANDO	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	83
437	11042	Xajap Xuya, Jose Wenceslao	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	84
438	12005	Castillo Aguilar, Breder Vidani	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	87
439	12010	Esquivel Herrera, Blas Roosenvelt	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	88
440	12014	Jimenez Cortez David Isaias	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	89
441	12022	Morataya Rosales, Lizeth	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	91
442	12023	MOREIRA HERNANDEZ JOSE ADEMIR	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	92
443	12031	Toj Lopez,  William Edilser	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	96
444	13008	DUARTE ALAY ROBERTO CARLOS	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	97
445	13012	LEIVA RAMOS EVERTH LEMUEL	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	101
446	13022	Salgado Kegel, Romeo Alberto	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	103
447	13027	Campos Retana, Aroldo Federico	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	104
448	13036	Retana Valladares, Horacio Fabricio	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	105
449	13037	Vasquez Rivera, Luis Miguel	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	106
450	14004	Barrientos Revolorio, Madhelyn Lizbeth	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	108
451	14007	CABRERA CRUZ, BRYAN JOSE	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	109
452	14008	Charchalac Cox, Victor Raul	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	110
453	14013	Garcia Morales, Edgar Omar	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	111
454	14015	Martinez Anavizca William Estuardo	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	112
455	14017	Monterroso Perez, Mynor Rene	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	113
456	14020	Najarro Moran, Dular	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	114
457	14024	Santos Loy, Hiben Amadiel	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	116
458	15002	Alonzo Morales, Victor Manuel	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	118
459	15004	Argueta Bernal, Beyker Eduardo	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	120
460	15007	Asencio Corado, Alex Omar	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	123
461	15015	Belloso Flores, Carlos Alex	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	127
462	15024	Chinchilla Valenzuela, Kevin Estuardo	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	133
463	15026	Chub Coc, Salvador	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	135
464	15028	Contreras Paau, Jorge Humberto	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	137
465	15029	Corado Reynosa, Steeven Omar	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	138
466	15041	Estrada Morales, Carlos Leonel	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	143
467	15046	Garcia Castillo, Elmer Candelario	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	145
468	15066	Landaverde Rodriguez Byron Fernando	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	158
469	15068	Lima Yanes Jerson Geovani	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	159
470	15073	MANZANO PEREZ JOSEPH ALEXANDER	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	161
471	15074	MARROQUIN LOPEZ, EDWIN FABIO	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	162
472	15075	Martinez Brol, Anthony Steven	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	163
473	15081	Mendoza Belloso, Darvin Enrique	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	167
474	15083	Miranda Barrios, Lester Waldemar	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	169
475	15086	MONTERROSO ARGUETA EDWIN RODOLFO	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	170
476	15088	Morales Barrientos, Manglio Estiward	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	171
477	15089	Morales Barrientos, Marta Berenice	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	172
478	15095	NAJERA MORALES EDVIN ANTONIO	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	175
479	15098	Palencia Morales, Anderson Brenner	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	178
480	15106	PINEDA OSORIO, BRYAN ALEXANDER	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	184
481	15109	Quinteros Del Cid, Ervin Edgardo	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	185
482	15116	Rivas Regalado, Carlos Dagoberto	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	186
483	15122	Ruano Corado, Luzbeth Yaneth	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	187
484	15128	Santacruz Salazar, Ludbin Obel	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	191
485	15138	Yoc Elel, Edson Ernesto	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	196
486	16002	Aguilar Castillo, Santos Amilcar	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	199
487	16016	Cano Boteo Irrael	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	204
488	16017	Cano Serrano, Gervin Geovany	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	205
489	16019	Carrillo Rossell, Kevin Arnaldo	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	206
490	16032	Chiroy Revolorio Kerlin Arturo	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	210
491	16036	Corado Corado, Jerzon Anibal	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	212
492	16060	Franco Sierra Edgar Saray	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	223
493	16065	Jimenez Gonzales Rafael Estuardo	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	226
494	16075	Hernandez Barrera Rufino Dagoberto	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	231
495	16088	LINARES CRUZ ESDRAS EFRAIN	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	240
496	16094	Lorenzo Yac Anselmo	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	243
497	16095	Marroquin Argueta, Esleyder Antonio	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	244
498	16106	Morales Ochoa Selvin Vinicio	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	252
499	16125	Piox Cadenas Edwin Leonel Enrique	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	260
500	16126	Quintana Barrientos, Mario Roberto	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	261
501	16128	Ramirez Gereda Tayron Alexander	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	262
502	16131	Revolorio Arana Brayan Alexander	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	264
503	16139	Edvin Jose Rodolfo Ruiz Gutierrez	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	266
504	16145	Santos Turcios, Nelson Bladimiro	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	269
505	16146	Sical Manuel, Marlon Estuardo	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	270
506	16151	Sosa Barrios, Bryan Josue	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	273
507	16155	Virula y Virula, Osiel Antonio	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	276
508	16156	Vivas Nimacachi David Amilcar	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	277
509	16157	Zepeda Chavez, Axel Ariel	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	278
510	17004	Gomez Ramirez Samy Renato	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	280
511	17005	LOPEZ GUILLEN MARIO ROLANDO	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	281
512	17014	Kenia Estrella Barrientos Mendez	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	284
513	17015	Blanco Carias Evelin Maritza	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	285
514	17017	Campos Pinelo Edwin Daniel	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	287
515	17019	Chol Quiroa Cesar Antonio	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	289
516	17021	Corado Y Corado Ever Antonio	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	291
517	17034	Morales Ochoa Gerson Augusto	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	292
518	17022	Divas Anavisca Carla Yohana	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	293
519	17023	Flores Vargas Douglas Waldermar	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	294
520	17027	Jimenez Castillo Erick Geovanny	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	295
521	17031	Mayorga Perez Keyner Josue	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	297
522	17032	Mendez Suchite Roslyn Mariela	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	298
523	17033	Morales Marroquin Dilan Alexis	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	299
524	17035	Moran Florian, Astrid Rosmery	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	300
525	17036	Najarro Barillas, Elvia Dalila	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	301
526	17038	Ortiz Estrada Karla Edith	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	303
527	17040	Osorio Echeverria, Alicia Yamilet	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	305
528	17045	Ramirez Chapas Antony Mateus	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	306
529	17046	Sagastume Castillo Jose Manuel	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	307
530	17048	Santiago Sanchez, Joel Antonio	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	309
531	17050	Velasquez Yat Daniel Oswaldo	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	310
532	17051	Veliz Gereda Yerlin Yesenia	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	311
533	18001	Jorge Amilcar Aceituno Santos	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	312
534	18002	Adriano Hernandez Joshua Emanuel	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	313
535	18003	Albizures Ramirez Wilmer Abel	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	314
536	18005	Asencio Corado, Ronal Israel	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	316
537	18006	Walter Alexander Barrios Blanco	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	317
538	18007	Claudia Lucrecia Caal Cucul	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	318
539	18009	Edgar Daniel Cal Cal	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	320
540	18010	Roni Emilio Campos Gonzales	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	321
541	18011	Castellanos Perez Yeferson Gerber H.	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	322
542	18012	Dony Isidro Castillo Herrera	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	323
543	18013	Catherin Yanira Chapas Gonzales	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	324
544	18015	Coronado Alvarez Keiry Mirella	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	326
545	18016	Josseline Anabella Cortez Santay	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	327
546	18017	Cruz Mendez Cristian Alfredo	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	328
547	18019	De Leon Alvarado Cesar Alejandro	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	330
548	18020	Alexander David De Leon Lopez	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	331
549	18021	Josue David Diaz Chan	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	332
550	18023	Estrada Corominal Walter Isaias	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	334
551	18024	Edwin Alexander Figueroa Moran	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	335
552	18025	Walter Garcia Garcia	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	336
553	18027	Godinez Martinez Jorge Antonio	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	338
554	18028	Gomez Mendez Persy Aristidez	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	339
555	18029	Gudiel Gallardo Angeliz Amordi	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	340
556	18031	Hernandez Sandoval Helen Emilsa	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	342
557	18033	Lopez Lau Rogers Ernesto	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	344
558	18034	Morales Barrios Anderson Giovani	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	345
559	18036	Morales Rivas Cristian Francisco	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	347
560	18037	Cristopher Ricardo Monzon Ramos	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	348
561	18038	Osorio Machan Maria Yesenia	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	349
562	18043	Perez Perez Daminan de Jesus	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	354
563	18044	Sandro Emmanuel Ramirez Guerrero	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	355
564	18045	Ramirez Monroy Wilson Giovany	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	356
565	18046	Ramirez Pineda Franklin Irael	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	357
566	18047	Madelin Ivana Revolorio Orantes	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	358
567	18048	Reyes Ortiz Abner Antonio	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	359
568	18049	Salazar Ortiz Walter Arturo	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	360
569	18050	Sanchez Perez Esteban	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	361
570	18051	Santos Belteton, Seleni Yoliza	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	362
571	18053	Toto Paz Kevin Alberto	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	364
572	18054	Velasquez Mejia Yasmin Sorana	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	365
573	19001	Aguilar Melgar, Angel Humberto	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	366
574	19003	Aguirre Palma Luis Angel	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	368
575	19005	Alvarez Hernandez, Domingo Bayron	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	370
576	19012	Barco Galicia Carlos Eduardo	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	377
577	19013	Barrientos Corado, Danis Estid	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	378
578	19016	Cabrera Alfaro, Carlos Alfonso	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	381
579	19017	Cal Xona Liliana Beverly	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	382
580	19024	Castillo Godoy, Mario Alejandro	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	389
581	19028	Chinchilla Corado, Darwin Omar	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	393
582	19034	Cotto Sanchez, Marcela Judith	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	399
583	19036	Diaz, Luis Angel	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	401
584	19040	Juan Antonio Donis Alfaro	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	405
585	19044	Estrada Corominal Mirza Lizette	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	409
586	19048	Franco Herrera, Alma Yaneth	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	413
587	19049	Fuentes Cruz, Luis Diego	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	414
588	19050	Galicia Gomez, Nelson Geovanny	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	415
589	19051	Galicia Najarro, Gerson David	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	416
590	19062	Garza Flores William Armando	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	427
591	19063	Garza Godoy, Katerin Dalila	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	428
592	19071	Grijalva Belloso Juan Carlos	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	436
593	19072	Gudiel Castillo, Ever Yahir Alexis	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	437
594	19078	Ichich Choc, Edgar Zaqueo	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	443
595	19080	Isidro Baltazar Adolfo Angel	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	445
596	19083	Jui Alvarado Hugo Leonel	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	448
597	19084	Latin Bernal, Sandy Esperanza	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	449
598	19086	Linares Linares, Anthony Isael	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	451
599	19091	Lopez Jimenez, Jesfri Omar	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	456
600	19096	Maquin Cacao, Cristian Vidal	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	461
601	19100	Maroquin Orozco, Iris Madai	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	465
602	19101	Martinez Melgar, Gloria Francis Amabel	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	466
603	19103	Melgar, Rogelio Raquel	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	468
604	19104	Mazariegos Arana Gilma Yolanda	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	469
605	19110	Najarro Barillas, Otilia Yesenia	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	475
606	19111	Willian Estuardo, Najarro Osorio	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	476
607	19112	Navarro Vasquez Nancy Roxana	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	477
608	4	Godoy Chinchilla, Emeldi Eulalia	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	541
609	6	Quevedo Donis, Helen Paola	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	543
610	7	Martinez Carias, Katherin Damaris	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	544
611	12	Lemus Batancourt, Rony Omar	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	549
612	17	Cotzajay Sandoval, Joseb Enmanuel	1	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	554
613	18	Garcia Barrios, Jaime Ruben	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	555
614	21	Carrera Torres, Carlos Alberto	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	558
615	22	Tobar Mendoza, Wilian Uliser	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	559
616	23	Cotto Trejo, Manuel Dario	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	560
617	24	Cetino Casimiro, Jeremias	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	561
618	28	Morales Barrios, Juan Manuel	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	565
619	26	L??pez Cifuentes, Karla Victoria	9	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	563
620	19131	Ramirez Chapas Brandon Omar	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	496
621	19135	Retana Cardona, Jhonatan Guillermo	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	500
622	19136	Retana Mazariegos, Yeni Maritza	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	501
623	19138	Reyes Ortiz, Victor Daniel	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	503
624	19139	Reyna Rivera Walter Alexis	6	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	504
625	19141	Rivera Esquivel Edwin Vinicio	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	506
626	19146	Ruano Pernillo Vasti Madai	8	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	511
627	19154	Soto Monterroso Freiser Enrique	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	519
628	19155	Tagua Zanunzini Frank Antonni	7	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	520
629	19160	Valenzuela Asencio Lucas David	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	525
630	19169	Villanueva Corado, Jerson Alexander	2	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	534
631	17000	Lizardo Gabriel Tash Giron	4	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	537
632	1	Araus Velasquez, Kevin Manfredo	5	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	538
330	19109	Morales Mej??a, Yair Alexander	3	t	2025-12-09 01:50:04.602659+00	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: brigada_unidad; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.brigada_unidad (id, brigada_id, unidad_id, rol_tripulacion, fecha_asignacion, fecha_fin, activo, observaciones, asignado_por, created_at, updated_at, es_comandante) FROM stdin;
\.


--
-- Data for Name: bus; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.bus (id, vehiculo_id, empresa, ruta_bus, numero_unidad, capacidad_pasajeros, fecha_registro, created_at) FROM stdin;
\.


--
-- Data for Name: calendario_grupo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.calendario_grupo (id, grupo, fecha, estado, observaciones, creado_por, created_at) FROM stdin;
\.


--
-- Data for Name: campo_personalizado; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.campo_personalizado (id, tabla_destino, clave, etiqueta, tipo, opciones, orden, activo, creado_por, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: catalogo_motivo_inactividad; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.catalogo_motivo_inactividad (id, codigo, nombre, descripcion, requiere_fecha_fin, activo, orden) FROM stdin;
1	VACACIONES	Vacaciones	Periodo de vacaciones	t	t	1
2	PERMISO_MEDICO	Permiso Médico	Incapacidad por enfermedad o accidente	t	t	2
3	LICENCIA_MATERNIDAD	Licencia de Maternidad	Licencia por maternidad/paternidad	t	t	3
4	SUSPENSION	Suspensión	Suspensión disciplinaria	t	t	4
5	CAPACITACION	Capacitación	Asistiendo a curso o capacitación	t	t	5
6	COMISION	Comisión de Servicio	Comisionado a otra dependencia	t	t	6
7	RENUNCIA	Renuncia	Renuncia voluntaria	f	t	7
8	DESPIDO	Despido	Terminación de contrato	f	t	8
9	JUBILACION	Jubilación	Retiro por jubilación	f	t	9
10	FALLECIMIENTO	Fallecimiento	Fallecimiento del empleado	f	t	10
11	OTRO	Otro	Otro motivo no especificado	f	t	99
\.


--
-- Data for Name: combustible_registro; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.combustible_registro (id, unidad_id, asignacion_id, turno_id, tipo, combustible_anterior, combustible_agregado, combustible_nuevo, combustible_consumido, odometro_anterior, odometro_actual, km_recorridos, rendimiento_km_litro, observaciones, registrado_por, created_at) FROM stdin;
\.


--
-- Data for Name: configuracion_alerta; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.configuracion_alerta (id, tipo, nombre, descripcion, severidad_default, activa, tiempo_inactividad_minutos, umbral_combustible, umbral_km, notificar_push, notificar_email, notificar_sms, roles_destino, created_at, updated_at) FROM stdin;
1	EMERGENCIA	Emergencia	Situación de emergencia reportada	CRITICA	t	60	20.00	5000	t	f	f	{COP,OPERACIONES,ADMIN,SUPER_ADMIN}	2026-01-01 07:20:52.425377	2026-01-01 07:20:52.425377
2	UNIDAD_SIN_ACTIVIDAD	Unidad sin actividad	Unidad sin reportar actividad por tiempo prolongado	MEDIA	t	60	20.00	5000	t	f	f	{COP,OPERACIONES}	2026-01-01 07:20:52.425377	2026-01-01 07:20:52.425377
3	INSPECCION_PENDIENTE	Inspección pendiente	Inspección 360 esperando aprobación	MEDIA	t	60	20.00	5000	t	f	f	{COP,BRIGADA}	2026-01-01 07:20:52.425377	2026-01-01 07:20:52.425377
4	BRIGADA_FUERA_ZONA	Brigada fuera de zona	Brigada detectada fuera de su zona asignada	ALTA	t	60	20.00	5000	t	f	f	{COP,OPERACIONES}	2026-01-01 07:20:52.425377	2026-01-01 07:20:52.425377
5	COMBUSTIBLE_BAJO	Combustible bajo	Nivel de combustible bajo reportado	MEDIA	t	60	20.00	5000	t	f	f	{COP,OPERACIONES}	2026-01-01 07:20:52.425377	2026-01-01 07:20:52.425377
6	MANTENIMIENTO_REQUERIDO	Mantenimiento requerido	Unidad requiere mantenimiento por kilometraje	BAJA	t	60	20.00	5000	t	f	f	{OPERACIONES}	2026-01-01 07:20:52.425377	2026-01-01 07:20:52.425377
7	APROBACION_REQUERIDA	Aprobación requerida	Una acción requiere aprobación	MEDIA	t	60	20.00	5000	t	f	f	{COP,BRIGADA}	2026-01-01 07:20:52.425377	2026-01-01 07:20:52.425377
8	SISTEMA	Alerta del sistema	Alertas generadas por el sistema	BAJA	t	60	20.00	5000	t	f	f	{ADMIN,SUPER_ADMIN}	2026-01-01 07:20:52.425377	2026-01-01 07:20:52.425377
9	PERSONALIZADA	Alerta personalizada	Alertas personalizadas	MEDIA	t	60	20.00	5000	t	f	f	{COP,OPERACIONES}	2026-01-01 07:20:52.425377	2026-01-01 07:20:52.425377
\.


--
-- Data for Name: configuracion_columnas_tabla; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.configuracion_columnas_tabla (id, sede_id, tabla_nombre, columnas_visibles, orden_columnas, created_at, updated_at, creado_por) FROM stdin;
1	2	brigadas	["chapa", "nombre", "rol_brigada", "grupo", "sede", "telefono", "estado"]	{chapa,nombre,rol_brigada,grupo,sede,telefono,estado}	2026-01-04 00:33:39.702675+00	2026-01-04 00:33:39.702675+00	\N
2	5	brigadas	["chapa", "nombre", "rol_brigada", "grupo", "sede", "telefono", "estado"]	{chapa,nombre,rol_brigada,grupo,sede,telefono,estado}	2026-01-04 00:33:39.702675+00	2026-01-04 00:33:39.702675+00	\N
3	8	brigadas	["chapa", "nombre", "rol_brigada", "grupo", "sede", "telefono", "estado"]	{chapa,nombre,rol_brigada,grupo,sede,telefono,estado}	2026-01-04 00:33:39.702675+00	2026-01-04 00:33:39.702675+00	\N
4	6	brigadas	["chapa", "nombre", "rol_brigada", "grupo", "sede", "telefono", "estado"]	{chapa,nombre,rol_brigada,grupo,sede,telefono,estado}	2026-01-04 00:33:39.702675+00	2026-01-04 00:33:39.702675+00	\N
5	4	brigadas	["chapa", "nombre", "rol_brigada", "grupo", "sede", "telefono", "estado"]	{chapa,nombre,rol_brigada,grupo,sede,telefono,estado}	2026-01-04 00:33:39.702675+00	2026-01-04 00:33:39.702675+00	\N
6	1	brigadas	["chapa", "nombre", "rol_brigada", "grupo", "sede", "telefono", "estado"]	{chapa,nombre,rol_brigada,grupo,sede,telefono,estado}	2026-01-04 00:33:39.702675+00	2026-01-04 00:33:39.702675+00	\N
7	3	brigadas	["chapa", "nombre", "rol_brigada", "grupo", "sede", "telefono", "estado"]	{chapa,nombre,rol_brigada,grupo,sede,telefono,estado}	2026-01-04 00:33:39.702675+00	2026-01-04 00:33:39.702675+00	\N
8	9	brigadas	["chapa", "nombre", "rol_brigada", "grupo", "sede", "telefono", "estado"]	{chapa,nombre,rol_brigada,grupo,sede,telefono,estado}	2026-01-04 00:33:39.702675+00	2026-01-04 00:33:39.702675+00	\N
9	7	brigadas	["chapa", "nombre", "rol_brigada", "grupo", "sede", "telefono", "estado"]	{chapa,nombre,rol_brigada,grupo,sede,telefono,estado}	2026-01-04 00:33:39.702675+00	2026-01-04 00:33:39.702675+00	\N
10	2	unidades	["codigo", "tipo_unidad", "marca", "modelo", "placa", "sede", "estado"]	{codigo,tipo_unidad,marca,modelo,placa,sede,estado}	2026-01-04 00:33:39.71991+00	2026-01-04 00:33:39.71991+00	\N
11	5	unidades	["codigo", "tipo_unidad", "marca", "modelo", "placa", "sede", "estado"]	{codigo,tipo_unidad,marca,modelo,placa,sede,estado}	2026-01-04 00:33:39.71991+00	2026-01-04 00:33:39.71991+00	\N
12	8	unidades	["codigo", "tipo_unidad", "marca", "modelo", "placa", "sede", "estado"]	{codigo,tipo_unidad,marca,modelo,placa,sede,estado}	2026-01-04 00:33:39.71991+00	2026-01-04 00:33:39.71991+00	\N
13	6	unidades	["codigo", "tipo_unidad", "marca", "modelo", "placa", "sede", "estado"]	{codigo,tipo_unidad,marca,modelo,placa,sede,estado}	2026-01-04 00:33:39.71991+00	2026-01-04 00:33:39.71991+00	\N
14	4	unidades	["codigo", "tipo_unidad", "marca", "modelo", "placa", "sede", "estado"]	{codigo,tipo_unidad,marca,modelo,placa,sede,estado}	2026-01-04 00:33:39.71991+00	2026-01-04 00:33:39.71991+00	\N
15	1	unidades	["codigo", "tipo_unidad", "marca", "modelo", "placa", "sede", "estado"]	{codigo,tipo_unidad,marca,modelo,placa,sede,estado}	2026-01-04 00:33:39.71991+00	2026-01-04 00:33:39.71991+00	\N
16	3	unidades	["codigo", "tipo_unidad", "marca", "modelo", "placa", "sede", "estado"]	{codigo,tipo_unidad,marca,modelo,placa,sede,estado}	2026-01-04 00:33:39.71991+00	2026-01-04 00:33:39.71991+00	\N
17	9	unidades	["codigo", "tipo_unidad", "marca", "modelo", "placa", "sede", "estado"]	{codigo,tipo_unidad,marca,modelo,placa,sede,estado}	2026-01-04 00:33:39.71991+00	2026-01-04 00:33:39.71991+00	\N
18	7	unidades	["codigo", "tipo_unidad", "marca", "modelo", "placa", "sede", "estado"]	{codigo,tipo_unidad,marca,modelo,placa,sede,estado}	2026-01-04 00:33:39.71991+00	2026-01-04 00:33:39.71991+00	\N
19	\N	brigadas	["chapa", "nombre", "rol_brigada", "grupo", "sede", "telefono", "estado"]	{chapa,nombre,rol_brigada,grupo,sede,telefono,estado}	2026-01-04 00:33:39.726049+00	2026-01-04 00:33:39.726049+00	\N
20	\N	unidades	["codigo", "tipo_unidad", "marca", "modelo", "placa", "sede", "estado"]	{codigo,tipo_unidad,marca,modelo,placa,sede,estado}	2026-01-04 00:33:39.726049+00	2026-01-04 00:33:39.726049+00	\N
\.


--
-- Data for Name: configuracion_sistema; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.configuracion_sistema (id, clave, valor, tipo, descripcion, categoria, modificado_por, created_at, updated_at) FROM stdin;
1	mantenimiento_activo	false	boolean	Modo mantenimiento del sistema	sistema	\N	2025-12-31 02:18:46.050662+00	2025-12-31 02:18:46.050662+00
2	mensaje_mantenimiento	El sistema esta en mantenimiento. Intente mas tarde.	string	Mensaje mostrado durante mantenimiento	sistema	\N	2025-12-31 02:18:46.050662+00	2025-12-31 02:18:46.050662+00
4	horas_token_expiracion	12	number	Horas de expiracion del token JWT	seguridad	\N	2025-12-31 02:18:46.050662+00	2025-12-31 02:18:46.050662+00
5	intentos_login_max	5	number	Intentos maximos de login antes de bloquear	seguridad	\N	2025-12-31 02:18:46.050662+00	2025-12-31 02:18:46.050662+00
6	minutos_bloqueo_login	30	number	Minutos de bloqueo despues de intentos fallidos	seguridad	\N	2025-12-31 02:18:46.050662+00	2025-12-31 02:18:46.050662+00
7	notif_push_habilitadas	true	boolean	Habilitar notificaciones push	notificaciones	\N	2026-01-01 07:19:32.626617+00	2026-01-01 07:19:32.626617+00
8	notif_tiempo_expiracion_aprobacion	30	number	Minutos para que expire una solicitud de aprobacion	notificaciones	\N	2026-01-01 07:19:32.626617+00	2026-01-01 07:19:32.626617+00
9	notif_confirmar_presencia_requerido	true	boolean	Requerir confirmacion de presencia antes de salida	notificaciones	\N	2026-01-01 07:19:32.626617+00	2026-01-01 07:19:32.626617+00
3	version_app_minima	1.0.0	string	Version minima requerida de la app movil	app	568	2025-12-31 02:18:46.050662+00	2026-01-03 07:09:39.719889+00
10	notif_aprobar_fin_jornada_requerido	true	boolean	Requerir aprobacion de tripulacion para fin de jornada	notificaciones	568	2026-01-01 07:19:32.626617+00	2026-01-03 07:09:57.82643+00
\.


--
-- Data for Name: configuracion_visual_sede; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.configuracion_visual_sede (id, sede_id, color_fondo, color_fondo_header, color_texto, color_acento, fuente, tamano_fuente, alerta_rotacion_rutas_activa, umbral_rotacion_rutas, created_at, updated_at, requiere_tripulacion) FROM stdin;
1	1	#f0fdf4	#dcfce7	#1f2937	#22c55e	Inter	normal	t	3	2025-12-14 16:38:13.960811+00	2025-12-14 16:38:13.960811+00	t
2	2	#fef3c7	#fde68a	#1f2937	#eab308	Inter	normal	t	3	2025-12-14 16:38:13.960811+00	2025-12-14 16:38:13.960811+00	t
3	5	#dbeafe	#bfdbfe	#1f2937	#3b82f6	Inter	normal	t	3	2025-12-14 16:38:13.960811+00	2025-12-14 16:38:13.960811+00	t
4	6	#ffedd5	#fed7aa	#1f2937	#f97316	Inter	normal	t	3	2025-12-14 16:38:13.960811+00	2025-12-14 16:38:13.960811+00	t
5	7	#f3e8ff	#e9d5ff	#1f2937	#a855f7	Inter	normal	t	3	2025-12-14 16:38:13.960811+00	2025-12-14 16:38:13.960811+00	t
6	8	#dcfce7	#bbf7d0	#1f2937	#10b981	Inter	normal	t	3	2025-12-14 16:38:13.960811+00	2025-12-14 16:38:13.960811+00	t
7	9	#e0f2fe	#bae6fd	#1f2937	#0ea5e9	Inter	normal	t	3	2025-12-14 16:38:13.960811+00	2025-12-14 16:38:13.960811+00	t
8	3	#fce7f3	#fbcfe8	#1f2937	#ec4899	Inter	normal	t	3	2025-12-14 16:38:13.960811+00	2025-12-14 16:38:13.960811+00	t
9	4	#e0e7ff	#c7d2fe	#1f2937	#6366f1	Inter	normal	t	3	2025-12-14 16:38:13.960811+00	2025-12-14 16:38:13.960811+00	t
\.


--
-- Data for Name: contenedor; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.contenedor (id, vehiculo_id, numero_contenedor, linea_naviera, tipo_contenedor, fecha_registro, created_at) FROM stdin;
\.


--
-- Data for Name: control_acceso_app; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.control_acceso_app (id, usuario_id, grupo, unidad_id, sede_id, acceso_permitido, motivo, fecha_inicio, fecha_fin, creado_por, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: departamento; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departamento (id, codigo, nombre, nombre_completo, region, created_at) FROM stdin;
1	01	Guatemala	Departamento de Guatemala	METROPOLITANA	2025-12-07 06:28:58.300558+00
2	02	El Progreso	Departamento de El Progreso	NORORIENTE	2025-12-07 06:28:58.300558+00
4	04	Chimaltenango	Departamento de Chimaltenango	CENTRAL	2025-12-07 06:28:58.300558+00
5	05	Escuintla	Departamento de Escuintla	CENTRAL	2025-12-07 06:28:58.300558+00
6	06	Santa Rosa	Departamento de Santa Rosa	SURORIENTE	2025-12-07 06:28:58.300558+00
9	09	Quetzaltenango	Departamento de Quetzaltenango	SUROCCIDENTE	2025-12-07 06:28:58.300558+00
11	11	Retalhuleu	Departamento de Retalhuleu	SUROCCIDENTE	2025-12-07 06:28:58.300558+00
12	12	San Marcos	Departamento de San Marcos	SUROCCIDENTE	2025-12-07 06:28:58.300558+00
13	13	Huehuetenango	Departamento de Huehuetenango	NOROCCIDENTE	2025-12-07 06:28:58.300558+00
15	15	Baja Verapaz	Departamento de Baja Verapaz	NORTE	2025-12-07 06:28:58.300558+00
16	16	Alta Verapaz	Departamento de Alta Verapaz	NORTE	2025-12-07 06:28:58.300558+00
18	18	Izabal	Departamento de Izabal	NORORIENTE	2025-12-07 06:28:58.300558+00
19	19	Zacapa	Departamento de Zacapa	NORORIENTE	2025-12-07 06:28:58.300558+00
20	20	Chiquimula	Departamento de Chiquimula	NORORIENTE	2025-12-07 06:28:58.300558+00
21	21	Jalapa	Departamento de Jalapa	SURORIENTE	2025-12-07 06:28:58.300558+00
22	22	Jutiapa	Departamento de Jutiapa	SURORIENTE	2025-12-07 06:28:58.300558+00
8	08	Totonicap??n	Departamento de Totonicap??n	SUROCCIDENTE	2025-12-07 06:28:58.300558+00
17	17	Pet??n	Departamento de Pet??n	PETEN	2025-12-07 06:28:58.300558+00
14	14	Quich??	Departamento de Quich??	NOROCCIDENTE	2025-12-07 06:28:58.300558+00
10	10	Suchitep??quez	Departamento de Suchitep??quez	SUROCCIDENTE	2025-12-07 06:28:58.300558+00
3	03	Sacatep??quez	Departamento de Sacatep??quez	CENTRAL	2025-12-07 06:28:58.300558+00
7	07	Solol??	Departamento de Solol??	SUROCCIDENTE	2025-12-07 06:28:58.300558+00
\.


--
-- Data for Name: departamento_sistema; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.departamento_sistema (id, codigo, nombre, descripcion, usa_sistema_grupos, orden, activo, created_at, updated_at) FROM stdin;
1	COP	Centro de Operaciones	Operadores del Centro de Operaciones	t	1	t	2025-12-31 02:18:46.050662+00	2025-12-31 02:18:46.050662+00
2	BRIGADA	Brigadas de Campo	Personal de campo en unidades moviles	t	2	t	2025-12-31 02:18:46.050662+00	2025-12-31 02:18:46.050662+00
3	OPERACIONES	Departamento de Operaciones	Gestion de operaciones y asignaciones	t	3	t	2025-12-31 02:18:46.050662+00	2025-12-31 02:18:46.050662+00
4	ACCIDENTOLOGIA	Departamento de Accidentologia	Analisis de accidentes e investigacion	t	4	t	2025-12-31 02:18:46.050662+00	2025-12-31 02:18:46.050662+00
5	MANDOS	Mandos Superiores	Jefes y supervisores	f	5	t	2025-12-31 02:18:46.050662+00	2025-12-31 02:18:46.050662+00
6	ENCARGADO_NOMINAS	Encargados de Nominas	Gestion de nominas por sede	f	6	t	2025-12-31 02:18:46.050662+00	2025-12-31 02:18:46.050662+00
7	ADMIN	Administradores	Administradores del sistema	f	7	t	2025-12-31 02:18:46.050662+00	2025-12-31 02:18:46.050662+00
8	SUPER_ADMIN	Super Administradores	Programadores y acceso total	f	8	t	2025-12-31 02:18:46.050662+00	2025-12-31 02:18:46.050662+00
9	TESTDEP	Departamento Actualizado	Este es un departamento de prueba	t	9	f	2026-01-04 00:23:21.568959+00	2026-01-04 00:23:32.223421+00
10	COM_SOCIAL	Comunicación Social	Departamento de Comunicación Social	f	10	t	2026-01-04 02:32:39.202409+00	2026-01-04 02:32:39.202409+00
\.


--
-- Data for Name: detalle_situacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.detalle_situacion (id, situacion_id, tipo_detalle, datos, creado_por, created_at, updated_at) FROM stdin;
11	38	VEHICULO	{"color": "Blanco", "marca": "Mercedes", "placa": "P999TEST", "tipo_vehiculo": "CAMION"}	358	2025-12-29 23:01:33.773689+00	2025-12-29 23:01:33.773689+00
12	38	GRUA	{"placa": "G123", "piloto": "Pedro Test", "empresa": "Gruas Express"}	358	2025-12-29 23:01:33.788735+00	2025-12-29 23:01:33.788735+00
13	38	AJUSTADOR	{"nombre": "Maria Test", "empresa": "Seguros G&T", "telefono": "1234-5678"}	358	2025-12-29 23:01:33.807002+00	2025-12-29 23:01:33.807002+00
14	38	AUTORIDADES_SOCORRO	{"socorro": ["BOMBEROS"], "autoridades": ["PNC", "PMT"], "detallesSocorro": {}, "detallesAutoridades": {}}	358	2025-12-29 23:01:33.823307+00	2025-12-29 23:01:33.823307+00
15	38	DANIOS	{"materiales": true, "infraestructura": true, "descripcion_infra": "Poste da�ado"}	358	2025-12-29 23:01:33.857365+00	2025-12-29 23:01:33.857365+00
16	38	SUBTIPO	{"subtipo": "VOLCADURA"}	358	2025-12-29 23:01:33.909221+00	2025-12-29 23:01:33.909221+00
\.


--
-- Data for Name: dispositivo_push; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dispositivo_push (id, usuario_id, push_token, plataforma, modelo_dispositivo, version_app, activo, ultimo_uso, created_at, updated_at) FROM stdin;
1	13	ExponentPushToken[test-token-12345]	android	Test Device	1.0.0	t	2026-01-01 08:50:27.013923+00	2026-01-01 07:53:56.389927+00	2026-01-01 08:50:27.013923+00
9	13	test_token_1767257977703	android	\N	\N	t	2026-01-01 08:59:37.694326+00	2026-01-01 08:59:37.694326+00	2026-01-01 08:59:37.694326+00
10	13	test_token_1767258616749	android	\N	\N	t	2026-01-01 09:10:16.759199+00	2026-01-01 09:10:16.759199+00	2026-01-01 09:10:16.759199+00
11	13	test_token_1767258673764	android	\N	\N	t	2026-01-01 09:11:13.772697+00	2026-01-01 09:11:13.772697+00	2026-01-01 09:11:13.772697+00
12	13	test_token_1767258827238	android	\N	\N	t	2026-01-01 09:13:47.24343+00	2026-01-01 09:13:47.24343+00	2026-01-01 09:13:47.24343+00
13	13	test_token_1767258977943	android	\N	\N	t	2026-01-01 09:16:17.946303+00	2026-01-01 09:16:17.946303+00	2026-01-01 09:16:17.946303+00
14	13	test_token_1767391886270	android	\N	\N	t	2026-01-02 22:11:26.279018+00	2026-01-02 22:11:26.279018+00	2026-01-02 22:11:26.279018+00
15	13	test_token_1767391974357	android	\N	\N	t	2026-01-02 22:12:54.363166+00	2026-01-02 22:12:54.363166+00	2026-01-02 22:12:54.363166+00
\.


--
-- Data for Name: estado_grupo_departamento; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.estado_grupo_departamento (id, departamento_id, sede_id, grupo, activo, modificado_por, fecha_modificacion, observaciones, created_at) FROM stdin;
1	1	1	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
3	1	1	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
4	1	2	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
5	1	2	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
6	1	2	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
7	1	5	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
8	1	5	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
9	1	5	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
10	1	6	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
11	1	6	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
12	1	6	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
13	1	8	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
14	1	8	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
15	1	8	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
16	1	3	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
17	1	3	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
18	1	3	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
19	1	4	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
20	1	4	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
21	1	4	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
22	1	7	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
23	1	7	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
24	1	7	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
26	1	9	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
27	1	9	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
29	2	1	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
30	2	1	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
31	2	2	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
32	2	2	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
33	2	2	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
34	2	5	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
35	2	5	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
36	2	5	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
37	2	6	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
38	2	6	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
39	2	6	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
40	2	8	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
41	2	8	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
42	2	8	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
43	2	3	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
44	2	3	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
45	2	3	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
46	2	4	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
47	2	4	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
48	2	4	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
49	2	7	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
50	2	7	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
51	2	7	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
52	2	9	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
53	2	9	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
54	2	9	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
55	3	1	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
56	3	1	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
57	3	1	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
58	3	2	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
59	3	2	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
60	3	2	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
61	3	5	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
62	3	5	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
63	3	5	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
64	3	6	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
65	3	6	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
66	3	6	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
67	3	8	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
68	3	8	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
69	3	8	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
70	3	3	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
71	3	3	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
72	3	3	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
73	3	4	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
74	3	4	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
75	3	4	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
76	3	7	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
77	3	7	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
78	3	7	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
79	3	9	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
80	3	9	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
81	3	9	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
82	4	1	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
83	4	1	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
84	4	1	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
86	4	2	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
87	4	2	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
88	4	5	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
89	4	5	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
90	4	5	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
91	4	6	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
92	4	6	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
93	4	6	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
94	4	8	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
95	4	8	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
96	4	8	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
97	4	3	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
28	2	1	0	t	568	2025-12-31 22:09:22.978814+00	\N	2025-12-31 02:18:46.050662+00
85	4	2	0	t	568	2026-01-03 06:47:07.477379+00	\N	2025-12-31 02:18:46.050662+00
25	1	9	0	t	568	2026-01-03 06:54:36.00295+00	\N	2025-12-31 02:18:46.050662+00
98	4	3	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
99	4	3	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
100	4	4	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
101	4	4	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
102	4	4	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
103	4	7	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
104	4	7	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
105	4	7	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
106	4	9	0	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
107	4	9	1	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
108	4	9	2	t	\N	2025-12-31 02:18:46.050662+00	Estado inicial	2025-12-31 02:18:46.050662+00
2	1	1	1	t	568	2025-12-31 05:21:44.896622+00	\N	2025-12-31 02:18:46.050662+00
\.


--
-- Data for Name: evento_persistente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.evento_persistente (id, titulo, descripcion, tipo, importancia, estado, ruta_id, km_inicio, km_fin, latitud, longitud, punto_referencia, fecha_inicio, fecha_fin_estimada, fecha_resolucion, creado_por, resuelto_por, observaciones, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: grua; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.grua (id, nombre, placa, telefono, empresa, nit, total_servicios, ultima_vez_usado, activa, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: grua_involucrada; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.grua_involucrada (id, incidente_id, vehiculo_asignado_id, tipo, placa, empresa, piloto, color, marca, traslado, traslado_a, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: historial_encargado_sede_grupo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.historial_encargado_sede_grupo (id, usuario_id, sede_id, grupo, fecha_inicio, fecha_fin, asignado_por, removido_por, motivo_asignacion, motivo_remocion, created_at) FROM stdin;
2	20	1	2	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
3	370	2	1	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
4	286	2	2	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
5	367	5	1	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
6	205	5	2	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
7	126	6	1	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
8	326	6	2	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
9	52	8	1	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
10	382	8	2	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
11	209	3	1	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
12	289	3	2	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
13	366	4	1	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
14	383	4	2	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
15	118	7	1	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
16	313	7	2	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
17	320	9	1	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
18	64	9	2	2025-12-31	\N	13	\N	Asignacion inicial automatica	\N	2025-12-31 02:18:46.050662+00
1	28	1	1	2025-12-31	2026-01-03	13	568	Asignacion inicial automatica	Removido por administrador	2025-12-31 02:18:46.050662+00
19	23	1	1	2026-01-03	\N	568	\N	Asignacion manual	\N	2026-01-03 07:00:42.630455+00
\.


--
-- Data for Name: historial_ruta_brigada; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.historial_ruta_brigada (id, usuario_id, ruta_id, fecha, turno_id, asignacion_id, created_at) FROM stdin;
\.


--
-- Data for Name: historial_situacion_brigada; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.historial_situacion_brigada (id, usuario_id, situacion_fija_id, fecha, turno_id, asignacion_id, created_at) FROM stdin;
\.


--
-- Data for Name: hoja_accidentologia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.hoja_accidentologia (id, situacion_id, tipo_accidente, descripcion_accidente, condiciones_climaticas, condiciones_via, iluminacion, visibilidad, kilometro, referencia_ubicacion, sentido_via, tipo_zona, causa_principal, causas_contribuyentes, pnc_presente, pnc_agente, bomberos_presente, bomberos_unidad, mp_presente, mp_fiscal, otras_autoridades, requiere_peritaje, numero_caso_pnc, numero_caso_mp, elaborado_por, revisado_por, fecha_elaboracion, estado, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: incidente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.incidente (id, uuid, numero_reporte, origen, estado, tipo_hecho_id, subtipo_hecho_id, ruta_id, km, sentido, referencia_ubicacion, latitud, longitud, unidad_id, brigada_id, fecha_hora_aviso, fecha_hora_asignacion, fecha_hora_llegada, fecha_hora_estabilizacion, fecha_hora_finalizacion, hay_heridos, cantidad_heridos, hay_fallecidos, cantidad_fallecidos, requiere_bomberos, requiere_pnc, requiere_ambulancia, observaciones_iniciales, observaciones_finales, condiciones_climaticas, tipo_pavimento, iluminacion, senalizacion, visibilidad, causa_probable, reportado_por_nombre, reportado_por_telefono, reportado_por_email, foto_url, creado_por, actualizado_por, created_at, updated_at, asignacion_id, departamento_id, municipio_id, jurisdiccion, direccion_detallada, obstruccion_detalle, danios_infraestructura_desc, danios_materiales, danios_infraestructura, obstruccion_data) FROM stdin;
\.


--
-- Data for Name: incidente_grua; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.incidente_grua (id, incidente_id, grua_id, hora_llamada, hora_llegada, destino, costo, created_at) FROM stdin;
\.


--
-- Data for Name: incidente_no_atendido; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.incidente_no_atendido (id, incidente_id, motivo_id, observaciones, registrado_por, created_at) FROM stdin;
\.


--
-- Data for Name: incidente_vehiculo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.incidente_vehiculo (id, incidente_id, vehiculo_id, piloto_id, estado_piloto, personas_asistidas, aseguradora_id, numero_poliza, created_at) FROM stdin;
\.


--
-- Data for Name: ingreso_sede; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ingreso_sede (id, salida_unidad_id, sede_id, fecha_hora_ingreso, fecha_hora_salida, tipo_ingreso, km_ingreso, combustible_ingreso, km_salida_nueva, combustible_salida_nueva, observaciones_ingreso, observaciones_salida, es_ingreso_final, registrado_por, created_at, updated_at) FROM stdin;
31	36	7	2025-12-29 20:01:33.698318+00	\N	FINALIZACION_JORNADA	\N	\N	\N	\N	Finalizando jornada sin novedades	\N	f	33	2025-12-29 20:01:33.698318+00	2025-12-29 20:01:33.698318+00
\.


--
-- Data for Name: inspeccion_360; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inspeccion_360 (id, salida_id, unidad_id, plantilla_id, realizado_por, aprobado_por, estado, fecha_realizacion, fecha_aprobacion, respuestas, observaciones_inspector, observaciones_comandante, motivo_rechazo, firma_inspector, firma_comandante, fotos, created_at, updated_at) FROM stdin;
1	\N	341	2	13	\N	PENDIENTE	2026-01-01 01:28:40.335947+00	\N	[{"valor": true, "codigo": "EXT001"}, {"valor": "BUENO", "codigo": "EXT002"}, {"valor": true, "codigo": "EXT003"}, {"valor": true, "codigo": "EXT004"}, {"valor": "BUENO", "codigo": "EXT005"}, {"valor": "BUENO", "codigo": "EXT006"}, {"valor": "Sin rayones visibles", "codigo": "EXT007"}, {"valor": "BUENO", "codigo": "EXT008"}, {"valor": "FUNCIONANDO", "codigo": "LUZ001"}, {"valor": "FUNCIONANDO", "codigo": "LUZ002"}, {"valor": "FUNCIONANDO", "codigo": "LUZ003"}, {"valor": "FUNCIONANDO", "codigo": "LUZ005"}, {"valor": "FUNCIONANDO", "codigo": "LUZ006"}, {"valor": "FUNCIONANDO", "codigo": "LUZ007"}, {"valor": "FUNCIONANDO", "codigo": "LUZ008"}, {"valor": "FUNCIONANDO", "codigo": "LUZ009"}, {"valor": "FUNCIONANDO", "codigo": "INT001"}, {"valor": true, "codigo": "INT002"}, {"valor": true, "codigo": "INT003"}, {"valor": true, "codigo": "INT004"}, {"valor": true, "codigo": "INT005"}, {"valor": true, "codigo": "INT006"}, {"valor": true, "codigo": "INT007"}, {"valor": true, "codigo": "INT008"}, {"valor": "BUENO", "codigo": "MEC001"}, {"valor": "BUENO", "codigo": "MEC002"}, {"valor": "NORMAL", "codigo": "MEC003"}, {"valor": "NORMAL", "codigo": "MEC004"}, {"valor": "NORMAL", "codigo": "MEC005"}, {"valor": "BUENO", "codigo": "MEC006"}, {"valor": "BUENO", "codigo": "MEC007"}, {"valor": "FUNCIONANDO", "codigo": "MEC008"}, {"valor": true, "codigo": "ACC001"}, {"valor": true, "codigo": "ACC002"}, {"valor": true, "codigo": "ACC003"}]	Vehiculo en buen estado general	\N	\N	\N	\N	\N	2026-01-01 01:28:40.335947+00	2026-01-01 01:28:40.335947+00
\.


--
-- Data for Name: inspeccion_360_archivo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.inspeccion_360_archivo (id, inspeccion_id, unidad_id, fecha_realizacion, estado, datos_comprimidos, created_at) FROM stdin;
\.


--
-- Data for Name: intelligence_refresh_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.intelligence_refresh_log (id, view_name, refreshed_at, duration_ms, rows_affected) FROM stdin;
\.


--
-- Data for Name: log_administracion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.log_administracion (id, accion, tabla_afectada, registro_id, usuario_afectado_id, datos_anteriores, datos_nuevos, realizado_por, ip_address, created_at) FROM stdin;
1	CAMBIAR_GRUPO	usuario	73	73	{"grupo": 1}	{"grupo": 2}	13	::1	2025-12-31 02:58:12.308096+00
2	CAMBIAR_GRUPO	usuario	73	73	{"grupo": 2}	{"grupo": 1}	13	::1	2025-12-31 02:59:50.816525+00
3	TOGGLE_USUARIO	usuario	121	121	{"activo": true}	{"activo": false}	568	::1	2025-12-31 05:21:44.836338+00
4	TOGGLE_USUARIO	usuario	121	121	{"activo": false}	{"activo": true}	568	::1	2025-12-31 05:21:44.865061+00
5	CAMBIAR_GRUPO	usuario	121	121	{"grupo": 2}	{"grupo": 1}	568	::1	2025-12-31 05:21:44.88461+00
6	TOGGLE_GRUPO	estado_grupo_departamento	\N	\N	\N	{"grupo": 1, "activo": true, "sede_id": 1, "departamento_id": 1}	568	::1	2025-12-31 05:21:44.906722+00
7	TOGGLE_GRUPO	estado_grupo_departamento	\N	\N	\N	{"grupo": 0, "activo": false, "sede_id": 1, "departamento_id": 2}	568	::1	2025-12-31 22:09:22.009318+00
8	TOGGLE_GRUPO	estado_grupo_departamento	\N	\N	\N	{"grupo": 0, "activo": true, "sede_id": 1, "departamento_id": 2}	568	::1	2025-12-31 22:09:22.986873+00
9	TOGGLE_ACCESO_APP	usuario	13	13	{"acceso_app_activo": true}	{"acceso_app_activo": false}	568	::1	2026-01-03 06:42:02.666089+00
10	TOGGLE_ACCESO_APP	usuario	13	13	{"acceso_app_activo": false}	{"acceso_app_activo": true}	568	::1	2026-01-03 06:42:03.537597+00
11	CAMBIAR_GRUPO	usuario	313	313	{"grupo": 2}	{"grupo": 2}	568	::1	2026-01-03 06:46:40.447291+00
12	TOGGLE_GRUPO	estado_grupo_departamento	\N	\N	\N	{"grupo": 0, "activo": false, "sede_id": 2, "departamento_id": 4}	568	::1	2026-01-03 06:47:06.88879+00
13	TOGGLE_GRUPO	estado_grupo_departamento	\N	\N	\N	{"grupo": 0, "activo": true, "sede_id": 2, "departamento_id": 4}	568	::1	2026-01-03 06:47:07.483908+00
14	TOGGLE_GRUPO	estado_grupo_departamento	\N	\N	\N	{"grupo": 0, "activo": false, "sede_id": 9, "departamento_id": 1}	568	::1	2026-01-03 06:54:35.097537+00
15	TOGGLE_GRUPO	estado_grupo_departamento	\N	\N	\N	{"grupo": 0, "activo": true, "sede_id": 9, "departamento_id": 1}	568	::1	2026-01-03 06:54:36.010659+00
16	REMOVER_ENCARGADO	historial_encargado_sede_grupo	\N	28	{"usuario_id": 28}	{"motivo": "Removido por administrador"}	568	::1	2026-01-03 07:00:34.10197+00
17	ASIGNAR_ENCARGADO	historial_encargado_sede_grupo	19	23	\N	{"grupo": 1, "sede_id": 1, "usuario_id": 23}	568	::1	2026-01-03 07:00:42.642166+00
18	CAMBIAR_CONFIG	configuracion_sistema	\N	\N	{"valor": "1.0.0"}	{"clave": "version_app_minima", "valor": "1.0.0"}	568	::1	2026-01-03 07:09:39.727614+00
19	CAMBIAR_CONFIG	configuracion_sistema	\N	\N	{"valor": "false"}	{"clave": "notif_aprobar_fin_jornada_requerido", "valor": "true"}	568	::1	2026-01-03 07:09:57.835088+00
20	CREAR_SEDE	sede	23	\N	\N	{"codigo": "PRUEBA2", "nombre": "Sede de Prueba 2", "es_sede_central": false}	13	::1	2026-01-04 00:22:11.50945+00
21	ELIMINAR_SEDE	sede	23	\N	{"id": 23, "activa": true, "codigo": "PRUEBA2", "nombre": "Sede Actualizada", "departamento_id": null, "es_sede_central": false}	\N	13	::1	2026-01-04 00:22:26.238003+00
22	EDITAR_SEDE	sede	1	\N	{"id": 1, "activa": true, "codigo": "CENTRAL", "nombre": "Central", "departamento_id": null, "es_sede_central": false}	{"es_sede_central": true}	13	::1	2026-01-04 00:23:11.25512+00
23	CREAR_DEPARTAMENTO	departamento_sistema	9	\N	\N	{"codigo": "TESTDEP", "nombre": "Departamento de Prueba", "descripcion": "Este es un departamento de prueba"}	13	::1	2026-01-04 00:23:21.597723+00
24	EDITAR_DEPARTAMENTO	departamento_sistema	9	\N	{"id": 9, "orden": 9, "activo": true, "codigo": "TESTDEP", "nombre": "Departamento de Prueba", "created_at": "2026-01-04T00:23:21.568Z", "updated_at": "2026-01-04T00:23:21.568Z", "descripcion": "Este es un departamento de prueba", "usa_sistema_grupos": true}	{"nombre": "Departamento Actualizado"}	13	::1	2026-01-04 00:23:32.230277+00
25	ELIMINAR_DEPARTAMENTO	departamento_sistema	9	\N	{"id": 9, "orden": 9, "activo": true, "codigo": "TESTDEP", "nombre": "Departamento Actualizado", "created_at": "2026-01-04T00:23:21.568Z", "updated_at": "2026-01-04T00:23:32.223Z", "descripcion": "Este es un departamento de prueba", "usa_sistema_grupos": true}	\N	13	::1	2026-01-04 00:23:33.235406+00
\.


--
-- Data for Name: marca; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.marca (id, nombre, activa, created_at, updated_at) FROM stdin;
1	Toyota	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
2	Honda	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
3	Nissan	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
4	Jeep	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
5	BMW	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
6	Mitsubishi	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
7	Suzuki	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
8	Hyundai	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
9	Mazda	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
10	Chevrolet	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
11	Freightliner	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
12	International	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
13	Volvo	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
14	Italika	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
15	Kia	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
16	Volkswagen	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
17	Ford	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
18	Audi	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
19	JAC	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
20	Hino	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
21	Otro	t	2025-12-07 06:28:58.860053	2025-12-07 06:28:58.860053
\.


--
-- Data for Name: marca_vehiculo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.marca_vehiculo (id, nombre, created_at) FROM stdin;
1	Toyota	2025-12-07 06:28:57.799023+00
2	Nissan	2025-12-07 06:28:57.799023+00
3	Honda	2025-12-07 06:28:57.799023+00
4	Mazda	2025-12-07 06:28:57.799023+00
5	Mitsubishi	2025-12-07 06:28:57.799023+00
6	Ford	2025-12-07 06:28:57.799023+00
7	Chevrolet	2025-12-07 06:28:57.799023+00
8	Hyundai	2025-12-07 06:28:57.799023+00
9	Kia	2025-12-07 06:28:57.799023+00
10	Suzuki	2025-12-07 06:28:57.799023+00
11	Volkswagen	2025-12-07 06:28:57.799023+00
12	Mercedes-Benz	2025-12-07 06:28:57.799023+00
13	Volvo	2025-12-07 06:28:57.799023+00
14	Scania	2025-12-07 06:28:57.799023+00
15	Freightliner	2025-12-07 06:28:57.799023+00
16	International	2025-12-07 06:28:57.799023+00
17	Isuzu	2025-12-07 06:28:57.799023+00
18	Otra	2025-12-07 06:28:57.799023+00
19	Desconocida	2025-12-07 06:28:57.799023+00
\.


--
-- Data for Name: motivo_no_atendido; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.motivo_no_atendido (id, nombre, descripcion, requiere_observaciones, activo, created_at) FROM stdin;
1	Sin Combustible	Unidad no ten??a combustible suficiente	f	t	2025-12-07 06:28:57.813+00
2	Fuera de Jurisdicci??n	Incidente fuera del ??rea de cobertura	f	t	2025-12-07 06:28:57.813+00
3	Unidad No Disponible	No hab??a unidad disponible en el momento	f	t	2025-12-07 06:28:57.813+00
4	Falsa Alarma	Reporte falso o no confirmado	f	t	2025-12-07 06:28:57.813+00
5	Ya Atendido por Otra Instituci??n	Otro organismo ya estaba atendiendo	f	t	2025-12-07 06:28:57.813+00
6	Riesgo para la Unidad	Condiciones peligrosas para el personal	t	t	2025-12-07 06:28:57.813+00
7	Fuera de Competencia	No corresponde a las funciones de la instituci??n	t	t	2025-12-07 06:28:57.813+00
8	Otro	Otro motivo no listado	t	t	2025-12-07 06:28:57.813+00
\.


--
-- Data for Name: movimiento_brigada; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.movimiento_brigada (id, usuario_id, turno_id, origen_asignacion_id, origen_unidad_id, destino_asignacion_id, destino_unidad_id, tipo_movimiento, ruta_id, km, latitud, longitud, hora_inicio, hora_fin, motivo, rol_en_destino, creado_por, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: multimedia_situacion_persistente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.multimedia_situacion_persistente (id, situacion_persistente_id, tipo, url, url_thumbnail, nombre_archivo, mime_type, tamanio_bytes, ancho, alto, duracion_segundos, orden, latitud, longitud, descripcion, subido_por, created_at) FROM stdin;
\.


--
-- Data for Name: municipio; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.municipio (id, departamento_id, codigo, nombre, nombre_completo, cabecera_municipal, poblacion, created_at) FROM stdin;
1	1	0101	Guatemala	Guatemala, Guatemala	Ciudad de Guatemala	\N	2025-12-07 06:28:58.301899+00
2	1	0102	Santa Catarina Pinula	Santa Catarina Pinula, Guatemala	Santa Catarina Pinula	\N	2025-12-07 06:28:58.301899+00
5	1	0105	Palencia	Palencia, Guatemala	Palencia	\N	2025-12-07 06:28:58.301899+00
6	1	0106	Chinautla	Chinautla, Guatemala	Chinautla	\N	2025-12-07 06:28:58.301899+00
7	1	0107	San Pedro Ayampuc	San Pedro Ayampuc, Guatemala	San Pedro Ayampuc	\N	2025-12-07 06:28:58.301899+00
8	1	0108	Mixco	Mixco, Guatemala	Mixco	\N	2025-12-07 06:28:58.301899+00
11	1	0111	San Raymundo	San Raymundo, Guatemala	San Raymundo	\N	2025-12-07 06:28:58.301899+00
12	1	0112	Chuarrancho	Chuarrancho, Guatemala	Chuarrancho	\N	2025-12-07 06:28:58.301899+00
13	1	0113	Fraijanes	Fraijanes, Guatemala	Fraijanes	\N	2025-12-07 06:28:58.301899+00
15	1	0115	Villa Nueva	Villa Nueva, Guatemala	Villa Nueva	\N	2025-12-07 06:28:58.301899+00
16	1	0116	Villa Canales	Villa Canales, Guatemala	Villa Canales	\N	2025-12-07 06:28:58.301899+00
17	1	0117	San Miguel Petapa	San Miguel Petapa, Guatemala	San Miguel Petapa	\N	2025-12-07 06:28:58.301899+00
18	2	0201	Guastatoya	Guastatoya, El Progreso	Guastatoya	\N	2025-12-07 06:28:58.304393+00
23	2	0206	Sansare	Sansare, El Progreso	Sansare	\N	2025-12-07 06:28:58.304393+00
24	2	0207	Sanarate	Sanarate, El Progreso	Sanarate	\N	2025-12-07 06:28:58.304393+00
25	2	0208	San Antonio La Paz	San Antonio La Paz, El Progreso	San Antonio La Paz	\N	2025-12-07 06:28:58.304393+00
26	3	0301	Antigua Guatemala	Antigua Guatemala, Sacatep??quez	Antigua Guatemala	\N	2025-12-07 06:28:58.305478+00
27	3	0302	Jocotenango	Jocotenango, Sacatep??quez	Jocotenango	\N	2025-12-07 06:28:58.305478+00
28	3	0303	Pastores	Pastores, Sacatep??quez	Pastores	\N	2025-12-07 06:28:58.305478+00
29	3	0304	Sumpango	Sumpango, Sacatep??quez	Sumpango	\N	2025-12-07 06:28:58.305478+00
30	3	0305	Santo Domingo Xenacoj	Santo Domingo Xenacoj, Sacatep??quez	Santo Domingo Xenacoj	\N	2025-12-07 06:28:58.305478+00
35	3	0310	Magdalena Milpas Altas	Magdalena Milpas Altas, Sacatep??quez	Magdalena Milpas Altas	\N	2025-12-07 06:28:58.305478+00
37	3	0312	Ciudad Vieja	Ciudad Vieja, Sacatep??quez	Ciudad Vieja	\N	2025-12-07 06:28:58.305478+00
39	3	0314	Alotenango	Alotenango, Sacatep??quez	Alotenango	\N	2025-12-07 06:28:58.305478+00
40	3	0315	San Antonio Aguas Calientes	San Antonio Aguas Calientes, Sacatep??quez	San Antonio Aguas Calientes	\N	2025-12-07 06:28:58.305478+00
41	3	0316	Santa Catarina Barahona	Santa Catarina Barahona, Sacatep??quez	Santa Catarina Barahona	\N	2025-12-07 06:28:58.305478+00
42	5	0501	Escuintla	Escuintla, Escuintla	Escuintla	\N	2025-12-07 06:28:58.30729+00
44	5	0503	La Democracia	La Democracia, Escuintla	La Democracia	\N	2025-12-07 06:28:58.30729+00
46	5	0505	Masagua	Masagua, Escuintla	Masagua	\N	2025-12-07 06:28:58.30729+00
47	5	0506	Tiquisate	Tiquisate, Escuintla	Tiquisate	\N	2025-12-07 06:28:58.30729+00
48	5	0507	La Gomera	La Gomera, Escuintla	La Gomera	\N	2025-12-07 06:28:58.30729+00
49	5	0508	Guanagazapa	Guanagazapa, Escuintla	Guanagazapa	\N	2025-12-07 06:28:58.30729+00
51	5	0510	Iztapa	Iztapa, Escuintla	Iztapa	\N	2025-12-07 06:28:58.30729+00
53	5	0512	San Vicente Pacaya	San Vicente Pacaya, Escuintla	San Vicente Pacaya	\N	2025-12-07 06:28:58.30729+00
55	9	0901	Quetzaltenango	Quetzaltenango, Quetzaltenango	Quetzaltenango	\N	2025-12-07 06:28:58.308903+00
57	9	0903	Olintepeque	Olintepeque, Quetzaltenango	Olintepeque	\N	2025-12-07 06:28:58.308903+00
58	9	0904	San Carlos Sija	San Carlos Sija, Quetzaltenango	San Carlos Sija	\N	2025-12-07 06:28:58.308903+00
59	9	0905	Sibilia	Sibilia, Quetzaltenango	Sibilia	\N	2025-12-07 06:28:58.308903+00
63	9	0909	San Juan Ostuncalco	San Juan Ostuncalco, Quetzaltenango	San Juan Ostuncalco	\N	2025-12-07 06:28:58.308903+00
64	9	0910	San Mateo	San Mateo, Quetzaltenango	San Mateo	\N	2025-12-07 06:28:58.308903+00
68	9	0914	Cantel	Cantel, Quetzaltenango	Cantel	\N	2025-12-07 06:28:58.308903+00
71	9	0917	Colomba Costa Cuca	Colomba Costa Cuca, Quetzaltenango	Colomba Costa Cuca	\N	2025-12-07 06:28:58.308903+00
73	9	0919	El Palmar	El Palmar, Quetzaltenango	El Palmar	\N	2025-12-07 06:28:58.308903+00
74	9	0920	Coatepeque	Coatepeque, Quetzaltenango	Coatepeque	\N	2025-12-07 06:28:58.308903+00
76	9	0922	Flores Costa Cuca	Flores Costa Cuca, Quetzaltenango	Flores Costa Cuca	\N	2025-12-07 06:28:58.308903+00
77	9	0923	La Esperanza	La Esperanza, Quetzaltenango	La Esperanza	\N	2025-12-07 06:28:58.308903+00
78	9	0924	Palestina de Los Altos	Palestina de Los Altos, Quetzaltenango	Palestina de Los Altos	\N	2025-12-07 06:28:58.308903+00
79	17	1701	Flores	Flores, Pet??n	Flores	\N	2025-12-07 06:28:58.31107+00
81	17	1703	San Benito	San Benito, Pet??n	San Benito	\N	2025-12-07 06:28:58.31107+00
83	17	1705	La Libertad	La Libertad, Pet??n	La Libertad	\N	2025-12-07 06:28:58.31107+00
84	17	1706	San Francisco	San Francisco, Pet??n	San Francisco	\N	2025-12-07 06:28:58.31107+00
85	17	1707	Santa Ana	Santa Ana, Pet??n	Santa Ana	\N	2025-12-07 06:28:58.31107+00
86	17	1708	Dolores	Dolores, Pet??n	Dolores	\N	2025-12-07 06:28:58.31107+00
87	17	1709	San Luis	San Luis, Pet??n	San Luis	\N	2025-12-07 06:28:58.31107+00
89	17	1711	Melchor de Mencos	Melchor de Mencos, Pet??n	Melchor de Mencos	\N	2025-12-07 06:28:58.31107+00
91	17	1713	Las Cruces	Las Cruces, Pet??n	Las Cruces	\N	2025-12-07 06:28:58.31107+00
92	17	1714	El Chal	El Chal, Pet??n	El Chal	\N	2025-12-07 06:28:58.31107+00
93	18	1801	Puerto Barrios	Puerto Barrios, Izabal	Puerto Barrios	\N	2025-12-07 06:28:58.312531+00
94	18	1802	Livingston	Livingston, Izabal	Livingston	\N	2025-12-07 06:28:58.312531+00
95	18	1803	El Estor	El Estor, Izabal	El Estor	\N	2025-12-07 06:28:58.312531+00
96	18	1804	Morales	Morales, Izabal	Morales	\N	2025-12-07 06:28:58.312531+00
97	18	1805	Los Amates	Los Amates, Izabal	Los Amates	\N	2025-12-07 06:28:58.312531+00
14	1	0114	Amatitl??n	Amatitl??n, Guatemala	Amatitl??n	\N	2025-12-07 06:28:58.301899+00
60	9	0906	Cabric??n	Cabric??n, Quetzaltenango	Cabric??n	\N	2025-12-07 06:28:58.308903+00
61	9	0907	Cajol??	Cajol??, Quetzaltenango	Cajol??	\N	2025-12-07 06:28:58.308903+00
54	5	0513	Nueva Concepci??n	Nueva Concepci??n, Escuintla	Nueva Concepci??n	\N	2025-12-07 06:28:58.30729+00
22	2	0205	El J??caro	El J??caro, El Progreso	El J??caro	\N	2025-12-07 06:28:58.304393+00
69	9	0915	Huit??n	Huit??n, Quetzaltenango	Huit??n	\N	2025-12-07 06:28:58.308903+00
19	2	0202	Moraz??n	Moraz??n, El Progreso	Moraz??n	\N	2025-12-07 06:28:58.304393+00
52	5	0511	Pal??n	Pal??n, Escuintla	Pal??n	\N	2025-12-07 06:28:58.30729+00
90	17	1712	Popt??n	Popt??n, Pet??n	Popt??n	\N	2025-12-07 06:28:58.31107+00
56	9	0902	Salcaj??	Salcaj??, Quetzaltenango	Salcaj??	\N	2025-12-07 06:28:58.308903+00
20	2	0203	San Agust??n Acasaguastl??n	San Agust??n Acasaguastl??n, El Progreso	San Agust??n Acasaguastl??n	\N	2025-12-07 06:28:58.304393+00
82	17	1704	San Andr??s	San Andr??s, Pet??n	San Andr??s	\N	2025-12-07 06:28:58.31107+00
75	9	0921	G??nova	G??nova, Quetzaltenango	G??nova	\N	2025-12-07 06:28:58.308903+00
67	9	0913	Almolonga	Almolonga, Quetzaltenango	Almolonga	\N	2025-12-07 06:28:58.308903+00
70	9	0916	Zunil	Zunil, Quetzaltenango	Zunil	\N	2025-12-07 06:28:58.308903+00
32	3	0307	San Bartolom?? Milpas Altas	San Bartolom?? Milpas Altas, Sacatep??quez	San Bartolom?? Milpas Altas	\N	2025-12-07 06:28:58.305478+00
21	2	0204	San Crist??bal Acasaguastl??n	San Crist??bal Acasaguastl??n, El Progreso	San Crist??bal Acasaguastl??n	\N	2025-12-07 06:28:58.304393+00
72	9	0918	San Francisco La Uni??n	San Francisco La Uni??n, Quetzaltenango	San Francisco La Uni??n	\N	2025-12-07 06:28:58.308903+00
9	1	0109	San Pedro Sacatep??quez	San Pedro Sacatep??quez, Guatemala	San Pedro Sacatep??quez	\N	2025-12-07 06:28:58.301899+00
10	1	0110	San Juan Sacatep??quez	San Juan Sacatep??quez, Guatemala	San Juan Sacatep??quez	\N	2025-12-07 06:28:58.301899+00
31	3	0306	Santiago Sacatep??quez	Santiago Sacatep??quez, Sacatep??quez	Santiago Sacatep??quez	\N	2025-12-07 06:28:58.305478+00
33	3	0308	San Lucas Sacatep??quez	San Lucas Sacatep??quez, Sacatep??quez	San Lucas Sacatep??quez	\N	2025-12-07 06:28:58.305478+00
66	9	0912	San Mart??n Sacatep??quez	San Mart??n Sacatep??quez, Quetzaltenango	San Mart??n Sacatep??quez	\N	2025-12-07 06:28:58.308903+00
38	3	0313	San Miguel Due??as	San Miguel Due??as, Sacatep??quez	San Miguel Due??as	\N	2025-12-07 06:28:58.305478+00
62	9	0908	San Miguel Sig??il??	San Miguel Sig??il??, Quetzaltenango	San Miguel Sig??il??	\N	2025-12-07 06:28:58.308903+00
34	3	0309	Santa Luc??a Milpas Altas	Santa Luc??a Milpas Altas, Sacatep??quez	Santa Luc??a Milpas Altas	\N	2025-12-07 06:28:58.305478+00
43	5	0502	Santa Luc??a Cotzumalguapa	Santa Luc??a Cotzumalguapa, Escuintla	Santa Luc??a Cotzumalguapa	\N	2025-12-07 06:28:58.30729+00
36	3	0311	Santa Mar??a de Jes??s	Santa Mar??a de Jes??s, Sacatep??quez	Santa Mar??a de Jes??s	\N	2025-12-07 06:28:58.305478+00
88	17	1710	Sayaxch??	Sayaxch??, Pet??n	Sayaxch??	\N	2025-12-07 06:28:58.31107+00
45	5	0504	Siquinal??	Siquinal??, Escuintla	Siquinal??	\N	2025-12-07 06:28:58.30729+00
3	1	0103	San Jos??	San Jos?? Pinula, Guatemala	San Jos?? Pinula	\N	2025-12-07 06:28:58.301899+00
4	1	0104	San Jos??	San Jos?? del Golfo, Guatemala	San Jos?? del Golfo	\N	2025-12-07 06:28:58.301899+00
50	5	0509	San Jos??	San Jos??, Escuintla	San Jos??	\N	2025-12-07 06:28:58.30729+00
80	17	1702	San Jos??	San Jos??, Pet??n	San Jos??	\N	2025-12-07 06:28:58.31107+00
65	9	0911	Concepci??n	Concepci??n Chiquirichapa, Quetzaltenango	Concepci??n Chiquirichapa	\N	2025-12-07 06:28:58.308903+00
\.


--
-- Data for Name: notificacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.notificacion (id, usuario_id, tipo, titulo, mensaje, datos, enviada, fecha_envio, error_envio, leida, fecha_lectura, created_at) FROM stdin;
\.


--
-- Data for Name: obstruccion_incidente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.obstruccion_incidente (id, incidente_id, descripcion_generada, datos_carriles_json, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: obstruccion_situacion_persistente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.obstruccion_situacion_persistente (id, situacion_persistente_id, hay_vehiculo_fuera_via, tipo_obstruccion, sentido_principal, sentido_contrario, descripcion_generada, descripcion_manual, created_at, updated_at) FROM stdin;
1	2	f	parcial	{"carriles": [], "cantidad_carriles": 2}	\N	\N	Carril derecho obstruido	2025-12-30 23:57:33.81494+00	2025-12-30 23:57:33.81494+00
4	6	f	total_ambos	\N	\N	Obstruccion total de ambos sentidos (via cerrada)	Via completamente cerrada por colapso de puente	2025-12-31 00:47:15.474324+00	2025-12-31 00:47:15.474324+00
5	7	f	total_sentido	\N	\N	Obstruccion total del sentido principal	\N	2025-12-31 00:47:15.508465+00	2025-12-31 00:47:15.508465+00
6	8	t	ninguna	\N	\N	Vehiculo fuera de la via	\N	2025-12-31 00:47:15.567768+00	2025-12-31 00:47:15.567768+00
2	4	t	parcial	{"carriles": [{"nombre": "Carril izquierdo", "porcentaje": 100}, {"nombre": "Carril derecho", "porcentaje": 50}], "cantidad_carriles": 2}	\N	Vehiculo fuera de la via. Ademas, Obstruccion parcial: Carril izquierdo (100%), Carril derecho (50%)	\N	2025-12-31 00:47:15.316923+00	2025-12-31 00:47:15.64164+00
8	10	f	parcial	{"carriles": [{"nombre": "Carril izquierdo", "porcentaje": 100}, {"nombre": "Carril central izquierdo", "porcentaje": 75}, {"nombre": "Carril central", "porcentaje": 50}, {"nombre": "Carril central derecho", "porcentaje": 25}, {"nombre": "Carril derecho", "porcentaje": 0}], "cantidad_carriles": 5}	\N	Obstruccion parcial: Carril izquierdo (100%), Carril central izquierdo (75%), Carril central (50%), Carril central derecho (25%)	\N	2025-12-31 00:47:15.718178+00	2025-12-31 00:47:15.718178+00
3	5	t	parcial	{"carriles": [{"nombre": "Carril izquierdo", "numero": 1, "porcentaje": 100}, {"nombre": "Carril central", "numero": 2, "porcentaje": 50}, {"nombre": "Carril derecho", "numero": 3, "porcentaje": 25}], "total_carriles": 3, "hay_obstruccion": true}	{"carriles": [], "total_carriles": 2, "hay_obstruccion": false}	Vehiculo fuera de la via. Ademas, Obstruccion parcial: Carril izquierdo (100%), Carril central (50%), Carril derecho (25%)	\N	2025-12-31 00:47:15.390708+00	2025-12-31 00:54:32.410208+00
\.


--
-- Data for Name: password_reset_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.password_reset_log (id, usuario_id, habilitado_por, fecha_habilitacion, fecha_completado, ip_completado, metodo, created_at) FROM stdin;
\.


--
-- Data for Name: permiso; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.permiso (id, nombre, descripcion, modulo, created_at) FROM stdin;
1	ver_brigadas	Ver lista de brigadas	BRIGADAS	2026-01-04 02:57:36.196524
2	crear_brigada	Crear nuevas brigadas	BRIGADAS	2026-01-04 02:57:36.196524
3	editar_brigada	Editar brigadas existentes	BRIGADAS	2026-01-04 02:57:36.196524
4	eliminar_brigada	Eliminar brigadas	BRIGADAS	2026-01-04 02:57:36.196524
5	ver_unidades	Ver lista de unidades	UNIDADES	2026-01-04 02:57:36.196524
6	crear_unidad	Crear nuevas unidades	UNIDADES	2026-01-04 02:57:36.196524
7	editar_unidad	Editar unidades	UNIDADES	2026-01-04 02:57:36.196524
8	gestion_usuarios	Gestionar usuarios del sistema	ADMIN	2026-01-04 02:57:36.196524
\.


--
-- Data for Name: persona_accidente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.persona_accidente (id, hoja_accidentologia_id, vehiculo_accidente_id, tipo_persona, nombre_completo, dpi, edad, genero, telefono, direccion, estado, tipo_lesion, descripcion_lesiones, requirio_atencion, hospital_trasladado, ambulancia_unidad, hora_traslado, hora_fallecimiento, lugar_fallecimiento, created_at) FROM stdin;
\.


--
-- Data for Name: persona_involucrada; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.persona_involucrada (id, incidente_id, vehiculo_id, tipo, nombre, genero, edad, estado, trasladado, lugar_traslado, consignado, lugar_consignacion, observaciones, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: piloto; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.piloto (id, nombre, licencia_tipo, licencia_numero, licencia_vencimiento, licencia_antiguedad, fecha_nacimiento, etnia, total_incidentes, total_sanciones, primer_incidente, ultimo_incidente, created_at, updated_at) FROM stdin;
1	Yair Alexander Morales Mejia 	M	2828070120204	2026-05-04	5	\N	\N	2	0	2025-12-11 16:22:21.218387+00	2025-12-11 19:06:18.496822+00	2025-12-11 16:22:21.202985+00	2025-12-11 19:06:18.496822+00
\.


--
-- Data for Name: plantilla_comunicacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.plantilla_comunicacion (id, nombre, descripcion, tipo_situacion, tipo_accidente, contenido_plantilla, activa, es_predefinida, hashtags, creado_por, created_at, updated_at) FROM stdin;
1	Comunicado General de Accidente	Plantilla estándar para comunicar accidentes de tránsito	INCIDENTE	\N	⚠️ COMUNICADO OFICIAL ⚠️\n\n📅 Fecha: {fecha}\n🕐 Hora: {hora}\n📍 Ubicación: {ubicacion}, {municipio}, {departamento}\n\n{descripcion}\n\n👥 Personas heridas: {heridos}\n🚗 Vehículos involucrados: {vehiculos}\n\nPROVIAL se encuentra atendiendo la emergencia.\n\n#PROVIAL #SeguridadVial #Guatemala	t	t	{PROVIAL,SeguridadVial,Guatemala,TransitoGT}	\N	2026-01-01 07:26:50.735959	2026-01-01 07:26:50.735959
2	Alerta de Tráfico	Plantilla para alertar sobre congestión vehicular	INCIDENTE	\N	🚧 ALERTA DE TRÁFICO 🚧\n\n📍 {ubicacion}\n\n⚠️ Se reporta {tipo} que ocasiona lentitud en la vía.\n\nSe recomienda tomar vías alternas.\n\n#TraficoGT #PROVIAL	t	t	{TraficoGT,PROVIAL,VíasAlternas}	\N	2026-01-01 07:26:50.735959	2026-01-01 07:26:50.735959
3	Accidente con Fallecidos	Plantilla para comunicar accidentes con víctimas mortales	INCIDENTE	\N	🕊️ COMUNICADO - ACCIDENTE DE TRÁNSITO 🕊️\n\n📅 {fecha} | 🕐 {hora}\n📍 {ubicacion}\n\nLamentamos informar que se registró un accidente de tránsito con consecuencias fatales.\n\n🚗 Vehículos involucrados: {vehiculos}\n👥 Heridos: {heridos}\n✝️ Fallecidos: {fallecidos}\n\nPROVIAL extiende sus condolencias a las familias afectadas.\n\n#PROVIAL #SeguridadVial	t	t	{PROVIAL,SeguridadVial}	\N	2026-01-01 07:26:50.735959	2026-01-01 07:26:50.735959
4	Emergencia Atendida	Plantilla para informar emergencias ya atendidas	EMERGENCIA	\N	✅ EMERGENCIA ATENDIDA ✅\n\n📍 {ubicacion}\n📅 {fecha} | 🕐 {hora}\n\nPROVIAL atendió exitosamente: {descripcion}\n\nLa vía se encuentra habilitada.\n\n#PROVIAL #Emergencia	t	t	{PROVIAL,Emergencia,ViaHabilitada}	\N	2026-01-01 07:26:50.735959	2026-01-01 07:26:50.735959
5	Asistencia Vial	Plantilla para comunicar asistencias	ASISTENCIA	\N	🛠️ ASISTENCIA VIAL 🛠️\n\n📍 {ubicacion}\n📅 {fecha}\n\nPROVIAL brindó asistencia: {descripcion}\n\n¿Necesitas ayuda en carretera? Comunícate con nosotros.\n\n#PROVIAL #AsistenciaVial	t	t	{PROVIAL,AsistenciaVial,AyudaEnCarretera}	\N	2026-01-01 07:26:50.735959	2026-01-01 07:26:50.735959
14	Test Exhaustivo 1767258827164	\N	\N	\N	Prueba de {tipo_situacion} en {ubicacion}	t	f	{}	13	2026-01-01 09:13:47.169775	2026-01-01 09:13:47.169775
15	TestX	\N	\N	\N	Contenido test	t	f	{}	13	2026-01-01 09:14:21.499739	2026-01-01 09:14:21.499739
\.


--
-- Data for Name: plantilla_inspeccion_360; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.plantilla_inspeccion_360 (id, tipo_unidad, nombre, descripcion, version, secciones, activa, creado_por, created_at, updated_at) FROM stdin;
1	DEFAULT	Inspección 360 General	Plantilla general para vehículos sin plantilla específica	1	[{"items": [{"tipo": "CHECKBOX", "codigo": "EXT001", "requerido": true, "descripcion": "Emblemas/logos visibles"}, {"tipo": "ESTADO", "codigo": "EXT002", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Espejos retrovisores"}, {"tipo": "CHECKBOX", "codigo": "EXT003", "requerido": true, "descripcion": "Placas visibles"}, {"tipo": "ESTADO", "codigo": "EXT004", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de pintura"}, {"tipo": "TEXTO_FOTO", "codigo": "EXT005", "requerido": true, "descripcion": "Rayones o golpes"}], "nombre": "Exterior"}, {"items": [{"tipo": "ESTADO", "codigo": "LUZ001", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luces delanteras"}, {"tipo": "ESTADO", "codigo": "LUZ002", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luces traseras"}, {"tipo": "ESTADO", "codigo": "LUZ003", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Direccionales"}, {"tipo": "ESTADO", "codigo": "LUZ004", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luces de freno"}], "nombre": "Luces"}, {"items": [{"tipo": "ESTADO", "codigo": "INT001", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Radio/Comunicaciones"}, {"tipo": "CHECKBOX", "codigo": "INT002", "requerido": true, "descripcion": "Extintor"}, {"tipo": "CHECKBOX", "codigo": "INT003", "requerido": true, "descripcion": "Triángulos de seguridad"}, {"tipo": "CHECKBOX", "codigo": "INT004", "requerido": false, "descripcion": "Botiquín"}, {"tipo": "CHECKBOX", "codigo": "INT005", "requerido": true, "descripcion": "Documentos del vehículo"}], "nombre": "Interior"}, {"items": [{"tipo": "ESTADO", "codigo": "MEC001", "opciones": ["LLENO", "3/4", "1/2", "1/4", "RESERVA"], "requerido": true, "descripcion": "Nivel de combustible"}, {"tipo": "ESTADO", "codigo": "MEC002", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de llantas"}, {"tipo": "ESTADO", "codigo": "MEC003", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Frenos"}, {"tipo": "CHECKBOX", "codigo": "MEC004", "requerido": true, "descripcion": "Llanta de repuesto"}, {"tipo": "CHECKBOX", "codigo": "MEC005", "requerido": true, "descripcion": "Herramientas básicas (tricket, llave cruz)"}], "nombre": "Mecánico"}]	t	\N	2026-01-01 00:04:34.511051+00	2026-01-01 00:04:34.511051+00
2	PICK-UP	Inspección 360 Pick-Up	Plantilla para vehículos Pick-Up (Toyota, etc.)	1	[{"items": [{"tipo": "CHECKBOX", "codigo": "EXT001", "requerido": true, "descripcion": "Emblemas/logos PROVIAL"}, {"tipo": "ESTADO", "codigo": "EXT002", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Cámaras de video"}, {"tipo": "CHECKBOX", "codigo": "EXT003", "requerido": true, "descripcion": "Antenas (radio/GPS)"}, {"tipo": "CHECKBOX", "codigo": "EXT004", "requerido": true, "descripcion": "Placas visibles y legibles"}, {"tipo": "ESTADO", "codigo": "EXT005", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Espejos retrovisores"}, {"tipo": "ESTADO", "codigo": "EXT006", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de pintura"}, {"tipo": "TEXTO_FOTO", "codigo": "EXT007", "requerido": true, "descripcion": "Rayones/golpes (describir y fotografiar)"}, {"tipo": "ESTADO", "codigo": "EXT008", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de vidrios"}], "nombre": "Exterior"}, {"items": [{"tipo": "ESTADO", "codigo": "LUZ001", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luces delanteras (bajas)"}, {"tipo": "ESTADO", "codigo": "LUZ002", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luces delanteras (altas)"}, {"tipo": "ESTADO", "codigo": "LUZ003", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luces traseras"}, {"tipo": "ESTADO", "codigo": "LUZ004", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA", "N/A"], "requerido": false, "descripcion": "Neblineras"}, {"tipo": "ESTADO", "codigo": "LUZ005", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Direccionales delanteras"}, {"tipo": "ESTADO", "codigo": "LUZ006", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Direccionales traseras"}, {"tipo": "ESTADO", "codigo": "LUZ007", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luces de freno"}, {"tipo": "ESTADO", "codigo": "LUZ008", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luz de reversa"}, {"tipo": "ESTADO", "codigo": "LUZ009", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Balizas/torretas"}], "nombre": "Luces y Señalización"}, {"items": [{"tipo": "ESTADO", "codigo": "INT001", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Radio de comunicación"}, {"tipo": "CHECKBOX", "codigo": "INT002", "requerido": true, "descripcion": "Extintor (fecha vigente)"}, {"tipo": "CHECKBOX", "codigo": "INT003", "requerido": true, "descripcion": "Triángulos de seguridad (2)"}, {"tipo": "CHECKBOX", "codigo": "INT004", "requerido": true, "descripcion": "Botiquín primeros auxilios"}, {"tipo": "CHECKBOX", "codigo": "INT005", "requerido": true, "descripcion": "Chaleco reflectivo"}, {"tipo": "CHECKBOX", "codigo": "INT006", "requerido": true, "descripcion": "Linterna"}, {"tipo": "CHECKBOX", "codigo": "INT007", "requerido": true, "descripcion": "Documentos del vehículo"}, {"tipo": "CHECKBOX", "codigo": "INT008", "requerido": true, "descripcion": "Póliza de seguro vigente"}], "nombre": "Interior y Equipamiento"}, {"items": [{"tipo": "ESTADO", "codigo": "MEC001", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de batería"}, {"tipo": "ESTADO", "codigo": "MEC002", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Limpiabrisas"}, {"tipo": "ESTADO", "codigo": "MEC003", "opciones": ["NORMAL", "BAJO", "CRÍTICO"], "requerido": true, "descripcion": "Nivel de aceite"}, {"tipo": "ESTADO", "codigo": "MEC004", "opciones": ["NORMAL", "BAJO", "CRÍTICO"], "requerido": true, "descripcion": "Nivel de refrigerante"}, {"tipo": "ESTADO", "codigo": "MEC005", "opciones": ["NORMAL", "BAJO", "CRÍTICO"], "requerido": true, "descripcion": "Nivel de líquido de frenos"}, {"tipo": "ESTADO", "codigo": "MEC006", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de llantas delanteras"}, {"tipo": "ESTADO", "codigo": "MEC007", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de llantas traseras"}, {"tipo": "ESTADO", "codigo": "MEC008", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Freno de mano"}], "nombre": "Mecánico"}, {"items": [{"tipo": "CHECKBOX", "codigo": "ACC001", "requerido": true, "descripcion": "Llanta de repuesto"}, {"tipo": "CHECKBOX", "codigo": "ACC002", "requerido": true, "descripcion": "Gato/Tricket"}, {"tipo": "CHECKBOX", "codigo": "ACC003", "requerido": true, "descripcion": "Llave de cruz"}, {"tipo": "CHECKBOX", "codigo": "ACC004", "requerido": false, "descripcion": "Cables de arranque"}, {"tipo": "CHECKBOX", "codigo": "ACC005", "requerido": false, "descripcion": "Cuerda de remolque"}], "nombre": "Accesorios y Herramientas"}]	t	\N	2026-01-01 00:04:34.517841+00	2026-01-01 00:04:34.517841+00
3	GRUA	Inspección 360 Grúa	Plantilla para vehículos tipo Grúa	1	[{"items": [{"tipo": "CHECKBOX", "codigo": "EXT001", "requerido": true, "descripcion": "Emblemas/logos PROVIAL"}, {"tipo": "ESTADO", "codigo": "EXT002", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Cámaras de video"}, {"tipo": "CHECKBOX", "codigo": "EXT003", "requerido": true, "descripcion": "Antenas (radio/GPS)"}, {"tipo": "CHECKBOX", "codigo": "EXT004", "requerido": true, "descripcion": "Placas visibles y legibles"}, {"tipo": "ESTADO", "codigo": "EXT005", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Espejos retrovisores"}, {"tipo": "ESTADO", "codigo": "EXT006", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de pintura"}, {"tipo": "TEXTO_FOTO", "codigo": "EXT007", "requerido": true, "descripcion": "Rayones/golpes (describir y fotografiar)"}, {"tipo": "ESTADO", "codigo": "EXT008", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de vidrios"}, {"tipo": "ESTADO", "codigo": "EXT009", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Calcomanías/franjas reflectivas"}], "nombre": "Exterior"}, {"items": [{"tipo": "ESTADO", "codigo": "FED001", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Balizas LED"}, {"tipo": "ESTADO", "codigo": "FED002", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Sirena"}, {"tipo": "ESTADO", "codigo": "FED003", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Horn (bocina emergencia)"}, {"tipo": "ESTADO", "codigo": "FED004", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Wail (sirena americana)"}, {"tipo": "ESTADO", "codigo": "FED005", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Megáfono/PA"}, {"tipo": "ESTADO", "codigo": "FED006", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Callejoneras"}], "nombre": "Sistema Federal Master"}, {"items": [{"tipo": "ESTADO", "codigo": "COM001", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Radio H&T"}, {"tipo": "ESTADO", "codigo": "COM002", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Radio Motorola"}, {"tipo": "ESTADO", "codigo": "COM003", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Radio base/móvil"}], "nombre": "Comunicaciones"}, {"items": [{"tipo": "ESTADO", "codigo": "LUZ001", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luces delanteras"}, {"tipo": "ESTADO", "codigo": "LUZ002", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luces traseras"}, {"tipo": "ESTADO", "codigo": "LUZ003", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Direccionales"}, {"tipo": "ESTADO", "codigo": "LUZ004", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luces de freno"}, {"tipo": "ESTADO", "codigo": "LUZ005", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luces de trabajo (pluma)"}], "nombre": "Luces"}, {"items": [{"tipo": "ESTADO", "codigo": "HID001", "opciones": ["NORMAL", "BAJO", "CRÍTICO"], "requerido": true, "descripcion": "Nivel de aceite hidráulico"}, {"tipo": "ESTADO", "codigo": "HID002", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de mangueras hidráulicas"}, {"tipo": "ESTADO", "codigo": "HID003", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Funcionamiento pluma"}, {"tipo": "ESTADO", "codigo": "HID004", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de cables winche"}, {"tipo": "ESTADO", "codigo": "HID005", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Funcionamiento winche"}, {"tipo": "ESTADO", "codigo": "HID006", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Estabilizadores/patas"}, {"tipo": "ESTADO", "codigo": "HID007", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": false, "descripcion": "Control remoto grúa"}], "nombre": "Sistema Hidráulico y Grúa"}, {"items": [{"tipo": "ESTADO", "codigo": "MEC001", "opciones": ["NORMAL", "BAJO", "CRÍTICO"], "requerido": true, "descripcion": "Nivel de aceite motor"}, {"tipo": "ESTADO", "codigo": "MEC002", "opciones": ["NORMAL", "BAJO", "CRÍTICO"], "requerido": true, "descripcion": "Nivel de refrigerante"}, {"tipo": "ESTADO", "codigo": "MEC003", "opciones": ["NORMAL", "BAJO", "CRÍTICO"], "requerido": true, "descripcion": "Nivel líquido de frenos"}, {"tipo": "ESTADO", "codigo": "MEC004", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de llantas"}, {"tipo": "ESTADO", "codigo": "MEC005", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Freno de mano/estacionamiento"}], "nombre": "Mecánico y Niveles"}, {"items": [{"tipo": "CHECKBOX", "codigo": "INT001", "requerido": true, "descripcion": "Extintor (fecha vigente)"}, {"tipo": "CHECKBOX", "codigo": "INT002", "requerido": true, "descripcion": "Triángulos de seguridad"}, {"tipo": "CHECKBOX", "codigo": "INT003", "requerido": true, "descripcion": "Conos de señalización"}, {"tipo": "CHECKBOX", "codigo": "INT004", "requerido": true, "descripcion": "Chaleco reflectivo"}, {"tipo": "CHECKBOX", "codigo": "INT005", "requerido": true, "descripcion": "Guantes de trabajo"}, {"tipo": "CHECKBOX", "codigo": "INT006", "requerido": true, "descripcion": "Documentos del vehículo"}, {"tipo": "CHECKBOX", "codigo": "INT007", "requerido": true, "descripcion": "Póliza de seguro vigente"}], "nombre": "Interior y Equipamiento"}]	t	\N	2026-01-01 00:04:34.522678+00	2026-01-01 00:04:34.522678+00
4	MOTO	Inspección 360 Motocicleta	Plantilla para motocicletas	1	[{"items": [{"tipo": "CHECKBOX", "codigo": "EXT001", "requerido": true, "descripcion": "Emblemas/logos PROVIAL"}, {"tipo": "ESTADO", "codigo": "EXT002", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Espejos retrovisores (ambos)"}, {"tipo": "CHECKBOX", "codigo": "EXT003", "requerido": true, "descripcion": "Placas visibles"}, {"tipo": "ESTADO", "codigo": "EXT004", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de pintura"}, {"tipo": "TEXTO_FOTO", "codigo": "EXT005", "requerido": true, "descripcion": "Rayones/golpes (describir y fotografiar)"}, {"tipo": "ESTADO", "codigo": "EXT006", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Guardafangos"}], "nombre": "Exterior"}, {"items": [{"tipo": "ESTADO", "codigo": "LUZ001", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luz delantera"}, {"tipo": "ESTADO", "codigo": "LUZ002", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luz trasera"}, {"tipo": "ESTADO", "codigo": "LUZ003", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Direccionales delanteras"}, {"tipo": "ESTADO", "codigo": "LUZ004", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Direccionales traseras"}, {"tipo": "ESTADO", "codigo": "LUZ005", "opciones": ["FUNCIONANDO", "PARCIAL", "NO FUNCIONA"], "requerido": true, "descripcion": "Luz de freno"}], "nombre": "Luces"}, {"items": [{"tipo": "ESTADO", "codigo": "MEC001", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Freno delantero"}, {"tipo": "ESTADO", "codigo": "MEC002", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Freno trasero"}, {"tipo": "ESTADO", "codigo": "MEC003", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de cadena"}, {"tipo": "ESTADO", "codigo": "MEC004", "opciones": ["CORRECTA", "FLOJA", "TENSA"], "requerido": true, "descripcion": "Tensión de cadena"}, {"tipo": "ESTADO", "codigo": "MEC005", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de llanta delantera"}, {"tipo": "ESTADO", "codigo": "MEC006", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Estado de llanta trasera"}, {"tipo": "ESTADO", "codigo": "MEC007", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Suspensión delantera"}, {"tipo": "ESTADO", "codigo": "MEC008", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Suspensión trasera"}, {"tipo": "ESTADO", "codigo": "MEC009", "opciones": ["NORMAL", "BAJO", "CRÍTICO"], "requerido": true, "descripcion": "Nivel de aceite motor"}, {"tipo": "ESTADO", "codigo": "MEC010", "opciones": ["FUNCIONANDO", "NO FUNCIONA"], "requerido": true, "descripcion": "Bocina/claxon"}], "nombre": "Mecánico"}, {"items": [{"tipo": "ESTADO", "codigo": "SEG001", "opciones": ["BUENO", "REGULAR", "MALO"], "requerido": true, "descripcion": "Casco (estado)"}, {"tipo": "CHECKBOX", "codigo": "SEG002", "requerido": true, "descripcion": "Chaleco reflectivo"}, {"tipo": "CHECKBOX", "codigo": "SEG003", "requerido": false, "descripcion": "Guantes"}, {"tipo": "CHECKBOX", "codigo": "SEG004", "requerido": true, "descripcion": "Documentos del vehículo"}, {"tipo": "CHECKBOX", "codigo": "SEG005", "requerido": true, "descripcion": "Licencia de conducir"}], "nombre": "Equipamiento de Seguridad"}]	t	\N	2026-01-01 00:04:34.525994+00	2026-01-01 00:04:34.525994+00
\.


--
-- Data for Name: publicacion_social; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.publicacion_social (id, situacion_id, hoja_accidentologia_id, plantilla_id, contenido_texto, contenido_editado, hashtags, fotos_urls, publicado_facebook, publicado_twitter, publicado_instagram, publicado_whatsapp, publicado_threads, fecha_publicacion, publicado_por, estado, fecha_programada, created_at) FROM stdin;
1	\N	\N	\N	Publicación de prueba automática	Contenido editado por pruebas	{PROVIAL,Test}	{}	t	f	f	f	f	2026-01-01 07:53:56.367063	13	PUBLICADO	\N	2026-01-01 07:53:56.33718
2	\N	\N	\N	Publicación de prueba automática	Contenido editado por pruebas	{PROVIAL,Test}	{}	t	f	f	f	f	2026-01-01 08:01:56.047782	13	PUBLICADO	\N	2026-01-01 08:01:56.021708
3	\N	\N	\N	Publicación de prueba automática	Contenido editado por pruebas	{PROVIAL,Test}	{}	t	f	f	f	f	2026-01-01 08:12:22.715838	13	PUBLICADO	\N	2026-01-01 08:12:22.688216
4	\N	\N	\N	Publicación de prueba automática	Contenido editado por pruebas	{PROVIAL,Test}	{}	t	f	f	f	f	2026-01-01 08:13:17.835329	13	PUBLICADO	\N	2026-01-01 08:13:17.809898
5	\N	\N	\N	Publicación de prueba automática	Contenido editado por pruebas	{PROVIAL,Test}	{}	t	f	f	f	f	2026-01-01 08:15:10.549418	13	PUBLICADO	\N	2026-01-01 08:15:10.52063
6	\N	\N	\N	Publicación de prueba automática	Contenido editado por pruebas	{PROVIAL,Test}	{}	t	f	f	f	f	2026-01-01 08:16:09.25996	13	PUBLICADO	\N	2026-01-01 08:16:09.23427
7	\N	\N	\N	Publicación de prueba automática	Contenido editado por pruebas	{PROVIAL,Test}	{}	t	f	f	f	f	2026-01-01 08:42:15.828159	13	PUBLICADO	\N	2026-01-01 08:42:15.792596
8	\N	\N	\N	Publicación de prueba automática	Contenido editado por pruebas	{PROVIAL,Test}	{}	t	f	f	f	f	2026-01-01 08:50:26.981497	13	PUBLICADO	\N	2026-01-01 08:50:26.918797
9	\N	\N	\N	Test publicacion	\N	{}	{}	f	f	f	f	f	2026-01-01 09:12:30.784172	13	BORRADOR	\N	2026-01-01 09:12:30.784172
10	\N	\N	\N	Publicación de prueba exhaustiva 1767258827185	\N	{}	{}	f	f	f	f	f	2026-01-01 09:13:47.191266	13	BORRADOR	\N	2026-01-01 09:13:47.191266
11	\N	\N	\N	Publicación de prueba exhaustiva 1767258977874	\N	{}	{}	f	t	f	f	f	2026-01-01 09:16:17.905412	13	PUBLICADO	\N	2026-01-01 09:16:17.878245
12	\N	\N	\N	Publicación de prueba exhaustiva 1767391886004	\N	{}	{}	f	t	f	f	f	2026-01-02 22:11:26.237706	13	PUBLICADO	\N	2026-01-02 22:11:26.012973
13	\N	\N	\N	Publicación de prueba exhaustiva 1767391974281	\N	{}	{}	f	t	f	f	f	2026-01-02 22:12:54.313056	13	PUBLICADO	\N	2026-01-02 22:12:54.287999
\.


--
-- Data for Name: reasignacion_sede; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reasignacion_sede (id, tipo, recurso_id, sede_origen_id, sede_destino_id, fecha_inicio, fecha_fin, es_permanente, motivo, estado, autorizado_por, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: recurso_incidente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.recurso_incidente (id, incidente_id, tipo_recurso, descripcion, hora_solicitud, hora_llegada, observaciones, created_at) FROM stdin;
\.


--
-- Data for Name: registro_cambio; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.registro_cambio (id, tipo_cambio, usuario_afectado_id, asignacion_id, situacion_id, unidad_id, valores_anteriores, valores_nuevos, motivo, realizado_por, autorizado_por, created_at) FROM stdin;
\.


--
-- Data for Name: relevo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.relevo (id, situacion_id, tipo_relevo, unidad_saliente_id, unidad_entrante_id, brigadistas_salientes, brigadistas_entrantes, fecha_hora, observaciones, registrado_por, created_at) FROM stdin;
\.


--
-- Data for Name: reporte_horario; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reporte_horario (id, asignacion_id, km_actual, sentido_actual, latitud, longitud, novedad, reportado_por, created_at) FROM stdin;
\.


--
-- Data for Name: rol; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rol (id, nombre, descripcion, permisos, created_at) FROM stdin;
1	ADMIN	Administrador del sistema	{"all": true}	2025-12-07 06:28:57.702667+00
2	COP	Operador del Centro de Operaciones	{"reportes": ["read"], "unidades": ["read", "update"], "incidentes": ["read", "update"]}	2025-12-07 06:28:57.702667+00
3	BRIGADA	Personal de campo	{"incidentes": ["create", "read", "update"], "actividades": ["create", "read"]}	2025-12-07 06:28:57.702667+00
4	OPERACIONES	Departamento de Operaciones	{"reportes": ["read"], "actividades": ["read"], "estadisticas": ["read"]}	2025-12-07 06:28:57.702667+00
5	ACCIDENTOLOGIA	Departamento de Accidentolog??a	{"reportes": ["read"], "incidentes": ["read"], "estadisticas": ["read"]}	2025-12-07 06:28:57.702667+00
6	MANDOS	Jefes y supervisores	{"all": ["read"], "reportes": ["read"], "estadisticas": ["read"]}	2025-12-07 06:28:57.702667+00
7	PUBLICO	Usuario ciudadano	{"reportes_publicos": ["create"], "incidentes_publicos": ["read"]}	2025-12-07 06:28:57.702667+00
9	ENCARGADO_NOMINAS	Encargado de nóminas - Vista de asignaciones, gestión limitada	{}	2025-12-14 17:52:40.02096+00
10	SUPER_ADMIN	Acceso total al sistema - Solo programadores	{"all": true}	2025-12-31 02:18:46.050662+00
11	COMUNICACION_SOCIAL	Departamento de Comunicacion Social	{}	2026-01-03 08:31:08.034305+00
\.


--
-- Data for Name: rol_permiso; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.rol_permiso (rol_id, permiso_id) FROM stdin;
\.


--
-- Data for Name: ruta; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ruta (id, codigo, nombre, tipo_ruta, km_inicial, km_final, activa, created_at) FROM stdin;
70	CA-1 Occidente	CA-1 Occidente	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
71	CA-1 Oriente	CA-1 Oriente	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
72	CA-2 Occidente	CA-2 Occidente	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
73	CA-9 Norte	CA-9 Norte	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
74	CA-9 Sur	CA-9 Sur	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
75	CA-10	CA-10	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
76	CA-11	CA-11	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
77	CA-13	CA-13	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
78	CA-14	CA-14	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
79	CA-2 Oriente	CA-2 Oriente	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
80	CA-8 Oriente	CA-8 Oriente	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
81	CA-9 Sur A	CA-9 Sur A	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
82	CHM-11	CHM-11	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
83	CITO-180	CITO-180	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
84	CIUDAD	CIUDAD	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
85	FTN	FTN	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
86	PRO-1	PRO-1	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
87	QUE-03	QUE-03	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
88	RD-1	RD-1	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
89	RD-3	RD-3	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
90	RD-9 Norte	RD-9 Norte	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
91	RD-10	RD-10	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
92	RD-16	RD-16	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
93	RD-AV-09	RD-AV-09	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
94	RD-CHI-01	RD-CHI-01	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
95	RD-ESC-01	RD-ESC-01	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
96	RD-GUA-01	RD-GUA-01	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
97	RD-GUA-04-06	RD-GUA-04-06	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
98	RD-GUA-10	RD-GUA-10	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
99	RD-GUA-16	RD-GUA-16	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
100	RD-JUT-03	RD-JUT-03	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
101	RD-PET-01	RD-PET-01	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
102	RD-PET-03	RD-PET-03	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
103	RD-PET-11	RD-PET-11	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
104	RD-PET-13	RD-PET-13	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
105	RD-SAC-08	RD-SAC-08	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
106	RD-SAC-11	RD-SAC-11	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
107	RD-SCH-14	RD-SCH-14	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
108	RD-SM-01	RD-SM-01	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
109	RD-SOL03	RD-SOL03	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
110	RD-SRO-03	RD-SRO-03	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
111	RD-STR-003	RD-STR-003	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
112	RD-ZA-05	RD-ZA-05	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
113	RN-01	RN-01	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
114	RN-02	RN-02	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
115	RN-05	RN-05	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
116	RN-07 E	RN-07 E	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
117	RN-9S	RN-9S	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
118	RN-10	RN-10	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
119	RN-11	RN-11	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
120	RN-14	RN-14	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
121	RN-15	RN-15	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
122	RN-15-03	RN-15-03	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
123	RN-16	RN-16	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
124	RN-17	RN-17	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
125	RN-18	RN-18	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
126	RN-19	RN-19	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
127	RUTA VAS SUR	RUTA VAS SUR	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
128	RUTA VAS OCC	RUTA VAS OCC	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
129	RUTA VAS OR	RUTA VAS OR	\N	\N	\N	t	2025-12-07 06:30:42.940443+00
\.


--
-- Data for Name: salida_unidad; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.salida_unidad (id, unidad_id, fecha_hora_salida, fecha_hora_regreso, estado, ruta_inicial_id, km_inicial, combustible_inicial, km_final, combustible_final, km_recorridos, tripulacion, finalizada_por, observaciones_salida, observaciones_regreso, created_at, updated_at, sede_origen_id, inspeccion_360_id) FROM stdin;
35	406	2025-12-29 18:02:50.274604+00	\N	EN_SALIDA	70	45000.00	75.00	\N	\N	\N	\N	\N	\N	\N	2025-12-29 18:02:50.274604+00	2025-12-29 18:02:50.274604+00	1	\N
36	341	2025-12-29 20:00:32.628337+00	\N	EN_SALIDA	70	45000.00	0.75	\N	\N	\N	[{"rol": "PILOTO", "chapa": "4028", "nombre": "Laj Tecu Juan Antonio", "brigada_id": 33}]	\N	\N	\N	2025-12-29 20:00:32.628337+00	2025-12-29 20:00:32.628337+00	\N	\N
\.


--
-- Data for Name: sancion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sancion (id, incidente_id, vehiculo_id, piloto_id, articulo_sancion_id, descripcion, monto, pagada, fecha_pago, aplicada_por, created_at) FROM stdin;
\.


--
-- Data for Name: sede; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sede (id, codigo, nombre, departamento, municipio, direccion, telefono, activa, created_at, departamento_id, municipio_id, es_sede_central, updated_at) FROM stdin;
2	MAZATE	Mazatenango	\N	\N	Mazatenango, Suchitep??quez	\N	t	2025-12-07 06:30:42.699269+00	\N	\N	f	2026-01-04 00:18:09.622576+00
5	XELA	Quetzaltenango	\N	\N	Quetzaltenango	\N	t	2025-12-07 06:30:42.699269+00	\N	\N	f	2026-01-04 00:18:09.622576+00
6	COATE	Coatepeque	\N	\N	Coatepeque, Quetzaltenango	\N	t	2025-12-07 06:30:42.699269+00	\N	\N	f	2026-01-04 00:18:09.622576+00
8	MORALES	Morales	\N	\N	Morales, Izabal	\N	t	2025-12-07 06:30:42.699269+00	\N	\N	f	2026-01-04 00:18:09.622576+00
3	POPTUN	Poptún	\N	\N	Popt??n, Pet??n	\N	t	2025-12-07 06:30:42.699269+00	\N	\N	f	2026-01-04 00:18:09.622576+00
4	SANCRIS	San Cristóbal	\N	\N	San Crist??bal Verapaz, Alta Verapaz	\N	t	2025-12-07 06:30:42.699269+00	\N	\N	f	2026-01-04 00:18:09.622576+00
7	PALIN	Palín Escuintla	\N	\N	Pal??n, Escuintla	\N	t	2025-12-07 06:30:42.699269+00	\N	\N	f	2026-01-04 00:18:09.622576+00
9	RIODULCE	Río Dulce	\N	\N	R??o Dulce, Izabal	\N	t	2025-12-07 06:30:42.699269+00	\N	\N	f	2026-01-04 00:18:09.622576+00
1	CENTRAL	Central	\N	\N	Ciudad de Guatemala	\N	t	2025-12-07 06:30:42.699269+00	\N	\N	t	2026-01-04 00:23:11.248132+00
\.


--
-- Data for Name: situacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.situacion (id, uuid, numero_situacion, tipo_situacion, estado, asignacion_id, unidad_id, turno_id, ruta_id, km, sentido, latitud, longitud, ubicacion_manual, combustible, kilometraje_unidad, tripulacion_confirmada, descripcion, observaciones, incidente_id, creado_por, actualizado_por, created_at, updated_at, departamento_id, municipio_id, modificado_despues_cierre, motivo_modificacion_cierre, combustible_fraccion, salida_unidad_id, evento_persistente_id, obstruccion_data) FROM stdin;
37	14206e12-c36b-410c-834f-792897082e6e	SIT-2025-0001	PATRULLAJE	CERRADA	40	406	30	70	52.50	NORTE	14.62340000	-90.54560000	f	\N	\N	\N	Patrullaje normal en CA-1	Cerrada automáticamente al iniciar INCIDENTE	\N	448	448	2025-12-29 18:02:52.329423+00	2025-12-29 19:00:04.462774+00	\N	\N	f	\N	\N	35	\N	\N
48	df90c12e-9c0d-478d-9eb3-37bb1de6db52	SIT-2025-0003	ASISTENCIA_VEHICULAR	CERRADA	41	341	32	70	55.50	OCCIDENTE	14.41580000	-90.78390000	f	\N	\N	\N	Colision multiple en km 55.5	\N	\N	33	33	2025-12-29 20:00:32.805802+00	2025-12-29 20:00:33.150525+00	\N	\N	f	\N	\N	36	\N	\N
49	c662a44a-f47e-4b6c-8901-9f0a46b36eb7	SIT-2025-0004	PATRULLAJE	ACTIVA	41	341	32	70	60.00	OCCIDENTE	14.42580000	-90.80390000	f	\N	\N	\N	Continuando patrullaje	\N	\N	33	\N	2025-12-29 20:00:33.220225+00	2025-12-29 20:00:33.220225+00	\N	\N	f	\N	\N	36	\N	\N
38	b2c43ed0-d9d6-4339-abee-48a52928107a	SIT-2025-0002	INCIDENTE	ACTIVA	40	406	30	70	58.20	NORTE	14.64070000	-90.51330000	f	\N	\N	\N	Colisión múltiple - 3 vehículos involucrados	Actualizado con datos completos	\N	448	358	2025-12-29 18:02:55.447051+00	2025-12-29 23:01:33.735595+00	\N	\N	f	\N	\N	35	\N	\N
\.


--
-- Data for Name: situacion_fija; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.situacion_fija (id, sede_id, titulo, descripcion, tipo, ruta_id, km_inicio, km_fin, punto_referencia, hora_inicio, hora_fin, dias_semana, fecha_inicio, fecha_fin, activa, observaciones, puntos_destacar, requiere_unidad_especifica, unidad_tipo_requerido, creado_por, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: situacion_multimedia; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.situacion_multimedia (id, situacion_id, tipo, orden, url_original, url_thumbnail, nombre_archivo, mime_type, tamanio_bytes, ancho, alto, duracion_segundos, latitud, longitud, subido_por, created_at) FROM stdin;
\.


--
-- Data for Name: situacion_persistente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.situacion_persistente (id, uuid, numero, titulo, tipo, subtipo, estado, importancia, ruta_id, km_inicio, km_fin, sentido, latitud, longitud, direccion_referencia, descripcion, observaciones_generales, fecha_inicio, fecha_fin_estimada, fecha_fin_real, creado_por, cerrado_por, created_at, updated_at, tipo_emergencia_id, situacion_origen_id, es_promocion, fecha_promocion, promovido_por, jurisdiccion) FROM stdin;
2	4ea93c57-ea78-49e1-92c9-fa37ebb3b6a6	SP-2025-0001	Derrumbe Test Km 45	DERRUMBE	\N	ACTIVA	ALTA	70	45.00	46.00	NORTE_SUR	\N	\N	\N	Prueba de derrumbe en carretera	\N	2025-12-30 23:57:33.802278+00	\N	\N	306	\N	2025-12-30 23:57:33.802278+00	2025-12-30 23:57:33.802278+00	5	\N	f	\N	\N	Escuintla
3	671acbd9-934e-4d24-a3d0-c2deddfa69fa	SP-2025-0002	Incidente promovido a persistente	DERRUMBE	\N	ACTIVA	ALTA	70	58.20	\N	NORTE	14.64070000	-90.51330000	\N	Este es un incidente que se promueve a situacion extraordinaria	\N	2025-12-30 23:58:50.865874+00	\N	\N	306	\N	2025-12-30 23:58:50.865874+00	2025-12-30 23:58:50.865874+00	5	38	t	2025-12-30 23:58:50.865874+00	306	\N
7	72722aa8-a4a3-40b4-a3c1-93a75f8583c6	SP-2025-0006	Deslizamiento km 85	DERRUMBE	\N	ACTIVA	ALTA	70	85.00	\N	Norte	\N	\N	\N	\N	\N	2025-12-31 00:47:15.495967+00	\N	\N	568	\N	2025-12-31 00:47:15.495967+00	2025-12-31 00:47:15.495967+00	5	\N	f	\N	\N	\N
8	93db8060-750c-46cc-a6d3-6e85f1c4fe44	SP-2025-0007	Vehiculo volcado km 55	CAIDA_PUENTE	\N	ACTIVA	ALTA	70	55.00	\N	Sur	\N	\N	\N	\N	\N	2025-12-31 00:47:15.561958+00	\N	\N	247	\N	2025-12-31 00:47:15.561958+00	2025-12-31 00:47:15.561958+00	3	\N	f	\N	\N	\N
10	c09b846d-8156-4b3c-ad8d-f9705f580e74	SP-2025-0008	Autopista km 300 - 5 carriles	CAIDA_PUENTE	\N	ACTIVA	ALTA	70	300.00	\N	Este	\N	\N	\N	\N	\N	2025-12-31 00:47:15.712372+00	\N	\N	568	\N	2025-12-31 00:47:15.712372+00	2025-12-31 00:47:15.712372+00	3	\N	f	\N	\N	\N
6	7acb7ceb-9f18-4d71-aeda-52813529edf9	SP-2025-0005	Puente colapsado km 200	DESPRENDIMIENTO_ROCAS	\N	FINALIZADA	CRITICA	70	200.00	201.00	Ambos	\N	\N	\N	\N	\N	2025-12-31 00:47:15.451457+00	\N	2025-12-31 00:47:15.750924+00	568	568	2025-12-31 00:47:15.451457+00	2025-12-31 00:47:15.750924+00	8	\N	f	\N	\N	\N
4	6aefeaea-a13f-483b-9ab3-fbd902022cee	SP-2025-0003	Derrumbe km 45 CA-9 Norte	ACUMULACION_AGUA	\N	ACTIVA	ALTA	70	45.00	46.00	Norte	\N	\N	\N	Derrumbe por lluvias, material en via	\N	2025-12-31 00:47:15.292842+00	\N	\N	568	\N	2025-12-31 00:47:15.292842+00	2025-12-31 00:47:15.794093+00	1	\N	f	\N	\N	\N
5	2dad0de6-4903-4b00-a9cf-75d43f115b63	SP-2025-0004	Situacion editada 00:54:32	CAIDA_PUENTE	\N	ACTIVA	ALTA	70	120.00	\N	Sur	\N	\N	\N	Descripcion actualizada desde pruebas automatizadas	\N	2025-12-31 00:47:15.384083+00	\N	\N	247	\N	2025-12-31 00:47:15.384083+00	2025-12-31 00:54:32.520961+00	3	\N	f	\N	\N	\N
\.


--
-- Data for Name: socorro_situacion_persistente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.socorro_situacion_persistente (id, situacion_persistente_id, tipo_socorro, hora_llegada, nip_chapa, numero_unidad, nombre_comandante, cantidad_elementos, subestacion, cantidad_unidades, observaciones, created_at, updated_at) FROM stdin;
1	5	BOMBEROS	14:35:00	\N	\N	\N	\N	\N	2	\N	2025-12-31 00:47:15.424575+00	2025-12-31 00:47:15.424575+00
\.


--
-- Data for Name: sub_rol_cop; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sub_rol_cop (id, codigo, nombre, descripcion, puede_crear_persistentes, puede_cerrar_persistentes, puede_promover_situaciones, puede_asignar_unidades, solo_lectura, permisos, activo, created_at, updated_at, puede_gestionar_usuarios, puede_gestionar_grupos, puede_ver_todos_departamentos) FROM stdin;
1	ADMIN_COP	Administrador COP	Acceso total al Centro de Operaciones	t	t	t	t	f	{}	t	2025-12-30 23:51:54.387288+00	2025-12-31 02:18:46.050662+00	t	t	t
2	ENCARGADO_ISLA	Encargado de Isla	Responsable de una isla del COP, puede gestionar situaciones persistentes	t	t	t	t	f	{}	t	2025-12-30 23:51:54.387288+00	2025-12-31 02:18:46.050662+00	t	t	f
3	SUB_ENCARGADO_ISLA	Sub-Encargado de Isla	Asistente del encargado de isla, puede gestionar situaciones persistentes	t	t	t	t	f	{}	t	2025-12-30 23:51:54.387288+00	2025-12-31 02:18:46.050662+00	t	t	f
4	OPERADOR	Operador	Operador del COP, solo puede visualizar y monitorear	f	f	f	f	t	{}	t	2025-12-30 23:51:54.387288+00	2025-12-31 02:18:46.050662+00	f	f	f
\.


--
-- Data for Name: subtipo_hecho; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.subtipo_hecho (id, tipo_hecho_id, nombre, activo, created_at) FROM stdin;
1	1	Colisi??n	t	2025-12-07 06:28:57.784035+00
2	1	Volcamiento	t	2025-12-07 06:28:57.784035+00
3	1	Atropello	t	2025-12-07 06:28:57.784035+00
4	1	Salida de V??a	t	2025-12-07 06:28:57.784035+00
5	1	Choque contra Objeto Fijo	t	2025-12-07 06:28:57.784035+00
6	2	Falla Mec??nica	t	2025-12-07 06:28:57.785854+00
7	2	Sin Combustible	t	2025-12-07 06:28:57.785854+00
8	2	Llanta Ponchada	t	2025-12-07 06:28:57.785854+00
9	2	Sobrecalentamiento	t	2025-12-07 06:28:57.785854+00
\.


--
-- Data for Name: suscripcion_alerta; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.suscripcion_alerta (id, usuario_id, tipo_alerta, activa, solo_sede_id, severidad_minima, created_at) FROM stdin;
\.


--
-- Data for Name: tarjeta_circulacion; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tarjeta_circulacion (id, vehiculo_id, numero, nit, direccion_propietario, nombre_propietario, modelo, fecha_registro, created_at) FROM stdin;
1	7	12345678	100090655	No tiene	Yair Alexander Morales Mejia	\N	2025-12-11 16:22:21.230093+00	2025-12-11 16:22:21.230093+00
2	7	12345678	100090655	No tiene	Yair Alexander Morales Mejia	\N	2025-12-11 19:06:18.525125+00	2025-12-11 19:06:18.525125+00
\.


--
-- Data for Name: tipo_actividad; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tipo_actividad (id, nombre, requiere_incidente, color, created_at) FROM stdin;
1	Patrullaje	f	#4CAF50	2025-12-07 06:28:57.804646+00
2	Accidente Vial	t	#F44336	2025-12-07 06:28:57.804646+00
3	Regulaci??n de Tr??nsito	t	#2196F3	2025-12-07 06:28:57.804646+00
4	Almuerzo	f	#FFC107	2025-12-07 06:28:57.804646+00
5	Parada Estrat??gica	f	#9C27B0	2025-12-07 06:28:57.804646+00
6	Carga de Combustible	f	#FF9800	2025-12-07 06:28:57.804646+00
7	Fuera de Servicio	f	#9E9E9E	2025-12-07 06:28:57.804646+00
8	Mantenimiento	f	#795548	2025-12-07 06:28:57.804646+00
9	Veh??culo Varado	t	#FF5722	2025-12-07 06:28:57.804646+00
\.


--
-- Data for Name: tipo_emergencia_vial; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tipo_emergencia_vial (id, codigo, nombre, descripcion, icono, color, activo, orden, created_at) FROM stdin;
1	ACUMULACION_AGUA	Acumulacion de Agua	\N	\N	#EF4444	t	1	2025-12-30 23:51:54.387288+00
2	CAIDA_ARBOL	Caida de Arbol	\N	\N	#EF4444	t	2	2025-12-30 23:51:54.387288+00
3	CAIDA_PUENTE	Caida de Puente	\N	\N	#EF4444	t	3	2025-12-30 23:51:54.387288+00
4	CAIDA_VALLA	Caida de Valla Publicitaria	\N	\N	#EF4444	t	4	2025-12-30 23:51:54.387288+00
5	DERRUMBE	Derrumbe	\N	\N	#EF4444	t	5	2025-12-30 23:51:54.387288+00
6	DESBORDAMIENTO_RIO	Desbordamiento de Rio	\N	\N	#EF4444	t	6	2025-12-30 23:51:54.387288+00
7	DESLAVE	Deslave	\N	\N	#EF4444	t	7	2025-12-30 23:51:54.387288+00
8	DESPRENDIMIENTO_ROCAS	Desprendimiento de Rocas	\N	\N	#EF4444	t	8	2025-12-30 23:51:54.387288+00
9	HUNDIMIENTO	Hundimiento	\N	\N	#EF4444	t	9	2025-12-30 23:51:54.387288+00
10	INCENDIO_FORESTAL	Incendio Forestal	\N	\N	#EF4444	t	10	2025-12-30 23:51:54.387288+00
11	SOCAVAMIENTO	Socavamiento	\N	\N	#EF4444	t	11	2025-12-30 23:51:54.387288+00
12	APOYO_ANTORCHA	Apoyo Antorcha	\N	\N	#EF4444	t	12	2025-12-30 23:51:54.387288+00
13	OTRO	Otro	\N	\N	#EF4444	t	99	2025-12-30 23:51:54.387288+00
\.


--
-- Data for Name: tipo_hecho; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tipo_hecho (id, nombre, icono, color, activo, created_at) FROM stdin;
1	Accidente Vial	accident	#FF0000	t	2025-12-07 06:28:57.773008+00
2	Veh??culo Varado	car-breakdown	#FFA500	t	2025-12-07 06:28:57.773008+00
3	Derrumbe	landslide	#8B4513	t	2025-12-07 06:28:57.773008+00
4	??rbol Ca??do	tree	#228B22	t	2025-12-07 06:28:57.773008+00
5	Trabajos en la V??a	construction	#FFD700	t	2025-12-07 06:28:57.773008+00
6	Manifestaci??n	protest	#FF69B4	t	2025-12-07 06:28:57.773008+00
7	Regulaci??n de Tr??nsito	traffic-control	#1E90FF	t	2025-12-07 06:28:57.773008+00
8	Otro	question	#808080	t	2025-12-07 06:28:57.773008+00
\.


--
-- Data for Name: tipo_vehiculo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tipo_vehiculo (id, nombre, categoria, created_at) FROM stdin;
52	Motocicleta	\N	2025-12-07 06:30:42.904079+00
53	Jaula Ca??era	\N	2025-12-07 06:30:42.904079+00
54	Rastra	\N	2025-12-07 06:30:42.904079+00
55	Bicicleta	\N	2025-12-07 06:30:42.904079+00
56	Jeep	\N	2025-12-07 06:30:42.904079+00
57	Bus escolar	\N	2025-12-07 06:30:42.904079+00
58	Maquinaria	\N	2025-12-07 06:30:42.904079+00
59	Bus turismo	\N	2025-12-07 06:30:42.904079+00
60	Tractor	\N	2025-12-07 06:30:42.904079+00
61	Ambulancia	\N	2025-12-07 06:30:42.904079+00
62	Camionetilla	\N	2025-12-07 06:30:42.904079+00
63	Pulman	\N	2025-12-07 06:30:42.904079+00
64	Autopatrulla PNC	\N	2025-12-07 06:30:42.904079+00
65	Bus extraurbano	\N	2025-12-07 06:30:42.904079+00
66	Bus urbano	\N	2025-12-07 06:30:42.904079+00
67	Camioneta agricola	\N	2025-12-07 06:30:42.904079+00
68	Cisterna	\N	2025-12-07 06:30:42.904079+00
69	Furgon	\N	2025-12-07 06:30:42.904079+00
70	Mototaxi	\N	2025-12-07 06:30:42.904079+00
71	Microbus	\N	2025-12-07 06:30:42.904079+00
72	Motobicicleta	\N	2025-12-07 06:30:42.904079+00
73	Plataforma	\N	2025-12-07 06:30:42.904079+00
74	Panel	\N	2025-12-07 06:30:42.904079+00
75	Unidad de PROVIAL	\N	2025-12-07 06:30:42.904079+00
76	Gr??a	\N	2025-12-07 06:30:42.904079+00
77	Bus institucional	\N	2025-12-07 06:30:42.904079+00
78	Cuatrimoto	\N	2025-12-07 06:30:42.904079+00
79	Doble remolque	\N	2025-12-07 06:30:42.904079+00
80	Tesla	\N	2025-12-07 06:30:42.904079+00
81	Peaton	\N	2025-12-07 06:30:42.904079+00
82	Fugado	\N	2025-12-07 06:30:42.904079+00
83	Sedan	\N	2025-12-07 06:30:42.904079+00
84	Pick-up	\N	2025-12-07 06:30:42.904079+00
85	Cami??n	\N	2025-12-07 06:30:42.904079+00
86	Bus	\N	2025-12-07 06:30:42.904079+00
87	Cabezal	\N	2025-12-07 06:30:42.904079+00
88	Otro	\N	2025-12-07 06:30:42.904079+00
90	Jaula Cañera	\N	2025-12-09 23:09:41.779421+00
113	Grúa	\N	2025-12-09 23:09:41.779421+00
122	Camión	\N	2025-12-09 23:09:41.779421+00
\.


--
-- Data for Name: tripulacion_turno; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.tripulacion_turno (id, asignacion_id, usuario_id, rol_tripulacion, presente, observaciones, created_at, telefono_contacto, es_comandante) FROM stdin;
35	34	38	PILOTO	t	\N	2025-12-15 06:40:45.659138+00	\N	f
41	38	20	PILOTO	t	\N	2025-12-15 18:52:52.4022+00	\N	f
42	38	28	COPILOTO	t	\N	2025-12-15 18:52:52.4022+00	\N	f
43	38	329	ACOMPAÑANTE	t	\N	2025-12-15 18:52:52.4022+00	\N	f
44	38	73	ACOMPAÑANTE	t	\N	2025-12-15 18:52:52.4022+00	\N	f
45	39	20	PILOTO	t	\N	2025-12-17 15:46:01.043934+00	\N	f
46	40	448	PILOTO	t	\N	2025-12-29 19:00:04.462774+00	\N	f
47	40	531	COPILOTO	t	\N	2025-12-29 19:00:04.462774+00	\N	f
48	41	33	PILOTO	t	\N	2025-12-29 19:53:38.417735+00	\N	f
\.


--
-- Data for Name: turno; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.turno (id, fecha, estado, observaciones, creado_por, aprobado_por, fecha_aprobacion, created_at, updated_at, fecha_fin, publicado, fecha_publicacion, publicado_por, sede_id) FROM stdin;
9	2025-12-07	ACTIVO	\N	15	\N	\N	2025-12-07 06:30:43.722975+00	2025-12-07 06:30:43.722975+00	\N	f	\N	\N	\N
10	2025-12-08	ACTIVO	\N	13	\N	\N	2025-12-08 22:19:25.970794+00	2025-12-08 22:19:25.970794+00	\N	f	\N	\N	\N
12	2025-12-10	PLANIFICADO	\N	14	\N	\N	2025-12-09 22:44:06.217679+00	2025-12-09 22:44:06.217679+00	\N	f	\N	\N	\N
27	2025-12-16	PLANIFICADO	\N	151	\N	\N	2025-12-15 06:40:45.608041+00	2025-12-15 06:59:52.87538+00	\N	f	\N	\N	7
28	2025-12-18	PLANIFICADO	\N	212	\N	\N	2025-12-17 15:46:00.997669+00	2025-12-17 15:46:00.997669+00	\N	f	\N	\N	1
30	2025-12-29	ACTIVO	\N	121	\N	\N	2025-12-29 19:00:04.462774+00	2025-12-29 19:00:04.462774+00	\N	f	\N	\N	1
32	2025-12-29	PLANIFICADO	Turno de prueba API	33	\N	\N	2025-12-29 19:53:38.417735+00	2025-12-29 19:53:38.417735+00	\N	f	\N	\N	7
\.


--
-- Data for Name: ubicacion_brigada; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.ubicacion_brigada (id, usuario_id, asignacion_origen_id, unidad_origen_id, unidad_actual_id, asignacion_actual_id, estado, punto_fijo_km, punto_fijo_sentido, punto_fijo_ruta_id, punto_fijo_latitud, punto_fijo_longitud, punto_fijo_descripcion, situacion_persistente_id, inicio_ubicacion, fin_ubicacion, creado_por, motivo, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: unidad; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.unidad (id, codigo, tipo_unidad, marca, modelo, anio, placa, sede_id, activa, created_at, updated_at, combustible_actual, capacidad_combustible, odometro_actual, custom_fields) FROM stdin;
341	1109	PICK-UP	Toyota	2019	\N	P1109XX	7	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	130000.00	{}
342	1110	PICK-UP	Toyota	2020	\N	P1110XX	3	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	110000.00	{}
343	1111	PICK-UP	Toyota	2018	\N	P1111XX	9	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	155000.00	{}
344	1112	PICK-UP	Toyota	2021	\N	P1112XX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	75000.00	{}
345	1113	PICK-UP	Toyota	2019	\N	P1113XX	9	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	125000.00	{}
346	1114	PICK-UP	Toyota	2020	\N	P1114XX	9	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	105000.00	{}
347	1115	PICK-UP	Toyota	2018	\N	P1115XX	6	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	165000.00	{}
348	1116	PICK-UP	Toyota	2021	\N	P1116XX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	70000.00	{}
349	1117	PICK-UP	Toyota	2019	\N	P1117XX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	135000.00	{}
350	1118	PICK-UP	Toyota	2020	\N	P1118XX	6	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	115000.00	{}
351	1119	PICK-UP	Toyota	2018	\N	P1119XX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	170000.00	{}
352	1120	PICK-UP	Toyota	2021	\N	P1120XX	3	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	65000.00	{}
353	1121	PICK-UP	Toyota	2019	\N	P1121XX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	140000.00	{}
354	1122	PICK-UP	Toyota	2020	\N	P1122XX	6	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	108000.00	{}
355	1123	PICK-UP	Toyota	2018	\N	P1123XX	3	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	175000.00	{}
356	1124	PICK-UP	Toyota	2021	\N	P1124XX	6	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	72000.00	{}
357	1125	PICK-UP	Toyota	2019	\N	P1125XX	5	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	145000.00	{}
358	1126	PICK-UP	Toyota	2020	\N	P1126XX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	112000.00	{}
359	1127	PICK-UP	Toyota	2018	\N	P1127XX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	180000.00	{}
360	1128	PICK-UP	Toyota	2021	\N	P1128XX	3	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	68000.00	{}
361	1129	PICK-UP	Toyota	2019	\N	P1129XX	2	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	150000.00	{}
362	1130	PICK-UP	Toyota	2020	\N	P1130XX	8	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	118000.00	{}
363	1131	PICK-UP	Toyota	2018	\N	P1131XX	8	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	185000.00	{}
364	1132	PICK-UP	Toyota	2021	\N	P1132XX	3	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	60000.00	{}
402	026	PICK-UP	Toyota	2020	\N	P026XXX	7	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	82000.00	{}
403	027	PICK-UP	Toyota	2019	\N	P027XXX	7	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	132000.00	{}
404	028	PICK-UP	Toyota	2021	\N	P028XXX	8	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	55000.00	{}
405	029	PICK-UP	Toyota	2018	\N	P029XXX	2	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	185000.00	{}
406	030	PICK-UP	Toyota	2020	\N	P030XXX	1	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	78000.00	{}
365	1133	PICK-UP	Toyota	2019	\N	P1133XX	8	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	155000.00	{}
366	1134	PICK-UP	Toyota	2020	\N	P1134XX	6	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	122000.00	{}
367	1135	PICK-UP	Toyota	2018	\N	P1135XX	6	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	190000.00	{}
368	1137	PICK-UP	Toyota	2021	\N	P1137XX	3	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	55000.00	{}
369	1138	PICK-UP	Toyota	2019	\N	P1138XX	7	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	160000.00	{}
370	1139	PICK-UP	Toyota	2020	\N	P1139XX	9	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	125000.00	{}
371	1170	CAMIONETA	Toyota	2020	\N	P1170XX	8	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	95000.00	{}
372	1171	CAMIONETA	Toyota	2021	\N	P1171XX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	85000.00	{}
373	1172	CAMIONETA	Toyota	2019	\N	P1172XX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	105000.00	{}
374	1173	CAMIONETA	Toyota	2020	\N	P1173XX	3	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	90000.00	{}
375	1174	CAMIONETA	Toyota	2021	\N	P1174XX	2	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	80000.00	{}
376	1175	CAMIONETA	Toyota	2019	\N	P1175XX	3	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	110000.00	{}
377	1176	CAMIONETA	Toyota	2020	\N	P1176XX	7	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	88000.00	{}
380	004	PICK-UP	Toyota	2021	\N	P004XXX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	75000.00	{}
381	005	PICK-UP	Toyota	2018	\N	P005XXX	6	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	150000.00	{}
382	006	PICK-UP	Toyota	2020	\N	P006XXX	2	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	95000.00	{}
383	007	PICK-UP	Toyota	2019	\N	P007XXX	5	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	115000.00	{}
329	M001	MOTOCICLETA	Toyota	2020	\N	M001XXX	2	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	10000.00	{}
330	M002	MOTOCICLETA	Toyota	2021	\N	M002XXX	3	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	8000.00	{}
331	M003	MOTOCICLETA	Toyota	2019	\N	M003XXX	7	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	15000.00	{}
332	M004	MOTOCICLETA	Toyota	2022	\N	M004XXX	6	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	5000.00	{}
333	M005	MOTOCICLETA	Toyota	2020	\N	M005XXX	6	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	12000.00	{}
334	M006	MOTOCICLETA	Toyota	2021	\N	M006XXX	5	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	9000.00	{}
335	M007	MOTOCICLETA	Toyota	2022	\N	M007XXX	1	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	3000.00	{}
336	1104	PICK-UP	Toyota	2018	\N	P1104XX	6	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	150000.00	{}
337	1105	PICK-UP	Toyota	2019	\N	P1105XX	2	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	120000.00	{}
338	1106	PICK-UP	Toyota	2020	\N	P1106XX	2	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	100000.00	{}
339	1107	PICK-UP	Toyota	2018	\N	P1107XX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	160000.00	{}
340	1108	PICK-UP	Toyota	2021	\N	P1108XX	1	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	80000.00	{}
384	008	PICK-UP	Toyota	2021	\N	P008XXX	5	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	70000.00	{}
385	009	PICK-UP	Toyota	2018	\N	P009XXX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	160000.00	{}
386	010	PICK-UP	Toyota	2020	\N	P010XXX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	98000.00	{}
387	011	PICK-UP	Toyota	2019	\N	P011XXX	6	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	118000.00	{}
388	012	PICK-UP	Toyota	2021	\N	P012XXX	5	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	68000.00	{}
389	013	PICK-UP	Toyota	2018	\N	P013XXX	4	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	165000.00	{}
390	014	PICK-UP	Toyota	2020	\N	P014XXX	7	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	92000.00	{}
379	003	PICK-UP	Toyota	2019	\N	P003XXX	8	t	2025-12-07 06:30:42.70216+00	2025-12-31 22:08:15.722756+00	100.00	100.00	120000.00	{}
391	015	PICK-UP	Toyota	2019	\N	P015XXX	8	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	122000.00	{}
392	016	PICK-UP	Toyota	2021	\N	P016XXX	5	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	65000.00	{}
393	017	PICK-UP	Toyota	2018	\N	P017XXX	5	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	170000.00	{}
394	018	PICK-UP	Toyota	2020	\N	P018XXX	5	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	88000.00	{}
395	019	PICK-UP	Toyota	2019	\N	P019XXX	9	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	125000.00	{}
396	020	PICK-UP	Toyota	2021	\N	P020XXX	8	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	62000.00	{}
397	021	PICK-UP	Toyota	2018	\N	P021XXX	6	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	175000.00	{}
398	022	PICK-UP	Toyota	2020	\N	P022XXX	3	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	85000.00	{}
399	023	PICK-UP	Toyota	2019	\N	P023XXX	3	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	128000.00	{}
400	024	PICK-UP	Toyota	2021	\N	P024XXX	7	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	58000.00	{}
401	025	PICK-UP	Toyota	2018	\N	P025XXX	5	t	2025-12-07 06:30:42.70216+00	2025-12-08 20:34:07.016518+00	100.00	100.00	180000.00	{}
407	Peatonal	PEATONAL	Toyota	\N	\N	\N	4	f	2025-12-07 06:30:42.70216+00	2025-12-31 22:08:40.680662+00	100.00	100.00	0.00	{}
378	002	PICKUP	Toyota	2020	\N	P002XXX	1	t	2025-12-07 06:30:42.70216+00	2026-01-03 07:51:15.626551+00	100.00	100.00	100000.00	{}
\.


--
-- Data for Name: usuario; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.usuario (id, uuid, username, password_hash, nombre_completo, email, telefono, rol_id, sede_id, activo, ultimo_acceso, created_at, updated_at, grupo, fecha_inicio_ciclo, acceso_app_activo, exento_grupos, chapa, rol_brigada, puede_ver_todas_sedes, genero, sub_rol_cop_id, es_encargado_grupo, password_reset_required, password_last_reset, password_reset_by, password_reset_enabled_at, custom_fields, reset_password_enabled) FROM stdin;
293	f0204a8b-28fa-4b14-818b-2b4333d6ad49	17022	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Divas Anavisca Carla Yohana	\N	\N	3	1	t	2025-12-31 22:51:20.467443+00	2025-12-07 06:32:57.885741+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	17022	\N	f	FEMENINO	4	f	f	\N	\N	\N	{}	f
222	d83cae24-0a04-43fe-b4cc-0ca2ec2025b0	16057	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Florián Morán, Luis Fernando	\N	\N	3	1	t	\N	2025-12-07 06:32:57.61101+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	16057	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
358	d73e18b9-c139-4110-9bde-06253e6bedc1	18047	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Madelin Ivania Revolorio Orantes	\N	\N	3	1	t	\N	2025-12-07 06:32:59.724063+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	18047	\N	f	FEMENINO	4	f	f	\N	\N	\N	{}	f
1852	5d23a744-2fcf-48ff-a6b1-015aaa8c7d34	admin.test	$2a$10$uuuesh8giy09pDq9Gp8puOxT5XV83MwJHN5Ue2xTitLiMEAKs90MK	Usuario Admin	\N	\N	1	1	t	2026-01-03 07:14:00.289989+00	2026-01-03 05:13:39.073793+00	2026-01-03 07:14:00.289989+00	\N	\N	t	f	\N	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
1854	cbc74c5a-689b-4b34-be96-38caabeca84e	mandos	$2a$10$uuuesh8giy09pDq9Gp8puOxT5XV83MwJHN5Ue2xTitLiMEAKs90MK	Usuario Mandos	\N	\N	6	1	t	2026-01-03 08:16:33.52563+00	2026-01-03 05:13:39.129038+00	2026-01-03 08:16:33.52563+00	\N	\N	t	f	\N	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
1853	36cffc08-e972-4adb-9c86-e54bab0b8441	accidentologia	$2a$10$uuuesh8giy09pDq9Gp8puOxT5XV83MwJHN5Ue2xTitLiMEAKs90MK	Usuario Accidentología	\N	\N	5	1	t	2026-01-03 08:17:26.168751+00	2026-01-03 05:13:39.120912+00	2026-01-03 08:17:26.168751+00	\N	\N	t	f	\N	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
66	b6286402-4a12-4b40-98af-8f4d5a9da972	10013	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gonzales Cardona Luis Alberto	\N	\N	3	7	t	\N	2025-12-07 06:32:55.107343+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	10013	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
430	43eb8a53-cb0a-44f2-8508-58d1cd2504bc	19065	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gómez Sales Baudilio	\N	\N	3	7	t	\N	2025-12-07 06:33:00.060121+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19065	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
33	4046f1ed-eccc-4353-867a-ff01cc7b0e09	4028	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Laj Tecu Juan Antonio	\N	\N	3	7	t	2025-12-29 19:46:57.506162+00	2025-12-07 06:32:54.956062+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	4028	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
1855	0d89208e-2d20-4bb5-9330-e361afef6196	cop.test	$2a$10$Uo.Yd/IEyQC2lGtzipHabehN7lqccZHPvPje1irf5os0MUxkvQ3pO	Usuario COP Pruebas	\N	\N	2	1	t	2026-01-03 07:52:04.177085+00	2026-01-03 05:29:43.37419+00	2026-01-03 07:52:04.177085+00	\N	\N	t	f	\N	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
411	b429ef39-bc5a-4283-b34c-457b0e903157	19046	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Florián Vásquez, José Manuel	\N	\N	3	7	t	\N	2025-12-07 06:32:59.981888+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19046	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
491	d7d502a7-ea19-47c0-aac7-95107f062c24	19126	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pop Xé, Maurilio	\N	\N	3	7	t	\N	2025-12-07 06:33:00.228297+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19126	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
500	976c3883-576e-41d0-a11b-579bcd1c4fd1	19135	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Retana Cardona, Jhonatan Guillermo	\N	\N	3	7	t	\N	2025-12-07 06:33:00.290851+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19135	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
324	108e00c0-a5c9-4d75-91b1-4e623467dfb1	18013	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Chapas Gonzáles, Catherin Yanira	\N	\N	3	1	t	\N	2025-12-07 06:32:57.969987+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	18013	\N	f	FEMENINO	4	f	f	\N	\N	\N	{}	f
396	63ac21e6-38fa-43a8-b620-41d004e865bb	19031	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Corado Morán, Edgar Antonio	\N	\N	3	1	t	\N	2025-12-07 06:32:59.916243+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	19031	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
413	7d3290c2-e79a-4afd-b308-cec174068032	19048	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Franco Herrera, Alma Yaneth	\N	\N	3	1	t	\N	2025-12-07 06:32:59.984352+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	19048	\N	f	FEMENINO	4	f	f	\N	\N	\N	{}	f
449	42a68750-f8b7-40d2-8a63-fb3b53c2f2ee	19084	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Latin Bernal, Sandy Esperanza	\N	\N	3	1	t	\N	2025-12-07 06:33:00.079191+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	19084	\N	f	FEMENINO	4	f	f	\N	\N	\N	{}	f
456	4baf54b8-5dbb-4c34-9d55-95630f9c3c28	19091	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Lopez Jimenez, Jesfri Omar	\N	\N	3	1	t	\N	2025-12-07 06:33:00.086452+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	19091	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
465	8e74946a-579c-431e-8a5c-c1f3bd4cf11b	19100	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Maroquin Orozco, Iris Madai	\N	\N	3	1	t	\N	2025-12-07 06:33:00.096321+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	19100	\N	f	FEMENINO	4	f	f	\N	\N	\N	{}	f
433	efcbf56d-c558-450b-b68b-be8f7d9db58a	19068	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	González Alvarado, Lestid Eliazar	\N	\N	3	1	t	2025-12-11 19:02:23.880209+00	2025-12-07 06:33:00.063113+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	19068	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
445	c172b187-d14e-4db4-affa-ecceeecc8968	19080	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Isidro Baltazar Adolfo Angel	\N	\N	3	1	t	\N	2025-12-07 06:33:00.075074+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	19080	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
143	c12cb14a-66a1-4905-a7b6-f384762c4103	15041	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Estrada Morales, Carlos Leonel	\N	\N	3	1	t	2025-12-31 00:54:32.309048+00	2025-12-07 06:32:57.27286+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	15041	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
1856	3ea85022-9ec9-418a-8271-f231673e9b4b	cop.admin	$2a$10$nv7IgyPxPB99941eIrGMiOFPmRUcQegVkkVnfN50WyC4pseEIvapO	Administrador COP	\N	\N	2	1	t	\N	2026-01-03 08:27:17.627226+00	2026-01-03 08:27:17.627226+00	\N	\N	t	f	\N	\N	t	\N	\N	f	f	\N	\N	\N	{}	f
503	1dbab8c0-7cf7-4855-b814-24c0f4ef2d6d	19138	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Reyes Ortiz, Victor Daniel	\N	\N	3	7	t	\N	2025-12-07 06:33:00.295169+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19138	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
531	1ef2a528-d3ba-4521-ae74-7ea221bd54ba	19166	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Aury Ayendy Velásquez Dominguez	\N	\N	3	1	t	\N	2025-12-07 06:33:00.376243+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19166	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
448	274f09e6-943f-4397-ad74-8e96d2ce39c8	19083	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Jui Alvarado Hugo Leonel	\N	\N	3	1	t	2025-12-29 18:02:50.225834+00	2025-12-07 06:33:00.077999+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19083	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
568	ed8f9943-dfff-474e-8e3a-46f1c34afdc2	19109	$2a$10$Xk81wdlle8YfZsrmUJHxH.dBNflz6NU7EYwafGMHhYNqQv6Zf2R.u	Morales Mejía, Yair Alexander	\N	\N	10	1	t	2026-01-03 23:45:24.056795+00	2025-12-10 16:11:45.720995+00	2026-01-03 23:45:24.056795+00	1	\N	t	f	19109	\N	f	MASCULINO	1	f	f	\N	\N	\N	{}	f
370	ee542b0a-2416-4662-8e27-b490d4caf2f3	19005	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Alvarez Hernandez, Domingo Bayron	\N	\N	3	2	t	\N	2025-12-07 06:32:59.786441+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19005	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
306	d4443f3e-7abf-42d0-95fa-877538efc2c8	17045	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramirez Chapas Antony Mateus	\N	\N	3	1	t	2025-12-30 23:56:20.552696+00	2025-12-07 06:32:57.94757+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	17045	\N	f	MASCULINO	1	f	f	\N	\N	\N	{}	f
121	d777f1e7-aaba-439d-b87a-6709ebc6effe	15005	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Argueta Sandoval, Delmi Odíly	\N	\N	3	1	t	2025-12-31 05:02:15.156698+00	2025-12-07 06:32:57.150814+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	15005	\N	f	FEMENINO	4	f	f	\N	\N	\N	{}	f
247	c76bda68-5155-4ce2-aa81-271aa0963dee	16100	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Menchú Anavisca, Hilmy Julissa	\N	\N	3	1	t	2025-12-31 00:47:15.132079+00	2025-12-07 06:32:57.686461+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	16100	\N	f	FEMENINO	2	f	f	\N	\N	\N	{}	f
1857	36936a62-6a2b-45f2-a5ee-21ae72d5cfe4	mandos.test	$2a$10$zEI80ChOnBg/h78lNpK93.8PP0ePG9JxYxK0H8y3rw5UC4V7c6MKm	Usuario Mandos Test	\N	\N	6	1	t	\N	2026-01-03 08:33:02.074272+00	2026-01-03 08:33:02.074272+00	\N	\N	t	f	\N	\N	t	\N	\N	f	f	\N	\N	\N	{}	f
1858	9c25e4ca-f212-40e3-aa4a-96814afbb9ac	accidentologia.test	$2a$10$19KKHoczq3qyNmVxtu1f7ei5f1l1F1Xc7NDIgz2GE1FrD5f8X51Ii	Usuario Accidentologia Test	\N	\N	5	1	t	\N	2026-01-03 08:33:02.169369+00	2026-01-03 08:33:02.169369+00	\N	\N	t	f	\N	\N	t	\N	\N	f	f	\N	\N	\N	{}	f
1859	0c4adb85-f580-4f6f-9aa7-7eaec3f7f2ab	comunicacion.test	$2a$10$X.MWurKpAEZd02ba8K6b6eqTAILlfgOy1diW.OhtqMXe2DCqpsjvq	Usuario Comunicacion Social Test	\N	\N	11	1	t	\N	2026-01-03 08:33:02.31186+00	2026-01-03 08:33:02.31186+00	\N	\N	t	f	\N	\N	t	\N	\N	f	f	\N	\N	\N	{}	f
367	d2c65557-462c-4704-a1a4-57bfff213977	19002	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Aguilón Pérez, Juan Orlando	\N	\N	3	5	t	\N	2025-12-07 06:32:59.781717+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19002	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
52	4c379f33-263e-4eed-8640-fe214ff71128	8003	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Arrivillaga Oliva, Edgar Geovanni	\N	\N	3	8	t	\N	2025-12-07 06:32:55.040829+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	8003	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
366	fa4d68e1-eaf8-423e-88f3-603bbee683d8	19001	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Aguilar Melgar, Angel Humberto	\N	\N	3	4	t	\N	2025-12-07 06:32:59.780602+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19001	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
131	c2adbc1a-7da4-45a2-8728-fd27370064be	15021	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cermeño Barahona, Wilsson Israel	\N	\N	3	1	t	2025-12-15 17:43:42.104031+00	2025-12-07 06:32:57.159809+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15021	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
566	1e09445d-8fbe-4a3f-bc77-f1868f32f21c	operador	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Operador Pruebas	\N	\N	4	1	f	2025-12-09 14:49:30.268275+00	2025-12-08 19:52:00.688912+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	\N	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
86	2da3b52f-d6f6-43cd-89bb-2fc72f59f377	12003	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Carias Zuñiga, Walfre Oswaldo	\N	\N	3	1	t	\N	2025-12-07 06:32:55.17717+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	12003	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
90	55a2dae8-8579-450c-9c03-2f6b40c7832c	12018	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Mendoza Zelada, Marvín Emanuel	\N	\N	3	1	t	\N	2025-12-07 06:32:55.180448+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	12018	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
176	f130c4a6-4ea4-4ea6-8533-f9e8f5cb6570	15096	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Orellana González, Leonel Enrique	\N	\N	3	1	t	\N	2025-12-07 06:32:57.462808+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15096	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
125	85b0a431-b806-44e5-92d1-da6b04445835	15012	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Barrera Rodríguez, Félix Daniel	\N	\N	3	1	t	\N	2025-12-07 06:32:57.154471+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15012	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
136	767e6814-8667-496d-a995-7b1127216bcb	15027	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Colop Xec, Abelardo Abigaíl	\N	\N	3	1	t	\N	2025-12-07 06:32:57.215918+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15027	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
183	8cc19b08-accf-45a0-a060-ed8dbee2f377	15103	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pérez Pérez, José Emedardo	\N	\N	3	1	t	\N	2025-12-07 06:32:57.471207+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15103	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
132	f12f786c-9f4f-4177-bbcf-d7aca0081d4b	15022	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cermeño Barrios, Edgar Alfonso	\N	\N	3	1	t	\N	2025-12-07 06:32:57.160632+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15022	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
320	560fb054-fe56-40c4-8306-54954f844ca7	18009	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cal Cal, Edgar Daniel	\N	\N	3	9	t	\N	2025-12-07 06:32:57.96335+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18009	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
149	7227703c-5987-4f4c-a1fb-8cb636091025	15051	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gómez Aceytuno, Manuel Estuardo	\N	\N	3	1	t	\N	2025-12-07 06:32:57.325431+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15051	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
154	215a26f1-1b1a-48b7-a714-f89a5b9e9cd2	15062	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández Fajardo, Rufino David	\N	\N	3	1	t	\N	2025-12-07 06:32:57.336762+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15062	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
218	9abf1155-7f3e-4fdc-8f87-636683337f66	16048	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Escobar Beltrán, Marlon Geobany	\N	\N	3	1	t	\N	2025-12-07 06:32:57.607178+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16048	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
253	df2c8e44-d4b8-4b59-b158-b990d78a01d9	16107	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morán Cazún, Mynor Armando	\N	\N	3	1	t	\N	2025-12-07 06:32:57.692692+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16107	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
321	bdd5c1d5-e03d-4941-9591-3b1ddbe1b674	18010	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Campos González, Rony Emilio	\N	\N	3	1	t	\N	2025-12-07 06:32:57.964569+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18010	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
323	88f7c0a0-723e-492e-b990-a38f58e492c8	18012	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Castillo Herrera, Dony Isidro	\N	\N	3	1	t	\N	2025-12-07 06:32:57.96821+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18012	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
155	78eefceb-a506-4ca3-b411-fa0bc61499fd	15063	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández Y Hernández, Edwin Rolando	\N	\N	3	6	t	\N	2025-12-07 06:32:57.337562+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15063	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
211	2909b4cf-db68-4392-9fce-578540830886	16033	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cojom Damian, Emanuel Isaías	\N	\N	3	6	t	\N	2025-12-07 06:32:57.552679+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16033	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
341	9cfbae7f-6a1f-4215-9a33-efaf029b9a6e	18030	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández Castillo, Ahiderson André	\N	\N	3	1	t	\N	2025-12-07 06:32:59.644932+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18030	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
380	7a74423f-acb1-4e8c-a644-1e9f7dfc196f	19015	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Batres Hernández, Denilson Ottoniel	\N	\N	3	1	t	\N	2025-12-07 06:32:59.846688+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19015	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
381	d6d670da-477b-4bc5-9d4e-6f429a9f444b	19016	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cabrera Alfaro, Carlos Alfonso	\N	\N	3	1	t	\N	2025-12-07 06:32:59.848313+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19016	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
391	f23f4a52-73d9-4122-9771-b0c743071ce9	19026	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cazún Zepeda, María Concepción	\N	\N	3	1	t	\N	2025-12-07 06:32:59.859656+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19026	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
406	1ee5ca5f-d602-4fc1-ae54-536313c21070	19041	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Donis Alfaro, María Celeste	\N	\N	3	1	t	2025-12-15 06:19:44.814403+00	2025-12-07 06:32:59.92838+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19041	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
412	ba4c0722-ddde-4c8c-ac2f-576733f662bb	19047	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Florián Vásquez, José Rolando	\N	\N	3	1	t	\N	2025-12-07 06:32:59.983239+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19047	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
421	f3a6ffcc-b3a4-49b1-837d-8f355ec7798b	19056	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	García Granados, Edilson Esaul	\N	\N	3	1	t	\N	2025-12-07 06:32:59.993907+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19056	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
423	c5d97c86-2329-441f-b16c-e925edfaea07	19058	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Garcia Peréz, Lucas Fernando	\N	\N	3	1	t	\N	2025-12-07 06:32:59.995836+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19058	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
424	5f7e0762-6ea9-4e1b-ab77-5fbd8b0d7ab3	19059	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	García Pineda, Amner Estuardo	\N	\N	3	1	t	\N	2025-12-07 06:32:59.996666+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19059	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
428	5eabad13-87da-451a-bcdb-01f6c8454c2d	19063	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Garza Godoy, Katerin Dalila	\N	\N	3	1	t	\N	2025-12-07 06:33:00.002358+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19063	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
435	b6df903c-2491-4350-876b-da505501ed83	19070	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	González Jiménez, Elman Ivan	\N	\N	3	1	t	\N	2025-12-07 06:33:00.064787+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19070	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
441	6fda933a-8da5-442c-9188-04c8aad686dc	19076	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández Salguero, Karen Gemima	\N	\N	3	1	t	\N	2025-12-07 06:33:00.071298+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19076	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
454	02744422-572e-4851-ae9f-1ce02ddc47ca	19089	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	López Alvarez, Lusbin Guadalupe	\N	\N	3	1	t	\N	2025-12-07 06:33:00.084379+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19089	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
475	6d74cb6e-88ca-4c6a-be15-177a48f89950	19110	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Najarro Barillas, Otilia Yesenia	\N	\N	3	1	t	\N	2025-12-07 06:33:00.157713+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19110	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
498	2c893adb-49eb-48b6-9890-300947ecc3ed	19133	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramirez Santos Willian Estuardo	\N	\N	3	1	t	\N	2025-12-07 06:33:00.238648+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19133	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
527	9220eee0-9086-4b6c-ad62-6071ee3cd0a1	19162	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Vásquez Domínguez, Manolo Exzequiel	\N	\N	3	1	t	\N	2025-12-07 06:33:00.370544+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19162	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
528	d5763e8f-cf86-4c5c-8b03-15ea61e33cff	19163	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Vásquez Gonzalez, Edilson Romario	\N	\N	3	1	t	\N	2025-12-07 06:33:00.371532+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19163	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
58	83bf79f6-2293-4749-89eb-9241b32ea6c2	9005	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Quiñonez Hernandez, Edwing Orlando	\N	\N	3	1	t	\N	2025-12-07 06:32:55.099346+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	9005	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
535	dcea6fae-e39d-44b4-ab09-3f50f0c59c04	19170	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Xoná Ajanel, Darwin Abelino	\N	\N	3	1	t	\N	2025-12-07 06:33:00.428942+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19170	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
536	189546ef-2657-4c58-b27b-a2ba13d80948	19171	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Zamora Cabrera, José Luis	\N	\N	3	1	t	\N	2025-12-07 06:33:00.42979+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19171	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
73	fb6c4f02-e249-490a-a77c-5f1af5b7f67c	11002	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Albisures García, Juan Carlos	\N	\N	3	1	t	\N	2025-12-07 06:32:55.114681+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	11002	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
224	3a67e27a-7ad7-4c00-9006-d33532f314f8	16061	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gaitán Cruz, Juan José	\N	\N	3	7	t	\N	2025-12-07 06:32:57.612552+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16061	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
151	36276114-9f77-4025-beae-d62155ac7d6b	15056	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	González García, Brayan Josué	\N	54337385	3	7	t	2025-12-15 17:37:28.644902+00	2025-12-07 06:32:57.333827+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	15056	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
95	afc02813-0172-40d0-be39-f18a4eef8f12	12026	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Quiná Simon, Marvin Dinael	\N	\N	3	1	t	\N	2025-12-07 06:32:55.235755+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	12026	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
105	16822e96-218a-4fac-bf0f-5289542702d8	13036	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Retana Valladares, Horacio Fabricio	\N	\N	3	7	t	\N	2025-12-07 06:32:55.572088+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	13036	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
191	93ca72d4-6168-4dce-9ae1-32665a2f6dbd	15128	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Santacruz Salazar, Ludbin Obel	\N	\N	3	7	t	\N	2025-12-07 06:32:57.479245+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15128	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
242	3b10be6f-099d-4725-9a8e-270fe8a8d963	16092	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	López Morales, Mario Samuel	\N	\N	3	5	t	\N	2025-12-07 06:32:57.680916+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16092	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
216	cbc3362e-36bd-4f0d-b42d-7007496d1a4f	16042	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	De La Rosa Monterroso, Manuel De Jesús	\N	\N	3	7	t	\N	2025-12-07 06:32:57.605165+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16042	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
487	6efdd7fe-5629-458f-977b-f10312347369	19122	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pérez Ramírez Elfido Miguel	\N	\N	3	5	t	\N	2025-12-07 06:33:00.222273+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19122	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
229	aa1a0d90-27c8-4169-83fb-a7143b844aa7	16070	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	González Ríos, Walfred David Alexander	\N	\N	3	7	t	\N	2025-12-07 06:32:57.617551+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16070	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
246	e3e1456c-2723-47e3-a891-bb70471d340f	16097	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Martínez Arévalo, Noé De Jesús	\N	\N	3	7	t	\N	2025-12-07 06:32:57.685545+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16097	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
330	b3e674ea-f77a-4291-a6d9-ce6502e0bb37	18019	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	De Leon Alvarado Cesar Alejandro	\N	\N	3	7	t	\N	2025-12-07 06:32:58.317034+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18019	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
332	3aa489e4-32df-4bf9-b98c-23394de2edea	18021	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Díaz Chan, Josue David	\N	\N	3	7	t	\N	2025-12-07 06:32:58.51475+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18021	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
79	91859fd8-9fd6-453b-a9f1-8d0d1bc0fc07	11024	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Juarez Sanchez, Edwin Antonio	\N	\N	3	1	t	\N	2025-12-07 06:32:55.169127+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	11024	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
200	c8f9a047-962f-4c7d-9751-63503831219a	16008	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Belloso Peñate Karen Jeannette	\N	\N	3	1	t	\N	2025-12-07 06:32:57.539634+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	16008	\N	f	FEMENINO	4	f	f	\N	\N	\N	{}	f
483	848d5249-ea04-446d-b1e7-2c2ffcae04a6	19118	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pérez Arias, Axel René	\N	\N	3	7	t	\N	2025-12-07 06:33:00.169252+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19118	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
56	8808529a-5cad-4a48-93ce-6a0bac4e1fb4	8044	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Santizo Pérez, Juan Antonio	\N	\N	3	4	t	\N	2025-12-07 06:32:55.097387+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	8044	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
42	b2f8fbe8-dff1-4d0c-92a7-657aba703b52	5041	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Reyes Sacul Cupertino	\N	\N	3	4	t	\N	2025-12-07 06:32:55.027657+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	5041	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
153	1400b363-c771-4241-95a1-c982c00016f9	15061	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Guzmán Lemus, Erick Randolfo	\N	\N	3	4	t	\N	2025-12-07 06:32:57.335934+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15061	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
220	1cebec09-85cf-444e-83a9-bb724ed20002	16052	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Escobar García, Kevin Alfredo	\N	\N	3	4	t	\N	2025-12-07 06:32:57.609064+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16052	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
255	da6f264f-271b-4084-8812-98b42b131d35	16113	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Orellana Estrada, Jesús Emilio	\N	\N	3	4	t	\N	2025-12-07 06:32:57.744902+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16113	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
301	13f6ab93-af73-4ec4-a700-4a4135cb70cb	17036	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Najarro Barillas, Elvia Dalila	\N	\N	3	4	t	\N	2025-12-07 06:32:57.89274+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	17036	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
319	7c1c46f4-9efb-4e42-90b3-436ef03f8253	18008	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Caál España, Astrid Melissa	\N	\N	3	4	t	\N	2025-12-07 06:32:57.961706+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18008	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
327	2af238be-cf4f-44f7-9eb3-cdf9f93483e1	18016	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cortez Sontay, Josselyne Anabella	\N	\N	3	4	t	\N	2025-12-07 06:32:58.070796+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18016	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
336	db45293f-80f4-4665-a5e0-bd7937517bfa	18025	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Garcia Garcia, Walter	\N	\N	3	4	t	\N	2025-12-07 06:32:58.905748+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18025	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
337	79c4071c-ed4b-4f42-bcea-6d7f74b27a41	18026	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Garrido Trabanino, Evelyn Nohelí	\N	\N	3	4	t	\N	2025-12-07 06:32:59.051683+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18026	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
340	26e99c77-d233-4581-b370-f7e1054b36f1	18029	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gudiel Gallardo Angeliz Amordi	\N	\N	3	4	t	\N	2025-12-07 06:32:59.496222+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18029	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
163	14a5eab5-b411-4136-b3d7-50332b0ad973	15075	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Martinez Brol, Anthony Steven	\N	\N	3	1	t	\N	2025-12-07 06:32:57.39696+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15075	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
384	7894367e-c0e4-400f-a4f7-49ce9f5a7642	19019	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Canahuí García, Helen Marisol	\N	\N	3	4	t	\N	2025-12-07 06:32:59.85241+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19019	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
395	301d52f2-6e7d-4be7-823c-3d827aa1e2e7	19030	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Corado Garza, Estéfany Melisa	\N	\N	3	4	t	\N	2025-12-07 06:32:59.913683+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19030	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
416	0b6aadf2-8efa-4cbd-8cc6-b341c8640141	19051	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Galicia Najarro, Gerson David	\N	\N	3	4	t	\N	2025-12-07 06:32:59.987762+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19051	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
32	b1158256-50e8-482b-88b0-cdec49386e98	4022	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gutierrez Chaclán, Fernando Norberto	\N	\N	3	2	t	\N	2025-12-07 06:32:54.955069+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	4022	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
51	611f98b6-49a7-464c-90db-2fb65694d22f	7058	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramirez Castillo, Remigio Alexander	\N	\N	3	2	t	\N	2025-12-07 06:32:55.038977+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	7058	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
62	c8bead72-819b-46c5-966c-18b879b4b57c	9019	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Orellana Paz, David Gerardo	\N	\N	3	2	t	\N	2025-12-07 06:32:55.102981+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	9019	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
85	60517f64-ad81-444d-90db-e93cd66ab6d4	12002	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Camas Andrade, Edwin José	\N	\N	3	2	t	\N	2025-12-07 06:32:55.175752+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	12002	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
150	60bfe8b2-5888-46ad-b609-cce656ab016b	15052	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gómez González, Wilfido Enrique	\N	\N	3	2	t	\N	2025-12-07 06:32:57.327612+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15052	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
561	743ea20b-1963-4233-b3a4-4d8144f431e6	24	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cetino Casimiro, Jeremias	\N	\N	3	3	f	\N	2025-12-07 06:33:00.507976+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	24	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
565	6f03020c-abee-4bac-884f-a461ea69e500	28	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morales Barrios, Juan Manuel	\N	\N	3	3	f	\N	2025-12-07 06:33:00.514332+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	28	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
169	e2d38031-a6e7-46bd-b4d1-0c4e8308118b	15083	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Miranda Barrios, Lester Waldemar	\N	\N	3	2	f	\N	2025-12-07 06:32:57.454049+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15083	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
171	eeb5ed9d-c656-4c96-89dd-240352bc12cb	15088	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morales Barrientos, Manglio Estiward	\N	\N	3	8	f	\N	2025-12-07 06:32:57.457196+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15088	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
207	3e6f06cf-59f8-4bc1-8f2a-9aaebc59086a	16020	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Castañon Rodríguez Estuardo Odely	\N	\N	3	7	f	\N	2025-12-07 06:32:57.548229+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16020	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
212	09e17999-d2a6-454c-8126-c74cf825e59d	16036	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Corado Corado, Jerzon Anibal	\N	\N	3	1	t	2025-12-17 15:41:32.008439+00	2025-12-07 06:32:57.553488+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	16036	\N	t	MASCULINO	\N	f	f	\N	\N	\N	{}	f
112	881a021a-19cb-4e2b-b58b-45bc5d071b2c	14015	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Martinez Anavisca, William Estuardo	\N	\N	3	1	t	\N	2025-12-07 06:32:56.474736+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	14015	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
106	bac558ac-be67-4b1e-a67c-7f89cd2788f8	13037	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Vasquez Rivera, Luis Miguel	\N	\N	3	1	t	\N	2025-12-07 06:32:55.727265+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	13037	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
135	2689cec1-2483-4861-a3b1-03fd7647394c	15026	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Chub Coc, Salvador	\N	\N	3	1	t	\N	2025-12-07 06:32:57.21435+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15026	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
194	727cc37a-75f2-4f41-91e7-c2ba925688ac	15134	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Valdez Martínez, Cristopher Obed	\N	\N	3	7	f	\N	2025-12-07 06:32:57.482368+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15134	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
99	967804c5-ba97-4d80-862b-b7c9b31cf910	13010	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernandez Pèrez, Josuè Daniel	\N	\N	3	2	t	\N	2025-12-07 06:32:55.242553+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	13010	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
144	4dab18d6-091a-4329-b3e1-c772abe4e33d	15044	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Fuentes García, Milton Danilo	\N	\N	3	2	t	\N	2025-12-07 06:32:57.273821+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15044	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
315	e3057037-ef61-47e3-8d2b-15b1d3899a92	18004	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Arévalo Florian, Paula Jimena	\N	\N	3	2	t	\N	2025-12-07 06:32:57.957577+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18004	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
477	5831ea95-608f-445d-85b0-0817f4bfa6ec	19112	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Navarro Vasquez Nancy Roxana	\N	\N	3	2	t	\N	2025-12-07 06:33:00.162547+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19112	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
379	0766137f-d8a4-47ad-8739-736e0522d66e	19014	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Barrios López, Axel Eberto	\N	\N	3	2	t	\N	2025-12-07 06:32:59.845592+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19014	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
495	852ff860-78b3-4e20-9b35-0355c9e14126	19130	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramírez Herrarte, Jenderly Andrea	\N	\N	3	2	t	\N	2025-12-07 06:33:00.23432+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19130	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
53	c6650dbf-d278-4caf-b137-3ddec6daba80	8012	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cuxil Xicay, Edwin Estuardo	\N	\N	3	5	t	\N	2025-12-07 06:32:55.094376+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	8012	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
130	a5be95f8-0135-4571-9dad-77a3c8e8524d	15019	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Carrillo García, Walter Aristides	\N	\N	3	5	t	\N	2025-12-07 06:32:57.15898+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15019	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
156	3876e4a7-dde5-49ca-9835-448ef910b009	15064	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Isaacs Peñate, Carlos Iván	\N	\N	3	5	t	\N	2025-12-07 06:32:57.338399+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15064	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
162	27db3e60-4d27-44ec-b676-3c2d13bb9d70	15074	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Marroquin Lopez, Edwin Fabio	\N	\N	3	1	f	\N	2025-12-07 06:32:57.39613+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15074	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
160	b0e5a8a0-597b-4a19-95ff-5925a26ff769	15069	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	López Castro, Francel Isaías	\N	\N	3	5	t	\N	2025-12-07 06:32:57.394378+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15069	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
214	4dc5f232-a081-4c04-9f3e-4bc83493675b	16038	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Córdova González, Junnior Danilo	\N	\N	3	5	t	\N	2025-12-07 06:32:57.603382+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16038	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
331	966c7bc4-3a9a-4a3b-a32d-3f61f4f28d71	18020	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	De Leon López, Alexander David	\N	\N	3	5	t	\N	2025-12-07 06:32:58.415818+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18020	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
355	f243b235-8f42-4538-be3e-9d7a0013125f	18044	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramirez Guerrero, Sandro Emmanuel	\N	\N	3	5	t	\N	2025-12-07 06:32:59.72045+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18044	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
386	fbec9ed7-9c29-45a9-8779-5edd23322c4a	19021	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cardona López, Wilson Adán	\N	\N	3	5	t	\N	2025-12-07 06:32:59.854225+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19021	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
401	02141d66-1f2e-4bb2-ac0d-e0d5e93916e7	19036	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Diaz, Luis Angel	\N	\N	3	5	t	\N	2025-12-07 06:32:59.923603+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19036	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
133	fa2b6eed-01c8-4e69-a2f5-eb8eb344c374	15024	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Chinchilla Valenzuela, Kevin Estuardo	\N	\N	3	1	t	\N	2025-12-07 06:32:57.161422+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15024	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
472	199c7f64-ed95-4bbe-8758-f0026e7992b4	19107	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Monzón García, Miguel Angel	\N	\N	3	5	t	\N	2025-12-07 06:33:00.153283+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19107	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
521	9a50e666-6e52-49b2-b5cd-1dd2c3a6b169	19156	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Tomás Agustín, Franklin Mayck	\N	\N	3	5	t	\N	2025-12-07 06:33:00.36317+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19156	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
530	fb144ab7-b044-4cd0-ac49-01f869c956f6	19165	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Velasquez Coronado, Vinicio Efraín	\N	\N	3	5	t	\N	2025-12-07 06:33:00.375008+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19165	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
266	df719a64-de28-4e96-aa7d-ecd1f5d63395	16139	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ruiz Gutiérrez, Edvin José Rodolfo	\N	\N	3	8	t	\N	2025-12-07 06:32:57.810334+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16139	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
346	f27289f1-0002-4661-b113-bc6287d2260c	18035	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morales Gálvez, Gervin Friceli	\N	\N	3	8	t	\N	2025-12-07 06:32:59.660911+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18035	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
431	c0daadfc-50f8-4aa4-bbd8-6bb7e2e43bcf	19066	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gómez Ortíz, Carmen Liliana	\N	\N	3	8	t	\N	2025-12-07 06:33:00.06142+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19066	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
466	661a92e1-a4d4-4b08-bdcc-7e39cac007c2	19101	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Martinez Melgar, Gloria Francis Amabel	\N	\N	3	8	t	\N	2025-12-07 06:33:00.097126+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19101	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
481	f88563fd-cb19-4441-91d3-d5e6d804a65e	19116	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Peñate Colindres, Yeymy Elizabeth	\N	\N	3	8	t	\N	2025-12-07 06:33:00.167318+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19116	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
501	5d6aca56-5109-4a8f-a5e5-d291a20dc490	19136	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Retana Mazariegos, Yeni Maritza	\N	\N	3	8	t	\N	2025-12-07 06:33:00.292168+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19136	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
517	5d35348b-516a-4374-b22c-6ab123245538	19152	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Sánchez Vargas, Carlos Humberto	\N	\N	3	8	t	\N	2025-12-07 06:33:00.311666+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19152	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
534	703c0847-ddba-4fbf-9063-0def1eefa7d9	19169	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Villanueva Corado, Jerson Alexander	\N	\N	3	8	t	\N	2025-12-07 06:33:00.427785+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19169	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
36	180bd170-926a-46d3-9ff7-265d112333cc	4054	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Xitumul Pérez Julio Alberto	\N	\N	3	9	t	\N	2025-12-07 06:32:55.014978+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	4054	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
190	ebd7b6cf-bb85-494f-aafe-8a3f05f7ea6a	15125	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Samayoa Dubón, Cristian Omar	\N	\N	3	9	t	\N	2025-12-07 06:32:57.478243+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15125	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
348	c8ebecd8-a250-4705-a10f-58f1dc4911f9	18037	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Monzon Ramos, Cristopher Ricardo	\N	\N	3	9	t	\N	2025-12-07 06:32:59.712108+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18037	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
363	747d6cb4-37cd-401b-803f-78508fa1657b	18052	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Santos López, Yulian Ronaldo	\N	\N	3	9	t	\N	2025-12-07 06:32:59.77804+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18052	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
425	abdf4ab9-9124-4d45-89b4-919878e342fd	19060	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	García Pineda, Anibal Nicolas	\N	\N	3	9	t	\N	2025-12-07 06:32:59.997686+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19060	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
437	58cd2f8e-e6db-4e31-a3f5-b8d4e94130cb	19072	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gudiel Castillo, Ever Yahir Alexis	\N	\N	3	9	t	\N	2025-12-07 06:33:00.06767+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19072	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
443	e1aaec6b-94f4-481a-8e32-008c6dbebc22	19078	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ichich Choc, Edgar Zaqueo	\N	\N	3	9	t	\N	2025-12-07 06:33:00.073084+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19078	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
461	35ae67f0-f3bb-4920-a9d1-7408a8750dc4	19096	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Maquin Cacao, Cristian Vidal	\N	\N	3	9	t	\N	2025-12-07 06:33:00.091471+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19096	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
468	985412ad-2647-4d8d-8495-0a84621b818e	19103	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Melgar, Rogelio Raquel	\N	\N	3	9	t	\N	2025-12-07 06:33:00.099214+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19103	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
509	1fd0697a-eb2a-4ce6-b22f-cab2e07a8650	19144	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Rodríguez Hipólito, Cristian Alexander	\N	\N	3	9	t	\N	2025-12-07 06:33:00.301576+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19144	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
102	54314f32-6a94-440e-8d33-1df19918638b	13017	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Melgar Lòpez, Edwin Leonardo	\N	\N	3	3	t	\N	2025-12-07 06:32:55.304514+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	13017	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
60	143c4fb4-5f6f-4fcd-ae72-e6cdb86370f7	9015	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Fuentes Fuentes, Federico Margarito	\N	\N	3	3	t	\N	2025-12-07 06:32:55.101184+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	9015	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
264	6f538dc2-fe09-429e-a1dd-0185c54715fa	16131	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Revolorio Arana, Brayan Alexander	\N	\N	3	3	t	\N	2025-12-07 06:32:57.807508+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16131	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
298	e53f6ff0-c328-417e-a1e8-9d314f448acc	17032	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Méndez Súchite Roslyn Mariela	\N	\N	3	3	t	\N	2025-12-07 06:32:57.890129+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	17032	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
479	afa7482c-3f14-45de-ad47-56f88fbbc677	19114	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ortíz Jímenez, Esmeralda Idalia	\N	\N	3	3	t	\N	2025-12-07 06:33:00.164731+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19114	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
529	8c7e5543-0d4c-4f43-ae27-05a0ec5cd726	19164	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Vela Ortíz, Maynor Manuel	\N	\N	3	3	t	\N	2025-12-07 06:33:00.372718+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19164	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
31	db8a1758-8aa4-4746-a55a-fe6f7d4607d3	4016	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Fuentes López, Uber Dionel	\N	\N	3	6	t	\N	2025-12-07 06:32:54.954135+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	4016	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
94	89f48781-857d-42d2-8737-cd6e7dbb1de7	12025	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Quevedo Corado, Jeidí Patricia	\N	\N	3	6	t	\N	2025-12-07 06:32:55.233894+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	12025	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
82	43d3042b-cacc-46c4-82e3-7d7255cb7c50	11035	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Quieza Porras, Chrystian Mario Enrique	\N	\N	3	6	t	\N	2025-12-07 06:32:55.171842+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	11035	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
350	927339cc-125e-415f-b050-25ce6d2fbde1	18039	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Peña Lemus, Elvis Rogelio	\N	\N	3	6	t	\N	2025-12-07 06:32:59.714761+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18039	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
447	76f979f2-b963-41fa-a9d2-8ee1d7d433e0	19082	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Juárez Alfaro, Gustavo Adolfo	\N	\N	3	6	t	\N	2025-12-07 06:33:00.076734+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19082	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
471	379c9c03-0bae-4984-b181-9c5d99073acb	19106	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Monzón De Paz, Jennifer Vanessa	\N	\N	3	6	t	\N	2025-12-07 06:33:00.15227+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19106	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
537	c6935a1b-12a6-4727-ad43-b9827bf74b37	17000	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Lisardo Tash Giron	\N	\N	3	1	t	2025-12-10 16:09:12.601934+00	2025-12-07 06:33:00.430819+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	17000	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
258	5add9b2e-6413-4930-9af4-856e68f4d93c	16117	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ortíz Paz, Luis Carlos	\N	\N	3	9	t	\N	2025-12-07 06:32:57.749012+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16117	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
494	7957b0ba-d543-48cc-b613-08408bbd2f89	19129	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Rabanales Fuentes César Obdulio	\N	\N	3	6	t	\N	2025-12-07 06:33:00.232779+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19129	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
514	4af7c54b-6fa1-4b5f-b8c9-0f05a9be2a70	19149	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Sales Gómez, Antony Josue	\N	\N	3	6	t	\N	2025-12-07 06:33:00.308946+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19149	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
126	9aec2da5-f52f-42c1-8dd5-e5f819551735	15014	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Bautista De León, Sergio Rubén	\N	\N	3	6	t	\N	2025-12-07 06:32:57.155179+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15014	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
19	93a99893-12ea-4b91-9b6f-0fc569190ee7	1016	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Edna Melisa Marchorro Paiz	\N	\N	3	1	t	\N	2025-12-07 06:32:54.936025+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	1016	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
290	02d3ffe8-ceb0-41dc-ad4d-6683cd077a51	17020	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cifuentes Cermeño, Dora Iracema	\N	\N	3	1	t	\N	2025-12-07 06:32:57.883099+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	17020	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
80	b3c85cde-77c6-41c8-bf83-b0607b56d417	11026	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Lopez Rosales, Marco Luis	\N	\N	3	1	t	\N	2025-12-07 06:32:55.170009+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	11026	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
239	435a98ff-e518-416e-93bb-9196e65ec7d7	16086	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Lima López, Hugo David	\N	\N	3	1	t	\N	2025-12-07 06:32:57.677576+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16086	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
452	cf5fc89e-3b0b-4a66-adfd-a105674f5638	19087	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	López, Gerber Ottoniel	\N	\N	3	1	t	\N	2025-12-07 06:33:00.082576+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19087	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
273	da992c69-63aa-40f9-8cbd-955b79384d57	16151	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Sosa Barrios, Bryan Josue	\N	\N	3	1	t	\N	2025-12-07 06:32:57.817294+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16151	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
63	302bb92d-3c4d-4b3d-be1e-541ff972786e	9021	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Perez Miranda, Feliciano	\N	\N	3	1	t	\N	2025-12-07 06:32:55.103834+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	9021	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
98	5e4cd462-9688-4639-8d44-3f85056cdfc7	13009	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	García Esquivel, Lester Yancarlo	\N	\N	3	1	t	\N	2025-12-07 06:32:55.240471+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	13009	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
142	21c6a7f3-7780-4ba2-9828-de04454ca0b1	15040	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Esteban Estrada, Edras Josué	\N	\N	3	1	t	\N	2025-12-07 06:32:57.27195+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15040	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
270	7d40f70d-30a2-45c8-a10d-5797295c8053	16146	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Sical Manuel, Marlon Estuardo	\N	\N	3	1	t	\N	2025-12-07 06:32:57.814091+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16146	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
206	7078a5ec-99cb-40a2-976c-2d4d04d36713	16019	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Carrillo Rossell, Kevin Arnaldo	\N	\N	3	1	t	\N	2025-12-07 06:32:57.546885+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16019	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
179	cdc6f6cb-b9d3-4ae6-9799-68a5ee224e70	15099	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Peñate Arévalo, Ana Patricia	\N	\N	3	1	t	\N	2025-12-07 06:32:57.466989+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15099	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
16	4c51496e-97a8-4788-9142-12b232bb130b	1012	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Angel Mario Garcia Garcia	\N	\N	3	1	t	\N	2025-12-07 06:32:54.877913+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	1012	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
69	17982c95-7851-415e-aa70-b87ada9cb731	10032	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramos Cinto Rodelfi Adelaido	\N	\N	3	1	t	\N	2025-12-07 06:32:55.110948+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	10032	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
50	1fc448ca-31db-42bb-a7f0-10eacea9b8da	7045	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Rodas Carcamo Cesar Joaquin	\N	\N	3	1	t	\N	2025-12-07 06:32:55.037518+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	7045	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
25	4c9b3c52-283b-436d-99e6-9424d96c50dc	3025	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Perdomo Lòpez, Edgar Rolando	\N	\N	3	1	t	\N	2025-12-07 06:32:54.945542+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	3025	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
175	d27ad9f1-c241-48fd-b596-1f51188eb388	15095	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Nájera Morales Edvin Antonio	\N	\N	3	1	t	\N	2025-12-07 06:32:57.461801+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15095	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
184	dd1a6f4f-d0c7-44d3-9843-43ad5f1665b8	15106	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pineda Osorio, Bryan Alexander	\N	\N	3	1	t	\N	2025-12-07 06:32:57.47205+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15106	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
78	f5c2476e-0dbc-48b2-8601-4e43e8ba11c9	11018	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Godinez Velasquez Kevin	\N	\N	3	1	t	\N	2025-12-07 06:32:55.168297+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	11018	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
101	1dc4ce73-d9b0-42f3-b503-7a72b1e444da	13012	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Leiva Ramos Everth Lemuel	\N	\N	3	1	t	\N	2025-12-07 06:32:55.245961+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	13012	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
100	feb75c59-2658-492c-805b-4d9d83474101	13011	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Juàrez Chen, Edwin Eduardo	\N	\N	3	1	t	\N	2025-12-07 06:32:55.244431+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	13011	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
177	fe762843-b84e-41fd-87c8-09a3449a7f4b	15097	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ortíz Catalán, Augusto	\N	\N	3	1	t	\N	2025-12-07 06:32:57.464459+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15097	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
108	8837f926-215a-4bba-b5c2-9959c8e5b8ba	14004	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Barrientos Revolorio, Madhelyn Lizbeth	\N	\N	3	8	f	\N	2025-12-07 06:32:55.99678+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	14004	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
178	1f53d02e-b492-48a1-aa32-e990cc95dc07	15098	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Palencia Morales, Anderson Brenner	\N	\N	3	1	t	\N	2025-12-07 06:32:57.465706+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15098	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
192	0f3e5f1d-cc73-4948-94c8-5e8d61486322	15129	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Santos Pérez, William Michael	\N	\N	3	1	t	\N	2025-12-07 06:32:57.480145+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15129	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
238	02b9c108-e27b-453e-9a57-658124a9c26e	16083	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ixchop Corado Efémber José Rodrigo	\N	\N	3	1	t	\N	2025-12-07 06:32:57.676197+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16083	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
311	f5497ac0-db33-40c8-8437-f2dc9cb0633c	17051	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Veliz Gereda Yerlin Yesenia	\N	\N	3	1	t	\N	2025-12-07 06:32:57.952808+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17051	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
122	143f9eb8-aed3-4034-9a98-a0f0fcceced0	15006	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Aroche Ucelo, Francisco Jesús	\N	\N	3	1	t	\N	2025-12-07 06:32:57.152062+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15006	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
195	0182e674-9b13-4f50-84f9-66b5f949e0d6	15137	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Velásquez Escobar, Roger Wilfredo	\N	\N	3	1	t	\N	2025-12-07 06:32:57.483333+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15137	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
148	3dd3ca46-216a-422c-9198-a92f7b047397	15050	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Girón Méndez, Miguel Angel	\N	\N	3	1	t	\N	2025-12-07 06:32:57.324051+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15050	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
210	d98c8055-f118-4529-aa16-4143ab1ed2f4	16032	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Chiroy Revolorio Kerlin Arturo	\N	\N	3	1	t	\N	2025-12-07 06:32:57.551885+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16032	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
231	cb5e162c-873d-4cae-9604-319241468ccf	16075	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández Barrera Rufino Dagoberto	\N	\N	3	1	t	\N	2025-12-07 06:32:57.619632+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16075	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
232	9f28d5b0-93c5-4a7a-a4a8-eae2c6b8dd14	16076	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández Castañeda Mario José	\N	\N	3	1	t	\N	2025-12-07 06:32:57.620559+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16076	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
248	75276000-f358-455f-9394-9d3630f27ca0	16101	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Mendez Malchic, José Efraín	\N	\N	3	1	t	\N	2025-12-07 06:32:57.687597+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16101	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
262	38bd7ee3-a824-42bc-b7d2-7e18ef8a8bc0	16128	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramírez Gereda Tayron Alexander	\N	\N	3	1	t	\N	2025-12-07 06:32:57.804681+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16128	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
39	e1782d09-95b1-49ff-a8e1-01190cf25f21	5005	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cruz Veliz Osmar Ramiro	\N	\N	3	1	t	\N	2025-12-07 06:32:55.023946+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	5005	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
276	21d9e38d-f64f-4ae4-be10-dd0bccdef5bd	16155	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Virula Y Virula, Osiel Antonio	\N	\N	3	1	t	\N	2025-12-07 06:32:57.820406+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16155	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
285	cbdc1823-041f-44e5-8151-3011151ea4f3	17015	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Blanco Carias Evelin Maritza	\N	\N	3	1	t	\N	2025-12-07 06:32:57.878105+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17015	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
299	f5019052-9196-470b-bdf7-09c1044ef099	17033	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morales Marroquin Dilan Alexis	\N	\N	3	1	t	\N	2025-12-07 06:32:57.891011+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17033	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
292	3039cf32-bbb6-4fb3-9a27-83ae5769c6c5	17034	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gerson Augusto Morales Ochoa	\N	\N	3	1	t	\N	2025-12-07 06:32:57.884925+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17034	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
329	e417ddeb-3681-4993-a244-cf0607172a13	18018	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Alberto Josué Cruz Sarceño	\N	\N	3	1	t	\N	2025-12-07 06:32:58.218759+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18018	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
360	fcafa361-6a83-405d-8c5d-60728ca99d80	18049	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Salazar Ortíz Walter Arturo	\N	\N	3	1	t	\N	2025-12-07 06:32:59.774086+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18049	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
357	66022744-23f2-4565-b3a1-534f51781551	18046	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramirez Pineda Franklin Irael	\N	\N	3	1	t	\N	2025-12-07 06:32:59.722693+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18046	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
29	cfb611ff-e018-4add-8f9b-9eab2df62432	4009	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cisneros Esquivel Ricardo Wilfredo	\N	\N	3	1	t	\N	2025-12-07 06:32:54.951901+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	4009	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
196	2a2e2b13-a043-431c-aa9f-ef55720776a6	15138	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Yoc Elel, Edson Ernesto	\N	\N	3	1	t	\N	2025-12-07 06:32:57.484537+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	15138	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
364	84f48c33-4deb-4989-8248-d5dc94f542f8	18053	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Toto Paz Kevin Alberto	\N	\N	3	1	t	\N	2025-12-07 06:32:59.778912+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18053	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
314	446775f1-404c-43c4-af3b-b4952b310aa7	18003	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Albizures Ramírez Wilmer Abel	\N	\N	3	1	t	\N	2025-12-07 06:32:57.956562+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18003	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
333	68c6e385-8c76-469c-a565-57d8258cfb8c	18022	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Escobar Peñate Rubén Alejandro	\N	\N	3	1	t	\N	2025-12-07 06:32:58.612858+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18022	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
328	78c40bf3-2b9a-4dc8-9e94-9b358dd8d4c1	18017	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Crúz Méndez Cristian Alfredo	\N	\N	3	1	t	\N	2025-12-07 06:32:58.120092+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18017	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
516	ed591bb6-8ecf-4ccc-a7bd-c4d19dcd0492	19151	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Sánchez Tobar Victor Francisco	\N	\N	3	1	t	\N	2025-12-07 06:33:00.310795+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19151	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
407	8f9496b4-c745-4659-9c66-05038b53ae23	19042	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ronald Israel Escobar Echeverría	\N	\N	3	1	t	\N	2025-12-07 06:32:59.929322+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19042	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
436	2b9fe7ed-1379-46d9-b119-cc527d992bbe	19071	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Grijalva Belloso Juan Carlos	\N	\N	3	1	t	\N	2025-12-07 06:33:00.066203+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19071	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
365	9e342841-de98-4f02-898b-d3f8af8f8dbd	18054	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Velásquez Mejía Yásmin Sorana	\N	\N	3	1	t	\N	2025-12-07 06:32:59.77978+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	18054	\N	f	FEMENINO	4	f	f	\N	\N	\N	{}	f
453	202479e6-65f6-457d-9052-810f68857dce	19088	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	López Gustavo Adolfo	\N	\N	3	1	t	\N	2025-12-07 06:33:00.08356+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	19088	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
510	df248bb4-e047-4229-8d1d-d0db9b3dc7a3	19145	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Rodríguez Orozco Yesica Fabiola	\N	\N	3	1	t	\N	2025-12-07 06:33:00.302924+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	19145	\N	f	FEMENINO	4	f	f	\N	\N	\N	{}	f
442	d6d56e21-0630-4b6b-8d39-d43f569aaab5	19077	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hurtado Asencio Elvidio De Jesús	\N	\N	3	1	t	\N	2025-12-07 06:33:00.072081+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19077	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
434	1e6ddbce-256e-40b1-a8be-1fa311f98fee	19069	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	González Escobar Leidy Mariela	\N	\N	3	1	t	\N	2025-12-07 06:33:00.063909+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19069	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
505	78497615-4e7e-4c6c-ada4-55d0ae075c31	19140	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ríos Barrera De Asencio Zoila Virginia	\N	\N	3	1	t	\N	2025-12-07 06:33:00.296972+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19140	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
400	8100e1cb-11ca-4097-8eb5-e2c3add416ed	19035	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cutzal García Eddy Obdulio	\N	\N	3	1	t	\N	2025-12-07 06:32:59.922349+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19035	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
460	7f9b4fd0-ff1e-4d62-a3e1-3363052ed156	19095	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	López Témaj Jonatan Rolando	\N	\N	3	1	t	\N	2025-12-07 06:33:00.0901+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19095	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
375	4e5795e0-546a-4610-b3b1-759e15c5c788	19010	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Grely Aneth Aviche Carías	\N	\N	3	1	t	\N	2025-12-07 06:32:59.793479+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19010	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
371	2b7ff3f9-d4a2-470f-a2ee-ece39f980cb6	19006	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Alvarez Muñoz Christian René	\N	\N	3	1	t	\N	2025-12-07 06:32:59.787902+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19006	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
486	9c500219-18ab-4367-9027-030caecb8c09	19121	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pérez Pérez Eber José	\N	\N	3	1	t	\N	2025-12-07 06:33:00.22104+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19121	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
490	14c008b7-5359-41ba-9550-f2f76dfdd2aa	19125	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ponciano Lázaro Sandra Angélica	\N	\N	3	1	t	\N	2025-12-07 06:33:00.227096+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19125	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
291	4ac06f45-3401-463e-939b-e5df6dae07be	17021	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Corado Y Corado Ever Antonio	\N	\N	3	6	f	\N	2025-12-07 06:32:57.883982+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	17021	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
349	d8f89c28-0318-41fc-b911-a5a544646a2b	18038	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Osorio Machán María Yesenia	\N	\N	3	1	t	\N	2025-12-07 06:32:59.713209+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	18038	\N	f	FEMENINO	4	f	f	\N	\N	\N	{}	f
405	ed2fcac6-11e7-4403-9aef-a79f3e56dac7	19040	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Juan Antonio Donis Alfaro	\N	\N	3	1	t	\N	2025-12-07 06:32:59.927559+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19040	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
409	8f18eec6-90c1-4b6e-82ee-04e17b434928	19044	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Estrada Corominal Mirza Lizette	\N	\N	3	1	t	\N	2025-12-07 06:32:59.931523+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19044	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
398	34839bf3-c541-4085-8642-d9d350e21cc1	19033	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cortéz Velásquez Alex Adonis	\N	\N	3	1	t	\N	2025-12-07 06:32:59.919526+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19033	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
469	28d4b645-b06e-4b23-9ea7-3d2642b9e2a1	19104	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Mazariegos Arana Gilma Yolanda	\N	\N	3	1	t	\N	2025-12-07 06:33:00.149088+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19104	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
470	068dc098-d3db-4732-929a-541987a57229	19105	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Miranda Méndez Mynor	\N	\N	3	1	t	\N	2025-12-07 06:33:00.15079+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19105	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
403	312f7ec4-b9c8-4f19-81e0-f5d1933c0bf2	19038	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	De Páz Santos Breder Alexander	\N	\N	3	1	t	\N	2025-12-07 06:32:59.92536+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	19038	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
378	5cdba3d7-c92d-419d-a3c5-f6c75ce7640f	19013	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Barrientos Corado, Danis Estid	\N	\N	3	1	t	\N	2025-12-07 06:32:59.796224+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19013	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
280	41f27d54-8fb3-4216-9359-e7418683a6de	17004	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gomez Ramirez, Samy Renato	\N	\N	3	1	t	\N	2025-12-07 06:32:57.824226+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	17004	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
482	9da9667e-b8cf-4de0-800a-ff60c7bc79bc	19117	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Peralta Marroquín Jasmine Saraí	\N	\N	3	1	t	\N	2025-12-07 06:33:00.168408+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19117	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
508	3cf126ea-c63d-4b89-bcca-564bf158bd2d	19143	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Rivera Vásquez Beverlin Graciela	\N	\N	3	1	t	\N	2025-12-07 06:33:00.300644+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19143	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
26	b1285b4e-8ed2-4493-bd8a-64d39d715547	3031	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramirez Marroquin, Santiago Leonidas	\N	\N	3	7	t	\N	2025-12-07 06:32:54.946766+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	3031	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
70	7b43f60c-fa55-492e-831b-6d15ae0ccd98	10033	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Revolorio Revolorio Silverio Eliseo	\N	\N	3	7	t	\N	2025-12-07 06:32:55.111781+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	10033	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
140	446815bf-2c65-4b72-9aa4-35e4de4652a6	15031	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cruz López, Estuardo	\N	\N	3	7	t	\N	2025-12-07 06:32:57.270226+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15031	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
227	cf9a8d46-8444-49f1-ac35-b080f8793742	16067	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gómez Elvira José Fernando	\N	\N	3	7	t	\N	2025-12-07 06:32:57.615571+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16067	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
124	c3b29b0c-479d-4038-bdd1-d11f2eb4a5ce	15011	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Barillas Velásquez, Jaime Bernabé	\N	\N	3	7	t	\N	2025-12-07 06:32:57.153711+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15011	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
104	42f63bd6-30a0-402a-9ea3-b986e53d3dc5	13027	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Campos Retana, Aroldo Federico	\N	\N	3	7	t	\N	2025-12-07 06:32:55.463445+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	13027	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
168	4f217143-2af7-4083-b29b-b688448aee82	15082	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Miranda Aguilar, Esaú Emanuel	\N	\N	3	7	t	\N	2025-12-07 06:32:57.402383+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15082	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
286	94ab8ad3-6276-42b9-a550-c5fb7f46005f	17016	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Campos Cermeño César Eduardo	\N	\N	3	2	t	\N	2025-12-07 06:32:57.87911+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17016	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
383	7292fd6d-e0cd-4be8-9e85-938a228ccec3	19018	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Campos Cermeño Miguel Angel Arcangel	\N	\N	3	4	t	\N	2025-12-07 06:32:59.850894+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19018	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
344	4671a61f-6624-443c-a25b-e1bb32a43fac	18033	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Lopez Lau Rogers Ernesto	\N	\N	3	7	t	\N	2025-12-07 06:32:59.65491+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18033	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
361	1f8cf817-58f8-48cc-abc3-e589f0681c1a	18050	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Sánchez Pérez Esteban	\N	\N	3	7	t	\N	2025-12-07 06:32:59.775799+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18050	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
377	854bd8f3-ad1a-4176-94a5-ca2dd341d8a6	19012	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Barco Galicia Carlos Eduardo	\N	\N	3	7	t	\N	2025-12-07 06:32:59.795417+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19012	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
397	25c03c83-39e2-4bda-a3c9-52d6c38744d2	19032	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Corado Y Corado José David	\N	\N	3	7	t	\N	2025-12-07 06:32:59.918377+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19032	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
390	2ca79f58-1d56-4246-aa52-eba4a4ff33f9	19025	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cazún Godoy Walter Oswaldo	\N	\N	3	7	t	\N	2025-12-07 06:32:59.858482+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19025	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
507	7321ae8c-7b6f-415e-969d-3382f5f78bf7	19142	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Rivera Vásquez Ander Yoel	\N	\N	3	7	t	\N	2025-12-07 06:33:00.299377+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19142	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
496	ea57a667-28f8-4335-8a18-82b0e38af3bd	19131	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramirez Chapas Brandon Omar	\N	\N	3	7	t	\N	2025-12-07 06:33:00.236281+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19131	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
21	8591afd6-2c94-4d76-a352-f679e5539313	1048	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morales Roman, Josè Adriàn	\N	\N	3	4	t	\N	2025-12-07 06:32:54.939688+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	1048	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
147	d4c3e073-42dc-43f3-a4bc-5b83230ba527	15049	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	García Pineda, Gelber Alexander	\N	\N	3	4	t	\N	2025-12-07 06:32:57.276594+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15049	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
268	36a29dfa-954d-42e7-b20b-98d670eef8c6	16144	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Santos Beltetón, Yonatan Eduardo	\N	\N	3	4	t	\N	2025-12-07 06:32:57.81238+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16144	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
185	cb02d28f-db6b-445d-bdb0-35c62c9620d9	15109	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Quinteros Del Cid, Ervin Edgardo	\N	\N	3	4	t	\N	2025-12-07 06:32:57.47325+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15109	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
263	d26c974f-c206-4208-b4e4-f45f25de79b7	16130	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramírez Yanes, Jonyr Rolando	\N	\N	3	4	t	\N	2025-12-07 06:32:57.806105+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16130	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
313	2239381e-e4bd-4db8-8202-79f1dee33a8e	18002	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Adriano Hernández Joshuá Emanuel	\N	\N	3	7	t	\N	2025-12-07 06:32:57.95554+00	2026-01-03 06:46:40.432709+00	2	\N	t	f	18002	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
302	48aaa7ab-589e-4437-b439-6a85767b404b	17037	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ordoñez García Sindy Carolina	\N	\N	3	4	t	\N	2025-12-07 06:32:57.893576+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17037	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
362	4d2210ac-f01a-441f-b3b0-88d52558dd88	18051	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Santos Belteton, Seleni Yoliza	\N	\N	3	4	t	\N	2025-12-07 06:32:59.777156+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18051	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
506	962b4592-23a5-4047-ab1d-81d47a7feeb3	19141	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Rivera Esquivel Edwin Vinicio	\N	\N	3	4	t	\N	2025-12-07 06:33:00.298242+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19141	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
478	309d2afb-2bd8-4004-ad47-46437e7522cc	19113	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ordoñez Ortega Sergio Estuardo	\N	\N	3	4	t	\N	2025-12-07 06:33:00.163401+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19113	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
519	f2a934f9-033d-443a-bb2a-910f3ee8e28d	19154	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Soto Monterroso Freiser Enrique	\N	\N	3	4	t	\N	2025-12-07 06:33:00.361344+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19154	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
464	972550c5-defd-4bb1-bf40-6672498fa6c3	19099	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Marroquín Orellana María Alejandra	\N	\N	3	4	t	\N	2025-12-07 06:33:00.095443+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19099	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
473	42b112cc-62a0-405f-b25b-f8ebf0517aef	19108	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morales Mejía Beberlyn Alejandra	\N	\N	3	4	t	\N	2025-12-07 06:33:00.154301+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19108	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
511	3a1403d8-8696-4a90-88f1-632add94cc0e	19146	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ruano Pernillo Vasti Madai	\N	\N	3	4	t	\N	2025-12-07 06:33:00.304106+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19146	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
27	a8662f5c-e15d-4fcb-91c5-c85a8ae9d7ae	3032	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramirez Toc, Jorge Mario	\N	\N	3	2	t	\N	2025-12-07 06:32:54.948092+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	3032	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
252	08ab8139-1356-4f1e-a4d1-8d504f71f783	16106	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morales Ochoa Selvin Vinicio	\N	\N	3	2	t	\N	2025-12-07 06:32:57.691749+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16106	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
402	b0eb02fc-3fb6-4789-b976-350a111114e4	19037	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	De Paz Nicolás, Juan Alberto	\N	\N	3	2	t	\N	2025-12-07 06:32:59.924499+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19037	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
399	2072f9fd-98af-4a84-b12b-f5e06152e75f	19034	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Marcela Judith Cotto Sanchez	\N	\N	3	2	t	\N	2025-12-07 06:32:59.920951+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19034	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
480	940d5827-b8e9-47c4-ab13-e1056940bfc5	19115	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pablo Tomás Gricelda Micaela	\N	\N	3	2	t	\N	2025-12-07 06:33:00.166252+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19115	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
512	8f8a8f8a-e527-4329-86a2-497ff62a269c	19147	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Salanic Gómez Marvin Orlando	\N	\N	3	2	t	\N	2025-12-07 06:33:00.305911+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19147	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
499	6dcc058f-a51c-4247-b900-c03fc69ad8b8	19134	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramos Godoy Aracely	\N	\N	3	2	t	\N	2025-12-07 06:33:00.239993+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19134	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
427	9edf9725-3fb9-440b-849f-4b7309f70e88	19062	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Garza Flores William Armando	\N	\N	3	2	t	\N	2025-12-07 06:33:00.001262+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19062	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
533	39826fc1-7b96-45c8-abe8-6384b45a4f49	19168	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Osbin Audiel Veliz Ramírez	\N	\N	3	2	t	\N	2025-12-07 06:33:00.378141+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19168	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
48	c9358720-3459-4f57-aa2b-278a67c4530c	7012	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Diaz De Leon Gustavo Adolfo	\N	\N	3	5	t	\N	2025-12-07 06:32:55.034996+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	7012	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
146	1dbc6074-0bd0-4077-b8d6-73f7c07b69e5	15047	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	García García, Pedro César	\N	\N	3	5	t	\N	2025-12-07 06:32:57.275796+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15047	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
256	db88d178-acd1-4bb8-8b53-76c17e114131	16114	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Orozco Témaj Byron Armando	\N	\N	3	5	t	\N	2025-12-07 06:32:57.746674+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16114	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
334	b3481657-7a54-478b-8719-37523a307290	18023	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Estrada Corominal Walter Isaias	\N	\N	3	5	t	\N	2025-12-07 06:32:58.709323+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18023	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
338	89a9bfb8-590b-47a8-8934-1e31f53d5814	18027	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Godinez Martinez Jorge Antonio	\N	\N	3	5	t	\N	2025-12-07 06:32:59.152651+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18027	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
394	acd61f1d-3d4e-4485-a7ac-7afa89bb06a3	19029	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cop Galvan Guillermo Eduardo	\N	\N	3	5	t	\N	2025-12-07 06:32:59.862789+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19029	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
504	3b14126c-a9d7-4391-9446-b027fd4431ce	19139	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Reyna Rivera Walter Alexis	\N	\N	3	5	t	\N	2025-12-07 06:33:00.296039+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19139	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
457	fab2348f-d1ba-43e1-8887-de79e6d7c353	19092	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	López Montero Crúz Armando	\N	\N	3	5	t	\N	2025-12-07 06:33:00.087365+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19092	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
439	4ea4bb5f-ad4d-4690-a99a-2c7d095e4952	19074	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández De León Maria Fernanda De Aquino	\N	\N	3	8	t	\N	2025-12-07 06:33:00.069511+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19074	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
422	41590c1a-e5b8-497d-8c26-a4c2961fb3bc	19057	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	García Hernández Luciano	\N	\N	3	8	t	\N	2025-12-07 06:32:59.995004+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19057	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
492	8693d7ec-75e3-46b6-a699-75cce6a75c51	19127	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Quiñonez Hernández Rudimán Omar	\N	\N	3	8	t	\N	2025-12-07 06:33:00.230149+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19127	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
485	49e829cc-e1fe-4190-817b-3d130c023654	19120	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pérez Crúz César Adonay	\N	\N	3	8	t	\N	2025-12-07 06:33:00.219936+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19120	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
429	d2bc89f3-221a-40a1-9fc8-c8ac49d3f179	19064	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Godoy López Wilson	\N	\N	3	8	t	\N	2025-12-07 06:33:00.003349+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19064	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
458	5a0f5492-2505-4ad3-84ab-fd977429454a	19093	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	López Muñoz Augusto César	\N	\N	3	8	t	\N	2025-12-07 06:33:00.088212+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19093	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
55	64b223e0-5c04-4abf-8a7f-9d7ca23ccded	8043	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Rivas Diaz Kennedy Josué	\N	\N	3	9	t	\N	2025-12-07 06:32:55.096531+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	8043	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
158	35608f04-c924-45f8-b35e-18894ecbb275	15066	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Landaverde Rodriguez Byron Fernando	\N	\N	3	9	t	\N	2025-12-07 06:32:57.34038+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15066	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
219	cc5ca476-2f70-4a4f-bf9a-4018cecf2fda	16050	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Escobar Cermeño, Marvin Geovani	\N	\N	3	9	t	\N	2025-12-07 06:32:57.608023+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16050	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
294	5be6b805-4d88-4a5a-b6a9-1ec23a2911ef	17023	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Flores Vargas Douglas Waldermar	\N	\N	3	9	t	\N	2025-12-07 06:32:57.886759+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17023	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
322	ce0342fe-8d27-456c-8c1a-87c2ef3eb413	18011	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Castellanos Perez Yeferson Gerber H.	\N	\N	3	9	t	\N	2025-12-07 06:32:57.966635+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18011	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
347	6bbfb9dd-6929-4cc2-82ce-7fc1c5f80868	18036	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morales Rivas Cristian Francisco	\N	\N	3	9	t	\N	2025-12-07 06:32:59.71029+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18036	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
467	aab4be33-3f60-4917-8c20-86db659e078b	19102	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Mayorga Pérez Remy Angel Arturo	\N	\N	3	9	t	\N	2025-12-07 06:33:00.098173+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19102	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
463	a3e686e8-f05a-4202-b727-d73b0140b12e	19098	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Marroquín Argueta Edwin Humberto	\N	\N	3	9	t	\N	2025-12-07 06:33:00.093878+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19098	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
450	2c805e28-2a77-4a79-a91d-a8ab0ade3bf8	19085	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Lémus Ramirez Wilmer Samuel	\N	\N	3	9	t	\N	2025-12-07 06:33:00.080346+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19085	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
40	cc35a570-e959-4de5-b9e0-bb3b25ddebc7	5006	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cifuentes Cu Jose Luis	\N	\N	3	3	t	\N	2025-12-07 06:32:55.02529+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	5006	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
235	bf3bf255-4cf3-432f-a1c3-dd509326e8dc	16079	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández Juárez, Pablo	\N	\N	3	3	t	\N	2025-12-07 06:32:57.671883+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16079	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
354	d0b5ce4e-3ed6-45e0-8bca-d30fdb9fceaf	18043	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Perez Perez Damian De Jesus	\N	\N	3	3	t	\N	2025-12-07 06:32:59.719089+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18043	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
524	a06355fe-5c00-41b2-845f-77db7e4b0004	19159	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Valdéz Herrera Carlos Alberto	\N	\N	3	3	t	\N	2025-12-07 06:33:00.367084+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19159	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
49	f8334475-3c6e-4fa7-94c6-16a024d414ed	7043	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramos Alfaro, Bayron Yobany	\N	\N	3	6	t	\N	2025-12-07 06:32:55.036121+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	7043	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
243	8fb52e3c-64be-4030-9ba0-d1d73af0d728	16094	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Lorenzo Yac Anselmo	\N	\N	3	6	t	\N	2025-12-07 06:32:57.682698+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16094	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
233	b9df6c78-228d-470a-9052-79ce215831b8	16077	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández Cotill Abner Misael	\N	\N	3	6	t	\N	2025-12-07 06:32:57.668665+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16077	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
205	93a8ecfe-7305-4598-b6fd-4dc47aa5c5d0	16017	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cano Serrano, Gervin Geovany	\N	\N	3	5	t	\N	2025-12-07 06:32:57.545615+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16017	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
326	f039e5bb-0fc3-4db4-966e-cc04eff1d4ff	18015	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Coronado Alvarez Keiry Mirella	\N	\N	3	6	t	\N	2025-12-07 06:32:58.020855+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18015	\N	f	FEMENINO	\N	t	f	\N	\N	\N	{}	f
382	4adcb956-ef68-4545-aa86-87ddb8104342	19017	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cal Xona Liliana Beverly	\N	\N	3	8	t	\N	2025-12-07 06:32:59.849833+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19017	\N	f	FEMENINO	\N	t	f	\N	\N	\N	{}	f
289	b1ab056d-0c05-4750-bf24-af7b75823c95	17019	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Chol Quiroa Cesar Antonio	\N	\N	3	3	t	\N	2025-12-07 06:32:57.881909+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17019	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
64	11c80596-7b50-4964-a3f9-fa31c3f7c976	10005	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Calderon Rodriguez Gerson Noe	\N	\N	3	9	t	\N	2025-12-07 06:32:55.104664+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	10005	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
522	e0e8d3d7-8503-42d7-8b5d-943f3802e311	19157	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Tomás Cardona Fredy Ovando	\N	\N	3	5	t	\N	2025-12-07 06:33:00.364378+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19157	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
45	54596f2e-b69e-4057-8ecd-074ef08191ac	6033	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Torres Perez, Denis Bernardo	\N	\N	3	8	t	\N	2025-12-07 06:32:55.031017+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	6033	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
54	102fcade-a172-4933-a3a1-fc06ed5df1f6	8031	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pacheco Escobar Vilma Yaneth	\N	\N	3	8	t	\N	2025-12-07 06:32:55.095561+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	8031	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
277	08c29cb5-2d98-4de1-b764-979908f0b26c	16156	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Vivas Nimacachi David Amilcar	\N	\N	3	8	t	\N	2025-12-07 06:32:57.821286+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16156	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
250	0408b587-9a75-4551-a548-556ca8f49d11	16103	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Miranda Melgar Edson Ariel	\N	\N	3	8	t	\N	2025-12-07 06:32:57.689579+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16103	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
303	0350803d-a1ed-4388-abe6-8affda7a434e	17038	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ortiz Estrada Karla Edith	\N	\N	3	8	t	\N	2025-12-07 06:32:57.894366+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17038	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
438	0c503629-7dd5-4961-b871-8e67e5cf471d	19073	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández Aguilar Angel David	\N	\N	3	6	t	\N	2025-12-07 06:33:00.068654+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19073	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
489	034c74e3-d951-4738-a7b6-3fd2489d1490	19124	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pineda Carías Ivan Alexander	\N	\N	3	6	t	\N	2025-12-07 06:33:00.225507+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19124	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
513	9b1f500c-e3e8-4456-b15f-f31e3389ed75	19148	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Sales Gómez, Adán Alexander	\N	\N	3	6	t	\N	2025-12-07 06:33:00.307372+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19148	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
22	10b9c33e-2b45-4aa0-8387-1dac22fd0216	3016	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernàndez Galdàmez, Wilner	\N	\N	3	1	t	\N	2025-12-07 06:32:54.941707+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	3016	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
109	5552d372-08be-4a42-8454-0af67ba138b7	14007	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	CABRERA CRUZ, BRYAN JOSE	\N	\N	3	6	f	\N	2025-12-07 06:32:56.105163+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	14007	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
111	782add4a-0a9f-4974-b80e-dad473f198ec	14013	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Garcia Morales, Edgar Omar	\N	\N	3	2	f	\N	2025-12-07 06:32:56.372398+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	14013	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
24	5fff3c40-4efd-4cab-90b4-372736b613f5	3024	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morales Romero, Griselda Roxana	\N	\N	3	1	t	\N	2025-12-07 06:32:54.944345+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	3024	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
72	2e054d96-9f55-40ac-a05f-36fa32f9b213	10041	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Velasquez Pablo Telesforo Alberto	\N	\N	3	1	t	\N	2025-12-07 06:32:55.113557+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	10041	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
68	ff4d3987-b3ff-44f2-8aeb-3afd6d35bd84	10025	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Monzon Morales Mitsiu Yonathan	\N	\N	3	1	t	\N	2025-12-07 06:32:55.110025+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	10025	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
81	842c8065-e944-468a-9519-33c8226e7208	11034	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Perez Gomez Bryan Israel	\N	\N	3	1	t	\N	2025-12-07 06:32:55.17099+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	11034	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
84	555c232b-2830-4de2-b783-15de3eefe38d	11042	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Xajap Xuya, Jose Wenceslao	\N	\N	3	1	t	\N	2025-12-07 06:32:55.174489+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	11042	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
283	9344ddca-4cf2-457a-aefb-9f1dc2673e2e	17012	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Retana Vásquez, José Armando	\N	\N	3	1	t	\N	2025-12-07 06:32:57.875612+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17012	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
269	6e7e44af-c490-4c2e-987a-8054d2250d16	16145	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Santos Turcios, Nelson Bladimiro	\N	\N	3	1	t	\N	2025-12-07 06:32:57.813222+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16145	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
166	63f2fd93-3fab-4f2d-998c-3482a8937696	15080	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Méndez García, Wiliam Neftalí	\N	\N	3	1	t	\N	2025-12-07 06:32:57.400659+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15080	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
225	c4e9a282-9137-49fe-b766-2445fbaa349a	16064	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	García Ramirez Elder Alfredo	\N	\N	3	1	t	\N	2025-12-07 06:32:57.613355+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16064	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
134	456f0102-a40e-469e-bc07-a4a5b85e7c7d	15025	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Chú Ichich, Oscar Arnoldo	\N	\N	3	1	t	\N	2025-12-07 06:32:57.212778+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15025	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
165	ff492e0f-b75e-4d11-b40b-f4bf4967053f	15079	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Mejía Hernández, Christian Geovanni	\N	\N	3	1	t	\N	2025-12-07 06:32:57.399232+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15079	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
279	bac6836c-8220-4b74-bde5-a4b4e829c72b	16158	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Zuñiga Godoy José Armando	\N	\N	3	1	t	\N	2025-12-07 06:32:57.823262+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16158	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
297	57aa9f49-7d5f-4da3-8f71-d9dfa25e2974	17031	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Mayorga Perez Keyner Josue	\N	\N	3	1	t	\N	2025-12-07 06:32:57.889196+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17031	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
426	e8b906d9-bc49-48cb-9493-d742d9c78ec8	19061	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gacía Zuñiga Nixozón Rolando	\N	\N	3	1	t	\N	2025-12-07 06:32:59.999809+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19061	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
515	2662980a-bb17-4066-90ec-ee277e11e638	19150	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Sánchez Ramos Jefrey Samuel	\N	\N	3	1	t	\N	2025-12-07 06:33:00.309895+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	19150	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
484	ea67f320-8dc1-4d54-90b1-166d016fee88	19119	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pérez Arriaza Victor Ovidio	\N	\N	3	1	f	\N	2025-12-07 06:33:00.218533+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19119	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
287	cffae9ef-f814-4efe-b165-1cad166cdd90	17017	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Campos Pinelo Edwin Daniel	\N	\N	3	9	f	\N	2025-12-07 06:32:57.879943+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17017	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
164	7b3285fc-3f76-4e79-9adf-996f18cc1a3a	15076	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Martínez Herrera, Miguel Antonio	\N	\N	3	9	f	\N	2025-12-07 06:32:57.398327+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15076	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
20	77d7e3de-ea32-44a3-9a9c-fb88c6f7f0b4	1022	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Adriano Lopez, Manuel De Jesús	\N	\N	3	1	t	2025-12-17 15:44:16.429434+00	2025-12-07 06:32:54.938078+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	1022	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
374	394e62a2-78d3-4ca4-a590-93d666476a75	19009	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Arevalo Herrera Marvín Eduardo	\N	\N	3	1	t	\N	2025-12-07 06:32:59.792308+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19009	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
193	efb4969a-994e-47b8-8f5f-edededecb31b	15131	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Sióc Ortíz, Marvyn Gundemaro	\N	\N	3	6	t	\N	2025-12-07 06:32:57.4811+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15131	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
388	b45730a7-d99d-4fc4-8a4b-a23cc75fa08a	19023	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Carías Godoy Ronald Vinicio	\N	\N	3	9	f	\N	2025-12-07 06:32:59.856328+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19023	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
123	384db6d2-3dc5-4e98-9619-ff9078125250	15007	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Asencio Corado, Alex Omar	\N	\N	3	2	f	\N	2025-12-07 06:32:57.152878+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15007	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
137	7c1df91a-96d3-47f5-8f1f-5b607b8ceced	15028	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Contreras Paau, Jorge Humberto	\N	\N	3	1	f	\N	2025-12-07 06:32:57.21712+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15028	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
138	9ac828b9-ae4e-4b43-b6b7-aa78526052f3	15029	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Corado Reynosa, Steeven Omar	\N	\N	3	2	f	\N	2025-12-07 06:32:57.218691+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15029	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
145	7870ef1f-a5d8-41e6-94f9-5a26d198d6a7	15046	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Garcia Castillo, Elmer Candelario	\N	\N	3	2	f	\N	2025-12-07 06:32:57.274779+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15046	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
167	da658007-c174-44b6-badb-2507bed0210b	15081	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Mendoza Belloso, Darvin Enrique	\N	\N	3	4	f	\N	2025-12-07 06:32:57.401541+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15081	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
257	6ca9b130-a9ae-4769-aacd-5eb7fd9f505c	16116	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ortiz Carrillo Kevin Renato	\N	\N	3	6	f	\N	2025-12-07 06:32:57.747846+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16116	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
555	f328f858-1505-4ae5-9707-c9b497de86e2	18	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Garcia Barrios, Jaime Ruben	\N	\N	3	8	f	\N	2025-12-07 06:33:00.501039+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	18	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
558	86c6e01c-a65e-4148-adf8-050fe831242a	21	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Carrera Torres, Carlos Alberto	\N	\N	3	6	f	\N	2025-12-07 06:33:00.504394+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	21	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
559	04060073-8821-4987-aaf1-aee1e59fd7b5	22	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Tobar Mendoza, Wilian Uliser	\N	\N	3	8	f	\N	2025-12-07 06:33:00.505268+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	22	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
418	164dcb39-3bf6-4683-a6e6-d09c8642280b	19053	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	García Asencio Dandis Imanol	\N	\N	3	1	f	\N	2025-12-07 06:32:59.989955+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19053	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
281	06d267c2-baf2-478f-b046-19733a532215	17005	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Lopez Guillen Mario Rolando	\N	\N	3	5	f	\N	2025-12-07 06:32:57.825025+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17005	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
339	3ca8826f-a0fa-4653-9741-9084eed8a939	18028	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gómez Méndez Persy Aristides	\N	\N	3	2	f	\N	2025-12-07 06:32:59.253433+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18028	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
440	be469424-5e67-4b15-a19e-53b83b0200fa	19075	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández López Carlos Alberto	\N	\N	3	1	f	\N	2025-12-07 06:33:00.070358+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19075	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
502	ed593ed5-b0f2-4999-b7bb-c153f179f697	19137	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Revolorio Latín German Oswaldo	\N	\N	3	1	f	\N	2025-12-07 06:33:00.293591+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19137	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
497	49aa48d6-cb79-409f-8db2-b3a191eff8a8	19132	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramírez Herrera Mynor Anibal	\N	\N	3	1	f	\N	2025-12-07 06:33:00.237284+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19132	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
415	96a8442f-f7d0-4a18-95f2-0eb47db6f990	19050	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Galicia Gomez, Nelson Geovanny	\N	\N	3	1	t	\N	2025-12-07 06:32:59.986971+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19050	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
28	5c237746-4546-413b-b15c-a9ba22e39e59	4001	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Agustin Lopez, Esteban Domingo	\N		3	1	t	\N	2025-12-07 06:32:54.949466+00	2026-01-03 07:00:34.063688+00	1	\N	t	f	4001	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
110	1e947f1b-1770-4d63-bd09-2a0a8d81c266	14008	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Charchalac Cox, Victor Raul	\N	\N	3	7	t	\N	2025-12-07 06:32:56.213129+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	14008	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
118	cd66bb0d-80e3-4935-b102-682c577bead9	15002	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Alonzo Morales, Victor Manuel	\N	\N	3	7	t	\N	2025-12-07 06:32:57.143825+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15002	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
120	50847a06-13c0-4645-95f7-a706c67763dd	15004	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Argueta Bernal, Beyker Eduardo	\N	\N	3	1	t	\N	2025-12-07 06:32:57.148386+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15004	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
114	8de8045d-b143-4624-a229-b153dd967260	14020	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Najarro Moran, Dular Migdael	\N	\N	3	1	t	\N	2025-12-07 06:32:56.782848+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	14020	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
127	0fc39b5e-bfa9-48b6-b0cb-ee3b5797555e	15015	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Belloso Flores, Carlos Alex	\N	\N	3	1	t	\N	2025-12-07 06:32:57.155953+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15015	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
113	7bfbb293-8aef-4e00-82fd-85ce0a6dead3	14017	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Monterroso Perez, Mynor Rene	\N	\N	3	1	t	\N	2025-12-07 06:32:56.633151+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	14017	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
103	75ddca7a-ed92-4587-9172-91ccaed29ea6	13022	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Salgado Kegel, Romeo Alberto	\N	\N	3	1	t	\N	2025-12-07 06:32:55.359807+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	13022	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
161	5813b49a-4769-4316-a908-0d7b05dabeac	15073	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Manzano Pérez Joseph Alexander	\N	\N	3	1	t	\N	2025-12-07 06:32:57.395292+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15073	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
274	898ca555-fd86-4035-9781-338aefcee423	16152	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Tecú Raxcacó Víctor Manuel	\N	\N	3	1	t	\N	2025-12-07 06:32:57.818458+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16152	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
116	50da0dc0-8143-42c5-b20b-91861a5de61b	14024	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Santos Loy, Hiben Amadiel	\N	\N	3	1	t	\N	2025-12-07 06:32:56.938625+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	14024	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
159	5f4bd0e7-3829-45ba-a04b-fccff48d502f	15068	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Lima Yanes Jerson Geovani	\N	\N	3	1	t	\N	2025-12-07 06:32:57.392819+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15068	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
520	174cb93b-7332-40df-8d6e-e12f847c1018	19155	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Tagua Zanunzini Frank Antonni	\N	\N	3	1	t	\N	2025-12-07 06:33:00.362326+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19155	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
525	c5ea0648-c935-42e9-8999-72a2ede6f569	19160	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Valenzuela Asencio Lucas David	\N	\N	3	6	t	\N	2025-12-07 06:33:00.368137+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19160	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
172	2a1545e7-ae2f-43a5-8b24-eb1d396a9548	15089	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morales Barrientos, Marta Berenice	\N	\N	3	4	f	\N	2025-12-07 06:32:57.458534+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15089	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
560	4482625c-c533-456e-93f5-fca8a75854e7	23	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cotto Trejo, Manuel Dario	\N	\N	3	6	f	\N	2025-12-07 06:33:00.506337+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	23	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
186	43f30e66-730f-45e3-84ee-2b1bd6429e3a	15116	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Rivas Regalado, Carlos Dagoberto	\N	\N	3	6	f	\N	2025-12-07 06:32:57.474653+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15116	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
187	61418fd4-d680-44a0-8021-9f65d5101415	15122	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ruano Corado, Luzbeth Yaneth	\N	\N	3	5	f	\N	2025-12-07 06:32:57.475607+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15122	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
199	5a6e80e1-28ed-4b9e-99aa-c2a8fbb66f43	16002	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Aguilar Castillo, Santos Amilcar	\N	\N	3	2	f	\N	2025-12-07 06:32:57.537807+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16002	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
67	6b5b9027-d1a7-4e1c-aaca-f62d824ec036	10021	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	LUC PEREZ, JOSUE	\N	\N	3	6	f	\N	2025-12-07 06:32:55.108838+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	10021	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
223	f58c64d0-031c-408f-860a-54898dff0c6d	16060	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Franco Sierra Edgar Saray	\N	\N	3	7	f	\N	2025-12-07 06:32:57.611801+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16060	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
226	1ef2354e-a623-4167-b0f8-47a51d1d2181	16065	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Jimenez Gonzales Rafael Estuardo	\N	\N	3	2	f	\N	2025-12-07 06:32:57.614236+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16065	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
556	05341f67-7305-46d2-89a5-f831c5fa9333	19	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Jimenez Muñoz, Josue Donaldo	\N	\N	3	1	f	\N	2025-12-07 06:33:00.502103+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
543	991a3b17-8409-4bb4-878e-a0efd6b5411b	6	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Quevedo Donis, Helen Paola	\N	\N	3	9	f	\N	2025-12-07 06:33:00.438228+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	6	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
544	91da46da-a6da-464a-b660-c40dd16ae136	7	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Martinez Carias, Katherin Damaris	\N	\N	3	3	f	\N	2025-12-07 06:33:00.439212+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	7	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
549	3baaf7e6-455a-4a11-a93c-10aae674d672	12	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Lemus Batancourt, Rony Omar	\N	\N	3	6	f	\N	2025-12-07 06:33:00.445078+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	12	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
554	7c4e6a19-f145-49fd-a278-25b6d44828a8	17	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cotzajay Sandoval, Joseb Enmanuel	\N	\N	3	1	f	\N	2025-12-07 06:33:00.499956+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	17	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
181	856153af-f4ab-49e7-aedd-ac7ce1b60c4e	15101	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pérez Melgar, José Carlos.	\N	\N	3	9	f	\N	2025-12-07 06:32:57.469452+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15101	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
451	7342eeae-9dde-49cd-9e7c-bc0ff08b5d2e	19086	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Linares Linares, Anthony Isael	\N	\N	3	3	f	\N	2025-12-07 06:33:00.081325+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19086	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
77	c3567b29-e7f9-4030-91a4-4dbbbd876c25	11017	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Garcia Lima, Edy Reginaldo	\N	\N	3	1	t	\N	2025-12-07 06:32:55.167423+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	11017	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
75	2b258206-1414-44c5-8c47-470722d31172	11006	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Atz Argueta, Jose Vicente	\N	\N	3	1	t	\N	2025-12-07 06:32:55.165417+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	11006	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
244	78fecbfa-75d3-42b3-b087-335fa62208a1	16095	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Marroquin Argueta, Esleyder Antonio	\N	\N	3	1	t	\N	2025-12-07 06:32:57.683806+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16095	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
476	8c73f709-15f8-4e2e-99ca-705ead207133	19111	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Willian Estuardo, Najarro Osorio	\N	\N	3	1	t	\N	2025-12-07 06:33:00.161486+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19111	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
564	6cdbe7f9-6c26-425a-8b9d-088d3804a1ae	27	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Jumique Oliva, Yoyi Natasha	\N	\N	3	9	f	\N	2025-12-07 06:33:00.512724+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	27	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
57	2c407ad6-ae0b-489c-9d37-c0a46ebabe12	8047	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Suchite Orellana, Maynor	\N	\N	3	4	f	\N	2025-12-07 06:32:55.098363+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	8047	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
65	69951274-7e65-47a0-b3e2-7a696c71677d	10006	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	CARRETO PEREZ WENDY YOMARA	\N	\N	3	2	f	\N	2025-12-07 06:32:55.105548+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	10006	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
71	37fc7ca4-ae25-4725-a654-c93fd52fe656	10034	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	REVOLORIO ORTIZ JHONY MARTIN	\N	\N	3	7	f	\N	2025-12-07 06:32:55.112615+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	10034	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
76	a837677c-4b43-4029-a7b8-488f7a7413b1	11014	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Galicia Galicia, Marcela	\N	\N	3	8	f	\N	2025-12-07 06:32:55.166406+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	11014	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
240	9ee000cb-df00-478c-9d18-b10440b10a73	16088	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	LINARES CRUZ ESDRAS EFRAIN	\N	\N	3	4	f	\N	2025-12-07 06:32:57.67874+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16088	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
260	24346673-4377-4dbb-9a84-746c4909a86f	16125	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Piox Cadenas Edwin Leonel Enrique	\N	\N	3	5	f	\N	2025-12-07 06:32:57.751894+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16125	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
278	ee321fc8-add0-4640-a53f-aad1d6eec23f	16157	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Zepeda Chavez, Axel Ariel	\N	\N	3	1	t	\N	2025-12-07 06:32:57.822307+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16157	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
309	742bdbeb-4b7b-4ee2-b1c2-eba727950eef	17048	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Santiago Sánchez, Joel Antonio	\N	\N	3	1	t	\N	2025-12-07 06:32:57.950892+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	17048	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
284	9dde5fbb-f08a-4568-8d8b-5b6f3a39dd05	17014	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Kenia Estrella Barrientos Mendez	\N	\N	3	7	f	\N	2025-12-07 06:32:57.876683+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	17014	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
300	70843720-846b-4a5c-ae50-1f6ac38bfc62	17035	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Moran Florian, Astrid Rosmery	\N	\N	3	7	f	\N	2025-12-07 06:32:57.891923+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	17035	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
305	9535ce42-5e8f-45ea-885d-ddcea74a689b	17040	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Osorio Echeverria, Alicia Yamilet	\N	\N	3	5	f	\N	2025-12-07 06:32:57.946276+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	17040	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
307	42a6eca8-96ee-4b47-9c6b-a327e2c447de	17046	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Sagastume Castillo Jose Manuel	\N	\N	3	8	f	\N	2025-12-07 06:32:57.948737+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	17046	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
312	6791bd50-7a52-4cd0-b719-2986be5102c1	18001	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Jorge Amilcar Aceituno Santos	\N	\N	3	8	f	\N	2025-12-07 06:32:57.953784+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	18001	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
335	8c50cd06-5a45-4aae-af32-fca99725d878	18024	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Figueroa Moran, Edwin Alexander	\N	\N	3	1	t	\N	2025-12-07 06:32:58.806192+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18024	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
38	7ef34a8e-a88c-4085-936b-837af134522c	5003	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cumez Chacach, Fredy	\N	\N	3	7	t	\N	2025-12-07 06:32:55.022413+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	5003	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
317	f58a0e49-414d-4c86-af5a-d81efc5a340c	18006	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Walter Alexander Barrios Blanco	\N	\N	3	5	f	\N	2025-12-07 06:32:57.959596+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	18006	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
318	c17939f2-bfdf-4b9f-890f-9a0f09ed111e	18007	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Claudia Lucrecia Caal Cucul	\N	\N	3	5	f	\N	2025-12-07 06:32:57.960631+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	18007	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
342	51783cf6-4fd7-4baf-b948-65600f2c1939	18031	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernandez Sandoval Helen Emilsa	\N	\N	3	5	f	\N	2025-12-07 06:32:59.649252+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	18031	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
356	816b73de-eb4f-4e0a-b8f9-bdbaece7ba08	18045	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ramirez Monroy Wilson Giovany	\N	\N	3	9	f	\N	2025-12-07 06:32:59.721445+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	18045	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
389	315bc763-212a-48e5-9f0a-185f6bf4822a	19024	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Castillo Godoy, Mario Alejandro	\N	\N	3	1	t	\N	2025-12-07 06:32:59.857306+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19024	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
393	7cf9b825-33a3-4311-a1c8-5c817554d4dc	19028	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Chinchilla Corado, Darwin Omar	\N	\N	3	1	t	\N	2025-12-07 06:32:59.861979+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19028	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
414	7b0c6e25-a242-4847-889f-68eb32654509	19049	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Fuentes Cruz, Luis Diego	\N	\N	3	1	t	\N	2025-12-07 06:32:59.985381+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19049	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
541	d26bb41c-6de2-4ecc-afa9-76ecacd9f125	4	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Godoy Chinchilla, Emeldi Eulalia	\N	\N	3	7	f	\N	2025-12-07 06:33:00.436683+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	4	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
272	3d36f0e5-99b8-457b-a962-472bc44ad6bd	16150	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Solares Carias Jorge	\N	\N	3	7	f	\N	2025-12-07 06:32:57.816299+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16150	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
182	556b3209-cc17-4531-bab7-410f1462e9ff	15102	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pérez Morales, Anibal Eliandro	\N	\N	3	7	f	\N	2025-12-07 06:32:57.470351+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15102	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
538	77b8e397-e480-4bb8-87f2-2876bc865082	1	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Araus Velasquez, Kevin Manfredo	\N	\N	3	5	f	\N	2025-12-07 06:33:00.43246+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	1	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
208	1006a9ae-d01d-4b38-9232-9654df4437c4	16023	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Castillo García, Cesar José	\N	\N	3	9	f	\N	2025-12-07 06:32:57.549628+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16023	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
15	9536036c-6c56-4acd-86e9-8ed6f110bbfa	00001	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Agente Brigada 01	brigada01@provial.gob.gt	\N	3	1	t	2025-12-08 22:09:11.856415+00	2025-12-07 06:30:43.529651+00	2026-01-03 07:48:40.310804+00	1	2025-12-07	t	f	00001	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
228	d8575a4d-95db-4c0a-b649-cc723423f019	16068	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	González Estrada, Marlon Estuardo	\N	\N	3	8	f	\N	2025-12-07 06:32:57.616427+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16068	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
201	b0b4cf03-a92b-445d-9c78-4f31218aeff8	16013	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Calderón Hector Oswaldo	\N	\N	3	4	f	\N	2025-12-07 06:32:57.54117+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16013	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
202	90269213-3c6d-43c8-b746-83efb138cd92	16014	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Calderón López Clara Luz	\N	\N	3	1	f	\N	2025-12-07 06:32:57.542371+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16014	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
562	9b3578d7-ae43-424d-b2e8-e5bf6f09eb69	25	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández Palencia, Yasmin María Paola	\N	\N	3	4	f	\N	2025-12-07 06:33:00.509617+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	25	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
462	4a0f0267-77b7-4529-9057-7aba00739122	19097	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Maradiaga Ramos Otto René	\N	\N	3	7	f	\N	2025-12-07 06:33:00.092578+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19097	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
493	1860aae6-3d32-416b-a776-4b2d164ef36e	19128	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Quiñónez Ramos, Edwin René	\N	\N	3	3	f	\N	2025-12-07 06:33:00.231441+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19128	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
351	11064086-4452-4023-b00f-d90e095c020a	18040	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Fernando Iván Peñate Rodriguez	\N	\N	3	2	f	\N	2025-12-07 06:32:59.715869+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	18040	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
157	fa9f9492-5ecd-4cfe-99bb-8fb642d0a92e	15065	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Jiménez González, Rafael Estuardo	\N	\N	3	7	f	\N	2025-12-07 06:32:57.339352+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15065	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
189	720ad90c-1cd7-4f15-ae6f-679f463e642b	15124	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Salazar Gutiérrez, Angel José	\N	\N	3	2	f	\N	2025-12-07 06:32:57.477371+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15124	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
249	4792dbfd-68fe-4a4d-9d4a-1a7f4aba0aea	16102	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Méndez Ortiz, Juan José	\N	\N	3	7	f	\N	2025-12-07 06:32:57.688548+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16102	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
188	433ababe-0f1b-4833-9f98-f4c755c86f1e	15123	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ruiz Ruiz, José Fabricio Alizardy	\N	\N	3	5	f	\N	2025-12-07 06:32:57.476468+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15123	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
542	47df8995-83e4-4406-a0e7-20e2b92ee076	5	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Tuells Agustín, Alisson Mariana	\N	\N	3	3	f	\N	2025-12-07 06:33:00.437473+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	5	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
392	201a28fa-746b-482a-9b4d-0b38275f984c	19027	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Chávez Peña, Darwin Ronald	\N	\N	3	6	f	\N	2025-12-07 06:32:59.860987+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19027	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
215	767d5d26-7c19-497d-af42-a9ed5d1b627f	16040	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cortéz Menéndez, Oscar Anibal	\N	\N	3	1	t	\N	2025-12-07 06:32:57.604324+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16040	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
129	e303f302-3037-4ff4-a33c-a2067dbff4f8	15018	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cárdenas Argueta, Allan Josué	\N	\N	3	8	f	\N	2025-12-07 06:32:57.158121+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15018	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
152	c7819f4d-156e-4097-b48e-aefd4d5c2fbe	15058	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gudiel Osorio, Cedín Fernando	\N	\N	3	3	f	\N	2025-12-07 06:32:57.33502+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15058	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
217	9ac5919e-4e4c-4dd8-a53a-74bc592f7a9c	16044	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Del Cid Hernández, Junior Humberto	\N	\N	3	8	f	\N	2025-12-07 06:32:57.606219+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16044	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
282	a35d695b-f031-445b-99cf-d1151ff65096	17010	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Peñate Moran, Ana Mary	\N	\N	3	1	t	\N	2025-12-07 06:32:57.873969+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	17010	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
93	0fabf269-adad-4448-ac5a-15114369cc2c	12024	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Obregón Chinchilla, Jorge Luis	\N	\N	3	1	t	\N	2025-12-07 06:32:55.183086+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	12024	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
128	c5cb5ae4-c5c3-486f-9b94-d083d1deae82	15017	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cabrera Suchite, Kleiver Josué	\N	\N	3	1	t	\N	2025-12-07 06:32:57.157123+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15017	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
198	08e7ee87-f6f8-425e-a73e-698bc4a94122	16001	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Adqui López Arly Paola	\N	\N	3	3	f	\N	2025-12-07 06:32:57.536359+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16001	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
173	cbd26b38-267c-4127-9bb1-6cf8f85043f6	15091	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morales Lemus, Héctor Adulfo	\N	\N	3	5	f	\N	2025-12-07 06:32:57.459656+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15091	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
295	0bb6aeb3-0583-4a35-bc41-c7d1b85c78f6	17027	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Jimenez Castillo Erick Geovanny	\N	\N	3	1	t	\N	2025-12-07 06:32:57.887618+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	17027	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
343	c7100795-2f70-49af-bff2-540430b9b617	18032	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Jorge López, Kimberly Alejandra	\N	\N	3	1	t	\N	2025-12-07 06:32:59.651489+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	18032	\N	f	FEMENINO	4	f	f	\N	\N	\N	{}	f
251	4ac9bcf1-5835-4f7a-b941-c43b36c8a770	16105	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morales Gómez, Mario Fernando	\N	\N	3	6	f	\N	2025-12-07 06:32:57.69073+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16105	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
254	aa3a6a73-292f-4e79-b332-7eab7cdf27c3	16109	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morán Puaque Elmar Rolando	\N	\N	3	3	f	\N	2025-12-07 06:32:57.693532+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16109	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
259	e9a82b38-e91a-4f98-9364-d94417f7aaf2	16119	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pérez Garrido Mailyng Leilani	\N	\N	3	6	f	\N	2025-12-07 06:32:57.750676+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16119	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
265	c021d8d5-afcf-4d46-8718-b381277b868e	16135	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Rodríguez Larios, Pedro Caín	\N	\N	3	6	f	\N	2025-12-07 06:32:57.809222+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16135	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
271	a63c2589-c16c-44dd-ae7a-3866722b35a4	16147	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Sifuentes Ávila Kevin Ernesto	\N	\N	3	6	f	\N	2025-12-07 06:32:57.815288+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16147	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
288	4692bdcf-bffb-4c28-8315-ec744fe770c6	17018	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cermeño Pineda Evelin Siomara	\N	\N	3	2	f	\N	2025-12-07 06:32:57.880895+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	17018	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
296	7998ace2-c188-4b8c-b7a8-e94ecb850c0a	17029	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	López Carranza Sandra Soeveldiny	\N	\N	3	4	f	\N	2025-12-07 06:32:57.888403+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	17029	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
230	4a5125a1-b2b6-4ddf-964f-a124ec69870f	16074	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Gutiérrez Herrera, Edvin Edilson	\N	\N	3	6	f	\N	2025-12-07 06:32:57.618381+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16074	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
237	0c1ca580-7a6c-4bdd-986a-dadddc3ae19b	16082	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hurtado Asencio, María De Los Ángeles	\N	\N	3	3	f	\N	2025-12-07 06:32:57.674787+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16082	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
267	b7f502eb-b4bd-4400-9d09-3174bd21ab08	16143	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Santizo Bojorquez, Alexis Efraín	\N	\N	3	4	f	\N	2025-12-07 06:32:57.811551+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16143	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
563	3df2d43d-7162-492b-986c-14a598a22d92	26	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	López Cifuentes, Karla Victoria	\N	\N	3	9	f	\N	2025-12-07 06:33:00.511702+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	26	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
376	56aadbd4-0c13-4dd4-b43c-b19f7c5509ac	19011	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Bailón Hernández Andy Adalberto	\N	\N	3	2	f	\N	2025-12-07 06:32:59.794499+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19011	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
304	18793412-b6eb-46e8-aa8d-72589e975cae	17039	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ortiz Catalán, Geovanni José Maria	\N	\N	3	1	t	\N	2025-12-07 06:32:57.944708+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	17039	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
373	0bb7d938-7e34-4759-8592-f21254989b14	19008	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Arana Martínez, Pedro Alberto	\N	\N	3	1	t	\N	2025-12-07 06:32:59.791098+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19008	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
387	bcdbb786-70b7-4f0d-ac2a-61411c8cb88d	19022	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Carías Castro, Mario Llivinson	\N	\N	3	1	t	\N	2025-12-07 06:32:59.855428+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19022	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
420	5ea2c917-1b5f-45d4-9c4e-22dc6525c19e	19055	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	García Esquivel Cristian Xavier	\N	\N	3	8	f	\N	2025-12-07 06:32:59.992862+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19055	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
455	3651f273-ba91-4ea9-ab50-5853f93e4dcb	19090	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	López Coronado, Fernando	\N	\N	3	1	f	\N	2025-12-07 06:33:00.085188+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19090	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
410	6034fdf7-8f42-4692-b11a-386f616cae2b	19045	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Flores Latín Junior Antonio	\N	\N	3	4	f	\N	2025-12-07 06:32:59.932794+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19045	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
446	aa3d9078-1253-412d-a78a-398ae45966e9	19081	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pineda Jiménez, Cristopher Oswaldo	\N	\N	3	4	f	\N	2025-12-07 06:33:00.075924+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19081	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
444	4c4deff1-12d1-4322-a108-f337b7cc4294	19079	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ica Gómez, Ketherine Rocío	\N	\N	3	8	f	\N	2025-12-07 06:33:00.074193+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19079	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
488	e1782ade-705a-456d-848c-99ce3eb15ebb	19123	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pérez Velásquez, Gerber Estuardo	\N	\N	3	9	f	\N	2025-12-07 06:33:00.223809+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19123	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
552	4b97791a-7db0-41c7-aa8d-05fc359ccae7	15	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Munguía Flores, Vivian Guadalupe	\N	\N	3	2	f	\N	2025-12-07 06:33:00.496655+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
385	11dcefab-cf26-4a7e-8c25-6ba29de7e39e	19020	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cardona Coronado Ronald Geremías	\N	\N	3	1	t	\N	2025-12-07 06:32:59.853438+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	19020	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
557	f018e06d-38a5-4de4-b002-b11153d9b3ea	20	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Jerónimo Estrada, Jeison Ernesto	\N	\N	3	8	f	\N	2025-12-07 06:33:00.503226+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	20	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
545	4718b855-544a-4e7a-b495-88c5d0b9cc33	8	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ché Ichich, Victor Manuel	\N	\N	3	8	f	\N	2025-12-07 06:33:00.44064+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	8	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
547	25d07dfb-0700-43cc-b93e-d933b1bb5776	10	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Juarez Alfaro, Mábel Sofía	\N	\N	3	8	f	\N	2025-12-07 06:33:00.443145+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	10	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
548	4298dced-8a56-4f8f-9972-f2bb158f950b	11	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Maldonado Mejía, Ylin Guadalupe	\N	\N	3	6	f	\N	2025-12-07 06:33:00.444253+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	11	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
532	86b1bd48-ccd6-4c1b-8e56-9a7194f78085	19167	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Velásquez Latín, Abner Alexis	\N	\N	3	2	f	\N	2025-12-07 06:33:00.377313+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19167	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
546	4b562b14-fd7a-4f89-8479-f87328972285	9	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Galicia López, Ingrid Noemí	\N	\N	3	6	f	\N	2025-12-07 06:33:00.441824+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	9	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
551	0b486137-c2d8-401f-9c43-4f4bc722afdc	14	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Marroquín Marroquín, Katerine de Jesús	\N	\N	3	3	f	\N	2025-12-07 06:33:00.446841+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	14	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
553	b8ea679b-22b5-4d72-9829-d12cb4f9cbfd	16	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Godinez Matal, Wilder Neptalí	\N	\N	3	4	f	\N	2025-12-07 06:33:00.498519+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
550	d46fe39f-f67f-4b27-86a8-88960598300b	13	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Miranda Aguilar, Jenner Moisés	\N	\N	3	8	f	\N	2025-12-07 06:33:00.445858+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	13	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
540	58704b25-6c1a-4245-9360-c2c6d011a06c	3	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ordóñez Tzoc, Erick Alberto	\N	\N	3	8	f	\N	2025-12-07 06:33:00.435769+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	3	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
83	bc744508-3290-4d05-b5ff-81d3de9dcbb4	11040	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Torres Galvan Luis Fernando	\N	\N	3	1	t	\N	2025-12-07 06:32:55.172817+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	11040	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
23	73e2b25d-bcae-4b99-a5f0-33bf739d5119	3018	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Herrarte Silva, Gustavo Adolfo	\N	\N	3	1	t	\N	2025-12-07 06:32:54.943089+00	2026-01-03 07:00:42.630455+00	1	\N	t	f	3018	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
213	53cc12fe-b6a9-4ff1-85d8-b8ce52e7ad28	16037	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Corado Ramírez, Claudia Fabiola	\N	\N	3	6	f	\N	2025-12-07 06:32:57.602143+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16037	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
234	474ce902-7a05-4c64-9bf7-075650bf4a5b	16078	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández Giron Yonathan Alexander	\N	\N	3	5	f	\N	2025-12-07 06:32:57.67044+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16078	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
236	c85412b9-8be8-4189-9603-34440339d286	16080	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández Palencia, Albert Gennady	\N	\N	3	2	f	\N	2025-12-07 06:32:57.673268+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16080	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
241	f5d43702-4ea3-48b3-92f9-af298b4cba52	16089	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	López Alonzo, Marcos Daniel	\N	\N	3	5	f	\N	2025-12-07 06:32:57.68005+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16089	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
245	66e74b43-c185-4cbd-a97c-904b4929c7fe	16096	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Martínez Anavisca Brian Luis Felipe	\N	\N	3	2	f	\N	2025-12-07 06:32:57.68467+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16096	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
523	df78f67b-c6a6-4fd7-8122-c95debaebd3c	19158	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Tzunux Hernández, Jose Daniel	\N	\N	3	8	f	\N	2025-12-07 06:33:00.365743+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19158	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
34	1a70a9b0-7361-4188-aa97-950929aa304d	4046	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Salazar Portillo, Pedro Antonio	\N	\N	3	1	t	\N	2025-12-07 06:32:54.957304+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	4046	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
353	d6fdc871-d79c-4f43-9370-2df5e35f767b	18042	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pérez Osorio, Rudy Osmín	\N	\N	3	1	t	\N	2025-12-07 06:32:59.717976+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	18042	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
404	59f7856d-c9f9-4d28-8ddb-f52ac5276285	19039	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Dominguez Gaitán, Amalio Rodrigo	\N	\N	3	1	t	\N	2025-12-07 06:32:59.926143+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19039	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
417	364dd436-190a-452d-97ea-69d5d147fd8a	19052	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Galindo Hernández, Osmin Manolo	\N	\N	3	1	t	2025-12-15 06:56:50.685914+00	2025-12-07 06:32:59.988873+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19052	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
459	30e717c8-80e4-4db2-ab3c-8853c33b4ca4	19094	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	López Peña, Luis Fernando	\N	\N	3	1	t	\N	2025-12-07 06:33:00.089049+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19094	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
526	562c6094-1dd0-40a5-9971-9498557584a5	19161	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Vásquez Domínguez, Omer Naias	\N	\N	3	7	t	\N	2025-12-07 06:33:00.369492+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19161	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
308	7ec907d1-6401-42df-a9d2-37a8c253f973	17047	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Sandoval Aguilar, Rubí De Los Angeles	\N	\N	3	8	t	\N	2025-12-07 06:32:57.950017+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	17047	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
352	d140b963-47a4-454d-886d-4953e4ca211f	18041	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Melvin Adalberto Pérez Coc	\N	\N	3	4	f	\N	2025-12-07 06:32:59.716825+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	18041	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
35	45ae9e51-2bde-43c5-af00-c31437266ed7	4053	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Vicente Ajtun, Moises	\N	\N	3	5	f	\N	2025-12-07 06:32:54.958355+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	4053	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
325	ca14be0a-184d-44d5-8287-fc6c826c585c	18014	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cristian Abraham Citalin Custodio	\N	\N	3	7	f	\N	2025-12-07 06:32:57.970924+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	18014	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
261	d2e0b700-3c37-4d6f-82c2-314f62e70238	16126	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Quintana Barrientos, Mario Roberto	\N	\N	3	5	f	\N	2025-12-07 06:32:57.802976+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16126	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
37	2fbd0921-81d5-4d66-ba2c-b3d47d03c897	5000	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Aquino Escobar, Juan	\N	\N	3	5	f	\N	2025-12-07 06:32:55.020645+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	5000	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
316	8d6f06cb-e088-4277-8d51-656cfcd444de	18005	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Asencio Corado, Ronal Israel	\N	\N	3	3	f	\N	2025-12-07 06:32:57.958446+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	18005	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
368	43c5be8c-2e51-42ee-8d03-6a32c8e7a650	19003	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Aguirre Palma Luis Angel	\N	\N	3	6	f	\N	2025-12-07 06:32:59.783354+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19003	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
372	8a79cf8e-e40b-482a-8e71-31ce47c2ec29	19007	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Arana García, José David	\N	\N	3	5	f	\N	2025-12-07 06:32:59.789738+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19007	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
107	bcf22047-a35d-4600-9d8b-8c43efb1b68b	14003	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Argueta, Guilver Yónatan	\N	\N	3	4	f	\N	2025-12-07 06:32:55.882539+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	14003	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
221	6611f4e2-75d9-4af5-affd-66672a0c37a0	16053	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Escobar Hernández Yeison Humberto	\N	\N	3	4	f	\N	2025-12-07 06:32:57.610229+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	16053	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
539	7942c0ec-659e-4737-bf74-ab9f985be70f	2	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Hernández Colaj, Josué David	\N	\N	3	4	f	\N	2025-12-07 06:33:00.434323+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	2	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
197	a1b90ee1-0179-407b-b237-312edcc04140	15139	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Zuñiga Fernández German Danilo	\N	\N	3	1	t	\N	2025-12-07 06:32:57.535171+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15139	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
419	d944d920-02b0-40af-9c11-a26c359a32a5	19054	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	García Bertránd Yeison Wilfredo	\N	\N	3	4	t	\N	2025-12-07 06:32:59.991196+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19054	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
961	0eab439f-7843-4cfa-b0e1-58a05cf4b70d	11020	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Guerra Marroquin Joel Wilfredo	\N	\N	3	1	t	\N	2025-12-14 22:23:11.302582+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	11020	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
310	2deb5688-cd33-43e9-b1bf-3e7a1631ac11	17050	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Velásquez Yat Daniel Oswaldo	\N	\N	3	1	t	\N	2025-12-07 06:32:57.951767+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	17050	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
345	79a4fccd-05be-4bb6-bbb8-faaa35f754d8	18034	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morales Barrios Anderson Giovani	\N	\N	3	1	t	\N	2025-12-07 06:32:59.657948+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18034	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
981	6e0dcc1a-336f-48db-8573-ff43447a46b7	16045	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Franklin Yoel Diaz Soto	\N	\N	3	1	f	\N	2025-12-14 22:23:11.52371+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16045	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
204	ee9d622b-0549-4f73-8fba-79b9fa92f106	16016	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cano Boteo Irrael	\N	\N	3	1	t	\N	2025-12-07 06:32:57.54435+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16016	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
209	540adc75-4ac9-40a3-92d1-b3eafbd37b36	16031	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Chén Xuc, José Luis	\N	\N	3	3	t	\N	2025-12-07 06:32:57.550894+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16031	\N	f	MASCULINO	\N	t	f	\N	\N	\N	{}	f
30	79fbbce4-8620-4e40-96c6-3723f80ce093	4015	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Fajardo Rodas, Elmer Antonio	\N	\N	3	1	t	\N	2025-12-07 06:32:54.953188+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	4015	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
74	021db388-625f-47f0-b11c-5ea227faf6c2	11004	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Arana Franco, Wagner Danuvy	\N	\N	3	1	t	\N	2025-12-07 06:32:55.164048+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	11004	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
91	bddea5e9-b40e-4e1b-92bb-6b416b113220	12022	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morataya Rosales, Gloria Lizeth	\N	\N	3	1	t	\N	2025-12-07 06:32:55.1813+00	2026-01-03 05:29:22.010762+00	1	\N	t	f	12022	\N	f	FEMENINO	4	f	f	\N	\N	\N	{}	f
61	a969285b-b1e6-4929-86b6-10408ccfcd5f	9016	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Jor Max Ruben Dario	\N	\N	3	1	t	\N	2025-12-07 06:32:55.102066+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	9016	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
44	eba9e992-d21e-42f8-ad50-ee3aafd0895d	6026	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Mateo Lopez, Cesar Everildo	\N	\N	3	1	t	\N	2025-12-07 06:32:55.029959+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	6026	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
369	591b47db-a40d-4a43-b2aa-ffc1947badfa	19004	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Agustín Diego Luis Fernando	\N	\N	3	1	t	\N	2025-12-07 06:32:59.784932+00	2026-01-03 05:29:22.010762+00	2	\N	t	f	19004	\N	f	MASCULINO	4	f	f	\N	\N	\N	{}	f
97	9c13b309-d64e-4fc0-89b6-1384f99aabfc	13008	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Duarte Alay Roberto Carlos	\N	\N	3	1	t	\N	2025-12-07 06:32:55.238273+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	13008	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
141	3ceb75ea-8094-4f2f-9384-34fc284cc8b1	15036	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Donis Ortíz, Marco Tulio	\N	\N	3	1	t	\N	2025-12-07 06:32:57.271077+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15036	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
518	a3b300d1-7a9a-4134-b929-3018d9ffc79a	19153	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Santizo Valdez Angela Noemí	\N	\N	3	7	f	\N	2025-12-07 06:33:00.360171+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	19153	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
43	79e946fc-c718-429f-8957-1c93d65e707e	6008	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	CAXAJ GIRON JACOB	\N	\N	3	5	f	\N	2025-12-07 06:32:55.028679+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	6008	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
139	c7d8cd37-2565-4b0e-8179-7f9beae2170f	15030	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Cortez Cisneros,Juan Wilberto	\N	\N	3	6	f	\N	2025-12-07 06:32:57.268873+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15030	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
92	b8864ae9-1809-4d71-ad12-adec55667bb9	12023	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	MOREIRA HERNANDEZ JOSE ADEMIR	\N	\N	3	6	f	\N	2025-12-07 06:32:55.182275+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	12023	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
88	50870c09-6d79-478f-9862-7c00390c5f16	12010	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Esquivel Herrera, Blas Roosenvelt	\N	\N	3	7	t	\N	2025-12-07 06:32:55.178784+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	12010	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
203	68a9b318-45eb-4a4e-b2b8-8896111fd486	16015	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Camó Acoj, Cristhian Geovany	\N	\N	3	8	t	\N	2025-12-07 06:32:57.543434+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	16015	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
87	eec70140-3090-470c-af5f-4f747016ee3b	12005	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Castillo Aguilar Breder Vidani	\N	\N	3	1	t	\N	2025-12-07 06:32:55.177991+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	12005	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
89	c1a30240-7717-4b0d-993e-e47085df9b56	12014	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Jimenez Cortez David Isaias	\N	\N	3	1	t	\N	2025-12-07 06:32:55.179612+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	12014	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
59	cc50f99e-9235-479f-8d03-4fd8bee1c309	9006	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Oliva Paiz, Ubaldo	\N	\N	3	4	t	\N	2025-12-07 06:32:55.100258+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	9006	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
96	2ac5b2a7-0bf5-4d66-91ff-c3fa8fc96f2c	12031	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Toj Lopez, William Edilser	\N	\N	3	5	t	\N	2025-12-07 06:32:55.237118+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	12031	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
170	3522c23b-b8f7-4fb0-a898-1a258d557ce8	15086	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Monterroso Argueta Edwin Rodolfo	\N	\N	3	4	f	\N	2025-12-07 06:32:57.455602+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15086	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
408	5e82e2b0-1042-4492-9adb-3b40c178162f	19043	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Esquivel Ramírez Medary	\N	\N	3	8	t	\N	2025-12-07 06:32:59.930458+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	19043	\N	f	FEMENINO	\N	f	f	\N	\N	\N	{}	f
14	4620532f-c660-4840-ab3c-9d0c8234233f	operaciones	$2a$10$uuuesh8giy09pDq9Gp8puOxT5XV83MwJHN5Ue2xTitLiMEAKs90MK	Operaciones Central	operaciones@provial.gob.gt	\N	4	1	t	2026-01-03 07:25:41.822317+00	2025-12-07 06:30:43.330556+00	2026-01-03 07:25:41.822317+00	\N	\N	t	f	\N	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
13	e204d77a-e921-4f27-81ef-f06b08a68026	admin	$2a$10$IKj2Xf6.QAshWktq/lqAOugutnuD4vTj1RruDod9pIG4mgPgLxpyG	Administrador Sistema	admin@provial.gob.gt	\N	10	\N	t	2026-01-04 05:50:00.339254+00	2025-12-07 06:30:43.132445+00	2026-01-04 05:50:00.339254+00	\N	\N	t	f	ADMIN001	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
359	f55a061f-1ca3-494d-8e18-a80716c1a96d	18048	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Reyes Ortiz Abner Antonio	\N	\N	3	1	t	\N	2025-12-07 06:32:59.725111+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	18048	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
432	c664771f-8b7d-47cf-85a0-05364931c14e	19067	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	González Alfaro, Eddy Rafael	\N	\N	3	1	t	\N	2025-12-07 06:33:00.062319+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	19067	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
275	0fc0078d-2435-4f9b-900d-a538224041f3	16153	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Valladares González Héctor Nóel	\N	\N	3	1	t	\N	2025-12-07 06:32:57.819466+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	16153	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
47	58ea471c-faf1-4b9d-b79b-5894ab1516b5	7010	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	De Leon Roldan, Marcos Roberto	\N	\N	3	1	t	\N	2025-12-07 06:32:55.033844+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	7010	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
18	4a030601-58a1-4c65-88fe-3c6387219980	1006	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Santos Avila, Marvin, Donato	\N	\N	3	7	t	\N	2025-12-07 06:32:54.933229+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	1006	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
119	56005258-18e0-4117-b750-70bcbab2bf85	15003	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Ardiano Velásquez, Abdi Abisaí	\N	\N	3	5	t	\N	2025-12-07 06:32:57.146168+00	2025-12-31 05:08:11.619437+00	1	\N	t	f	15003	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
41	bc86a525-eabf-47c7-8280-a95d8c27632c	5037	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Quiché Velásquez, Bartolo	\N	\N	3	1	t	\N	2025-12-07 06:32:55.026276+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	5037	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
174	fdccc737-bfe4-4936-9285-96a4905a8f22	15094	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Morán López, Jayme Josue.	\N	\N	3	7	t	\N	2025-12-07 06:32:57.460649+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15094	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
180	0d259849-e254-4cd2-92d5-06ecf3c096b3	15100	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Pérez Asencio, Ronal Orlando	\N	\N	3	7	t	\N	2025-12-07 06:32:57.468378+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	15100	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
17	8c679a2b-d47c-4279-81da-b37d7983fb45	1032	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Mazariegos Rodríguez, Julio Orlando	\N	\N	3	2	t	\N	2025-12-07 06:32:54.930511+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	1032	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
46	c4a82c9f-6fbb-4a7e-8b42-6dd871ced2cd	7006	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Carrillo Hernàndez, Juan Alberto	\N	\N	3	2	t	\N	2025-12-07 06:32:55.032454+00	2025-12-31 05:08:11.619437+00	2	\N	t	f	7006	\N	f	MASCULINO	\N	f	f	\N	\N	\N	{}	f
115	8c324475-42b6-4d00-8efb-a06e7ef48ad4	14023	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Rodriguez Quiñones, Marvin Alexander	\N	\N	3	6	f	\N	2025-12-07 06:32:56.835855+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	14023	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
117	e0034ba7-1d1e-4114-b731-bd628e1a21ce	15001	$2a$10$CISwkpfzJQIyGITmYNFznuM60YSdzDqENfOVbfQ70wzuVJ96KGk6q	Adriano Hernández, Adolfo Estuardo	\N	\N	3	6	f	\N	2025-12-07 06:32:57.041018+00	2025-12-31 05:08:11.619437+00	\N	\N	t	f	15001	\N	f	\N	\N	f	f	\N	\N	\N	{}	f
\.


--
-- Data for Name: usuario_inactividad; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.usuario_inactividad (id, usuario_id, motivo_id, fecha_inicio, fecha_fin_estimada, fecha_fin_real, observaciones, registrado_por, reactivado_por, created_at, updated_at) FROM stdin;
\.


--
-- Data for Name: usuario_rol; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.usuario_rol (id, usuario_id, rol_id, sede_id, es_rol_principal, activo, asignado_por, fecha_asignacion, fecha_revocacion, created_at) FROM stdin;
1	326	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
2	491	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
3	164	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
4	527	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
5	278	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
6	306	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
7	78	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
8	421	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
9	32	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
10	85	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
11	173	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
12	448	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
13	358	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
14	546	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
15	375	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
16	188	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
17	158	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
18	427	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
19	331	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
20	232	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
21	411	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
22	24	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
23	260	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
24	445	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
25	184	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
26	183	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
27	377	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
28	63	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
29	172	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
30	113	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
31	279	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
32	436	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
33	133	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
34	289	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
35	345	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
36	492	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
37	416	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
38	490	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
39	443	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
40	212	9	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
41	420	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
42	100	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
43	308	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
44	150	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
45	283	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
46	300	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
47	223	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
48	128	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
49	38	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
50	240	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
51	456	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
52	130	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
53	272	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
54	565	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
55	548	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
56	217	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
57	231	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
58	55	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
59	494	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
60	403	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
61	170	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
62	244	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
63	118	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
64	88	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
65	535	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
66	374	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
67	68	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
68	202	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
69	263	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
70	216	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
71	453	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
72	14	4	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
73	144	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
74	266	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
75	328	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
76	383	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
77	353	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
78	538	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
79	256	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
80	166	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
81	392	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
82	259	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
83	298	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
84	43	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
85	340	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
86	367	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
87	482	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
88	220	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
89	498	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
90	96	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
91	176	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
92	61	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
93	201	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
94	388	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
95	169	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
96	87	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
97	432	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
98	522	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
99	519	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
100	429	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
101	431	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
102	112	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
103	254	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
104	423	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
105	291	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
106	435	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
107	147	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
108	221	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
109	530	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
110	121	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
111	107	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
112	476	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
113	344	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
114	396	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
115	319	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
116	472	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
117	493	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
118	317	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
119	366	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
120	52	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
121	65	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
122	35	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
123	37	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
124	503	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
125	440	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
126	161	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
127	258	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
128	210	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
129	215	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
130	154	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
131	398	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
132	157	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
133	19	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
134	108	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
135	290	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
136	189	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
137	507	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
138	404	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
139	333	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
140	544	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
141	468	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
142	484	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
143	58	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
144	500	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
145	226	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
146	86	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
147	376	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
148	91	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
149	360	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
150	515	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
151	22	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
152	49	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
153	562	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
154	111	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
155	485	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
156	206	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
157	547	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
158	233	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
159	556	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
160	372	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
161	237	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
162	364	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
163	543	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
164	495	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
165	293	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
166	303	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
167	540	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
168	532	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
169	365	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
170	60	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
171	225	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
172	45	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
173	70	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
174	199	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
175	401	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
176	124	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
177	536	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
178	475	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
179	469	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
180	75	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
181	152	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
182	181	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
183	425	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
184	499	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
185	415	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
186	245	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
187	461	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
188	229	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
189	301	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
190	510	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
191	561	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
192	462	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
193	281	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
194	287	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
195	165	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
196	21	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
197	105	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
198	327	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
199	422	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
200	297	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
201	138	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
202	242	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
203	410	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
204	517	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
205	16	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
206	190	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
207	314	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
208	419	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
209	459	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
210	337	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
211	227	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
212	171	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
213	480	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
214	346	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
215	402	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
216	467	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
217	539	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
218	566	4	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
219	347	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
220	311	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
221	280	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
222	380	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
223	247	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
224	208	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
225	236	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
226	148	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
227	115	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
228	525	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
229	322	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
230	323	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
231	473	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
232	342	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
233	400	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
234	54	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
235	274	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
236	444	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
237	391	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
238	412	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
239	103	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
240	47	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
241	426	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
242	320	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
243	407	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
244	451	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
245	140	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
246	77	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
247	125	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
248	73	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
249	200	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
250	257	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
251	153	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
252	368	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
253	294	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
254	46	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
255	211	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
256	361	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
257	174	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
258	15	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
259	304	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
260	36	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
261	83	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
262	348	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
263	528	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
264	23	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
265	568	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
266	332	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
267	371	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
268	44	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
269	355	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
270	53	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
271	182	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
272	40	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
273	56	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
274	92	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
275	261	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
276	123	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
277	275	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
278	13	1	\N	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
279	222	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
280	277	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
281	18	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
282	134	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
283	481	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
284	90	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
285	450	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
286	324	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
287	502	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
288	42	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
289	143	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
290	192	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
291	146	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
292	139	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
293	59	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
294	557	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
295	219	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
296	81	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
297	505	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
298	552	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
299	393	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
300	34	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
301	441	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
302	385	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
303	321	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
304	79	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
305	428	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
306	282	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
307	521	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
308	296	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
309	273	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
310	250	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
311	167	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
312	350	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
313	116	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
314	271	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
315	381	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
316	193	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
317	98	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
318	424	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
319	338	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
320	243	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
321	466	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
322	433	2	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
323	408	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
324	458	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
325	207	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
326	163	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
327	418	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
328	413	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
329	104	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
330	74	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
331	198	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
332	235	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
333	478	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
334	64	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
335	145	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
336	501	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
337	84	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
338	248	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
339	387	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
340	394	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
341	177	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
342	516	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
343	234	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
344	186	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
345	41	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
346	564	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
347	141	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
348	246	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
349	533	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
350	71	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
351	463	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
352	315	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
353	509	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
354	102	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
355	354	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
356	343	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
357	267	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
358	72	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
359	159	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
360	488	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
361	29	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
362	269	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
363	249	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
364	386	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
365	302	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
366	295	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
367	39	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
368	430	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
369	523	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
370	252	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
371	228	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
372	194	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
373	126	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
374	534	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
375	511	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
376	135	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
377	351	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
378	554	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
379	558	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
380	156	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
381	191	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
382	369	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
383	178	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
384	457	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
385	67	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
386	316	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
387	537	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
388	506	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
389	131	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
390	378	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
391	559	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
392	489	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
393	132	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
394	526	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
395	520	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
396	508	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
397	336	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
398	89	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
399	160	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
400	479	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
401	477	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
402	224	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
403	563	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
404	142	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
405	66	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
406	33	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
407	512	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
408	50	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
409	284	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
410	504	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
411	465	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
412	352	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
413	464	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
414	241	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
415	357	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
416	255	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
417	471	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
418	17	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
419	395	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
420	325	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
421	460	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
422	69	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
423	406	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
424	76	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
425	524	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
426	31	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
427	288	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
428	239	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
429	529	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
430	203	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
431	334	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
432	513	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
433	51	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
434	109	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
435	57	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
436	442	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
437	560	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
438	137	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
439	213	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
440	26	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
441	265	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
442	185	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
443	438	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
444	117	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
445	25	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
446	439	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
447	82	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
448	359	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
449	553	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
450	218	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
451	196	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
452	363	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
453	349	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
454	373	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
455	309	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
456	545	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
457	379	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
458	405	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
459	136	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
460	168	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
461	487	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
462	292	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
463	155	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
464	446	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
465	449	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
466	414	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
467	409	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
468	434	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
469	417	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
470	27	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
471	238	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
472	341	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
473	230	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
474	286	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
475	205	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
476	335	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
477	541	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
478	555	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
479	114	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
480	187	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
481	447	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
482	197	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
483	382	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
484	97	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
485	307	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
486	93	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
487	389	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
488	149	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
489	80	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
490	497	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
491	305	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
492	452	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
493	179	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
494	312	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
495	318	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
496	551	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
497	285	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
498	120	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
499	106	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
500	129	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
501	195	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
502	251	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
503	264	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
504	483	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
505	110	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
506	276	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
507	550	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
508	175	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
509	370	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
510	542	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
511	470	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
512	455	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
513	496	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
514	209	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
515	253	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
516	30	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
517	162	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
518	384	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
520	95	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
521	270	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
522	299	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
523	356	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
524	119	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
525	399	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
526	48	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
527	99	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
528	362	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
529	204	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
530	94	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
531	313	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
532	262	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
533	28	3	1	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
534	20	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
535	339	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
536	101	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
537	390	3	3	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
538	127	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
539	397	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
540	330	3	4	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
541	486	3	8	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
542	329	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
543	518	3	7	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
544	514	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
545	62	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
546	437	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
547	122	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
548	180	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
549	214	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
550	310	3	2	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
551	454	3	9	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
552	531	3	5	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
553	268	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
554	549	3	6	t	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
519	151	3	3	f	t	\N	2025-12-14 19:05:50.546392+00	\N	2025-12-14 19:05:50.546392+00
555	151	9	\N	t	t	212	2025-12-15 05:31:17.074088+00	\N	2025-12-15 05:31:17.074088+00
\.


--
-- Data for Name: vehiculo; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vehiculo (id, placa, es_extranjero, tipo_vehiculo_id, color, marca_id, cargado, tipo_carga, total_incidentes, primer_incidente, ultimo_incidente, created_at, updated_at) FROM stdin;
7	M123HGH	f	\N	Rojo	\N	f	\N	2	2025-12-11 16:22:21.218387+00	2025-12-11 19:06:18.496822+00	2025-12-11 16:22:21.188305+00	2025-12-11 19:06:18.496822+00
\.


--
-- Data for Name: vehiculo_accidente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vehiculo_accidente (id, hoja_accidentologia_id, numero_vehiculo, tipo_vehiculo, placa, marca, linea, modelo_anio, color, numero_chasis, numero_motor, danos_descripcion, danos_estimados, posicion_final, propietario_nombre, propietario_dpi, propietario_telefono, propietario_direccion, conductor_nombre, conductor_dpi, conductor_licencia_tipo, conductor_licencia_numero, conductor_telefono, conductor_direccion, conductor_estado, tiene_seguro, aseguradora, numero_poliza, fotos, created_at) FROM stdin;
\.


--
-- Data for Name: vehiculo_incidente; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.vehiculo_incidente (id, incidente_id, tipo_vehiculo_id, marca_id, modelo, anio, color, placa, estado_piloto, nombre_piloto, licencia_piloto, heridos_en_vehiculo, fallecidos_en_vehiculo, danos_estimados, observaciones, created_at, marca, tarjeta_circulacion, nit, direccion_propietario, nombre_propietario, licencia_tipo, licencia_numero, licencia_vencimiento, licencia_antiguedad, piloto_nacimiento, piloto_etnia, piloto_edad, piloto_sexo, cargado, carga_tipo, carga_detalle, contenedor, doble_remolque, contenedor_detalle, bus_extraurbano, bus_detalle, sancion, sancion_detalle, personas_asistidas) FROM stdin;
\.


--
-- Name: actividad_unidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.actividad_unidad_id_seq', 4, true);


--
-- Name: actualizacion_situacion_persistente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.actualizacion_situacion_persistente_id_seq', 4, true);


--
-- Name: ajustador_involucrado_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ajustador_involucrado_id_seq', 1, false);


--
-- Name: alerta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.alerta_id_seq', 1, false);


--
-- Name: alerta_leida_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.alerta_leida_id_seq', 1, false);


--
-- Name: aprobacion_respuesta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.aprobacion_respuesta_id_seq', 1, false);


--
-- Name: aprobacion_tripulacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.aprobacion_tripulacion_id_seq', 1, false);


--
-- Name: articulo_sancion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.articulo_sancion_id_seq', 20, true);


--
-- Name: aseguradora_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.aseguradora_id_seq', 1, false);


--
-- Name: asignacion_situacion_persistente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.asignacion_situacion_persistente_id_seq', 8, true);


--
-- Name: asignacion_unidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.asignacion_unidad_id_seq', 41, true);


--
-- Name: auditoria_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.auditoria_log_id_seq', 11, true);


--
-- Name: autoridad_situacion_persistente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.autoridad_situacion_persistente_id_seq', 3, true);


--
-- Name: aviso_asignacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.aviso_asignacion_id_seq', 1, false);


--
-- Name: bitacora_historica_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.bitacora_historica_id_seq', 10, true);


--
-- Name: brigada_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.brigada_id_seq', 632, true);


--
-- Name: brigada_unidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.brigada_unidad_id_seq', 3, true);


--
-- Name: bus_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.bus_id_seq', 1, false);


--
-- Name: calendario_grupo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.calendario_grupo_id_seq', 2, true);


--
-- Name: campo_personalizado_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.campo_personalizado_id_seq', 1, false);


--
-- Name: catalogo_motivo_inactividad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.catalogo_motivo_inactividad_id_seq', 22, true);


--
-- Name: combustible_registro_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.combustible_registro_id_seq', 1, false);


--
-- Name: configuracion_alerta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.configuracion_alerta_id_seq', 9, true);


--
-- Name: configuracion_columnas_tabla_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.configuracion_columnas_tabla_id_seq', 20, true);


--
-- Name: configuracion_sistema_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.configuracion_sistema_id_seq', 10, true);


--
-- Name: configuracion_visual_sede_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.configuracion_visual_sede_id_seq', 9, true);


--
-- Name: contenedor_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.contenedor_id_seq', 1, false);


--
-- Name: control_acceso_app_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.control_acceso_app_id_seq', 1, false);


--
-- Name: departamento_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.departamento_id_seq', 23, true);


--
-- Name: departamento_sistema_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.departamento_sistema_id_seq', 10, true);


--
-- Name: detalle_situacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.detalle_situacion_id_seq', 16, true);


--
-- Name: dispositivo_push_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.dispositivo_push_id_seq', 15, true);


--
-- Name: estado_grupo_departamento_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.estado_grupo_departamento_id_seq', 115, true);


--
-- Name: evento_persistente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.evento_persistente_id_seq', 1, false);


--
-- Name: grua_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.grua_id_seq', 1, false);


--
-- Name: grua_involucrada_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.grua_involucrada_id_seq', 1, false);


--
-- Name: historial_encargado_sede_grupo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.historial_encargado_sede_grupo_id_seq', 19, true);


--
-- Name: historial_ruta_brigada_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.historial_ruta_brigada_id_seq', 1, false);


--
-- Name: historial_situacion_brigada_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.historial_situacion_brigada_id_seq', 1, false);


--
-- Name: hoja_accidentologia_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.hoja_accidentologia_id_seq', 1, false);


--
-- Name: incidente_grua_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.incidente_grua_id_seq', 1, false);


--
-- Name: incidente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.incidente_id_seq', 17, true);


--
-- Name: incidente_no_atendido_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.incidente_no_atendido_id_seq', 1, false);


--
-- Name: incidente_vehiculo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.incidente_vehiculo_id_seq', 8, true);


--
-- Name: ingreso_sede_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ingreso_sede_id_seq', 31, true);


--
-- Name: inspeccion_360_archivo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inspeccion_360_archivo_id_seq', 1, false);


--
-- Name: inspeccion_360_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.inspeccion_360_id_seq', 1, true);


--
-- Name: intelligence_refresh_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.intelligence_refresh_log_id_seq', 1, false);


--
-- Name: log_administracion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.log_administracion_id_seq', 25, true);


--
-- Name: marca_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.marca_id_seq', 63, true);


--
-- Name: marca_vehiculo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.marca_vehiculo_id_seq', 20, true);


--
-- Name: motivo_no_atendido_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.motivo_no_atendido_id_seq', 9, true);


--
-- Name: movimiento_brigada_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.movimiento_brigada_id_seq', 1, false);


--
-- Name: multimedia_situacion_persistente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.multimedia_situacion_persistente_id_seq', 1, false);


--
-- Name: municipio_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.municipio_id_seq', 104, true);


--
-- Name: notificacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.notificacion_id_seq', 1, false);


--
-- Name: obstruccion_incidente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.obstruccion_incidente_id_seq', 4, true);


--
-- Name: obstruccion_situacion_persistente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.obstruccion_situacion_persistente_id_seq', 9, true);


--
-- Name: password_reset_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.password_reset_log_id_seq', 1, false);


--
-- Name: permiso_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.permiso_id_seq', 8, true);


--
-- Name: persona_accidente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.persona_accidente_id_seq', 1, false);


--
-- Name: persona_involucrada_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.persona_involucrada_id_seq', 1, false);


--
-- Name: piloto_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.piloto_id_seq', 2, true);


--
-- Name: plantilla_comunicacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.plantilla_comunicacion_id_seq', 18, true);


--
-- Name: plantilla_inspeccion_360_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.plantilla_inspeccion_360_id_seq', 4, true);


--
-- Name: publicacion_social_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.publicacion_social_id_seq', 13, true);


--
-- Name: reasignacion_sede_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reasignacion_sede_id_seq', 1, false);


--
-- Name: recurso_incidente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.recurso_incidente_id_seq', 7, true);


--
-- Name: registro_cambio_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.registro_cambio_id_seq', 1, false);


--
-- Name: relevo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.relevo_id_seq', 1, false);


--
-- Name: reporte_horario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.reporte_horario_id_seq', 6, true);


--
-- Name: rol_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rol_id_seq', 12, true);


--
-- Name: ruta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ruta_id_seq', 189, true);


--
-- Name: salida_unidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.salida_unidad_id_seq', 36, true);


--
-- Name: sancion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sancion_id_seq', 1, false);


--
-- Name: sede_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sede_id_seq', 23, true);


--
-- Name: seq_situacion_persistente; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.seq_situacion_persistente', 1, false);


--
-- Name: situacion_fija_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.situacion_fija_id_seq', 1, false);


--
-- Name: situacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.situacion_id_seq', 49, true);


--
-- Name: situacion_multimedia_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.situacion_multimedia_id_seq', 1, false);


--
-- Name: situacion_persistente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.situacion_persistente_id_seq', 10, true);


--
-- Name: socorro_situacion_persistente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.socorro_situacion_persistente_id_seq', 1, true);


--
-- Name: sub_rol_cop_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sub_rol_cop_id_seq', 4, true);


--
-- Name: subtipo_hecho_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.subtipo_hecho_id_seq', 11, true);


--
-- Name: suscripcion_alerta_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.suscripcion_alerta_id_seq', 1, false);


--
-- Name: tarjeta_circulacion_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tarjeta_circulacion_id_seq', 2, true);


--
-- Name: tipo_actividad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tipo_actividad_id_seq', 10, true);


--
-- Name: tipo_emergencia_vial_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tipo_emergencia_vial_id_seq', 13, true);


--
-- Name: tipo_hecho_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tipo_hecho_id_seq', 9, true);


--
-- Name: tipo_vehiculo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tipo_vehiculo_id_seq', 125, true);


--
-- Name: tripulacion_turno_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.tripulacion_turno_id_seq', 48, true);


--
-- Name: turno_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.turno_id_seq', 32, true);


--
-- Name: ubicacion_brigada_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.ubicacion_brigada_id_seq', 1, false);


--
-- Name: unidad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.unidad_id_seq', 407, true);


--
-- Name: usuario_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.usuario_id_seq', 1859, true);


--
-- Name: usuario_inactividad_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.usuario_inactividad_id_seq', 1, false);


--
-- Name: usuario_rol_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.usuario_rol_id_seq', 555, true);


--
-- Name: vehiculo_accidente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vehiculo_accidente_id_seq', 1, false);


--
-- Name: vehiculo_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vehiculo_id_seq', 8, true);


--
-- Name: vehiculo_incidente_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.vehiculo_incidente_id_seq', 11, true);


--
-- Name: vehiculo vehiculo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo
    ADD CONSTRAINT vehiculo_pkey PRIMARY KEY (id);


--
-- Name: mv_vehiculo_historial; Type: MATERIALIZED VIEW; Schema: public; Owner: -
--

CREATE MATERIALIZED VIEW public.mv_vehiculo_historial AS
 SELECT v.id,
    v.placa,
    v.es_extranjero,
    tv.nombre AS tipo_vehiculo,
    m.nombre AS marca,
    v.color,
    v.total_incidentes,
    v.primer_incidente,
    v.ultimo_incidente,
        CASE
            WHEN (v.primer_incidente IS NOT NULL) THEN (EXTRACT(day FROM (now() - v.primer_incidente)))::integer
            ELSE NULL::integer
        END AS dias_desde_primer_incidente,
        CASE
            WHEN (v.ultimo_incidente IS NOT NULL) THEN (EXTRACT(day FROM (now() - v.ultimo_incidente)))::integer
            ELSE NULL::integer
        END AS dias_desde_ultimo_incidente,
        CASE
            WHEN (v.total_incidentes >= 5) THEN 'ALTO'::text
            WHEN (v.total_incidentes >= 2) THEN 'MEDIO'::text
            ELSE 'BAJO'::text
        END AS nivel_alerta,
    COALESCE(json_agg(json_build_object('incidente_id', i.id, 'fecha', i.created_at, 'tipo_hecho', th.nombre, 'km', i.km, 'ruta_codigo', r.codigo, 'ruta_nombre', r.nombre, 'municipio', m.nombre, 'estado_piloto', iv.estado_piloto, 'cantidad_heridos', i.cantidad_heridos, 'cantidad_fallecidos', i.cantidad_fallecidos) ORDER BY i.created_at DESC) FILTER (WHERE (i.id IS NOT NULL)), '[]'::json) AS incidentes
   FROM (((((((public.vehiculo v
     LEFT JOIN public.tipo_vehiculo tv ON ((v.tipo_vehiculo_id = tv.id)))
     LEFT JOIN public.marca_vehiculo m ON ((v.marca_id = m.id)))
     LEFT JOIN public.incidente_vehiculo iv ON ((v.id = iv.vehiculo_id)))
     LEFT JOIN public.incidente i ON ((iv.incidente_id = i.id)))
     LEFT JOIN public.tipo_hecho th ON ((i.tipo_hecho_id = th.id)))
     LEFT JOIN public.ruta r ON ((i.ruta_id = r.id)))
     LEFT JOIN public.municipio mun ON ((i.municipio_id = mun.id)))
  GROUP BY v.id, tv.nombre, m.nombre
  ORDER BY v.total_incidentes DESC, v.ultimo_incidente DESC
  WITH NO DATA;


--
-- Name: MATERIALIZED VIEW mv_vehiculo_historial; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON MATERIALIZED VIEW public.mv_vehiculo_historial IS 'Historial completo de veh??culos con todos sus incidentes';


--
-- Name: actividad_unidad actividad_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actividad_unidad
    ADD CONSTRAINT actividad_unidad_pkey PRIMARY KEY (id);


--
-- Name: actualizacion_situacion_persistente actualizacion_situacion_persistente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actualizacion_situacion_persistente
    ADD CONSTRAINT actualizacion_situacion_persistente_pkey PRIMARY KEY (id);


--
-- Name: ajustador_involucrado ajustador_involucrado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ajustador_involucrado
    ADD CONSTRAINT ajustador_involucrado_pkey PRIMARY KEY (id);


--
-- Name: alerta_leida alerta_leida_alerta_id_usuario_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta_leida
    ADD CONSTRAINT alerta_leida_alerta_id_usuario_id_key UNIQUE (alerta_id, usuario_id);


--
-- Name: alerta_leida alerta_leida_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta_leida
    ADD CONSTRAINT alerta_leida_pkey PRIMARY KEY (id);


--
-- Name: alerta alerta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta
    ADD CONSTRAINT alerta_pkey PRIMARY KEY (id);


--
-- Name: aprobacion_respuesta aprobacion_respuesta_aprobacion_id_usuario_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aprobacion_respuesta
    ADD CONSTRAINT aprobacion_respuesta_aprobacion_id_usuario_id_key UNIQUE (aprobacion_id, usuario_id);


--
-- Name: aprobacion_respuesta aprobacion_respuesta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aprobacion_respuesta
    ADD CONSTRAINT aprobacion_respuesta_pkey PRIMARY KEY (id);


--
-- Name: aprobacion_tripulacion aprobacion_tripulacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aprobacion_tripulacion
    ADD CONSTRAINT aprobacion_tripulacion_pkey PRIMARY KEY (id);


--
-- Name: articulo_sancion articulo_sancion_numero_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articulo_sancion
    ADD CONSTRAINT articulo_sancion_numero_key UNIQUE (numero);


--
-- Name: articulo_sancion articulo_sancion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.articulo_sancion
    ADD CONSTRAINT articulo_sancion_pkey PRIMARY KEY (id);


--
-- Name: aseguradora aseguradora_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aseguradora
    ADD CONSTRAINT aseguradora_nombre_key UNIQUE (nombre);


--
-- Name: aseguradora aseguradora_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aseguradora
    ADD CONSTRAINT aseguradora_pkey PRIMARY KEY (id);


--
-- Name: asignacion_situacion_persistente asignacion_situacion_persistente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_situacion_persistente
    ADD CONSTRAINT asignacion_situacion_persistente_pkey PRIMARY KEY (id);


--
-- Name: asignacion_unidad asignacion_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_unidad
    ADD CONSTRAINT asignacion_unidad_pkey PRIMARY KEY (id);


--
-- Name: asignacion_unidad asignacion_unidad_turno_id_unidad_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_unidad
    ADD CONSTRAINT asignacion_unidad_turno_id_unidad_id_key UNIQUE (turno_id, unidad_id);


--
-- Name: auditoria_log auditoria_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_log
    ADD CONSTRAINT auditoria_log_pkey PRIMARY KEY (id);


--
-- Name: autoridad_situacion_persistente autoridad_situacion_persistente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autoridad_situacion_persistente
    ADD CONSTRAINT autoridad_situacion_persistente_pkey PRIMARY KEY (id);


--
-- Name: aviso_asignacion aviso_asignacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aviso_asignacion
    ADD CONSTRAINT aviso_asignacion_pkey PRIMARY KEY (id);


--
-- Name: bitacora_historica bitacora_historica_unidad_fecha_unique; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bitacora_historica
    ADD CONSTRAINT bitacora_historica_unidad_fecha_unique UNIQUE (fecha, unidad_id);


--
-- Name: bitacora_historica_2024 bitacora_historica_2024_fecha_unidad_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bitacora_historica_2024
    ADD CONSTRAINT bitacora_historica_2024_fecha_unidad_id_key UNIQUE (fecha, unidad_id);


--
-- Name: bitacora_historica bitacora_historica_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bitacora_historica
    ADD CONSTRAINT bitacora_historica_pkey PRIMARY KEY (id, fecha);


--
-- Name: bitacora_historica_2024 bitacora_historica_2024_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bitacora_historica_2024
    ADD CONSTRAINT bitacora_historica_2024_pkey PRIMARY KEY (id, fecha);


--
-- Name: bitacora_historica_2025 bitacora_historica_2025_fecha_unidad_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bitacora_historica_2025
    ADD CONSTRAINT bitacora_historica_2025_fecha_unidad_id_key UNIQUE (fecha, unidad_id);


--
-- Name: bitacora_historica_2025 bitacora_historica_2025_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bitacora_historica_2025
    ADD CONSTRAINT bitacora_historica_2025_pkey PRIMARY KEY (id, fecha);


--
-- Name: bitacora_historica_2026 bitacora_historica_2026_fecha_unidad_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bitacora_historica_2026
    ADD CONSTRAINT bitacora_historica_2026_fecha_unidad_id_key UNIQUE (fecha, unidad_id);


--
-- Name: bitacora_historica_2026 bitacora_historica_2026_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bitacora_historica_2026
    ADD CONSTRAINT bitacora_historica_2026_pkey PRIMARY KEY (id, fecha);


--
-- Name: brigada brigada_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brigada
    ADD CONSTRAINT brigada_codigo_key UNIQUE (codigo);


--
-- Name: brigada brigada_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brigada
    ADD CONSTRAINT brigada_pkey PRIMARY KEY (id);


--
-- Name: brigada_unidad brigada_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brigada_unidad
    ADD CONSTRAINT brigada_unidad_pkey PRIMARY KEY (id);


--
-- Name: brigada brigada_usuario_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brigada
    ADD CONSTRAINT brigada_usuario_id_key UNIQUE (usuario_id);


--
-- Name: bus bus_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bus
    ADD CONSTRAINT bus_pkey PRIMARY KEY (id);


--
-- Name: calendario_grupo calendario_grupo_grupo_fecha_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendario_grupo
    ADD CONSTRAINT calendario_grupo_grupo_fecha_key UNIQUE (grupo, fecha);


--
-- Name: calendario_grupo calendario_grupo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendario_grupo
    ADD CONSTRAINT calendario_grupo_pkey PRIMARY KEY (id);


--
-- Name: campo_personalizado campo_personalizado_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campo_personalizado
    ADD CONSTRAINT campo_personalizado_pkey PRIMARY KEY (id);


--
-- Name: campo_personalizado campo_personalizado_tabla_destino_clave_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campo_personalizado
    ADD CONSTRAINT campo_personalizado_tabla_destino_clave_key UNIQUE (tabla_destino, clave);


--
-- Name: catalogo_motivo_inactividad catalogo_motivo_inactividad_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalogo_motivo_inactividad
    ADD CONSTRAINT catalogo_motivo_inactividad_codigo_key UNIQUE (codigo);


--
-- Name: catalogo_motivo_inactividad catalogo_motivo_inactividad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.catalogo_motivo_inactividad
    ADD CONSTRAINT catalogo_motivo_inactividad_pkey PRIMARY KEY (id);


--
-- Name: combustible_registro combustible_registro_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.combustible_registro
    ADD CONSTRAINT combustible_registro_pkey PRIMARY KEY (id);


--
-- Name: configuracion_alerta configuracion_alerta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_alerta
    ADD CONSTRAINT configuracion_alerta_pkey PRIMARY KEY (id);


--
-- Name: configuracion_alerta configuracion_alerta_tipo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_alerta
    ADD CONSTRAINT configuracion_alerta_tipo_key UNIQUE (tipo);


--
-- Name: configuracion_columnas_tabla configuracion_columnas_tabla_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_columnas_tabla
    ADD CONSTRAINT configuracion_columnas_tabla_pkey PRIMARY KEY (id);


--
-- Name: configuracion_columnas_tabla configuracion_columnas_tabla_sede_id_tabla_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_columnas_tabla
    ADD CONSTRAINT configuracion_columnas_tabla_sede_id_tabla_nombre_key UNIQUE (sede_id, tabla_nombre);


--
-- Name: configuracion_sistema configuracion_sistema_clave_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_sistema
    ADD CONSTRAINT configuracion_sistema_clave_key UNIQUE (clave);


--
-- Name: configuracion_sistema configuracion_sistema_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_sistema
    ADD CONSTRAINT configuracion_sistema_pkey PRIMARY KEY (id);


--
-- Name: configuracion_visual_sede configuracion_visual_sede_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_visual_sede
    ADD CONSTRAINT configuracion_visual_sede_pkey PRIMARY KEY (id);


--
-- Name: configuracion_visual_sede configuracion_visual_sede_sede_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_visual_sede
    ADD CONSTRAINT configuracion_visual_sede_sede_id_key UNIQUE (sede_id);


--
-- Name: contenedor contenedor_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contenedor
    ADD CONSTRAINT contenedor_pkey PRIMARY KEY (id);


--
-- Name: control_acceso_app control_acceso_app_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_acceso_app
    ADD CONSTRAINT control_acceso_app_pkey PRIMARY KEY (id);


--
-- Name: departamento departamento_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamento
    ADD CONSTRAINT departamento_codigo_key UNIQUE (codigo);


--
-- Name: departamento departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamento
    ADD CONSTRAINT departamento_pkey PRIMARY KEY (id);


--
-- Name: departamento_sistema departamento_sistema_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamento_sistema
    ADD CONSTRAINT departamento_sistema_codigo_key UNIQUE (codigo);


--
-- Name: departamento_sistema departamento_sistema_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.departamento_sistema
    ADD CONSTRAINT departamento_sistema_pkey PRIMARY KEY (id);


--
-- Name: detalle_situacion detalle_situacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_situacion
    ADD CONSTRAINT detalle_situacion_pkey PRIMARY KEY (id);


--
-- Name: dispositivo_push dispositivo_push_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispositivo_push
    ADD CONSTRAINT dispositivo_push_pkey PRIMARY KEY (id);


--
-- Name: dispositivo_push dispositivo_push_usuario_id_push_token_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispositivo_push
    ADD CONSTRAINT dispositivo_push_usuario_id_push_token_key UNIQUE (usuario_id, push_token);


--
-- Name: estado_grupo_departamento estado_grupo_departamento_departamento_id_sede_id_grupo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estado_grupo_departamento
    ADD CONSTRAINT estado_grupo_departamento_departamento_id_sede_id_grupo_key UNIQUE (departamento_id, sede_id, grupo);


--
-- Name: estado_grupo_departamento estado_grupo_departamento_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estado_grupo_departamento
    ADD CONSTRAINT estado_grupo_departamento_pkey PRIMARY KEY (id);


--
-- Name: evento_persistente evento_persistente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evento_persistente
    ADD CONSTRAINT evento_persistente_pkey PRIMARY KEY (id);


--
-- Name: grua_involucrada grua_involucrada_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grua_involucrada
    ADD CONSTRAINT grua_involucrada_pkey PRIMARY KEY (id);


--
-- Name: grua grua_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grua
    ADD CONSTRAINT grua_pkey PRIMARY KEY (id);


--
-- Name: historial_encargado_sede_grupo historial_encargado_sede_grupo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_encargado_sede_grupo
    ADD CONSTRAINT historial_encargado_sede_grupo_pkey PRIMARY KEY (id);


--
-- Name: historial_ruta_brigada historial_ruta_brigada_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_ruta_brigada
    ADD CONSTRAINT historial_ruta_brigada_pkey PRIMARY KEY (id);


--
-- Name: historial_situacion_brigada historial_situacion_brigada_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_situacion_brigada
    ADD CONSTRAINT historial_situacion_brigada_pkey PRIMARY KEY (id);


--
-- Name: hoja_accidentologia hoja_accidentologia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hoja_accidentologia
    ADD CONSTRAINT hoja_accidentologia_pkey PRIMARY KEY (id);


--
-- Name: incidente_grua incidente_grua_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_grua
    ADD CONSTRAINT incidente_grua_pkey PRIMARY KEY (id);


--
-- Name: incidente_no_atendido incidente_no_atendido_incidente_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_no_atendido
    ADD CONSTRAINT incidente_no_atendido_incidente_id_key UNIQUE (incidente_id);


--
-- Name: incidente_no_atendido incidente_no_atendido_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_no_atendido
    ADD CONSTRAINT incidente_no_atendido_pkey PRIMARY KEY (id);


--
-- Name: incidente incidente_numero_reporte_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_numero_reporte_key UNIQUE (numero_reporte);


--
-- Name: incidente incidente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_pkey PRIMARY KEY (id);


--
-- Name: incidente incidente_uuid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_uuid_key UNIQUE (uuid);


--
-- Name: incidente_vehiculo incidente_vehiculo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_vehiculo
    ADD CONSTRAINT incidente_vehiculo_pkey PRIMARY KEY (id);


--
-- Name: ingreso_sede ingreso_sede_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingreso_sede
    ADD CONSTRAINT ingreso_sede_pkey PRIMARY KEY (id);


--
-- Name: inspeccion_360_archivo inspeccion_360_archivo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspeccion_360_archivo
    ADD CONSTRAINT inspeccion_360_archivo_pkey PRIMARY KEY (id);


--
-- Name: inspeccion_360 inspeccion_360_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspeccion_360
    ADD CONSTRAINT inspeccion_360_pkey PRIMARY KEY (id);


--
-- Name: intelligence_refresh_log intelligence_refresh_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.intelligence_refresh_log
    ADD CONSTRAINT intelligence_refresh_log_pkey PRIMARY KEY (id);


--
-- Name: log_administracion log_administracion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_administracion
    ADD CONSTRAINT log_administracion_pkey PRIMARY KEY (id);


--
-- Name: marca marca_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marca
    ADD CONSTRAINT marca_nombre_key UNIQUE (nombre);


--
-- Name: marca marca_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marca
    ADD CONSTRAINT marca_pkey PRIMARY KEY (id);


--
-- Name: marca_vehiculo marca_vehiculo_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marca_vehiculo
    ADD CONSTRAINT marca_vehiculo_nombre_key UNIQUE (nombre);


--
-- Name: marca_vehiculo marca_vehiculo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.marca_vehiculo
    ADD CONSTRAINT marca_vehiculo_pkey PRIMARY KEY (id);


--
-- Name: motivo_no_atendido motivo_no_atendido_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.motivo_no_atendido
    ADD CONSTRAINT motivo_no_atendido_nombre_key UNIQUE (nombre);


--
-- Name: motivo_no_atendido motivo_no_atendido_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.motivo_no_atendido
    ADD CONSTRAINT motivo_no_atendido_pkey PRIMARY KEY (id);


--
-- Name: movimiento_brigada movimiento_brigada_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimiento_brigada
    ADD CONSTRAINT movimiento_brigada_pkey PRIMARY KEY (id);


--
-- Name: multimedia_situacion_persistente multimedia_situacion_persistente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.multimedia_situacion_persistente
    ADD CONSTRAINT multimedia_situacion_persistente_pkey PRIMARY KEY (id);


--
-- Name: municipio municipio_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_codigo_key UNIQUE (codigo);


--
-- Name: municipio municipio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_pkey PRIMARY KEY (id);


--
-- Name: notificacion notificacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notificacion
    ADD CONSTRAINT notificacion_pkey PRIMARY KEY (id);


--
-- Name: obstruccion_incidente obstruccion_incidente_incidente_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obstruccion_incidente
    ADD CONSTRAINT obstruccion_incidente_incidente_id_key UNIQUE (incidente_id);


--
-- Name: obstruccion_incidente obstruccion_incidente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obstruccion_incidente
    ADD CONSTRAINT obstruccion_incidente_pkey PRIMARY KEY (id);


--
-- Name: obstruccion_situacion_persistente obstruccion_situacion_persistente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obstruccion_situacion_persistente
    ADD CONSTRAINT obstruccion_situacion_persistente_pkey PRIMARY KEY (id);


--
-- Name: obstruccion_situacion_persistente obstruccion_situacion_persistente_situacion_persistente_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obstruccion_situacion_persistente
    ADD CONSTRAINT obstruccion_situacion_persistente_situacion_persistente_id_key UNIQUE (situacion_persistente_id);


--
-- Name: password_reset_log password_reset_log_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_log
    ADD CONSTRAINT password_reset_log_pkey PRIMARY KEY (id);


--
-- Name: permiso permiso_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permiso
    ADD CONSTRAINT permiso_nombre_key UNIQUE (nombre);


--
-- Name: permiso permiso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.permiso
    ADD CONSTRAINT permiso_pkey PRIMARY KEY (id);


--
-- Name: persona_accidente persona_accidente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persona_accidente
    ADD CONSTRAINT persona_accidente_pkey PRIMARY KEY (id);


--
-- Name: persona_involucrada persona_involucrada_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persona_involucrada
    ADD CONSTRAINT persona_involucrada_pkey PRIMARY KEY (id);


--
-- Name: piloto piloto_licencia_numero_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piloto
    ADD CONSTRAINT piloto_licencia_numero_key UNIQUE (licencia_numero);


--
-- Name: piloto piloto_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.piloto
    ADD CONSTRAINT piloto_pkey PRIMARY KEY (id);


--
-- Name: plantilla_comunicacion plantilla_comunicacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plantilla_comunicacion
    ADD CONSTRAINT plantilla_comunicacion_pkey PRIMARY KEY (id);


--
-- Name: plantilla_inspeccion_360 plantilla_inspeccion_360_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plantilla_inspeccion_360
    ADD CONSTRAINT plantilla_inspeccion_360_pkey PRIMARY KEY (id);


--
-- Name: publicacion_social publicacion_social_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicacion_social
    ADD CONSTRAINT publicacion_social_pkey PRIMARY KEY (id);


--
-- Name: reasignacion_sede reasignacion_sede_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reasignacion_sede
    ADD CONSTRAINT reasignacion_sede_pkey PRIMARY KEY (id);


--
-- Name: recurso_incidente recurso_incidente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurso_incidente
    ADD CONSTRAINT recurso_incidente_pkey PRIMARY KEY (id);


--
-- Name: registro_cambio registro_cambio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registro_cambio
    ADD CONSTRAINT registro_cambio_pkey PRIMARY KEY (id);


--
-- Name: relevo relevo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relevo
    ADD CONSTRAINT relevo_pkey PRIMARY KEY (id);


--
-- Name: reporte_horario reporte_horario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reporte_horario
    ADD CONSTRAINT reporte_horario_pkey PRIMARY KEY (id);


--
-- Name: rol rol_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rol
    ADD CONSTRAINT rol_nombre_key UNIQUE (nombre);


--
-- Name: rol_permiso rol_permiso_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rol_permiso
    ADD CONSTRAINT rol_permiso_pkey PRIMARY KEY (rol_id, permiso_id);


--
-- Name: rol rol_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rol
    ADD CONSTRAINT rol_pkey PRIMARY KEY (id);


--
-- Name: ruta ruta_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruta
    ADD CONSTRAINT ruta_codigo_key UNIQUE (codigo);


--
-- Name: ruta ruta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ruta
    ADD CONSTRAINT ruta_pkey PRIMARY KEY (id);


--
-- Name: salida_unidad salida_unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salida_unidad
    ADD CONSTRAINT salida_unidad_pkey PRIMARY KEY (id);


--
-- Name: sancion sancion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sancion
    ADD CONSTRAINT sancion_pkey PRIMARY KEY (id);


--
-- Name: sede sede_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sede
    ADD CONSTRAINT sede_codigo_key UNIQUE (codigo);


--
-- Name: sede sede_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sede
    ADD CONSTRAINT sede_pkey PRIMARY KEY (id);


--
-- Name: situacion_fija situacion_fija_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_fija
    ADD CONSTRAINT situacion_fija_pkey PRIMARY KEY (id);


--
-- Name: situacion_multimedia situacion_multimedia_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_multimedia
    ADD CONSTRAINT situacion_multimedia_pkey PRIMARY KEY (id);


--
-- Name: situacion situacion_numero_situacion_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_numero_situacion_key UNIQUE (numero_situacion);


--
-- Name: situacion_persistente situacion_persistente_numero_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_persistente
    ADD CONSTRAINT situacion_persistente_numero_key UNIQUE (numero);


--
-- Name: situacion_persistente situacion_persistente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_persistente
    ADD CONSTRAINT situacion_persistente_pkey PRIMARY KEY (id);


--
-- Name: situacion_persistente situacion_persistente_uuid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_persistente
    ADD CONSTRAINT situacion_persistente_uuid_key UNIQUE (uuid);


--
-- Name: situacion situacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_pkey PRIMARY KEY (id);


--
-- Name: situacion situacion_uuid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_uuid_key UNIQUE (uuid);


--
-- Name: socorro_situacion_persistente socorro_situacion_persistente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.socorro_situacion_persistente
    ADD CONSTRAINT socorro_situacion_persistente_pkey PRIMARY KEY (id);


--
-- Name: sub_rol_cop sub_rol_cop_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_rol_cop
    ADD CONSTRAINT sub_rol_cop_codigo_key UNIQUE (codigo);


--
-- Name: sub_rol_cop sub_rol_cop_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sub_rol_cop
    ADD CONSTRAINT sub_rol_cop_pkey PRIMARY KEY (id);


--
-- Name: subtipo_hecho subtipo_hecho_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subtipo_hecho
    ADD CONSTRAINT subtipo_hecho_pkey PRIMARY KEY (id);


--
-- Name: subtipo_hecho subtipo_hecho_tipo_hecho_id_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subtipo_hecho
    ADD CONSTRAINT subtipo_hecho_tipo_hecho_id_nombre_key UNIQUE (tipo_hecho_id, nombre);


--
-- Name: suscripcion_alerta suscripcion_alerta_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suscripcion_alerta
    ADD CONSTRAINT suscripcion_alerta_pkey PRIMARY KEY (id);


--
-- Name: suscripcion_alerta suscripcion_alerta_usuario_id_tipo_alerta_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suscripcion_alerta
    ADD CONSTRAINT suscripcion_alerta_usuario_id_tipo_alerta_key UNIQUE (usuario_id, tipo_alerta);


--
-- Name: tarjeta_circulacion tarjeta_circulacion_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tarjeta_circulacion
    ADD CONSTRAINT tarjeta_circulacion_pkey PRIMARY KEY (id);


--
-- Name: tipo_actividad tipo_actividad_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_actividad
    ADD CONSTRAINT tipo_actividad_nombre_key UNIQUE (nombre);


--
-- Name: tipo_actividad tipo_actividad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_actividad
    ADD CONSTRAINT tipo_actividad_pkey PRIMARY KEY (id);


--
-- Name: tipo_emergencia_vial tipo_emergencia_vial_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_emergencia_vial
    ADD CONSTRAINT tipo_emergencia_vial_codigo_key UNIQUE (codigo);


--
-- Name: tipo_emergencia_vial tipo_emergencia_vial_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_emergencia_vial
    ADD CONSTRAINT tipo_emergencia_vial_pkey PRIMARY KEY (id);


--
-- Name: tipo_hecho tipo_hecho_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_hecho
    ADD CONSTRAINT tipo_hecho_nombre_key UNIQUE (nombre);


--
-- Name: tipo_hecho tipo_hecho_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_hecho
    ADD CONSTRAINT tipo_hecho_pkey PRIMARY KEY (id);


--
-- Name: tipo_vehiculo tipo_vehiculo_nombre_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_vehiculo
    ADD CONSTRAINT tipo_vehiculo_nombre_key UNIQUE (nombre);


--
-- Name: tipo_vehiculo tipo_vehiculo_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tipo_vehiculo
    ADD CONSTRAINT tipo_vehiculo_pkey PRIMARY KEY (id);


--
-- Name: tripulacion_turno tripulacion_turno_asignacion_id_usuario_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tripulacion_turno
    ADD CONSTRAINT tripulacion_turno_asignacion_id_usuario_id_key UNIQUE (asignacion_id, usuario_id);


--
-- Name: tripulacion_turno tripulacion_turno_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tripulacion_turno
    ADD CONSTRAINT tripulacion_turno_pkey PRIMARY KEY (id);


--
-- Name: turno turno_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turno
    ADD CONSTRAINT turno_pkey PRIMARY KEY (id);


--
-- Name: ubicacion_brigada ubicacion_brigada_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubicacion_brigada
    ADD CONSTRAINT ubicacion_brigada_pkey PRIMARY KEY (id);


--
-- Name: asignacion_situacion_persistente uk_asignacion_activa; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_situacion_persistente
    ADD CONSTRAINT uk_asignacion_activa UNIQUE (situacion_persistente_id, unidad_id, fecha_hora_desasignacion);


--
-- Name: unidad unidad_codigo_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unidad
    ADD CONSTRAINT unidad_codigo_key UNIQUE (codigo);


--
-- Name: unidad unidad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unidad
    ADD CONSTRAINT unidad_pkey PRIMARY KEY (id);


--
-- Name: situacion_multimedia uq_situacion_foto_orden; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_multimedia
    ADD CONSTRAINT uq_situacion_foto_orden UNIQUE (situacion_id, tipo, orden);


--
-- Name: usuario usuario_chapa_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_chapa_key UNIQUE (chapa);


--
-- Name: usuario_inactividad usuario_inactividad_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_inactividad
    ADD CONSTRAINT usuario_inactividad_pkey PRIMARY KEY (id);


--
-- Name: usuario usuario_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_pkey PRIMARY KEY (id);


--
-- Name: usuario_rol usuario_rol_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_rol
    ADD CONSTRAINT usuario_rol_pkey PRIMARY KEY (id);


--
-- Name: usuario_rol usuario_rol_usuario_id_rol_id_sede_id_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_rol
    ADD CONSTRAINT usuario_rol_usuario_id_rol_id_sede_id_key UNIQUE (usuario_id, rol_id, sede_id);


--
-- Name: usuario usuario_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_username_key UNIQUE (username);


--
-- Name: usuario usuario_uuid_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_uuid_key UNIQUE (uuid);


--
-- Name: vehiculo_accidente vehiculo_accidente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo_accidente
    ADD CONSTRAINT vehiculo_accidente_pkey PRIMARY KEY (id);


--
-- Name: vehiculo_incidente vehiculo_incidente_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo_incidente
    ADD CONSTRAINT vehiculo_incidente_pkey PRIMARY KEY (id);


--
-- Name: vehiculo vehiculo_placa_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo
    ADD CONSTRAINT vehiculo_placa_key UNIQUE (placa);


--
-- Name: idx_bitacora_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bitacora_fecha ON ONLY public.bitacora_historica USING btree (fecha DESC);


--
-- Name: bitacora_historica_2024_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2024_fecha_idx ON public.bitacora_historica_2024 USING btree (fecha DESC);


--
-- Name: idx_bitacora_fecha_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bitacora_fecha_unidad ON ONLY public.bitacora_historica USING btree (fecha DESC, unidad_id);


--
-- Name: bitacora_historica_2024_fecha_unidad_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2024_fecha_unidad_id_idx ON public.bitacora_historica_2024 USING btree (fecha DESC, unidad_id);


--
-- Name: idx_bitacora_sede; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bitacora_sede ON ONLY public.bitacora_historica USING btree (sede_origen_id, fecha DESC) WHERE (sede_origen_id IS NOT NULL);


--
-- Name: bitacora_historica_2024_sede_origen_id_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2024_sede_origen_id_fecha_idx ON public.bitacora_historica_2024 USING btree (sede_origen_id, fecha DESC) WHERE (sede_origen_id IS NOT NULL);


--
-- Name: idx_bitacora_tripulacion_gin; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bitacora_tripulacion_gin ON ONLY public.bitacora_historica USING gin (tripulacion_ids);


--
-- Name: bitacora_historica_2024_tripulacion_ids_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2024_tripulacion_ids_idx ON public.bitacora_historica_2024 USING gin (tripulacion_ids);


--
-- Name: idx_bitacora_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bitacora_unidad ON ONLY public.bitacora_historica USING btree (unidad_id, fecha DESC);


--
-- Name: bitacora_historica_2024_unidad_id_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2024_unidad_id_fecha_idx ON public.bitacora_historica_2024 USING btree (unidad_id, fecha DESC);


--
-- Name: bitacora_historica_2025_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2025_fecha_idx ON public.bitacora_historica_2025 USING btree (fecha DESC);


--
-- Name: bitacora_historica_2025_fecha_unidad_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2025_fecha_unidad_id_idx ON public.bitacora_historica_2025 USING btree (fecha DESC, unidad_id);


--
-- Name: bitacora_historica_2025_sede_origen_id_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2025_sede_origen_id_fecha_idx ON public.bitacora_historica_2025 USING btree (sede_origen_id, fecha DESC) WHERE (sede_origen_id IS NOT NULL);


--
-- Name: bitacora_historica_2025_tripulacion_ids_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2025_tripulacion_ids_idx ON public.bitacora_historica_2025 USING gin (tripulacion_ids);


--
-- Name: bitacora_historica_2025_unidad_id_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2025_unidad_id_fecha_idx ON public.bitacora_historica_2025 USING btree (unidad_id, fecha DESC);


--
-- Name: bitacora_historica_2026_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2026_fecha_idx ON public.bitacora_historica_2026 USING btree (fecha DESC);


--
-- Name: bitacora_historica_2026_fecha_unidad_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2026_fecha_unidad_id_idx ON public.bitacora_historica_2026 USING btree (fecha DESC, unidad_id);


--
-- Name: bitacora_historica_2026_sede_origen_id_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2026_sede_origen_id_fecha_idx ON public.bitacora_historica_2026 USING btree (sede_origen_id, fecha DESC) WHERE (sede_origen_id IS NOT NULL);


--
-- Name: bitacora_historica_2026_tripulacion_ids_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2026_tripulacion_ids_idx ON public.bitacora_historica_2026 USING gin (tripulacion_ids);


--
-- Name: bitacora_historica_2026_unidad_id_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX bitacora_historica_2026_unidad_id_fecha_idx ON public.bitacora_historica_2026 USING btree (unidad_id, fecha DESC);


--
-- Name: idx_accidentologia_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accidentologia_fecha ON public.hoja_accidentologia USING btree (fecha_elaboracion);


--
-- Name: idx_accidentologia_situacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accidentologia_situacion ON public.hoja_accidentologia USING btree (situacion_id);


--
-- Name: idx_accidentologia_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_accidentologia_tipo ON public.hoja_accidentologia USING btree (tipo_accidente);


--
-- Name: idx_actividad_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_actividad_activa ON public.actividad_unidad USING btree (unidad_id, hora_fin) WHERE (hora_fin IS NULL);


--
-- Name: idx_actividad_asignacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_actividad_asignacion ON public.actividad_unidad USING btree (asignacion_id);


--
-- Name: idx_actividad_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_actividad_fecha ON public.actividad_unidad USING btree (hora_inicio DESC);


--
-- Name: idx_actividad_incidente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_actividad_incidente ON public.actividad_unidad USING btree (incidente_id);


--
-- Name: idx_actividad_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_actividad_tipo ON public.actividad_unidad USING btree (tipo_actividad_id);


--
-- Name: idx_actividad_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_actividad_unidad ON public.actividad_unidad USING btree (unidad_id);


--
-- Name: idx_actualizacion_sit_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_actualizacion_sit_fecha ON public.actualizacion_situacion_persistente USING btree (fecha_hora);


--
-- Name: idx_actualizacion_sit_pers; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_actualizacion_sit_pers ON public.actualizacion_situacion_persistente USING btree (situacion_persistente_id);


--
-- Name: idx_actualizacion_sit_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_actualizacion_sit_unidad ON public.actualizacion_situacion_persistente USING btree (unidad_id);


--
-- Name: idx_actualizacion_sit_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_actualizacion_sit_usuario ON public.actualizacion_situacion_persistente USING btree (usuario_id);


--
-- Name: idx_ajustador_incidente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ajustador_incidente ON public.ajustador_involucrado USING btree (incidente_id);


--
-- Name: idx_alerta_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alerta_created ON public.alerta USING btree (created_at DESC);


--
-- Name: idx_alerta_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alerta_estado ON public.alerta USING btree (estado);


--
-- Name: idx_alerta_sede; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alerta_sede ON public.alerta USING btree (sede_id);


--
-- Name: idx_alerta_severidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alerta_severidad ON public.alerta USING btree (severidad);


--
-- Name: idx_alerta_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alerta_tipo ON public.alerta USING btree (tipo);


--
-- Name: idx_alerta_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_alerta_unidad ON public.alerta USING btree (unidad_id);


--
-- Name: idx_aprobacion_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aprobacion_estado ON public.aprobacion_tripulacion USING btree (estado);


--
-- Name: idx_aprobacion_pendiente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aprobacion_pendiente ON public.aprobacion_tripulacion USING btree (estado, fecha_inicio) WHERE ((estado)::text = 'PENDIENTE'::text);


--
-- Name: idx_aprobacion_respuesta_aprobacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aprobacion_respuesta_aprobacion ON public.aprobacion_respuesta USING btree (aprobacion_id);


--
-- Name: idx_aprobacion_respuesta_pendiente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aprobacion_respuesta_pendiente ON public.aprobacion_respuesta USING btree (aprobacion_id, respuesta) WHERE ((respuesta)::text = 'PENDIENTE'::text);


--
-- Name: idx_aprobacion_respuesta_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aprobacion_respuesta_usuario ON public.aprobacion_respuesta USING btree (usuario_id);


--
-- Name: idx_aprobacion_salida; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aprobacion_salida ON public.aprobacion_tripulacion USING btree (salida_id);


--
-- Name: idx_aprobacion_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aprobacion_tipo ON public.aprobacion_tripulacion USING btree (tipo);


--
-- Name: idx_aprobacion_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aprobacion_unidad ON public.aprobacion_tripulacion USING btree (unidad_id);


--
-- Name: idx_articulo_numero; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_articulo_numero ON public.articulo_sancion USING btree (numero);


--
-- Name: idx_aseguradora_nombre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aseguradora_nombre ON public.aseguradora USING btree (nombre);


--
-- Name: idx_asig_sit_pers_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asig_sit_pers_activa ON public.asignacion_situacion_persistente USING btree (situacion_persistente_id, fecha_hora_desasignacion) WHERE (fecha_hora_desasignacion IS NULL);


--
-- Name: idx_asig_sit_pers_situacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asig_sit_pers_situacion ON public.asignacion_situacion_persistente USING btree (situacion_persistente_id);


--
-- Name: idx_asig_sit_pers_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asig_sit_pers_unidad ON public.asignacion_situacion_persistente USING btree (unidad_id);


--
-- Name: idx_asignacion_dia_cerrado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asignacion_dia_cerrado ON public.asignacion_unidad USING btree (dia_cerrado, turno_id);


--
-- Name: idx_asignacion_ruta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asignacion_ruta ON public.asignacion_unidad USING btree (ruta_id);


--
-- Name: idx_asignacion_ruta_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asignacion_ruta_activa ON public.asignacion_unidad USING btree (ruta_activa_id) WHERE (ruta_activa_id IS NOT NULL);


--
-- Name: idx_asignacion_situacion_fija; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asignacion_situacion_fija ON public.asignacion_unidad USING btree (situacion_fija_id);


--
-- Name: idx_asignacion_turno; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asignacion_turno ON public.asignacion_unidad USING btree (turno_id);


--
-- Name: idx_asignacion_turno_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asignacion_turno_unidad ON public.asignacion_unidad USING btree (turno_id, unidad_id);


--
-- Name: idx_asignacion_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_asignacion_unidad ON public.asignacion_unidad USING btree (unidad_id);


--
-- Name: idx_auditoria_accion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_auditoria_accion ON public.auditoria_log USING btree (accion);


--
-- Name: idx_auditoria_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_auditoria_created ON public.auditoria_log USING btree (created_at DESC);


--
-- Name: idx_auditoria_tabla; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_auditoria_tabla ON public.auditoria_log USING btree (tabla_afectada);


--
-- Name: idx_auditoria_tabla_registro; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_auditoria_tabla_registro ON public.auditoria_log USING btree (tabla_afectada, registro_id);


--
-- Name: idx_auditoria_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_auditoria_usuario ON public.auditoria_log USING btree (usuario_id);


--
-- Name: idx_autoridad_sit_pers; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_autoridad_sit_pers ON public.autoridad_situacion_persistente USING btree (situacion_persistente_id);


--
-- Name: idx_autoridad_sit_pers_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_autoridad_sit_pers_tipo ON public.autoridad_situacion_persistente USING btree (situacion_persistente_id, tipo_autoridad);


--
-- Name: idx_aviso_asignacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_aviso_asignacion ON public.aviso_asignacion USING btree (asignacion_id);


--
-- Name: idx_brigada_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_brigada_activa ON public.brigada USING btree (activa);


--
-- Name: idx_brigada_activa_unica; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_brigada_activa_unica ON public.brigada_unidad USING btree (brigada_id) WHERE (activo = true);


--
-- Name: INDEX idx_brigada_activa_unica; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.idx_brigada_activa_unica IS 'Garantiza que un brigadista solo tenga una asignaci??n activa';


--
-- Name: idx_brigada_codigo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_brigada_codigo ON public.brigada USING btree (codigo);


--
-- Name: idx_brigada_sede; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_brigada_sede ON public.brigada USING btree (sede_id);


--
-- Name: idx_brigada_unidad_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_brigada_unidad_activo ON public.brigada_unidad USING btree (activo) WHERE (activo = true);


--
-- Name: idx_brigada_unidad_brigada; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_brigada_unidad_brigada ON public.brigada_unidad USING btree (brigada_id);


--
-- Name: idx_brigada_unidad_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_brigada_unidad_unidad ON public.brigada_unidad USING btree (unidad_id);


--
-- Name: idx_bus_empresa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bus_empresa ON public.bus USING btree (empresa);


--
-- Name: idx_bus_vehiculo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_bus_vehiculo ON public.bus USING btree (vehiculo_id);


--
-- Name: idx_calendario_grupo_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_calendario_grupo_estado ON public.calendario_grupo USING btree (estado, fecha);


--
-- Name: idx_calendario_grupo_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_calendario_grupo_fecha ON public.calendario_grupo USING btree (grupo, fecha DESC);


--
-- Name: idx_combustible_asignacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_combustible_asignacion ON public.combustible_registro USING btree (asignacion_id);


--
-- Name: idx_combustible_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_combustible_created ON public.combustible_registro USING btree (created_at DESC);


--
-- Name: idx_combustible_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_combustible_tipo ON public.combustible_registro USING btree (tipo);


--
-- Name: idx_combustible_turno; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_combustible_turno ON public.combustible_registro USING btree (turno_id);


--
-- Name: idx_combustible_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_combustible_unidad ON public.combustible_registro USING btree (unidad_id);


--
-- Name: idx_config_columnas_sede_tabla; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_config_columnas_sede_tabla ON public.configuracion_columnas_tabla USING btree (sede_id, tabla_nombre);


--
-- Name: idx_config_visual_sede; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_config_visual_sede ON public.configuracion_visual_sede USING btree (sede_id);


--
-- Name: idx_contenedor_numero; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_contenedor_numero ON public.contenedor USING btree (numero_contenedor);


--
-- Name: idx_contenedor_vehiculo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_contenedor_vehiculo ON public.contenedor USING btree (vehiculo_id);


--
-- Name: idx_control_acceso_grupo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_control_acceso_grupo ON public.control_acceso_app USING btree (grupo) WHERE (grupo IS NOT NULL);


--
-- Name: idx_control_acceso_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_control_acceso_usuario ON public.control_acceso_app USING btree (usuario_id) WHERE (usuario_id IS NOT NULL);


--
-- Name: idx_control_acceso_vigencia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_control_acceso_vigencia ON public.control_acceso_app USING btree (fecha_inicio, fecha_fin);


--
-- Name: idx_departamento_codigo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_departamento_codigo ON public.departamento USING btree (codigo);


--
-- Name: idx_departamento_region; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_departamento_region ON public.departamento USING btree (region);


--
-- Name: idx_detalle_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_detalle_created ON public.detalle_situacion USING btree (created_at DESC);


--
-- Name: idx_detalle_situacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_detalle_situacion ON public.detalle_situacion USING btree (situacion_id);


--
-- Name: idx_detalle_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_detalle_tipo ON public.detalle_situacion USING btree (tipo_detalle);


--
-- Name: idx_dispositivo_push_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dispositivo_push_activo ON public.dispositivo_push USING btree (activo) WHERE (activo = true);


--
-- Name: idx_dispositivo_push_token; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dispositivo_push_token ON public.dispositivo_push USING btree (push_token);


--
-- Name: idx_dispositivo_push_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_dispositivo_push_usuario ON public.dispositivo_push USING btree (usuario_id);


--
-- Name: idx_estado_grupo_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_estado_grupo_activo ON public.estado_grupo_departamento USING btree (activo) WHERE (activo = true);


--
-- Name: idx_estado_grupo_depto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_estado_grupo_depto ON public.estado_grupo_departamento USING btree (departamento_id);


--
-- Name: idx_estado_grupo_sede; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_estado_grupo_sede ON public.estado_grupo_departamento USING btree (sede_id);


--
-- Name: idx_evento_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_evento_estado ON public.evento_persistente USING btree (estado);


--
-- Name: idx_evento_importancia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_evento_importancia ON public.evento_persistente USING btree (importancia);


--
-- Name: idx_evento_ruta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_evento_ruta ON public.evento_persistente USING btree (ruta_id);


--
-- Name: idx_grua_incidente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_grua_incidente ON public.grua_involucrada USING btree (incidente_id);


--
-- Name: idx_grua_master_empresa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_grua_master_empresa ON public.grua USING btree (empresa);


--
-- Name: idx_grua_master_nombre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_grua_master_nombre ON public.grua USING btree (nombre);


--
-- Name: idx_grua_master_placa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_grua_master_placa ON public.grua USING btree (placa);


--
-- Name: idx_historial_encargado_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_historial_encargado_activo ON public.historial_encargado_sede_grupo USING btree (sede_id, grupo) WHERE (fecha_fin IS NULL);


--
-- Name: idx_historial_encargado_fechas; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_historial_encargado_fechas ON public.historial_encargado_sede_grupo USING btree (fecha_inicio, fecha_fin);


--
-- Name: idx_historial_encargado_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_historial_encargado_usuario ON public.historial_encargado_sede_grupo USING btree (usuario_id);


--
-- Name: idx_historial_ruta_brigada_ruta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_historial_ruta_brigada_ruta ON public.historial_ruta_brigada USING btree (ruta_id, usuario_id);


--
-- Name: idx_historial_ruta_brigada_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_historial_ruta_brigada_usuario ON public.historial_ruta_brigada USING btree (usuario_id, fecha DESC);


--
-- Name: idx_historial_situacion_brigada_situacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_historial_situacion_brigada_situacion ON public.historial_situacion_brigada USING btree (situacion_fija_id, usuario_id);


--
-- Name: idx_historial_situacion_brigada_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_historial_situacion_brigada_usuario ON public.historial_situacion_brigada USING btree (usuario_id, fecha DESC);


--
-- Name: idx_incidente_activos; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_activos ON public.incidente USING btree (fecha_hora_aviso, estado) WHERE ((estado)::text = ANY (ARRAY[('REPORTADO'::character varying)::text, ('EN_ATENCION'::character varying)::text, ('REGULACION'::character varying)::text]));


--
-- Name: idx_incidente_asignacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_asignacion ON public.incidente USING btree (asignacion_id);


--
-- Name: idx_incidente_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_created_at ON public.incidente USING btree (created_at DESC);


--
-- Name: idx_incidente_departamento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_departamento ON public.incidente USING btree (departamento_id);


--
-- Name: idx_incidente_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_estado ON public.incidente USING btree (estado);


--
-- Name: idx_incidente_fecha_aviso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_fecha_aviso ON public.incidente USING btree (fecha_hora_aviso);


--
-- Name: idx_incidente_grua_grua; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_grua_grua ON public.incidente_grua USING btree (grua_id);


--
-- Name: idx_incidente_grua_incidente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_grua_incidente ON public.incidente_grua USING btree (incidente_id);


--
-- Name: idx_incidente_municipio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_municipio ON public.incidente USING btree (municipio_id);


--
-- Name: idx_incidente_no_atendido; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_no_atendido ON public.incidente_no_atendido USING btree (incidente_id);


--
-- Name: idx_incidente_no_atendido_motivo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_no_atendido_motivo ON public.incidente_no_atendido USING btree (motivo_id);


--
-- Name: idx_incidente_numero; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_numero ON public.incidente USING btree (numero_reporte);


--
-- Name: idx_incidente_origen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_origen ON public.incidente USING btree (origen);


--
-- Name: idx_incidente_ruta_km; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_ruta_km ON public.incidente USING btree (ruta_id, km);


--
-- Name: idx_incidente_tipo_hecho; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_tipo_hecho ON public.incidente USING btree (tipo_hecho_id);


--
-- Name: idx_incidente_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_unidad ON public.incidente USING btree (unidad_id);


--
-- Name: idx_incidente_uuid; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_uuid ON public.incidente USING btree (uuid);


--
-- Name: idx_incidente_vehiculo_incidente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_vehiculo_incidente ON public.incidente_vehiculo USING btree (incidente_id);


--
-- Name: idx_incidente_vehiculo_piloto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_vehiculo_piloto ON public.incidente_vehiculo USING btree (piloto_id);


--
-- Name: idx_incidente_vehiculo_vehiculo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_incidente_vehiculo_vehiculo ON public.incidente_vehiculo USING btree (vehiculo_id);


--
-- Name: idx_ingreso_activo_por_salida; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_ingreso_activo_por_salida ON public.ingreso_sede USING btree (salida_unidad_id) WHERE (fecha_hora_salida IS NULL);


--
-- Name: INDEX idx_ingreso_activo_por_salida; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.idx_ingreso_activo_por_salida IS 'Garantiza que una salida solo tenga un ingreso activo a la vez';


--
-- Name: idx_ingreso_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ingreso_fecha ON public.ingreso_sede USING btree (fecha_hora_ingreso DESC);


--
-- Name: idx_ingreso_salida; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ingreso_salida ON public.ingreso_sede USING btree (salida_unidad_id);


--
-- Name: idx_ingreso_sede_sede; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ingreso_sede_sede ON public.ingreso_sede USING btree (sede_id);


--
-- Name: idx_inspeccion_360_archivo_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inspeccion_360_archivo_fecha ON public.inspeccion_360_archivo USING btree (fecha_realizacion);


--
-- Name: idx_inspeccion_360_archivo_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inspeccion_360_archivo_unidad ON public.inspeccion_360_archivo USING btree (unidad_id);


--
-- Name: idx_inspeccion_360_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inspeccion_360_estado ON public.inspeccion_360 USING btree (estado);


--
-- Name: idx_inspeccion_360_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inspeccion_360_fecha ON public.inspeccion_360 USING btree (fecha_realizacion DESC);


--
-- Name: idx_inspeccion_360_salida; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inspeccion_360_salida ON public.inspeccion_360 USING btree (salida_id);


--
-- Name: idx_inspeccion_360_salida_valida; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_inspeccion_360_salida_valida ON public.inspeccion_360 USING btree (salida_id) WHERE ((estado)::text = ANY ((ARRAY['PENDIENTE'::character varying, 'APROBADA'::character varying])::text[]));


--
-- Name: idx_inspeccion_360_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_inspeccion_360_unidad ON public.inspeccion_360 USING btree (unidad_id);


--
-- Name: idx_log_admin_accion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_log_admin_accion ON public.log_administracion USING btree (accion);


--
-- Name: idx_log_admin_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_log_admin_fecha ON public.log_administracion USING btree (created_at DESC);


--
-- Name: idx_log_admin_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_log_admin_usuario ON public.log_administracion USING btree (usuario_afectado_id);


--
-- Name: idx_marca_nombre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_marca_nombre ON public.marca USING btree (nombre);


--
-- Name: idx_motivo_no_atendido_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_motivo_no_atendido_activo ON public.motivo_no_atendido USING btree (activo);


--
-- Name: idx_movimiento_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movimiento_activo ON public.movimiento_brigada USING btree (hora_fin) WHERE (hora_fin IS NULL);


--
-- Name: idx_movimiento_brigada_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movimiento_brigada_usuario ON public.movimiento_brigada USING btree (usuario_id);


--
-- Name: idx_movimiento_destino; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movimiento_destino ON public.movimiento_brigada USING btree (destino_asignacion_id);


--
-- Name: idx_movimiento_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movimiento_fecha ON public.movimiento_brigada USING btree (created_at DESC);


--
-- Name: idx_movimiento_origen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movimiento_origen ON public.movimiento_brigada USING btree (origen_asignacion_id);


--
-- Name: idx_movimiento_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movimiento_tipo ON public.movimiento_brigada USING btree (tipo_movimiento);


--
-- Name: idx_movimiento_turno; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movimiento_turno ON public.movimiento_brigada USING btree (turno_id);


--
-- Name: idx_movimiento_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_movimiento_usuario ON public.movimiento_brigada USING btree (usuario_id);


--
-- Name: idx_multimedia_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_multimedia_created ON public.situacion_multimedia USING btree (created_at DESC);


--
-- Name: idx_multimedia_sit_pers; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_multimedia_sit_pers ON public.multimedia_situacion_persistente USING btree (situacion_persistente_id);


--
-- Name: idx_multimedia_sit_pers_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_multimedia_sit_pers_tipo ON public.multimedia_situacion_persistente USING btree (situacion_persistente_id, tipo);


--
-- Name: idx_multimedia_situacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_multimedia_situacion ON public.situacion_multimedia USING btree (situacion_id);


--
-- Name: idx_multimedia_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_multimedia_tipo ON public.situacion_multimedia USING btree (tipo);


--
-- Name: idx_municipio_codigo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_municipio_codigo ON public.municipio USING btree (codigo);


--
-- Name: idx_municipio_departamento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_municipio_departamento ON public.municipio USING btree (departamento_id);


--
-- Name: idx_municipio_nombre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_municipio_nombre ON public.municipio USING btree (nombre);


--
-- Name: idx_mv_estadisticas_diarias; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_mv_estadisticas_diarias ON public.mv_estadisticas_diarias USING btree (fecha, ruta_id, tipo_hecho_id, origen, estado);


--
-- Name: idx_mv_estadisticas_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mv_estadisticas_fecha ON public.mv_estadisticas_diarias USING btree (fecha DESC);


--
-- Name: idx_mv_estadisticas_ruta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mv_estadisticas_ruta ON public.mv_estadisticas_diarias USING btree (ruta_id);


--
-- Name: idx_mv_no_atendidos; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_mv_no_atendidos ON public.mv_no_atendidos_por_motivo USING btree (mes, motivo_id, COALESCE(ruta_id, 0), COALESCE(sede_id, 0));


--
-- Name: idx_mv_vehiculo_historial_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_mv_vehiculo_historial_id ON public.mv_vehiculo_historial USING btree (id);


--
-- Name: idx_mv_vehiculo_historial_nivel; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mv_vehiculo_historial_nivel ON public.mv_vehiculo_historial USING btree (nivel_alerta);


--
-- Name: idx_mv_vehiculo_historial_placa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_mv_vehiculo_historial_placa ON public.mv_vehiculo_historial USING btree (placa);


--
-- Name: idx_notificacion_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notificacion_fecha ON public.notificacion USING btree (created_at DESC);


--
-- Name: idx_notificacion_no_leida; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notificacion_no_leida ON public.notificacion USING btree (usuario_id, leida) WHERE (leida = false);


--
-- Name: idx_notificacion_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notificacion_tipo ON public.notificacion USING btree (tipo);


--
-- Name: idx_notificacion_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_notificacion_usuario ON public.notificacion USING btree (usuario_id);


--
-- Name: idx_obstruccion_incidente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_obstruccion_incidente ON public.obstruccion_incidente USING btree (incidente_id);


--
-- Name: idx_obstruccion_sit_pers_new; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_obstruccion_sit_pers_new ON public.obstruccion_situacion_persistente USING btree (situacion_persistente_id);


--
-- Name: idx_password_reset_log_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_log_fecha ON public.password_reset_log USING btree (fecha_habilitacion);


--
-- Name: idx_password_reset_log_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_password_reset_log_usuario ON public.password_reset_log USING btree (usuario_id);


--
-- Name: idx_persona_accidente_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_persona_accidente_estado ON public.persona_accidente USING btree (estado);


--
-- Name: idx_persona_accidente_hoja; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_persona_accidente_hoja ON public.persona_accidente USING btree (hoja_accidentologia_id);


--
-- Name: idx_persona_incidente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_persona_incidente ON public.persona_involucrada USING btree (incidente_id);


--
-- Name: idx_piloto_licencia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_piloto_licencia ON public.piloto USING btree (licencia_numero);


--
-- Name: idx_piloto_nombre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_piloto_nombre ON public.piloto USING btree (nombre);


--
-- Name: idx_plantilla_360_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_plantilla_360_activa ON public.plantilla_inspeccion_360 USING btree (activa) WHERE (activa = true);


--
-- Name: idx_plantilla_360_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_plantilla_360_tipo ON public.plantilla_inspeccion_360 USING btree (tipo_unidad);


--
-- Name: idx_plantilla_360_tipo_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_plantilla_360_tipo_activa ON public.plantilla_inspeccion_360 USING btree (tipo_unidad) WHERE (activa = true);


--
-- Name: idx_publicacion_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicacion_fecha ON public.publicacion_social USING btree (fecha_publicacion);


--
-- Name: idx_publicacion_situacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_publicacion_situacion ON public.publicacion_social USING btree (situacion_id);


--
-- Name: idx_reasignacion_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reasignacion_estado ON public.reasignacion_sede USING btree (estado);


--
-- Name: idx_reasignacion_fechas; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reasignacion_fechas ON public.reasignacion_sede USING btree (fecha_inicio, fecha_fin);


--
-- Name: idx_reasignacion_tipo_recurso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reasignacion_tipo_recurso ON public.reasignacion_sede USING btree (tipo, recurso_id);


--
-- Name: idx_recurso_incidente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_recurso_incidente ON public.recurso_incidente USING btree (incidente_id);


--
-- Name: idx_registro_asignacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_registro_asignacion ON public.registro_cambio USING btree (asignacion_id);


--
-- Name: idx_registro_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_registro_fecha ON public.registro_cambio USING btree (created_at DESC);


--
-- Name: idx_registro_realizado_por; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_registro_realizado_por ON public.registro_cambio USING btree (realizado_por);


--
-- Name: idx_registro_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_registro_tipo ON public.registro_cambio USING btree (tipo_cambio);


--
-- Name: idx_registro_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_registro_usuario ON public.registro_cambio USING btree (usuario_afectado_id);


--
-- Name: idx_relevo_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_relevo_fecha ON public.relevo USING btree (fecha_hora DESC);


--
-- Name: idx_relevo_situacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_relevo_situacion ON public.relevo USING btree (situacion_id);


--
-- Name: idx_relevo_unidad_entrante; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_relevo_unidad_entrante ON public.relevo USING btree (unidad_entrante_id);


--
-- Name: idx_relevo_unidad_saliente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_relevo_unidad_saliente ON public.relevo USING btree (unidad_saliente_id);


--
-- Name: idx_reporte_asignacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reporte_asignacion ON public.reporte_horario USING btree (asignacion_id);


--
-- Name: idx_reporte_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_reporte_created ON public.reporte_horario USING btree (created_at DESC);


--
-- Name: idx_ruta_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ruta_activa ON public.ruta USING btree (activa);


--
-- Name: idx_ruta_codigo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ruta_codigo ON public.ruta USING btree (codigo);


--
-- Name: idx_salida_activa_por_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_salida_activa_por_unidad ON public.salida_unidad USING btree (unidad_id) WHERE ((estado)::text = 'EN_SALIDA'::text);


--
-- Name: INDEX idx_salida_activa_por_unidad; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.idx_salida_activa_por_unidad IS 'Garantiza que una unidad solo tenga una salida activa a la vez';


--
-- Name: idx_salida_inspeccion_360; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_salida_inspeccion_360 ON public.salida_unidad USING btree (inspeccion_360_id);


--
-- Name: idx_salida_sede_origen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_salida_sede_origen ON public.salida_unidad USING btree (sede_origen_id);


--
-- Name: idx_salida_unidad_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_salida_unidad_estado ON public.salida_unidad USING btree (estado);


--
-- Name: idx_salida_unidad_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_salida_unidad_fecha ON public.salida_unidad USING btree (fecha_hora_salida DESC);


--
-- Name: idx_salida_unidad_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_salida_unidad_unidad ON public.salida_unidad USING btree (unidad_id);


--
-- Name: idx_sancion_articulo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sancion_articulo ON public.sancion USING btree (articulo_sancion_id);


--
-- Name: idx_sancion_incidente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sancion_incidente ON public.sancion USING btree (incidente_id);


--
-- Name: idx_sancion_piloto; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sancion_piloto ON public.sancion USING btree (piloto_id);


--
-- Name: idx_sancion_vehiculo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sancion_vehiculo ON public.sancion USING btree (vehiculo_id);


--
-- Name: idx_sede_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sede_activa ON public.sede USING btree (activa);


--
-- Name: idx_sede_codigo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sede_codigo ON public.sede USING btree (codigo);


--
-- Name: idx_sit_pers_es_promocion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sit_pers_es_promocion ON public.situacion_persistente USING btree (es_promocion);


--
-- Name: idx_sit_pers_situacion_origen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sit_pers_situacion_origen ON public.situacion_persistente USING btree (situacion_origen_id);


--
-- Name: idx_sit_pers_tipo_emergencia; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_sit_pers_tipo_emergencia ON public.situacion_persistente USING btree (tipo_emergencia_id);


--
-- Name: idx_situacion_asignacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_asignacion ON public.situacion USING btree (asignacion_id);


--
-- Name: idx_situacion_created; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_created ON public.situacion USING btree (created_at DESC);


--
-- Name: idx_situacion_departamento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_departamento ON public.situacion USING btree (departamento_id);


--
-- Name: idx_situacion_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_estado ON public.situacion USING btree (estado);


--
-- Name: idx_situacion_fija_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_fija_activa ON public.situacion_fija USING btree (activa, fecha_inicio, fecha_fin);


--
-- Name: idx_situacion_fija_ruta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_fija_ruta ON public.situacion_fija USING btree (ruta_id);


--
-- Name: idx_situacion_fija_sede; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_fija_sede ON public.situacion_fija USING btree (sede_id);


--
-- Name: idx_situacion_incidente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_incidente ON public.situacion USING btree (incidente_id) WHERE (incidente_id IS NOT NULL);


--
-- Name: idx_situacion_municipio; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_municipio ON public.situacion USING btree (municipio_id);


--
-- Name: idx_situacion_persistente_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_persistente_estado ON public.situacion_persistente USING btree (estado);


--
-- Name: idx_situacion_persistente_ruta; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_persistente_ruta ON public.situacion_persistente USING btree (ruta_id);


--
-- Name: idx_situacion_persistente_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_persistente_tipo ON public.situacion_persistente USING btree (tipo);


--
-- Name: idx_situacion_salida; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_salida ON public.situacion USING btree (salida_unidad_id);


--
-- Name: idx_situacion_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_tipo ON public.situacion USING btree (tipo_situacion);


--
-- Name: idx_situacion_turno; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_turno ON public.situacion USING btree (turno_id);


--
-- Name: idx_situacion_unidad; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_situacion_unidad ON public.situacion USING btree (unidad_id);


--
-- Name: idx_socorro_sit_pers; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_socorro_sit_pers ON public.socorro_situacion_persistente USING btree (situacion_persistente_id);


--
-- Name: idx_socorro_sit_pers_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_socorro_sit_pers_tipo ON public.socorro_situacion_persistente USING btree (situacion_persistente_id, tipo_socorro);


--
-- Name: idx_subtipo_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subtipo_activo ON public.subtipo_hecho USING btree (activo);


--
-- Name: idx_subtipo_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_subtipo_tipo ON public.subtipo_hecho USING btree (tipo_hecho_id);


--
-- Name: idx_tc_nit; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tc_nit ON public.tarjeta_circulacion USING btree (nit);


--
-- Name: idx_tc_numero; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tc_numero ON public.tarjeta_circulacion USING btree (numero);


--
-- Name: idx_tc_vehiculo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tc_vehiculo ON public.tarjeta_circulacion USING btree (vehiculo_id);


--
-- Name: idx_tipo_hecho_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tipo_hecho_activo ON public.tipo_hecho USING btree (activo);


--
-- Name: idx_tipo_vehiculo_categoria; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tipo_vehiculo_categoria ON public.tipo_vehiculo USING btree (categoria);


--
-- Name: idx_tipo_vehiculo_nombre; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tipo_vehiculo_nombre ON public.tipo_vehiculo USING btree (nombre);


--
-- Name: idx_tripulacion_asignacion; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tripulacion_asignacion ON public.tripulacion_turno USING btree (asignacion_id);


--
-- Name: idx_tripulacion_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tripulacion_usuario ON public.tripulacion_turno USING btree (usuario_id);


--
-- Name: idx_tripulacion_usuario_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_tripulacion_usuario_fecha ON public.tripulacion_turno USING btree (usuario_id, created_at);


--
-- Name: idx_turno_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_turno_estado ON public.turno USING btree (estado);


--
-- Name: idx_turno_fecha; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_turno_fecha ON public.turno USING btree (fecha DESC);


--
-- Name: idx_turno_fecha_estado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_turno_fecha_estado ON public.turno USING btree (fecha, estado);


--
-- Name: idx_turno_publicado; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_turno_publicado ON public.turno USING btree (publicado, fecha);


--
-- Name: idx_turno_sede; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_turno_sede ON public.turno USING btree (sede_id);


--
-- Name: idx_ubicacion_brigada_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ubicacion_brigada_activa ON public.ubicacion_brigada USING btree (usuario_id, fin_ubicacion) WHERE (fin_ubicacion IS NULL);


--
-- Name: idx_ubicacion_brigada_origen; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ubicacion_brigada_origen ON public.ubicacion_brigada USING btree (unidad_origen_id);


--
-- Name: idx_ubicacion_brigada_unidad_actual; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ubicacion_brigada_unidad_actual ON public.ubicacion_brigada USING btree (unidad_actual_id) WHERE (fin_ubicacion IS NULL);


--
-- Name: idx_ubicacion_brigada_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_ubicacion_brigada_usuario ON public.ubicacion_brigada USING btree (usuario_id);


--
-- Name: idx_un_piloto_por_asignacion; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_un_piloto_por_asignacion ON public.tripulacion_turno USING btree (asignacion_id) WHERE ((rol_tripulacion)::text = 'PILOTO'::text);


--
-- Name: INDEX idx_un_piloto_por_asignacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.idx_un_piloto_por_asignacion IS 'Garantiza que cada unidad tenga exactamente un piloto';


--
-- Name: idx_unidad_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_unidad_activa ON public.unidad USING btree (activa);


--
-- Name: idx_unidad_actividad_activa; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX idx_unidad_actividad_activa ON public.actividad_unidad USING btree (unidad_id) WHERE (hora_fin IS NULL);


--
-- Name: INDEX idx_unidad_actividad_activa; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON INDEX public.idx_unidad_actividad_activa IS 'Garantiza que una unidad solo tenga una actividad activa simult??neamente';


--
-- Name: idx_unidad_codigo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_unidad_codigo ON public.unidad USING btree (codigo);


--
-- Name: idx_unidad_combustible; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_unidad_combustible ON public.unidad USING btree (combustible_actual) WHERE (activa = true);


--
-- Name: idx_unidad_sede; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_unidad_sede ON public.unidad USING btree (sede_id);


--
-- Name: idx_usuario_acceso; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_acceso ON public.usuario USING btree (acceso_app_activo);


--
-- Name: idx_usuario_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_activo ON public.usuario USING btree (activo);


--
-- Name: idx_usuario_chapa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_chapa ON public.usuario USING btree (chapa);


--
-- Name: idx_usuario_exento; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_exento ON public.usuario USING btree (exento_grupos) WHERE (exento_grupos = true);


--
-- Name: idx_usuario_grupo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_grupo ON public.usuario USING btree (grupo) WHERE (grupo IS NOT NULL);


--
-- Name: idx_usuario_inactividad_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_inactividad_activo ON public.usuario_inactividad USING btree (fecha_fin_real) WHERE (fecha_fin_real IS NULL);


--
-- Name: idx_usuario_inactividad_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_inactividad_usuario ON public.usuario_inactividad USING btree (usuario_id);


--
-- Name: idx_usuario_password_reset; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_password_reset ON public.usuario USING btree (password_reset_required) WHERE (password_reset_required = true);


--
-- Name: idx_usuario_rol; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_rol ON public.usuario USING btree (rol_id);


--
-- Name: idx_usuario_rol_activo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_rol_activo ON public.usuario_rol USING btree (activo) WHERE (activo = true);


--
-- Name: idx_usuario_rol_brigada; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_rol_brigada ON public.usuario USING btree (rol_brigada) WHERE (rol_brigada IS NOT NULL);


--
-- Name: idx_usuario_rol_rol; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_rol_rol ON public.usuario_rol USING btree (rol_id);


--
-- Name: idx_usuario_rol_sede; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_rol_sede ON public.usuario_rol USING btree (sede_id);


--
-- Name: idx_usuario_rol_usuario; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_rol_usuario ON public.usuario_rol USING btree (usuario_id);


--
-- Name: idx_usuario_sede; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_sede ON public.usuario USING btree (sede_id);


--
-- Name: idx_usuario_sub_rol_cop; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_sub_rol_cop ON public.usuario USING btree (sub_rol_cop_id);


--
-- Name: idx_usuario_telefono; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_telefono ON public.usuario USING btree (telefono) WHERE (telefono IS NOT NULL);


--
-- Name: idx_usuario_username; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_usuario_username ON public.usuario USING btree (username);


--
-- Name: idx_vehiculo_accidente_hoja; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehiculo_accidente_hoja ON public.vehiculo_accidente USING btree (hoja_accidentologia_id);


--
-- Name: idx_vehiculo_incidente; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehiculo_incidente ON public.vehiculo_incidente USING btree (incidente_id);


--
-- Name: idx_vehiculo_master_marca; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehiculo_master_marca ON public.vehiculo USING btree (marca_id);


--
-- Name: idx_vehiculo_master_placa; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehiculo_master_placa ON public.vehiculo USING btree (placa);


--
-- Name: idx_vehiculo_master_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehiculo_master_tipo ON public.vehiculo USING btree (tipo_vehiculo_id);


--
-- Name: idx_vehiculo_tipo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX idx_vehiculo_tipo ON public.vehiculo_incidente USING btree (tipo_vehiculo_id);


--
-- Name: mv_pilotos_problematicos_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mv_pilotos_problematicos_id_idx ON public.mv_pilotos_problematicos USING btree (id);


--
-- Name: mv_pilotos_problematicos_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mv_pilotos_problematicos_id_idx1 ON public.mv_pilotos_problematicos USING btree (id);


--
-- Name: mv_pilotos_problematicos_id_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mv_pilotos_problematicos_id_idx2 ON public.mv_pilotos_problematicos USING btree (id);


--
-- Name: mv_pilotos_problematicos_licencia_numero_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_pilotos_problematicos_licencia_numero_idx ON public.mv_pilotos_problematicos USING btree (licencia_numero);


--
-- Name: mv_pilotos_problematicos_licencia_numero_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_pilotos_problematicos_licencia_numero_idx1 ON public.mv_pilotos_problematicos USING btree (licencia_numero);


--
-- Name: mv_pilotos_problematicos_licencia_numero_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_pilotos_problematicos_licencia_numero_idx2 ON public.mv_pilotos_problematicos USING btree (licencia_numero);


--
-- Name: mv_pilotos_problematicos_licencia_vencida_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_pilotos_problematicos_licencia_vencida_idx ON public.mv_pilotos_problematicos USING btree (licencia_vencida) WHERE (licencia_vencida = true);


--
-- Name: mv_pilotos_problematicos_licencia_vencida_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_pilotos_problematicos_licencia_vencida_idx1 ON public.mv_pilotos_problematicos USING btree (licencia_vencida) WHERE (licencia_vencida = true);


--
-- Name: mv_pilotos_problematicos_licencia_vencida_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_pilotos_problematicos_licencia_vencida_idx2 ON public.mv_pilotos_problematicos USING btree (licencia_vencida) WHERE (licencia_vencida = true);


--
-- Name: mv_pilotos_problematicos_nivel_riesgo_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_pilotos_problematicos_nivel_riesgo_idx ON public.mv_pilotos_problematicos USING btree (nivel_riesgo DESC);


--
-- Name: mv_pilotos_problematicos_nivel_riesgo_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_pilotos_problematicos_nivel_riesgo_idx1 ON public.mv_pilotos_problematicos USING btree (nivel_riesgo DESC);


--
-- Name: mv_pilotos_problematicos_nivel_riesgo_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_pilotos_problematicos_nivel_riesgo_idx2 ON public.mv_pilotos_problematicos USING btree (nivel_riesgo DESC);


--
-- Name: mv_puntos_calientes_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mv_puntos_calientes_id_idx ON public.mv_puntos_calientes USING btree (id);


--
-- Name: mv_puntos_calientes_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mv_puntos_calientes_id_idx1 ON public.mv_puntos_calientes USING btree (id);


--
-- Name: mv_puntos_calientes_id_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mv_puntos_calientes_id_idx2 ON public.mv_puntos_calientes USING btree (id);


--
-- Name: mv_puntos_calientes_municipio_codigo_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_puntos_calientes_municipio_codigo_idx ON public.mv_puntos_calientes USING btree (municipio_codigo);


--
-- Name: mv_puntos_calientes_municipio_codigo_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_puntos_calientes_municipio_codigo_idx1 ON public.mv_puntos_calientes USING btree (municipio_codigo);


--
-- Name: mv_puntos_calientes_municipio_codigo_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_puntos_calientes_municipio_codigo_idx2 ON public.mv_puntos_calientes USING btree (municipio_codigo);


--
-- Name: mv_puntos_calientes_nivel_peligrosidad_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_puntos_calientes_nivel_peligrosidad_idx ON public.mv_puntos_calientes USING btree (nivel_peligrosidad DESC);


--
-- Name: mv_puntos_calientes_nivel_peligrosidad_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_puntos_calientes_nivel_peligrosidad_idx1 ON public.mv_puntos_calientes USING btree (nivel_peligrosidad DESC);


--
-- Name: mv_puntos_calientes_nivel_peligrosidad_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_puntos_calientes_nivel_peligrosidad_idx2 ON public.mv_puntos_calientes USING btree (nivel_peligrosidad DESC);


--
-- Name: mv_puntos_calientes_ruta_codigo_kilometro_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_puntos_calientes_ruta_codigo_kilometro_idx ON public.mv_puntos_calientes USING btree (ruta_codigo, kilometro);


--
-- Name: mv_puntos_calientes_ruta_codigo_kilometro_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_puntos_calientes_ruta_codigo_kilometro_idx1 ON public.mv_puntos_calientes USING btree (ruta_codigo, kilometro);


--
-- Name: mv_puntos_calientes_ruta_codigo_kilometro_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_puntos_calientes_ruta_codigo_kilometro_idx2 ON public.mv_puntos_calientes USING btree (ruta_codigo, kilometro);


--
-- Name: mv_tendencias_temporales_anio_mes_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_anio_mes_idx ON public.mv_tendencias_temporales USING btree (anio, mes);


--
-- Name: mv_tendencias_temporales_anio_mes_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_anio_mes_idx1 ON public.mv_tendencias_temporales USING btree (anio, mes);


--
-- Name: mv_tendencias_temporales_anio_mes_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_anio_mes_idx2 ON public.mv_tendencias_temporales USING btree (anio, mes);


--
-- Name: mv_tendencias_temporales_dia_semana_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_dia_semana_idx ON public.mv_tendencias_temporales USING btree (dia_semana);


--
-- Name: mv_tendencias_temporales_dia_semana_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_dia_semana_idx1 ON public.mv_tendencias_temporales USING btree (dia_semana);


--
-- Name: mv_tendencias_temporales_dia_semana_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_dia_semana_idx2 ON public.mv_tendencias_temporales USING btree (dia_semana);


--
-- Name: mv_tendencias_temporales_fecha_hora_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mv_tendencias_temporales_fecha_hora_idx ON public.mv_tendencias_temporales USING btree (fecha, hora);


--
-- Name: mv_tendencias_temporales_fecha_hora_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mv_tendencias_temporales_fecha_hora_idx1 ON public.mv_tendencias_temporales USING btree (fecha, hora);


--
-- Name: mv_tendencias_temporales_fecha_hora_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mv_tendencias_temporales_fecha_hora_idx2 ON public.mv_tendencias_temporales USING btree (fecha, hora);


--
-- Name: mv_tendencias_temporales_fecha_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_fecha_idx ON public.mv_tendencias_temporales USING btree (fecha DESC);


--
-- Name: mv_tendencias_temporales_fecha_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_fecha_idx1 ON public.mv_tendencias_temporales USING btree (fecha DESC);


--
-- Name: mv_tendencias_temporales_fecha_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_fecha_idx2 ON public.mv_tendencias_temporales USING btree (fecha DESC);


--
-- Name: mv_tendencias_temporales_franja_horaria_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_franja_horaria_idx ON public.mv_tendencias_temporales USING btree (franja_horaria);


--
-- Name: mv_tendencias_temporales_franja_horaria_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_franja_horaria_idx1 ON public.mv_tendencias_temporales USING btree (franja_horaria);


--
-- Name: mv_tendencias_temporales_franja_horaria_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_franja_horaria_idx2 ON public.mv_tendencias_temporales USING btree (franja_horaria);


--
-- Name: mv_tendencias_temporales_hora_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_hora_idx ON public.mv_tendencias_temporales USING btree (hora);


--
-- Name: mv_tendencias_temporales_hora_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_hora_idx1 ON public.mv_tendencias_temporales USING btree (hora);


--
-- Name: mv_tendencias_temporales_hora_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_tendencias_temporales_hora_idx2 ON public.mv_tendencias_temporales USING btree (hora);


--
-- Name: mv_vehiculos_reincidentes_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mv_vehiculos_reincidentes_id_idx ON public.mv_vehiculos_reincidentes USING btree (id);


--
-- Name: mv_vehiculos_reincidentes_id_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mv_vehiculos_reincidentes_id_idx1 ON public.mv_vehiculos_reincidentes USING btree (id);


--
-- Name: mv_vehiculos_reincidentes_id_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX mv_vehiculos_reincidentes_id_idx2 ON public.mv_vehiculos_reincidentes USING btree (id);


--
-- Name: mv_vehiculos_reincidentes_nivel_riesgo_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_vehiculos_reincidentes_nivel_riesgo_idx ON public.mv_vehiculos_reincidentes USING btree (nivel_riesgo DESC);


--
-- Name: mv_vehiculos_reincidentes_nivel_riesgo_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_vehiculos_reincidentes_nivel_riesgo_idx1 ON public.mv_vehiculos_reincidentes USING btree (nivel_riesgo DESC);


--
-- Name: mv_vehiculos_reincidentes_nivel_riesgo_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_vehiculos_reincidentes_nivel_riesgo_idx2 ON public.mv_vehiculos_reincidentes USING btree (nivel_riesgo DESC);


--
-- Name: mv_vehiculos_reincidentes_placa_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_vehiculos_reincidentes_placa_idx ON public.mv_vehiculos_reincidentes USING btree (placa);


--
-- Name: mv_vehiculos_reincidentes_placa_idx1; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_vehiculos_reincidentes_placa_idx1 ON public.mv_vehiculos_reincidentes USING btree (placa);


--
-- Name: mv_vehiculos_reincidentes_placa_idx2; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX mv_vehiculos_reincidentes_placa_idx2 ON public.mv_vehiculos_reincidentes USING btree (placa);


--
-- Name: usuario_email_unique; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX usuario_email_unique ON public.usuario USING btree (email) WHERE ((email IS NOT NULL) AND ((email)::text <> ''::text));


--
-- Name: bitacora_historica_2024_fecha_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_fecha ATTACH PARTITION public.bitacora_historica_2024_fecha_idx;


--
-- Name: bitacora_historica_2024_fecha_unidad_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_fecha_unidad ATTACH PARTITION public.bitacora_historica_2024_fecha_unidad_id_idx;


--
-- Name: bitacora_historica_2024_fecha_unidad_id_key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.bitacora_historica_unidad_fecha_unique ATTACH PARTITION public.bitacora_historica_2024_fecha_unidad_id_key;


--
-- Name: bitacora_historica_2024_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.bitacora_historica_pkey ATTACH PARTITION public.bitacora_historica_2024_pkey;


--
-- Name: bitacora_historica_2024_sede_origen_id_fecha_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_sede ATTACH PARTITION public.bitacora_historica_2024_sede_origen_id_fecha_idx;


--
-- Name: bitacora_historica_2024_tripulacion_ids_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_tripulacion_gin ATTACH PARTITION public.bitacora_historica_2024_tripulacion_ids_idx;


--
-- Name: bitacora_historica_2024_unidad_id_fecha_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_unidad ATTACH PARTITION public.bitacora_historica_2024_unidad_id_fecha_idx;


--
-- Name: bitacora_historica_2025_fecha_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_fecha ATTACH PARTITION public.bitacora_historica_2025_fecha_idx;


--
-- Name: bitacora_historica_2025_fecha_unidad_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_fecha_unidad ATTACH PARTITION public.bitacora_historica_2025_fecha_unidad_id_idx;


--
-- Name: bitacora_historica_2025_fecha_unidad_id_key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.bitacora_historica_unidad_fecha_unique ATTACH PARTITION public.bitacora_historica_2025_fecha_unidad_id_key;


--
-- Name: bitacora_historica_2025_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.bitacora_historica_pkey ATTACH PARTITION public.bitacora_historica_2025_pkey;


--
-- Name: bitacora_historica_2025_sede_origen_id_fecha_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_sede ATTACH PARTITION public.bitacora_historica_2025_sede_origen_id_fecha_idx;


--
-- Name: bitacora_historica_2025_tripulacion_ids_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_tripulacion_gin ATTACH PARTITION public.bitacora_historica_2025_tripulacion_ids_idx;


--
-- Name: bitacora_historica_2025_unidad_id_fecha_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_unidad ATTACH PARTITION public.bitacora_historica_2025_unidad_id_fecha_idx;


--
-- Name: bitacora_historica_2026_fecha_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_fecha ATTACH PARTITION public.bitacora_historica_2026_fecha_idx;


--
-- Name: bitacora_historica_2026_fecha_unidad_id_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_fecha_unidad ATTACH PARTITION public.bitacora_historica_2026_fecha_unidad_id_idx;


--
-- Name: bitacora_historica_2026_fecha_unidad_id_key; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.bitacora_historica_unidad_fecha_unique ATTACH PARTITION public.bitacora_historica_2026_fecha_unidad_id_key;


--
-- Name: bitacora_historica_2026_pkey; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.bitacora_historica_pkey ATTACH PARTITION public.bitacora_historica_2026_pkey;


--
-- Name: bitacora_historica_2026_sede_origen_id_fecha_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_sede ATTACH PARTITION public.bitacora_historica_2026_sede_origen_id_fecha_idx;


--
-- Name: bitacora_historica_2026_tripulacion_ids_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_tripulacion_gin ATTACH PARTITION public.bitacora_historica_2026_tripulacion_ids_idx;


--
-- Name: bitacora_historica_2026_unidad_id_fecha_idx; Type: INDEX ATTACH; Schema: public; Owner: -
--

ALTER INDEX public.idx_bitacora_unidad ATTACH PARTITION public.bitacora_historica_2026_unidad_id_fecha_idx;


--
-- Name: v_estadisticas_unidades _RETURN; Type: RULE; Schema: public; Owner: -
--

CREATE OR REPLACE VIEW public.v_estadisticas_unidades AS
 SELECT un.id AS unidad_id,
    un.codigo AS unidad_codigo,
    un.tipo_unidad,
    un.marca,
    un.modelo,
    un.sede_id,
    s.nombre AS sede_nombre,
    un.activa,
    un.combustible_actual,
    un.capacidad_combustible,
    un.odometro_actual,
    count(DISTINCT au.id) FILTER (WHERE (t.fecha >= (CURRENT_DATE - '30 days'::interval))) AS turnos_ultimo_mes,
    count(DISTINCT au.id) FILTER (WHERE (t.fecha >= (CURRENT_DATE - '90 days'::interval))) AS turnos_ultimo_trimestre,
    max(t.fecha) AS ultimo_turno_fecha,
    (CURRENT_DATE - max(t.fecha)) AS dias_desde_ultimo_uso,
    min(t.fecha) FILTER (WHERE (t.fecha >= CURRENT_DATE)) AS proximo_turno_fecha,
    avg(cr.combustible_consumido) FILTER (WHERE (cr.created_at >= (CURRENT_DATE - '30 days'::interval))) AS consumo_promedio_diario,
    avg(cr.rendimiento_km_litro) FILTER (WHERE (cr.created_at >= (CURRENT_DATE - '30 days'::interval))) AS rendimiento_promedio,
    sum(au.km_recorridos) FILTER (WHERE (t.fecha >= (CURRENT_DATE - '30 days'::interval))) AS km_ultimo_mes
   FROM ((((public.unidad un
     JOIN public.sede s ON ((un.sede_id = s.id)))
     LEFT JOIN public.asignacion_unidad au ON ((un.id = au.unidad_id)))
     LEFT JOIN public.turno t ON ((au.turno_id = t.id)))
     LEFT JOIN public.combustible_registro cr ON (((un.id = cr.unidad_id) AND ((cr.tipo)::text = 'FINAL'::text))))
  GROUP BY un.id, un.codigo, un.tipo_unidad, un.marca, un.modelo, un.sede_id, s.nombre;


--
-- Name: aprobacion_tripulacion tr_aprobacion_tripulacion_updated; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tr_aprobacion_tripulacion_updated BEFORE UPDATE ON public.aprobacion_tripulacion FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: dispositivo_push tr_dispositivo_push_updated; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER tr_dispositivo_push_updated BEFORE UPDATE ON public.dispositivo_push FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: situacion trg_alerta_emergencia; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_alerta_emergencia AFTER INSERT ON public.situacion FOR EACH ROW EXECUTE FUNCTION public.trigger_alerta_emergencia();


--
-- Name: configuracion_columnas_tabla trg_config_columnas_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_config_columnas_updated_at BEFORE UPDATE ON public.configuracion_columnas_tabla FOR EACH ROW EXECUTE FUNCTION public.update_config_columnas_updated_at();


--
-- Name: situacion_persistente trg_numero_situacion_persistente; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_numero_situacion_persistente BEFORE INSERT ON public.situacion_persistente FOR EACH ROW EXECUTE FUNCTION public.fn_generar_numero_situacion_persistente();


--
-- Name: asignacion_unidad trg_validar_asignacion_unidad; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trg_validar_asignacion_unidad BEFORE INSERT OR UPDATE OF unidad_id, turno_id ON public.asignacion_unidad FOR EACH ROW EXECUTE FUNCTION public.trigger_validar_asignacion_unidad();


--
-- Name: asignacion_unidad trigger_asignacion_auditar_cierre; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_asignacion_auditar_cierre BEFORE UPDATE ON public.asignacion_unidad FOR EACH ROW WHEN ((old.dia_cerrado = true)) EXECUTE FUNCTION public.trigger_auditar_cambio_asignacion_cerrada();


--
-- Name: reporte_horario trigger_calcular_km_recorridos; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_calcular_km_recorridos AFTER INSERT ON public.reporte_horario FOR EACH ROW EXECUTE FUNCTION public.calcular_km_recorridos();


--
-- Name: actividad_unidad trigger_cerrar_actividad_anterior; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_cerrar_actividad_anterior BEFORE INSERT ON public.actividad_unidad FOR EACH ROW EXECUTE FUNCTION public.cerrar_actividad_anterior();


--
-- Name: obstruccion_situacion_persistente trigger_desc_obstruccion; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_desc_obstruccion BEFORE INSERT OR UPDATE ON public.obstruccion_situacion_persistente FOR EACH ROW EXECUTE FUNCTION public.trigger_actualizar_descripcion_obstruccion();


--
-- Name: evento_persistente trigger_evento_persistente_updated; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_evento_persistente_updated BEFORE UPDATE ON public.evento_persistente FOR EACH ROW EXECUTE FUNCTION public.update_evento_persistente_timestamp();


--
-- Name: incidente trigger_generar_numero_reporte; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_generar_numero_reporte BEFORE INSERT ON public.incidente FOR EACH ROW WHEN ((new.numero_reporte IS NULL)) EXECUTE FUNCTION public.generar_numero_reporte();


--
-- Name: situacion trigger_generar_numero_situacion; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_generar_numero_situacion BEFORE INSERT ON public.situacion FOR EACH ROW WHEN ((new.numero_situacion IS NULL)) EXECUTE FUNCTION public.generar_numero_situacion();


--
-- Name: incidente trigger_log_incidente_cambios; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_log_incidente_cambios AFTER INSERT OR DELETE OR UPDATE ON public.incidente FOR EACH ROW EXECUTE FUNCTION public.log_incidente_cambios();


--
-- Name: situacion trigger_situacion_actualizar_ruta_activa; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_situacion_actualizar_ruta_activa AFTER INSERT ON public.situacion FOR EACH ROW EXECUTE FUNCTION public.trigger_actualizar_ruta_activa();


--
-- Name: TRIGGER trigger_situacion_actualizar_ruta_activa ON situacion; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER trigger_situacion_actualizar_ruta_activa ON public.situacion IS 'Actualiza automáticamente la ruta activa cuando se crea SALIDA_SEDE o CAMBIO_RUTA';


--
-- Name: situacion trigger_situacion_auditar_cierre; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_situacion_auditar_cierre BEFORE UPDATE ON public.situacion FOR EACH ROW EXECUTE FUNCTION public.trigger_auditar_cambio_situacion_cerrada();


--
-- Name: incidente_vehiculo trigger_update_aseguradora_stats; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_aseguradora_stats AFTER INSERT ON public.incidente_vehiculo FOR EACH ROW EXECUTE FUNCTION public.update_aseguradora_stats();


--
-- Name: combustible_registro trigger_update_combustible_unidad; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_combustible_unidad AFTER INSERT ON public.combustible_registro FOR EACH ROW EXECUTE FUNCTION public.update_combustible_unidad();


--
-- Name: incidente_grua trigger_update_grua_stats; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_grua_stats AFTER INSERT ON public.incidente_grua FOR EACH ROW EXECUTE FUNCTION public.update_grua_stats();


--
-- Name: sancion trigger_update_piloto_sancion_stats; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_piloto_sancion_stats AFTER INSERT ON public.sancion FOR EACH ROW EXECUTE FUNCTION public.update_piloto_sancion_stats();


--
-- Name: incidente_vehiculo trigger_update_piloto_stats; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_piloto_stats AFTER INSERT ON public.incidente_vehiculo FOR EACH ROW EXECUTE FUNCTION public.update_piloto_stats();


--
-- Name: incidente_vehiculo trigger_update_vehiculo_stats; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_update_vehiculo_stats AFTER INSERT ON public.incidente_vehiculo FOR EACH ROW EXECUTE FUNCTION public.update_vehiculo_stats();


--
-- Name: usuario trigger_usuario_validar_suspension; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_usuario_validar_suspension BEFORE UPDATE ON public.usuario FOR EACH ROW WHEN ((old.acceso_app_activo IS DISTINCT FROM new.acceso_app_activo)) EXECUTE FUNCTION public.trigger_validar_suspension_acceso();


--
-- Name: TRIGGER trigger_usuario_validar_suspension ON usuario; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TRIGGER trigger_usuario_validar_suspension ON public.usuario IS 'Valida que un usuario pueda tener su acceso suspendido';


--
-- Name: actividad_unidad trigger_validar_actividad_incidente; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER trigger_validar_actividad_incidente BEFORE INSERT OR UPDATE ON public.actividad_unidad FOR EACH ROW EXECUTE FUNCTION public.validar_actividad_incidente();


--
-- Name: actividad_unidad update_actividad_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_actividad_updated_at BEFORE UPDATE ON public.actividad_unidad FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: asignacion_unidad update_asignacion_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_asignacion_updated_at BEFORE UPDATE ON public.asignacion_unidad FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: autoridad_situacion_persistente update_autoridad_sit_pers_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_autoridad_sit_pers_updated_at BEFORE UPDATE ON public.autoridad_situacion_persistente FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: brigada_unidad update_brigada_unidad_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_brigada_unidad_updated_at BEFORE UPDATE ON public.brigada_unidad FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: configuracion_visual_sede update_config_visual_sede_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_config_visual_sede_updated_at BEFORE UPDATE ON public.configuracion_visual_sede FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: detalle_situacion update_detalle_situacion_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_detalle_situacion_updated_at BEFORE UPDATE ON public.detalle_situacion FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: grua update_grua_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_grua_updated_at BEFORE UPDATE ON public.grua FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: incidente update_incidente_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_incidente_updated_at BEFORE UPDATE ON public.incidente FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: ingreso_sede update_ingreso_sede_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_ingreso_sede_updated_at BEFORE UPDATE ON public.ingreso_sede FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: inspeccion_360 update_inspeccion_360_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_inspeccion_360_updated_at BEFORE UPDATE ON public.inspeccion_360 FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: movimiento_brigada update_movimiento_brigada_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_movimiento_brigada_updated_at BEFORE UPDATE ON public.movimiento_brigada FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: obstruccion_incidente update_obstruccion_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_obstruccion_updated_at BEFORE UPDATE ON public.obstruccion_incidente FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: piloto update_piloto_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_piloto_updated_at BEFORE UPDATE ON public.piloto FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: plantilla_inspeccion_360 update_plantilla_360_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_plantilla_360_updated_at BEFORE UPDATE ON public.plantilla_inspeccion_360 FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: reasignacion_sede update_reasignacion_sede_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_reasignacion_sede_updated_at BEFORE UPDATE ON public.reasignacion_sede FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: salida_unidad update_salida_unidad_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_salida_unidad_updated_at BEFORE UPDATE ON public.salida_unidad FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: sede update_sede_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_sede_updated_at BEFORE UPDATE ON public.sede FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: situacion_fija update_situacion_fija_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_situacion_fija_updated_at BEFORE UPDATE ON public.situacion_fija FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: situacion update_situacion_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_situacion_updated_at BEFORE UPDATE ON public.situacion FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: socorro_situacion_persistente update_socorro_sit_pers_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_socorro_sit_pers_updated_at BEFORE UPDATE ON public.socorro_situacion_persistente FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: sub_rol_cop update_sub_rol_cop_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_sub_rol_cop_updated_at BEFORE UPDATE ON public.sub_rol_cop FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: turno update_turno_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_turno_updated_at BEFORE UPDATE ON public.turno FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: unidad update_unidad_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_unidad_updated_at BEFORE UPDATE ON public.unidad FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: usuario update_usuario_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_usuario_updated_at BEFORE UPDATE ON public.usuario FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: vehiculo update_vehiculo_updated_at; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER update_vehiculo_updated_at BEFORE UPDATE ON public.vehiculo FOR EACH ROW EXECUTE FUNCTION public.update_updated_at_column();


--
-- Name: actividad_unidad actividad_unidad_asignacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actividad_unidad
    ADD CONSTRAINT actividad_unidad_asignacion_id_fkey FOREIGN KEY (asignacion_id) REFERENCES public.asignacion_unidad(id) ON DELETE SET NULL;


--
-- Name: actividad_unidad actividad_unidad_incidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actividad_unidad
    ADD CONSTRAINT actividad_unidad_incidente_id_fkey FOREIGN KEY (incidente_id) REFERENCES public.incidente(id) ON DELETE SET NULL;


--
-- Name: actividad_unidad actividad_unidad_registrado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actividad_unidad
    ADD CONSTRAINT actividad_unidad_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: actividad_unidad actividad_unidad_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actividad_unidad
    ADD CONSTRAINT actividad_unidad_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(id) ON DELETE SET NULL;


--
-- Name: actividad_unidad actividad_unidad_tipo_actividad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actividad_unidad
    ADD CONSTRAINT actividad_unidad_tipo_actividad_id_fkey FOREIGN KEY (tipo_actividad_id) REFERENCES public.tipo_actividad(id) ON DELETE RESTRICT;


--
-- Name: actividad_unidad actividad_unidad_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actividad_unidad
    ADD CONSTRAINT actividad_unidad_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id) ON DELETE CASCADE;


--
-- Name: actualizacion_situacion_persistente actualizacion_situacion_persisten_situacion_persistente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actualizacion_situacion_persistente
    ADD CONSTRAINT actualizacion_situacion_persisten_situacion_persistente_id_fkey FOREIGN KEY (situacion_persistente_id) REFERENCES public.situacion_persistente(id) ON DELETE CASCADE;


--
-- Name: actualizacion_situacion_persistente actualizacion_situacion_persistent_asignacion_situacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actualizacion_situacion_persistente
    ADD CONSTRAINT actualizacion_situacion_persistent_asignacion_situacion_id_fkey FOREIGN KEY (asignacion_situacion_id) REFERENCES public.asignacion_situacion_persistente(id);


--
-- Name: actualizacion_situacion_persistente actualizacion_situacion_persistente_editado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actualizacion_situacion_persistente
    ADD CONSTRAINT actualizacion_situacion_persistente_editado_por_fkey FOREIGN KEY (editado_por) REFERENCES public.usuario(id);


--
-- Name: actualizacion_situacion_persistente actualizacion_situacion_persistente_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actualizacion_situacion_persistente
    ADD CONSTRAINT actualizacion_situacion_persistente_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id);


--
-- Name: actualizacion_situacion_persistente actualizacion_situacion_persistente_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.actualizacion_situacion_persistente
    ADD CONSTRAINT actualizacion_situacion_persistente_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: ajustador_involucrado ajustador_involucrado_incidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ajustador_involucrado
    ADD CONSTRAINT ajustador_involucrado_incidente_id_fkey FOREIGN KEY (incidente_id) REFERENCES public.incidente(id) ON DELETE CASCADE;


--
-- Name: ajustador_involucrado ajustador_involucrado_vehiculo_asignado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ajustador_involucrado
    ADD CONSTRAINT ajustador_involucrado_vehiculo_asignado_id_fkey FOREIGN KEY (vehiculo_asignado_id) REFERENCES public.vehiculo_incidente(id) ON DELETE SET NULL;


--
-- Name: alerta alerta_atendida_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta
    ADD CONSTRAINT alerta_atendida_por_fkey FOREIGN KEY (atendida_por) REFERENCES public.usuario(id);


--
-- Name: alerta alerta_brigada_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta
    ADD CONSTRAINT alerta_brigada_id_fkey FOREIGN KEY (brigada_id) REFERENCES public.brigada(id);


--
-- Name: alerta_leida alerta_leida_alerta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta_leida
    ADD CONSTRAINT alerta_leida_alerta_id_fkey FOREIGN KEY (alerta_id) REFERENCES public.alerta(id) ON DELETE CASCADE;


--
-- Name: alerta_leida alerta_leida_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta_leida
    ADD CONSTRAINT alerta_leida_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: alerta alerta_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta
    ADD CONSTRAINT alerta_sede_id_fkey FOREIGN KEY (sede_id) REFERENCES public.sede(id);


--
-- Name: alerta alerta_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alerta
    ADD CONSTRAINT alerta_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id);


--
-- Name: aprobacion_respuesta aprobacion_respuesta_aprobacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aprobacion_respuesta
    ADD CONSTRAINT aprobacion_respuesta_aprobacion_id_fkey FOREIGN KEY (aprobacion_id) REFERENCES public.aprobacion_tripulacion(id) ON DELETE CASCADE;


--
-- Name: aprobacion_respuesta aprobacion_respuesta_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aprobacion_respuesta
    ADD CONSTRAINT aprobacion_respuesta_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: aprobacion_tripulacion aprobacion_tripulacion_iniciado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aprobacion_tripulacion
    ADD CONSTRAINT aprobacion_tripulacion_iniciado_por_fkey FOREIGN KEY (iniciado_por) REFERENCES public.usuario(id);


--
-- Name: aprobacion_tripulacion aprobacion_tripulacion_inspeccion_360_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aprobacion_tripulacion
    ADD CONSTRAINT aprobacion_tripulacion_inspeccion_360_id_fkey FOREIGN KEY (inspeccion_360_id) REFERENCES public.inspeccion_360(id) ON DELETE CASCADE;


--
-- Name: aprobacion_tripulacion aprobacion_tripulacion_salida_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aprobacion_tripulacion
    ADD CONSTRAINT aprobacion_tripulacion_salida_id_fkey FOREIGN KEY (salida_id) REFERENCES public.salida_unidad(id) ON DELETE CASCADE;


--
-- Name: aprobacion_tripulacion aprobacion_tripulacion_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aprobacion_tripulacion
    ADD CONSTRAINT aprobacion_tripulacion_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id);


--
-- Name: asignacion_situacion_persistente asignacion_situacion_persistente_asignacion_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_situacion_persistente
    ADD CONSTRAINT asignacion_situacion_persistente_asignacion_unidad_id_fkey FOREIGN KEY (asignacion_unidad_id) REFERENCES public.asignacion_unidad(id);


--
-- Name: asignacion_situacion_persistente asignacion_situacion_persistente_asignado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_situacion_persistente
    ADD CONSTRAINT asignacion_situacion_persistente_asignado_por_fkey FOREIGN KEY (asignado_por) REFERENCES public.usuario(id);


--
-- Name: asignacion_situacion_persistente asignacion_situacion_persistente_desasignado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_situacion_persistente
    ADD CONSTRAINT asignacion_situacion_persistente_desasignado_por_fkey FOREIGN KEY (desasignado_por) REFERENCES public.usuario(id);


--
-- Name: asignacion_situacion_persistente asignacion_situacion_persistente_situacion_persistente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_situacion_persistente
    ADD CONSTRAINT asignacion_situacion_persistente_situacion_persistente_id_fkey FOREIGN KEY (situacion_persistente_id) REFERENCES public.situacion_persistente(id) ON DELETE CASCADE;


--
-- Name: asignacion_situacion_persistente asignacion_situacion_persistente_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_situacion_persistente
    ADD CONSTRAINT asignacion_situacion_persistente_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id);


--
-- Name: asignacion_unidad asignacion_unidad_cerrado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_unidad
    ADD CONSTRAINT asignacion_unidad_cerrado_por_fkey FOREIGN KEY (cerrado_por) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: asignacion_unidad asignacion_unidad_ruta_activa_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_unidad
    ADD CONSTRAINT asignacion_unidad_ruta_activa_id_fkey FOREIGN KEY (ruta_activa_id) REFERENCES public.ruta(id) ON DELETE SET NULL;


--
-- Name: asignacion_unidad asignacion_unidad_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_unidad
    ADD CONSTRAINT asignacion_unidad_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(id) ON DELETE SET NULL;


--
-- Name: asignacion_unidad asignacion_unidad_situacion_fija_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_unidad
    ADD CONSTRAINT asignacion_unidad_situacion_fija_id_fkey FOREIGN KEY (situacion_fija_id) REFERENCES public.situacion_fija(id);


--
-- Name: asignacion_unidad asignacion_unidad_turno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_unidad
    ADD CONSTRAINT asignacion_unidad_turno_id_fkey FOREIGN KEY (turno_id) REFERENCES public.turno(id) ON DELETE CASCADE;


--
-- Name: asignacion_unidad asignacion_unidad_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.asignacion_unidad
    ADD CONSTRAINT asignacion_unidad_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id) ON DELETE RESTRICT;


--
-- Name: auditoria_log auditoria_log_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.auditoria_log
    ADD CONSTRAINT auditoria_log_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: autoridad_situacion_persistente autoridad_situacion_persistente_situacion_persistente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.autoridad_situacion_persistente
    ADD CONSTRAINT autoridad_situacion_persistente_situacion_persistente_id_fkey FOREIGN KEY (situacion_persistente_id) REFERENCES public.situacion_persistente(id) ON DELETE CASCADE;


--
-- Name: aviso_asignacion aviso_asignacion_asignacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aviso_asignacion
    ADD CONSTRAINT aviso_asignacion_asignacion_id_fkey FOREIGN KEY (asignacion_id) REFERENCES public.asignacion_unidad(id) ON DELETE CASCADE;


--
-- Name: aviso_asignacion aviso_asignacion_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.aviso_asignacion
    ADD CONSTRAINT aviso_asignacion_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id);


--
-- Name: bitacora_historica bitacora_historica_finalizado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.bitacora_historica
    ADD CONSTRAINT bitacora_historica_finalizado_por_fkey FOREIGN KEY (finalizado_por) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: bitacora_historica bitacora_historica_ruta_inicial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.bitacora_historica
    ADD CONSTRAINT bitacora_historica_ruta_inicial_id_fkey FOREIGN KEY (ruta_inicial_id) REFERENCES public.ruta(id) ON DELETE SET NULL;


--
-- Name: bitacora_historica bitacora_historica_sede_origen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.bitacora_historica
    ADD CONSTRAINT bitacora_historica_sede_origen_id_fkey FOREIGN KEY (sede_origen_id) REFERENCES public.sede(id) ON DELETE SET NULL;


--
-- Name: bitacora_historica bitacora_historica_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE public.bitacora_historica
    ADD CONSTRAINT bitacora_historica_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id) ON DELETE RESTRICT;


--
-- Name: brigada brigada_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brigada
    ADD CONSTRAINT brigada_sede_id_fkey FOREIGN KEY (sede_id) REFERENCES public.sede(id) ON DELETE RESTRICT;


--
-- Name: brigada_unidad brigada_unidad_asignado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brigada_unidad
    ADD CONSTRAINT brigada_unidad_asignado_por_fkey FOREIGN KEY (asignado_por) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: brigada_unidad brigada_unidad_brigada_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brigada_unidad
    ADD CONSTRAINT brigada_unidad_brigada_id_fkey FOREIGN KEY (brigada_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


--
-- Name: brigada_unidad brigada_unidad_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brigada_unidad
    ADD CONSTRAINT brigada_unidad_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id) ON DELETE CASCADE;


--
-- Name: brigada brigada_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.brigada
    ADD CONSTRAINT brigada_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: bus bus_vehiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bus
    ADD CONSTRAINT bus_vehiculo_id_fkey FOREIGN KEY (vehiculo_id) REFERENCES public.vehiculo(id) ON DELETE CASCADE;


--
-- Name: calendario_grupo calendario_grupo_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendario_grupo
    ADD CONSTRAINT calendario_grupo_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: campo_personalizado campo_personalizado_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.campo_personalizado
    ADD CONSTRAINT campo_personalizado_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id);


--
-- Name: combustible_registro combustible_registro_asignacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.combustible_registro
    ADD CONSTRAINT combustible_registro_asignacion_id_fkey FOREIGN KEY (asignacion_id) REFERENCES public.asignacion_unidad(id) ON DELETE SET NULL;


--
-- Name: combustible_registro combustible_registro_registrado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.combustible_registro
    ADD CONSTRAINT combustible_registro_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: combustible_registro combustible_registro_turno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.combustible_registro
    ADD CONSTRAINT combustible_registro_turno_id_fkey FOREIGN KEY (turno_id) REFERENCES public.turno(id) ON DELETE SET NULL;


--
-- Name: combustible_registro combustible_registro_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.combustible_registro
    ADD CONSTRAINT combustible_registro_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id) ON DELETE CASCADE;


--
-- Name: configuracion_columnas_tabla configuracion_columnas_tabla_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_columnas_tabla
    ADD CONSTRAINT configuracion_columnas_tabla_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id);


--
-- Name: configuracion_columnas_tabla configuracion_columnas_tabla_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_columnas_tabla
    ADD CONSTRAINT configuracion_columnas_tabla_sede_id_fkey FOREIGN KEY (sede_id) REFERENCES public.sede(id) ON DELETE CASCADE;


--
-- Name: configuracion_sistema configuracion_sistema_modificado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_sistema
    ADD CONSTRAINT configuracion_sistema_modificado_por_fkey FOREIGN KEY (modificado_por) REFERENCES public.usuario(id);


--
-- Name: configuracion_visual_sede configuracion_visual_sede_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.configuracion_visual_sede
    ADD CONSTRAINT configuracion_visual_sede_sede_id_fkey FOREIGN KEY (sede_id) REFERENCES public.sede(id) ON DELETE CASCADE;


--
-- Name: contenedor contenedor_vehiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.contenedor
    ADD CONSTRAINT contenedor_vehiculo_id_fkey FOREIGN KEY (vehiculo_id) REFERENCES public.vehiculo(id) ON DELETE CASCADE;


--
-- Name: control_acceso_app control_acceso_app_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_acceso_app
    ADD CONSTRAINT control_acceso_app_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: control_acceso_app control_acceso_app_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_acceso_app
    ADD CONSTRAINT control_acceso_app_sede_id_fkey FOREIGN KEY (sede_id) REFERENCES public.sede(id) ON DELETE CASCADE;


--
-- Name: control_acceso_app control_acceso_app_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_acceso_app
    ADD CONSTRAINT control_acceso_app_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id) ON DELETE CASCADE;


--
-- Name: control_acceso_app control_acceso_app_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.control_acceso_app
    ADD CONSTRAINT control_acceso_app_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


--
-- Name: detalle_situacion detalle_situacion_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_situacion
    ADD CONSTRAINT detalle_situacion_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: detalle_situacion detalle_situacion_situacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.detalle_situacion
    ADD CONSTRAINT detalle_situacion_situacion_id_fkey FOREIGN KEY (situacion_id) REFERENCES public.situacion(id) ON DELETE CASCADE;


--
-- Name: dispositivo_push dispositivo_push_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dispositivo_push
    ADD CONSTRAINT dispositivo_push_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


--
-- Name: estado_grupo_departamento estado_grupo_departamento_departamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estado_grupo_departamento
    ADD CONSTRAINT estado_grupo_departamento_departamento_id_fkey FOREIGN KEY (departamento_id) REFERENCES public.departamento_sistema(id) ON DELETE CASCADE;


--
-- Name: estado_grupo_departamento estado_grupo_departamento_modificado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estado_grupo_departamento
    ADD CONSTRAINT estado_grupo_departamento_modificado_por_fkey FOREIGN KEY (modificado_por) REFERENCES public.usuario(id);


--
-- Name: estado_grupo_departamento estado_grupo_departamento_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.estado_grupo_departamento
    ADD CONSTRAINT estado_grupo_departamento_sede_id_fkey FOREIGN KEY (sede_id) REFERENCES public.sede(id) ON DELETE CASCADE;


--
-- Name: evento_persistente evento_persistente_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evento_persistente
    ADD CONSTRAINT evento_persistente_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id);


--
-- Name: evento_persistente evento_persistente_resuelto_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evento_persistente
    ADD CONSTRAINT evento_persistente_resuelto_por_fkey FOREIGN KEY (resuelto_por) REFERENCES public.usuario(id);


--
-- Name: evento_persistente evento_persistente_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.evento_persistente
    ADD CONSTRAINT evento_persistente_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(id);


--
-- Name: ubicacion_brigada fk_ubicacion_brigada_situacion; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubicacion_brigada
    ADD CONSTRAINT fk_ubicacion_brigada_situacion FOREIGN KEY (situacion_persistente_id) REFERENCES public.situacion_persistente(id) ON DELETE SET NULL;


--
-- Name: grua_involucrada grua_involucrada_incidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grua_involucrada
    ADD CONSTRAINT grua_involucrada_incidente_id_fkey FOREIGN KEY (incidente_id) REFERENCES public.incidente(id) ON DELETE CASCADE;


--
-- Name: grua_involucrada grua_involucrada_vehiculo_asignado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.grua_involucrada
    ADD CONSTRAINT grua_involucrada_vehiculo_asignado_id_fkey FOREIGN KEY (vehiculo_asignado_id) REFERENCES public.vehiculo_incidente(id) ON DELETE SET NULL;


--
-- Name: historial_encargado_sede_grupo historial_encargado_sede_grupo_asignado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_encargado_sede_grupo
    ADD CONSTRAINT historial_encargado_sede_grupo_asignado_por_fkey FOREIGN KEY (asignado_por) REFERENCES public.usuario(id);


--
-- Name: historial_encargado_sede_grupo historial_encargado_sede_grupo_removido_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_encargado_sede_grupo
    ADD CONSTRAINT historial_encargado_sede_grupo_removido_por_fkey FOREIGN KEY (removido_por) REFERENCES public.usuario(id);


--
-- Name: historial_encargado_sede_grupo historial_encargado_sede_grupo_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_encargado_sede_grupo
    ADD CONSTRAINT historial_encargado_sede_grupo_sede_id_fkey FOREIGN KEY (sede_id) REFERENCES public.sede(id) ON DELETE CASCADE;


--
-- Name: historial_encargado_sede_grupo historial_encargado_sede_grupo_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_encargado_sede_grupo
    ADD CONSTRAINT historial_encargado_sede_grupo_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


--
-- Name: historial_ruta_brigada historial_ruta_brigada_asignacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_ruta_brigada
    ADD CONSTRAINT historial_ruta_brigada_asignacion_id_fkey FOREIGN KEY (asignacion_id) REFERENCES public.asignacion_unidad(id) ON DELETE SET NULL;


--
-- Name: historial_ruta_brigada historial_ruta_brigada_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_ruta_brigada
    ADD CONSTRAINT historial_ruta_brigada_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(id) ON DELETE CASCADE;


--
-- Name: historial_ruta_brigada historial_ruta_brigada_turno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_ruta_brigada
    ADD CONSTRAINT historial_ruta_brigada_turno_id_fkey FOREIGN KEY (turno_id) REFERENCES public.turno(id) ON DELETE SET NULL;


--
-- Name: historial_ruta_brigada historial_ruta_brigada_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_ruta_brigada
    ADD CONSTRAINT historial_ruta_brigada_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


--
-- Name: historial_situacion_brigada historial_situacion_brigada_asignacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_situacion_brigada
    ADD CONSTRAINT historial_situacion_brigada_asignacion_id_fkey FOREIGN KEY (asignacion_id) REFERENCES public.asignacion_unidad(id) ON DELETE SET NULL;


--
-- Name: historial_situacion_brigada historial_situacion_brigada_situacion_fija_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_situacion_brigada
    ADD CONSTRAINT historial_situacion_brigada_situacion_fija_id_fkey FOREIGN KEY (situacion_fija_id) REFERENCES public.situacion_fija(id) ON DELETE CASCADE;


--
-- Name: historial_situacion_brigada historial_situacion_brigada_turno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_situacion_brigada
    ADD CONSTRAINT historial_situacion_brigada_turno_id_fkey FOREIGN KEY (turno_id) REFERENCES public.turno(id) ON DELETE SET NULL;


--
-- Name: historial_situacion_brigada historial_situacion_brigada_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.historial_situacion_brigada
    ADD CONSTRAINT historial_situacion_brigada_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


--
-- Name: hoja_accidentologia hoja_accidentologia_elaborado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hoja_accidentologia
    ADD CONSTRAINT hoja_accidentologia_elaborado_por_fkey FOREIGN KEY (elaborado_por) REFERENCES public.usuario(id);


--
-- Name: hoja_accidentologia hoja_accidentologia_revisado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hoja_accidentologia
    ADD CONSTRAINT hoja_accidentologia_revisado_por_fkey FOREIGN KEY (revisado_por) REFERENCES public.usuario(id);


--
-- Name: hoja_accidentologia hoja_accidentologia_situacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.hoja_accidentologia
    ADD CONSTRAINT hoja_accidentologia_situacion_id_fkey FOREIGN KEY (situacion_id) REFERENCES public.situacion(id) ON DELETE CASCADE;


--
-- Name: incidente incidente_actualizado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_actualizado_por_fkey FOREIGN KEY (actualizado_por) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: incidente incidente_asignacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_asignacion_id_fkey FOREIGN KEY (asignacion_id) REFERENCES public.asignacion_unidad(id) ON DELETE SET NULL;


--
-- Name: incidente incidente_brigada_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_brigada_id_fkey FOREIGN KEY (brigada_id) REFERENCES public.brigada(id) ON DELETE SET NULL;


--
-- Name: incidente incidente_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: incidente incidente_departamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_departamento_id_fkey FOREIGN KEY (departamento_id) REFERENCES public.departamento(id) ON DELETE SET NULL;


--
-- Name: incidente_grua incidente_grua_grua_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_grua
    ADD CONSTRAINT incidente_grua_grua_id_fkey FOREIGN KEY (grua_id) REFERENCES public.grua(id) ON DELETE CASCADE;


--
-- Name: incidente_grua incidente_grua_incidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_grua
    ADD CONSTRAINT incidente_grua_incidente_id_fkey FOREIGN KEY (incidente_id) REFERENCES public.incidente(id) ON DELETE CASCADE;


--
-- Name: incidente incidente_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipio(id) ON DELETE SET NULL;


--
-- Name: incidente_no_atendido incidente_no_atendido_incidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_no_atendido
    ADD CONSTRAINT incidente_no_atendido_incidente_id_fkey FOREIGN KEY (incidente_id) REFERENCES public.incidente(id) ON DELETE CASCADE;


--
-- Name: incidente_no_atendido incidente_no_atendido_motivo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_no_atendido
    ADD CONSTRAINT incidente_no_atendido_motivo_id_fkey FOREIGN KEY (motivo_id) REFERENCES public.motivo_no_atendido(id) ON DELETE RESTRICT;


--
-- Name: incidente_no_atendido incidente_no_atendido_registrado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_no_atendido
    ADD CONSTRAINT incidente_no_atendido_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: incidente incidente_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(id) ON DELETE RESTRICT;


--
-- Name: incidente incidente_subtipo_hecho_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_subtipo_hecho_id_fkey FOREIGN KEY (subtipo_hecho_id) REFERENCES public.subtipo_hecho(id) ON DELETE SET NULL;


--
-- Name: incidente incidente_tipo_hecho_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_tipo_hecho_id_fkey FOREIGN KEY (tipo_hecho_id) REFERENCES public.tipo_hecho(id) ON DELETE RESTRICT;


--
-- Name: incidente incidente_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente
    ADD CONSTRAINT incidente_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id) ON DELETE SET NULL;


--
-- Name: incidente_vehiculo incidente_vehiculo_aseguradora_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_vehiculo
    ADD CONSTRAINT incidente_vehiculo_aseguradora_id_fkey FOREIGN KEY (aseguradora_id) REFERENCES public.aseguradora(id) ON DELETE SET NULL;


--
-- Name: incidente_vehiculo incidente_vehiculo_incidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_vehiculo
    ADD CONSTRAINT incidente_vehiculo_incidente_id_fkey FOREIGN KEY (incidente_id) REFERENCES public.incidente(id) ON DELETE CASCADE;


--
-- Name: incidente_vehiculo incidente_vehiculo_piloto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_vehiculo
    ADD CONSTRAINT incidente_vehiculo_piloto_id_fkey FOREIGN KEY (piloto_id) REFERENCES public.piloto(id) ON DELETE SET NULL;


--
-- Name: incidente_vehiculo incidente_vehiculo_vehiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.incidente_vehiculo
    ADD CONSTRAINT incidente_vehiculo_vehiculo_id_fkey FOREIGN KEY (vehiculo_id) REFERENCES public.vehiculo(id) ON DELETE CASCADE;


--
-- Name: ingreso_sede ingreso_sede_registrado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingreso_sede
    ADD CONSTRAINT ingreso_sede_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: ingreso_sede ingreso_sede_salida_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingreso_sede
    ADD CONSTRAINT ingreso_sede_salida_unidad_id_fkey FOREIGN KEY (salida_unidad_id) REFERENCES public.salida_unidad(id) ON DELETE CASCADE;


--
-- Name: ingreso_sede ingreso_sede_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ingreso_sede
    ADD CONSTRAINT ingreso_sede_sede_id_fkey FOREIGN KEY (sede_id) REFERENCES public.sede(id) ON DELETE RESTRICT;


--
-- Name: inspeccion_360 inspeccion_360_aprobado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspeccion_360
    ADD CONSTRAINT inspeccion_360_aprobado_por_fkey FOREIGN KEY (aprobado_por) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: inspeccion_360 inspeccion_360_plantilla_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspeccion_360
    ADD CONSTRAINT inspeccion_360_plantilla_id_fkey FOREIGN KEY (plantilla_id) REFERENCES public.plantilla_inspeccion_360(id) ON DELETE RESTRICT;


--
-- Name: inspeccion_360 inspeccion_360_realizado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspeccion_360
    ADD CONSTRAINT inspeccion_360_realizado_por_fkey FOREIGN KEY (realizado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: inspeccion_360 inspeccion_360_salida_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspeccion_360
    ADD CONSTRAINT inspeccion_360_salida_id_fkey FOREIGN KEY (salida_id) REFERENCES public.salida_unidad(id) ON DELETE CASCADE;


--
-- Name: inspeccion_360 inspeccion_360_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.inspeccion_360
    ADD CONSTRAINT inspeccion_360_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id) ON DELETE RESTRICT;


--
-- Name: log_administracion log_administracion_realizado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_administracion
    ADD CONSTRAINT log_administracion_realizado_por_fkey FOREIGN KEY (realizado_por) REFERENCES public.usuario(id);


--
-- Name: log_administracion log_administracion_usuario_afectado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.log_administracion
    ADD CONSTRAINT log_administracion_usuario_afectado_id_fkey FOREIGN KEY (usuario_afectado_id) REFERENCES public.usuario(id);


--
-- Name: movimiento_brigada movimiento_brigada_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimiento_brigada
    ADD CONSTRAINT movimiento_brigada_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: movimiento_brigada movimiento_brigada_destino_asignacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimiento_brigada
    ADD CONSTRAINT movimiento_brigada_destino_asignacion_id_fkey FOREIGN KEY (destino_asignacion_id) REFERENCES public.asignacion_unidad(id) ON DELETE CASCADE;


--
-- Name: movimiento_brigada movimiento_brigada_destino_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimiento_brigada
    ADD CONSTRAINT movimiento_brigada_destino_unidad_id_fkey FOREIGN KEY (destino_unidad_id) REFERENCES public.unidad(id) ON DELETE RESTRICT;


--
-- Name: movimiento_brigada movimiento_brigada_origen_asignacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimiento_brigada
    ADD CONSTRAINT movimiento_brigada_origen_asignacion_id_fkey FOREIGN KEY (origen_asignacion_id) REFERENCES public.asignacion_unidad(id) ON DELETE CASCADE;


--
-- Name: movimiento_brigada movimiento_brigada_origen_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimiento_brigada
    ADD CONSTRAINT movimiento_brigada_origen_unidad_id_fkey FOREIGN KEY (origen_unidad_id) REFERENCES public.unidad(id) ON DELETE RESTRICT;


--
-- Name: movimiento_brigada movimiento_brigada_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimiento_brigada
    ADD CONSTRAINT movimiento_brigada_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(id) ON DELETE SET NULL;


--
-- Name: movimiento_brigada movimiento_brigada_turno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimiento_brigada
    ADD CONSTRAINT movimiento_brigada_turno_id_fkey FOREIGN KEY (turno_id) REFERENCES public.turno(id) ON DELETE CASCADE;


--
-- Name: movimiento_brigada movimiento_brigada_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.movimiento_brigada
    ADD CONSTRAINT movimiento_brigada_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: multimedia_situacion_persistente multimedia_situacion_persistente_situacion_persistente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.multimedia_situacion_persistente
    ADD CONSTRAINT multimedia_situacion_persistente_situacion_persistente_id_fkey FOREIGN KEY (situacion_persistente_id) REFERENCES public.situacion_persistente(id) ON DELETE CASCADE;


--
-- Name: multimedia_situacion_persistente multimedia_situacion_persistente_subido_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.multimedia_situacion_persistente
    ADD CONSTRAINT multimedia_situacion_persistente_subido_por_fkey FOREIGN KEY (subido_por) REFERENCES public.usuario(id);


--
-- Name: municipio municipio_departamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.municipio
    ADD CONSTRAINT municipio_departamento_id_fkey FOREIGN KEY (departamento_id) REFERENCES public.departamento(id) ON DELETE RESTRICT;


--
-- Name: notificacion notificacion_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notificacion
    ADD CONSTRAINT notificacion_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: obstruccion_incidente obstruccion_incidente_incidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obstruccion_incidente
    ADD CONSTRAINT obstruccion_incidente_incidente_id_fkey FOREIGN KEY (incidente_id) REFERENCES public.incidente(id) ON DELETE CASCADE;


--
-- Name: obstruccion_situacion_persistente obstruccion_situacion_persistente_situacion_persistente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.obstruccion_situacion_persistente
    ADD CONSTRAINT obstruccion_situacion_persistente_situacion_persistente_id_fkey FOREIGN KEY (situacion_persistente_id) REFERENCES public.situacion_persistente(id) ON DELETE CASCADE;


--
-- Name: password_reset_log password_reset_log_habilitado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_log
    ADD CONSTRAINT password_reset_log_habilitado_por_fkey FOREIGN KEY (habilitado_por) REFERENCES public.usuario(id);


--
-- Name: password_reset_log password_reset_log_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.password_reset_log
    ADD CONSTRAINT password_reset_log_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: persona_accidente persona_accidente_hoja_accidentologia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persona_accidente
    ADD CONSTRAINT persona_accidente_hoja_accidentologia_id_fkey FOREIGN KEY (hoja_accidentologia_id) REFERENCES public.hoja_accidentologia(id) ON DELETE CASCADE;


--
-- Name: persona_accidente persona_accidente_vehiculo_accidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persona_accidente
    ADD CONSTRAINT persona_accidente_vehiculo_accidente_id_fkey FOREIGN KEY (vehiculo_accidente_id) REFERENCES public.vehiculo_accidente(id);


--
-- Name: persona_involucrada persona_involucrada_incidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persona_involucrada
    ADD CONSTRAINT persona_involucrada_incidente_id_fkey FOREIGN KEY (incidente_id) REFERENCES public.incidente(id) ON DELETE CASCADE;


--
-- Name: persona_involucrada persona_involucrada_vehiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.persona_involucrada
    ADD CONSTRAINT persona_involucrada_vehiculo_id_fkey FOREIGN KEY (vehiculo_id) REFERENCES public.vehiculo_incidente(id) ON DELETE SET NULL;


--
-- Name: plantilla_comunicacion plantilla_comunicacion_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plantilla_comunicacion
    ADD CONSTRAINT plantilla_comunicacion_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id);


--
-- Name: plantilla_inspeccion_360 plantilla_inspeccion_360_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.plantilla_inspeccion_360
    ADD CONSTRAINT plantilla_inspeccion_360_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: publicacion_social publicacion_social_hoja_accidentologia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicacion_social
    ADD CONSTRAINT publicacion_social_hoja_accidentologia_id_fkey FOREIGN KEY (hoja_accidentologia_id) REFERENCES public.hoja_accidentologia(id);


--
-- Name: publicacion_social publicacion_social_plantilla_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicacion_social
    ADD CONSTRAINT publicacion_social_plantilla_id_fkey FOREIGN KEY (plantilla_id) REFERENCES public.plantilla_comunicacion(id);


--
-- Name: publicacion_social publicacion_social_publicado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicacion_social
    ADD CONSTRAINT publicacion_social_publicado_por_fkey FOREIGN KEY (publicado_por) REFERENCES public.usuario(id);


--
-- Name: publicacion_social publicacion_social_situacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.publicacion_social
    ADD CONSTRAINT publicacion_social_situacion_id_fkey FOREIGN KEY (situacion_id) REFERENCES public.situacion(id);


--
-- Name: reasignacion_sede reasignacion_sede_autorizado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reasignacion_sede
    ADD CONSTRAINT reasignacion_sede_autorizado_por_fkey FOREIGN KEY (autorizado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: reasignacion_sede reasignacion_sede_sede_destino_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reasignacion_sede
    ADD CONSTRAINT reasignacion_sede_sede_destino_id_fkey FOREIGN KEY (sede_destino_id) REFERENCES public.sede(id) ON DELETE RESTRICT;


--
-- Name: reasignacion_sede reasignacion_sede_sede_origen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reasignacion_sede
    ADD CONSTRAINT reasignacion_sede_sede_origen_id_fkey FOREIGN KEY (sede_origen_id) REFERENCES public.sede(id) ON DELETE RESTRICT;


--
-- Name: recurso_incidente recurso_incidente_incidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.recurso_incidente
    ADD CONSTRAINT recurso_incidente_incidente_id_fkey FOREIGN KEY (incidente_id) REFERENCES public.incidente(id) ON DELETE CASCADE;


--
-- Name: registro_cambio registro_cambio_asignacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registro_cambio
    ADD CONSTRAINT registro_cambio_asignacion_id_fkey FOREIGN KEY (asignacion_id) REFERENCES public.asignacion_unidad(id) ON DELETE SET NULL;


--
-- Name: registro_cambio registro_cambio_autorizado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registro_cambio
    ADD CONSTRAINT registro_cambio_autorizado_por_fkey FOREIGN KEY (autorizado_por) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: registro_cambio registro_cambio_realizado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registro_cambio
    ADD CONSTRAINT registro_cambio_realizado_por_fkey FOREIGN KEY (realizado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: registro_cambio registro_cambio_situacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registro_cambio
    ADD CONSTRAINT registro_cambio_situacion_id_fkey FOREIGN KEY (situacion_id) REFERENCES public.situacion(id) ON DELETE SET NULL;


--
-- Name: registro_cambio registro_cambio_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registro_cambio
    ADD CONSTRAINT registro_cambio_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id) ON DELETE SET NULL;


--
-- Name: registro_cambio registro_cambio_usuario_afectado_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.registro_cambio
    ADD CONSTRAINT registro_cambio_usuario_afectado_id_fkey FOREIGN KEY (usuario_afectado_id) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: relevo relevo_registrado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relevo
    ADD CONSTRAINT relevo_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: relevo relevo_situacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relevo
    ADD CONSTRAINT relevo_situacion_id_fkey FOREIGN KEY (situacion_id) REFERENCES public.situacion(id) ON DELETE CASCADE;


--
-- Name: relevo relevo_unidad_entrante_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relevo
    ADD CONSTRAINT relevo_unidad_entrante_id_fkey FOREIGN KEY (unidad_entrante_id) REFERENCES public.unidad(id) ON DELETE RESTRICT;


--
-- Name: relevo relevo_unidad_saliente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.relevo
    ADD CONSTRAINT relevo_unidad_saliente_id_fkey FOREIGN KEY (unidad_saliente_id) REFERENCES public.unidad(id) ON DELETE RESTRICT;


--
-- Name: reporte_horario reporte_horario_asignacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reporte_horario
    ADD CONSTRAINT reporte_horario_asignacion_id_fkey FOREIGN KEY (asignacion_id) REFERENCES public.asignacion_unidad(id) ON DELETE CASCADE;


--
-- Name: reporte_horario reporte_horario_reportado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.reporte_horario
    ADD CONSTRAINT reporte_horario_reportado_por_fkey FOREIGN KEY (reportado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: rol_permiso rol_permiso_permiso_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rol_permiso
    ADD CONSTRAINT rol_permiso_permiso_id_fkey FOREIGN KEY (permiso_id) REFERENCES public.permiso(id) ON DELETE CASCADE;


--
-- Name: rol_permiso rol_permiso_rol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rol_permiso
    ADD CONSTRAINT rol_permiso_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES public.rol(id) ON DELETE CASCADE;


--
-- Name: salida_unidad salida_unidad_finalizada_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salida_unidad
    ADD CONSTRAINT salida_unidad_finalizada_por_fkey FOREIGN KEY (finalizada_por) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: salida_unidad salida_unidad_inspeccion_360_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salida_unidad
    ADD CONSTRAINT salida_unidad_inspeccion_360_id_fkey FOREIGN KEY (inspeccion_360_id) REFERENCES public.inspeccion_360(id) ON DELETE SET NULL;


--
-- Name: salida_unidad salida_unidad_ruta_inicial_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salida_unidad
    ADD CONSTRAINT salida_unidad_ruta_inicial_id_fkey FOREIGN KEY (ruta_inicial_id) REFERENCES public.ruta(id) ON DELETE SET NULL;


--
-- Name: salida_unidad salida_unidad_sede_origen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salida_unidad
    ADD CONSTRAINT salida_unidad_sede_origen_id_fkey FOREIGN KEY (sede_origen_id) REFERENCES public.sede(id) ON DELETE RESTRICT;


--
-- Name: salida_unidad salida_unidad_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.salida_unidad
    ADD CONSTRAINT salida_unidad_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id) ON DELETE RESTRICT;


--
-- Name: sancion sancion_aplicada_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sancion
    ADD CONSTRAINT sancion_aplicada_por_fkey FOREIGN KEY (aplicada_por) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: sancion sancion_articulo_sancion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sancion
    ADD CONSTRAINT sancion_articulo_sancion_id_fkey FOREIGN KEY (articulo_sancion_id) REFERENCES public.articulo_sancion(id) ON DELETE SET NULL;


--
-- Name: sancion sancion_incidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sancion
    ADD CONSTRAINT sancion_incidente_id_fkey FOREIGN KEY (incidente_id) REFERENCES public.incidente(id) ON DELETE CASCADE;


--
-- Name: sancion sancion_piloto_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sancion
    ADD CONSTRAINT sancion_piloto_id_fkey FOREIGN KEY (piloto_id) REFERENCES public.piloto(id) ON DELETE SET NULL;


--
-- Name: sancion sancion_vehiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sancion
    ADD CONSTRAINT sancion_vehiculo_id_fkey FOREIGN KEY (vehiculo_id) REFERENCES public.vehiculo(id) ON DELETE CASCADE;


--
-- Name: sede sede_departamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sede
    ADD CONSTRAINT sede_departamento_id_fkey FOREIGN KEY (departamento_id) REFERENCES public.departamento(id) ON DELETE SET NULL;


--
-- Name: sede sede_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sede
    ADD CONSTRAINT sede_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipio(id) ON DELETE SET NULL;


--
-- Name: situacion situacion_actualizado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_actualizado_por_fkey FOREIGN KEY (actualizado_por) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: situacion situacion_asignacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_asignacion_id_fkey FOREIGN KEY (asignacion_id) REFERENCES public.asignacion_unidad(id) ON DELETE CASCADE;


--
-- Name: situacion situacion_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: situacion situacion_departamento_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_departamento_id_fkey FOREIGN KEY (departamento_id) REFERENCES public.departamento(id) ON DELETE SET NULL;


--
-- Name: situacion situacion_evento_persistente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_evento_persistente_id_fkey FOREIGN KEY (evento_persistente_id) REFERENCES public.evento_persistente(id);


--
-- Name: situacion_fija situacion_fija_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_fija
    ADD CONSTRAINT situacion_fija_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id);


--
-- Name: situacion_fija situacion_fija_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_fija
    ADD CONSTRAINT situacion_fija_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(id);


--
-- Name: situacion_fija situacion_fija_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_fija
    ADD CONSTRAINT situacion_fija_sede_id_fkey FOREIGN KEY (sede_id) REFERENCES public.sede(id) ON DELETE CASCADE;


--
-- Name: situacion situacion_incidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_incidente_id_fkey FOREIGN KEY (incidente_id) REFERENCES public.incidente(id) ON DELETE SET NULL;


--
-- Name: situacion_multimedia situacion_multimedia_situacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_multimedia
    ADD CONSTRAINT situacion_multimedia_situacion_id_fkey FOREIGN KEY (situacion_id) REFERENCES public.situacion(id) ON DELETE CASCADE;


--
-- Name: situacion_multimedia situacion_multimedia_subido_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_multimedia
    ADD CONSTRAINT situacion_multimedia_subido_por_fkey FOREIGN KEY (subido_por) REFERENCES public.usuario(id);


--
-- Name: situacion situacion_municipio_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_municipio_id_fkey FOREIGN KEY (municipio_id) REFERENCES public.municipio(id) ON DELETE SET NULL;


--
-- Name: situacion_persistente situacion_persistente_cerrado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_persistente
    ADD CONSTRAINT situacion_persistente_cerrado_por_fkey FOREIGN KEY (cerrado_por) REFERENCES public.usuario(id);


--
-- Name: situacion_persistente situacion_persistente_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_persistente
    ADD CONSTRAINT situacion_persistente_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id);


--
-- Name: situacion_persistente situacion_persistente_promovido_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_persistente
    ADD CONSTRAINT situacion_persistente_promovido_por_fkey FOREIGN KEY (promovido_por) REFERENCES public.usuario(id);


--
-- Name: situacion_persistente situacion_persistente_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_persistente
    ADD CONSTRAINT situacion_persistente_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(id);


--
-- Name: situacion_persistente situacion_persistente_situacion_origen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_persistente
    ADD CONSTRAINT situacion_persistente_situacion_origen_id_fkey FOREIGN KEY (situacion_origen_id) REFERENCES public.situacion(id);


--
-- Name: situacion_persistente situacion_persistente_tipo_emergencia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion_persistente
    ADD CONSTRAINT situacion_persistente_tipo_emergencia_id_fkey FOREIGN KEY (tipo_emergencia_id) REFERENCES public.tipo_emergencia_vial(id);


--
-- Name: situacion situacion_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_ruta_id_fkey FOREIGN KEY (ruta_id) REFERENCES public.ruta(id) ON DELETE SET NULL;


--
-- Name: situacion situacion_salida_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_salida_unidad_id_fkey FOREIGN KEY (salida_unidad_id) REFERENCES public.salida_unidad(id) ON DELETE SET NULL;


--
-- Name: situacion situacion_turno_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_turno_id_fkey FOREIGN KEY (turno_id) REFERENCES public.turno(id) ON DELETE CASCADE;


--
-- Name: situacion situacion_unidad_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.situacion
    ADD CONSTRAINT situacion_unidad_id_fkey FOREIGN KEY (unidad_id) REFERENCES public.unidad(id) ON DELETE RESTRICT;


--
-- Name: socorro_situacion_persistente socorro_situacion_persistente_situacion_persistente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.socorro_situacion_persistente
    ADD CONSTRAINT socorro_situacion_persistente_situacion_persistente_id_fkey FOREIGN KEY (situacion_persistente_id) REFERENCES public.situacion_persistente(id) ON DELETE CASCADE;


--
-- Name: subtipo_hecho subtipo_hecho_tipo_hecho_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.subtipo_hecho
    ADD CONSTRAINT subtipo_hecho_tipo_hecho_id_fkey FOREIGN KEY (tipo_hecho_id) REFERENCES public.tipo_hecho(id) ON DELETE CASCADE;


--
-- Name: suscripcion_alerta suscripcion_alerta_solo_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suscripcion_alerta
    ADD CONSTRAINT suscripcion_alerta_solo_sede_id_fkey FOREIGN KEY (solo_sede_id) REFERENCES public.sede(id);


--
-- Name: suscripcion_alerta suscripcion_alerta_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.suscripcion_alerta
    ADD CONSTRAINT suscripcion_alerta_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: tarjeta_circulacion tarjeta_circulacion_vehiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tarjeta_circulacion
    ADD CONSTRAINT tarjeta_circulacion_vehiculo_id_fkey FOREIGN KEY (vehiculo_id) REFERENCES public.vehiculo(id) ON DELETE CASCADE;


--
-- Name: tripulacion_turno tripulacion_turno_asignacion_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tripulacion_turno
    ADD CONSTRAINT tripulacion_turno_asignacion_id_fkey FOREIGN KEY (asignacion_id) REFERENCES public.asignacion_unidad(id) ON DELETE CASCADE;


--
-- Name: tripulacion_turno tripulacion_turno_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tripulacion_turno
    ADD CONSTRAINT tripulacion_turno_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: turno turno_aprobado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turno
    ADD CONSTRAINT turno_aprobado_por_fkey FOREIGN KEY (aprobado_por) REFERENCES public.usuario(id) ON DELETE SET NULL;


--
-- Name: turno turno_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turno
    ADD CONSTRAINT turno_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id) ON DELETE RESTRICT;


--
-- Name: turno turno_publicado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turno
    ADD CONSTRAINT turno_publicado_por_fkey FOREIGN KEY (publicado_por) REFERENCES public.usuario(id);


--
-- Name: turno turno_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.turno
    ADD CONSTRAINT turno_sede_id_fkey FOREIGN KEY (sede_id) REFERENCES public.sede(id);


--
-- Name: ubicacion_brigada ubicacion_brigada_asignacion_actual_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubicacion_brigada
    ADD CONSTRAINT ubicacion_brigada_asignacion_actual_id_fkey FOREIGN KEY (asignacion_actual_id) REFERENCES public.asignacion_unidad(id);


--
-- Name: ubicacion_brigada ubicacion_brigada_asignacion_origen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubicacion_brigada
    ADD CONSTRAINT ubicacion_brigada_asignacion_origen_id_fkey FOREIGN KEY (asignacion_origen_id) REFERENCES public.asignacion_unidad(id);


--
-- Name: ubicacion_brigada ubicacion_brigada_creado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubicacion_brigada
    ADD CONSTRAINT ubicacion_brigada_creado_por_fkey FOREIGN KEY (creado_por) REFERENCES public.usuario(id);


--
-- Name: ubicacion_brigada ubicacion_brigada_punto_fijo_ruta_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubicacion_brigada
    ADD CONSTRAINT ubicacion_brigada_punto_fijo_ruta_id_fkey FOREIGN KEY (punto_fijo_ruta_id) REFERENCES public.ruta(id);


--
-- Name: ubicacion_brigada ubicacion_brigada_unidad_actual_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubicacion_brigada
    ADD CONSTRAINT ubicacion_brigada_unidad_actual_id_fkey FOREIGN KEY (unidad_actual_id) REFERENCES public.unidad(id);


--
-- Name: ubicacion_brigada ubicacion_brigada_unidad_origen_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubicacion_brigada
    ADD CONSTRAINT ubicacion_brigada_unidad_origen_id_fkey FOREIGN KEY (unidad_origen_id) REFERENCES public.unidad(id);


--
-- Name: ubicacion_brigada ubicacion_brigada_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ubicacion_brigada
    ADD CONSTRAINT ubicacion_brigada_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id);


--
-- Name: unidad unidad_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.unidad
    ADD CONSTRAINT unidad_sede_id_fkey FOREIGN KEY (sede_id) REFERENCES public.sede(id) ON DELETE RESTRICT;


--
-- Name: usuario_inactividad usuario_inactividad_motivo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_inactividad
    ADD CONSTRAINT usuario_inactividad_motivo_id_fkey FOREIGN KEY (motivo_id) REFERENCES public.catalogo_motivo_inactividad(id);


--
-- Name: usuario_inactividad usuario_inactividad_reactivado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_inactividad
    ADD CONSTRAINT usuario_inactividad_reactivado_por_fkey FOREIGN KEY (reactivado_por) REFERENCES public.usuario(id);


--
-- Name: usuario_inactividad usuario_inactividad_registrado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_inactividad
    ADD CONSTRAINT usuario_inactividad_registrado_por_fkey FOREIGN KEY (registrado_por) REFERENCES public.usuario(id);


--
-- Name: usuario_inactividad usuario_inactividad_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_inactividad
    ADD CONSTRAINT usuario_inactividad_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


--
-- Name: usuario usuario_password_reset_by_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_password_reset_by_fkey FOREIGN KEY (password_reset_by) REFERENCES public.usuario(id);


--
-- Name: usuario_rol usuario_rol_asignado_por_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_rol
    ADD CONSTRAINT usuario_rol_asignado_por_fkey FOREIGN KEY (asignado_por) REFERENCES public.usuario(id);


--
-- Name: usuario usuario_rol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES public.rol(id) ON DELETE RESTRICT;


--
-- Name: usuario_rol usuario_rol_rol_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_rol
    ADD CONSTRAINT usuario_rol_rol_id_fkey FOREIGN KEY (rol_id) REFERENCES public.rol(id) ON DELETE CASCADE;


--
-- Name: usuario_rol usuario_rol_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_rol
    ADD CONSTRAINT usuario_rol_sede_id_fkey FOREIGN KEY (sede_id) REFERENCES public.sede(id);


--
-- Name: usuario_rol usuario_rol_usuario_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario_rol
    ADD CONSTRAINT usuario_rol_usuario_id_fkey FOREIGN KEY (usuario_id) REFERENCES public.usuario(id) ON DELETE CASCADE;


--
-- Name: usuario usuario_sede_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_sede_id_fkey FOREIGN KEY (sede_id) REFERENCES public.sede(id) ON DELETE SET NULL;


--
-- Name: usuario usuario_sub_rol_cop_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.usuario
    ADD CONSTRAINT usuario_sub_rol_cop_id_fkey FOREIGN KEY (sub_rol_cop_id) REFERENCES public.sub_rol_cop(id);


--
-- Name: vehiculo_accidente vehiculo_accidente_hoja_accidentologia_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo_accidente
    ADD CONSTRAINT vehiculo_accidente_hoja_accidentologia_id_fkey FOREIGN KEY (hoja_accidentologia_id) REFERENCES public.hoja_accidentologia(id) ON DELETE CASCADE;


--
-- Name: vehiculo_incidente vehiculo_incidente_incidente_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo_incidente
    ADD CONSTRAINT vehiculo_incidente_incidente_id_fkey FOREIGN KEY (incidente_id) REFERENCES public.incidente(id) ON DELETE CASCADE;


--
-- Name: vehiculo_incidente vehiculo_incidente_marca_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo_incidente
    ADD CONSTRAINT vehiculo_incidente_marca_id_fkey FOREIGN KEY (marca_id) REFERENCES public.marca_vehiculo(id) ON DELETE SET NULL;


--
-- Name: vehiculo_incidente vehiculo_incidente_tipo_vehiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo_incidente
    ADD CONSTRAINT vehiculo_incidente_tipo_vehiculo_id_fkey FOREIGN KEY (tipo_vehiculo_id) REFERENCES public.tipo_vehiculo(id) ON DELETE SET NULL;


--
-- Name: vehiculo vehiculo_marca_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo
    ADD CONSTRAINT vehiculo_marca_id_fkey FOREIGN KEY (marca_id) REFERENCES public.marca_vehiculo(id) ON DELETE SET NULL;


--
-- Name: vehiculo vehiculo_tipo_vehiculo_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.vehiculo
    ADD CONSTRAINT vehiculo_tipo_vehiculo_id_fkey FOREIGN KEY (tipo_vehiculo_id) REFERENCES public.tipo_vehiculo(id) ON DELETE SET NULL;


--
-- Name: mv_estadisticas_diarias; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.mv_estadisticas_diarias;


--
-- Name: mv_no_atendidos_por_motivo; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.mv_no_atendidos_por_motivo;


--
-- Name: mv_pilotos_problematicos; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.mv_pilotos_problematicos;


--
-- Name: mv_puntos_calientes; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.mv_puntos_calientes;


--
-- Name: mv_tendencias_temporales; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.mv_tendencias_temporales;


--
-- Name: mv_vehiculo_historial; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.mv_vehiculo_historial;


--
-- Name: mv_vehiculos_reincidentes; Type: MATERIALIZED VIEW DATA; Schema: public; Owner: -
--

REFRESH MATERIALIZED VIEW public.mv_vehiculos_reincidentes;


--
-- PostgreSQL database dump complete
--

\unrestrict 8SYJfBFTlLw0VAseiS0PpCvs1IoeCWVhh3CFnPY8K8P731DLC4b5ROoMRarSDkd

