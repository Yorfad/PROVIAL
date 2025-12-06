-- Migración 006: Tabla de auditoría

-- ========================================
-- TABLA: AUDITORIA LOG
-- ========================================

CREATE TABLE auditoria_log (
    id BIGSERIAL PRIMARY KEY,

    -- Usuario que realizó la acción
    usuario_id INT REFERENCES usuario(id) ON DELETE SET NULL,

    -- Acción realizada
    accion VARCHAR(50) NOT NULL CHECK (accion IN ('INSERT', 'UPDATE', 'DELETE', 'LOGIN', 'LOGOUT', 'EXPORT', 'OTHER')),

    -- Tabla/recurso afectado
    tabla_afectada VARCHAR(100),
    registro_id BIGINT,

    -- Datos del cambio
    datos_anteriores JSONB,
    datos_nuevos JSONB,

    -- Información de contexto
    ip_address VARCHAR(45),
    user_agent TEXT,

    -- Timestamp
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

COMMENT ON TABLE auditoria_log IS 'Log de auditoría de todas las acciones importantes del sistema';
COMMENT ON COLUMN auditoria_log.datos_anteriores IS 'Estado del registro antes del cambio';
COMMENT ON COLUMN auditoria_log.datos_nuevos IS 'Estado del registro después del cambio';

-- Índices
CREATE INDEX idx_auditoria_usuario ON auditoria_log(usuario_id);
CREATE INDEX idx_auditoria_tabla ON auditoria_log(tabla_afectada);
CREATE INDEX idx_auditoria_created ON auditoria_log(created_at DESC);
CREATE INDEX idx_auditoria_accion ON auditoria_log(accion);

-- Índice compuesto para búsquedas por tabla y registro
CREATE INDEX idx_auditoria_tabla_registro ON auditoria_log(tabla_afectada, registro_id);
