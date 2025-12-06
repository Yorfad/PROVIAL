import { create } from 'zustand';
import axios from 'axios';
import { API_URL } from '../constants/config';
import { TipoSituacion, EstadoSituacion } from '../constants/situacionTypes';

// ========================================
// INTERFACES
// ========================================

export interface UltimaSituacionUnidad {
  unidad_id: number;
  unidad_codigo: string;
  tipo_unidad: string;
  situacion_id: number;
  situacion_uuid: string;
  numero_situacion: string | null;
  tipo_situacion: TipoSituacion;
  estado: EstadoSituacion;
  ruta_id: number | null;
  ruta_codigo: string | null;
  ruta_nombre: string | null;
  km: number | null;
  sentido: string | null;
  latitud: number | null;
  longitud: number | null;
  descripcion: string | null;
  created_at: string;
  situacion_fecha: string;
  turno_id: number | null;
  turno_fecha: string | null;
}

export interface MapRegion {
  latitude: number;
  longitude: number;
  latitudeDelta: number;
  longitudeDelta: number;
}

interface MapState {
  // State
  unidades: UltimaSituacionUnidad[];
  selectedUnidad: UltimaSituacionUnidad | null;
  mapRegion: MapRegion | null;
  isLoading: boolean;
  error: string | null;
  lastUpdate: Date | null;
  autoRefresh: boolean;

  // Actions
  fetchUnidades: () => Promise<void>;
  selectUnidad: (unidad: UltimaSituacionUnidad | null) => void;
  setMapRegion: (region: MapRegion) => void;
  setAutoRefresh: (enabled: boolean) => void;
  refreshUnidades: () => Promise<void>;
  clearError: () => void;
}

// ========================================
// STORE
// ========================================

export const useMapStore = create<MapState>((set, get) => ({
  // Initial state
  unidades: [],
  selectedUnidad: null,
  mapRegion: null,
  isLoading: false,
  error: null,
  lastUpdate: null,
  autoRefresh: true,

  // ========================================
  // FETCH UNIDADES (MAPA)
  // ========================================
  fetchUnidades: async () => {
    set({ isLoading: true, error: null });

    try {
      const response = await axios.get(`${API_URL}/situaciones/mapa/unidades`);
      const unidades = response.data.unidades || [];

      set({
        unidades,
        isLoading: false,
        lastUpdate: new Date(),
      });
    } catch (error: any) {
      const errorMessage =
        error.response?.data?.error || error.message || 'Error al obtener unidades';

      set({
        error: errorMessage,
        isLoading: false,
      });

      console.error('Error al obtener unidades:', error);
    }
  },

  // ========================================
  // SELECT UNIDAD
  // ========================================
  selectUnidad: (unidad: UltimaSituacionUnidad | null) => {
    set({ selectedUnidad: unidad });

    // Si seleccionamos una unidad con ubicación, centrar mapa
    if (unidad && unidad.latitud && unidad.longitud) {
      set({
        mapRegion: {
          latitude: unidad.latitud,
          longitude: unidad.longitud,
          latitudeDelta: 0.05,
          longitudeDelta: 0.05,
        },
      });
    }
  },

  // ========================================
  // SET MAP REGION
  // ========================================
  setMapRegion: (region: MapRegion) => {
    set({ mapRegion: region });
  },

  // ========================================
  // SET AUTO REFRESH
  // ========================================
  setAutoRefresh: (enabled: boolean) => {
    set({ autoRefresh: enabled });
  },

  // ========================================
  // REFRESH UNIDADES
  // ========================================
  refreshUnidades: async () => {
    if (get().autoRefresh) {
      await get().fetchUnidades();
    }
  },

  // ========================================
  // CLEAR ERROR
  // ========================================
  clearError: () => {
    set({ error: null });
  },
}));
