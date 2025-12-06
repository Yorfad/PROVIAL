import axios from 'axios';
import AsyncStorage from '@react-native-async-storage/async-storage';

// IMPORTANTE: Cambiar esta URL a la IP de tu computadora
// Para encontrar tu IP: ipconfig (Windows) o ifconfig (Mac/Linux)
const API_URL = 'http://172.20.10.4:3000/api'; // <-- CAMBIAR ESTA IP

const api = axios.create({
  baseURL: API_URL,
  timeout: 10000,
  headers: {
    'Content-Type': 'application/json',
  },
});

// Interceptor para agregar token
api.interceptors.request.use(
  async (config) => {
    // Use 'token' key to match STORAGE_KEYS.TOKEN
    const token = await AsyncStorage.getItem('token');
    console.log('[API Interceptor] Token retrieved:', token ? 'YES (length: ' + token.length + ')' : 'NO');
    if (token) {
      config.headers.Authorization = `Bearer ${token}`;
    }
    console.log('[API Interceptor] Request to:', config.url);
    return config;
  },
  (error) => {
    console.error('[API Interceptor] Request error:', error);
    return Promise.reject(error);
  }
);

export interface LoginRequest {
  username: string;
  password: string;
}

export interface LoginResponse {
  message: string;
  user: {
    id: number;
    username: string;
    nombre: string;
    apellido: string;
    rol: string;
  };
  accessToken: string;
  refreshToken: string;
}

export interface CreateIncidenteRequest {
  tipo_hecho_id: number;
  subtipo_hecho_id?: number;
  ruta_id: number;
  km: number;
  sentido?: string;
  referencia_ubicacion?: string;
  latitud: number;
  longitud: number;
  hay_heridos: boolean;
  cantidad_heridos: number;
  hay_fallecidos: boolean;
  cantidad_fallecidos: number;
  requiere_bomberos: boolean;
  requiere_pnc: boolean;
  requiere_ambulancia: boolean;
  observaciones_iniciales?: string;
}

export const authAPI = {
  async login(credentials: LoginRequest): Promise<LoginResponse> {
    const { data } = await api.post<LoginResponse>('/auth/login', credentials);
    return data;
  },

  async logout(): Promise<void> {
    await api.post('/auth/logout');
    await AsyncStorage.multiRemove(['accessToken', 'refreshToken', 'user']);
  },
};

export const incidentesAPI = {
  async create(incidente: CreateIncidenteRequest): Promise<any> {
    const { data } = await api.post('/incidentes', incidente);
    return data;
  },

  async getMiAsignacionHoy(): Promise<any> {
    const { data } = await api.get('/turnos/mi-asignacion-hoy');
    return data;
  },
};

export const geografiaAPI = {
  async getRutas(): Promise<any[]> {
    const { data } = await api.get('/geografia/rutas');
    return data.rutas || [];
  },

  async getDepartamentos(): Promise<any[]> {
    const { data } = await api.get('/geografia/departamentos');
    return data.departamentos || [];
  },

  async getMunicipiosPorDepartamento(departamentoId: number): Promise<any[]> {
    const { data } = await api.get(`/geografia/municipios?departamento_id=${departamentoId}`);
    return data.municipios || [];
  },
};

export const turnosAPI = {
  async getMiAsignacionHoy(): Promise<any> {
    const { data } = await api.get('/turnos/mi-asignacion-hoy');
    return data;
  },

  async cambiarRuta(nuevaRutaId: number): Promise<any> {
    const { data } = await api.post('/salidas/cambiar-ruta', {
      nueva_ruta_id: nuevaRutaId,
    });
    return data;
  },

  async registrarCombustible(params: {
    combustible: number;
    tipo: 'INICIAL' | 'ACTUAL' | 'FINAL';
    observaciones?: string;
  }): Promise<any> {
    const { data } = await api.post('/turnos/registrar-combustible', params);
    return data;
  },
};

export default api;
