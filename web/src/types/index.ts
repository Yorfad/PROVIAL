// ============================================
// TIPOS DE AUTENTICACIÓN
// ============================================

export interface Usuario {
  id: number;
  username: string;
  nombre: string;
  apellido: string;
  rol: string;
  sede_id: number | null;
  sede_nombre?: string;
}

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  message: string;
  user: Usuario;
  accessToken: string;
  refreshToken: string;
}

// ============================================
// TIPOS DE INCIDENTES
// ============================================

export interface Incidente {
  id: number;
  uuid: string;
  numero_reporte: string | null;
  origen: 'BRIGADA' | 'USUARIO_PUBLICO' | 'CENTRO_CONTROL';
  estado: 'REPORTADO' | 'EN_ATENCION' | 'REGULACION' | 'CERRADO' | 'NO_ATENDIDO';

  // Tipo de hecho
  tipo_hecho: string;
  subtipo_hecho: string | null;
  tipo_hecho_color: string;
  tipo_hecho_icono: string;

  // Ubicación
  ruta_codigo: string;
  ruta_nombre: string;
  km: number;
  sentido: string | null;
  referencia_ubicacion: string | null;
  latitud: number | null;
  longitud: number | null;

  // Asignación
  unidad_codigo: string | null;
  brigada_nombre: string | null;

  // Tiempos
  fecha_hora_aviso: string;
  fecha_hora_asignacion: string | null;
  fecha_hora_llegada: string | null;
  fecha_hora_estabilizacion: string | null;
  fecha_hora_finalizacion: string | null;

  // Víctimas
  hay_heridos: boolean;
  cantidad_heridos: number;
  hay_fallecidos: boolean;
  cantidad_fallecidos: number;

  // Recursos
  requiere_bomberos: boolean;
  requiere_pnc: boolean;
  requiere_ambulancia: boolean;

  // Observaciones
  observaciones_iniciales: string | null;
  observaciones_finales: string | null;

  // Datos relacionados
  vehiculos?: VehiculoIncidente[];
  obstruccion?: ObstruccionIncidente;
  recursos?: RecursoIncidente[];

  // Auditoría
  creado_por_nombre: string;
  created_at: string;
  updated_at: string;
}

export interface VehiculoIncidente {
  id: number;
  incidente_id: number;
  placa: string | null;
  modelo: string | null;
  color: string | null;
  estado_piloto: string | null;
  nombre_piloto: string | null;
  heridos_en_vehiculo: number;
  fallecidos_en_vehiculo: number;
  danos_estimados: string | null;
  observaciones: string | null;
}

export interface ObstruccionIncidente {
  id: number;
  incidente_id: number;
  descripcion_generada: string | null;
  datos_carriles_json: any;
}

export interface RecursoIncidente {
  id: number;
  incidente_id: number;
  tipo_recurso: string;
  descripcion: string | null;
  hora_solicitud: string | null;
  hora_llegada: string | null;
  observaciones: string | null;
}

// ============================================
// TIPOS DE MAPAS
// ============================================

export interface MarkerIncidente {
  id: number;
  position: [number, number]; // [lat, lng]
  incidente: Incidente;
}
