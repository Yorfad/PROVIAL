import axios from 'axios';
import type { LoginRequest, LoginResponse, Incidente } from '../types';

// Crear instancia de axios
export const api = axios.create({
  baseURL: '/api', // Proxy configurado en vite.config.ts
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para agregar token a requests
api.interceptors.request.use(
  (config) => {
    const token = localStorage.getItem('accessToken');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    return config;
  },
  (error) => {
    return Promise.reject(error);
  }
);

// Interceptor para manejar errores de autenticación
api.interceptors.response.use(
  (response) => response,
  async (error) => {
    // Solo redirigir a login si NO es un intento de login y recibimos 401
    const isLoginRequest = error.config?.url?.includes('/auth/login');

    if (error.response?.status === 401 && !isLoginRequest) {
      // Token expirado en requests normales, limpiar y redirigir a login
      localStorage.removeItem('accessToken');
      localStorage.removeItem('refreshToken');
      localStorage.removeItem('user');
      window.location.href = '/login';
    }

    // Para requests de login, dejar que el componente maneje el error
    return Promise.reject(error);
  }
);

// ============================================
// AUTENTICACIÓN
// ============================================

export const authAPI = {
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    const { data } = await api.post<LoginResponse>('/auth/login', credentials);
    return data;
  },

  async logout(): Promise<void> {
    await api.post('/auth/logout');
  },

  async getMe(): Promise<any> {
    const { data } = await api.get('/auth/me');
    return data;
  },
};

// ============================================
// INCIDENTES
// ============================================

export const incidentesAPI = {
  async getActivos(): Promise<Incidente[]> {
    const { data } = await api.get<{ incidentes: Incidente[] }>(
      '/incidentes?activos_solo=true'
    );
    return data.incidentes;
  },

  async getAll(params?: {
    estado?: string;
    ruta_id?: number;
    desde?: string;
    hasta?: string;
    limit?: number;
  }): Promise<Incidente[]> {
    const { data } = await api.get<{ incidentes: Incidente[] }>('/incidentes', {
      params,
    });
    return data.incidentes;
  },

  async getById(id: number | string): Promise<Incidente> {
    const { data } = await api.get<{ incidente: Incidente }>(`/incidentes/${id}`);
    return data.incidente;
  },

  async create(incidente: Partial<Incidente>): Promise<Incidente> {
    const { data } = await api.post<{ incidente: Incidente }>(
      '/incidentes',
      incidente
    );
    return data.incidente;
  },

  async updateEstado(
    id: number,
    estado: string,
    fecha_hora?: string
  ): Promise<Incidente> {
    const { data } = await api.patch<{ incidente: Incidente }>(
      `/incidentes/${id}/estado`,
      { estado, fecha_hora }
    );
    return data.incidente;
  },

  async getMensajeGeneral(id: number): Promise<string> {
    const { data } = await api.get<{ mensaje: string }>(
      `/incidentes/${id}/mensaje-general`
    );
    return data.mensaje;
  },
};

// ============================================
// SITUACIONES
// ============================================

export const situacionesAPI = {
  async getActivas(): Promise<any[]> {
    const { data } = await api.get('/situaciones?estado=ACTIVA');
    return data.situaciones || [];
  },

  async getAll(params?: {
    estado?: string;
    unidad_id?: number;
    desde?: string;
    hasta?: string;
  }): Promise<any[]> {
    const { data } = await api.get('/situaciones', { params });
    return data.situaciones || [];
  },

  async getById(id: number): Promise<any> {
    const { data } = await api.get(`/situaciones/${id}`);
    return data.situacion;
  },

  async getResumenUnidades(): Promise<any[]> {
    const { data } = await api.get('/situaciones/resumen/unidades');
    return data.resumen || [];
  },

  async getBitacora(unidadId: number, params?: {
    fecha_desde?: string;
    fecha_hasta?: string;
    limit?: number;
  }): Promise<any[]> {
    const { data } = await api.get(`/situaciones/bitacora/${unidadId}`, { params });
    return data.bitacora || [];
  },

  async update(id: number, updates: any): Promise<any> {
    const { data } = await api.patch(`/situaciones/${id}`, updates);
    return data.situacion;
  },

  async cerrar(id: number, observaciones?: string): Promise<any> {
    const { data } = await api.patch(`/situaciones/${id}/cerrar`, {
      observaciones_finales: observaciones,
    });
    return data.situacion;
  },
};

// ============================================
// GEOGRAFÍA (RUTAS)
// ============================================

export const geografiaAPI = {
  async getRutas(): Promise<any[]> {
    const { data } = await api.get('/geografia/rutas');
    return data.rutas || [];
  },

  async getRuta(id: number | string): Promise<any> {
    const { data } = await api.get(`/geografia/rutas/${id}`);
    return data.ruta;
  },
};

// ============================================
// HEALTH CHECK
// ============================================

export const healthAPI = {
  async check(): Promise<any> {
    const { data } = await axios.get('http://localhost:3000/health');
    return data;
  },
};

export default api;
