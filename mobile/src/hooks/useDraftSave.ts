import { useEffect, useRef } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';

/**
 * Hook para auto-guardar borradores de formularios
 * Guarda automáticamente el estado cada vez que cambia
 * y permite recuperarlo si la app se cierra inesperadamente
 */
export function useDraftSave<T>(
  draftKey: string,
  data: T,
  options: {
    enabled?: boolean;
    debounceMs?: number;
  } = {}
) {
  const { enabled = true, debounceMs = 1000 } = options;
  const timeoutRef = useRef<NodeJS.Timeout | null>(null);
  const isFirstRender = useRef(true);

  // Auto-guardar cuando cambian los datos
  useEffect(() => {
    if (!enabled) return;

    // No guardar en el primer render
    if (isFirstRender.current) {
      isFirstRender.current = false;
      return;
    }

    // Limpiar timeout anterior
    if (timeoutRef.current) {
      clearTimeout(timeoutRef.current);
    }

    // Guardar después del debounce
    timeoutRef.current = setTimeout(async () => {
      try {
        const jsonData = JSON.stringify(data);
        await AsyncStorage.setItem(draftKey, jsonData);
        console.log(`[DRAFT] Borrador guardado: ${draftKey}`);
      } catch (error) {
        console.error('[DRAFT] Error guardando borrador:', error);
      }
    }, debounceMs);

    return () => {
      if (timeoutRef.current) {
        clearTimeout(timeoutRef.current);
      }
    };
  }, [data, draftKey, enabled, debounceMs]);

  return {
    /**
     * Cargar borrador guardado
     */
    async loadDraft(): Promise<T | null> {
      try {
        const jsonData = await AsyncStorage.getItem(draftKey);
        if (jsonData) {
          console.log(`[DRAFT] Borrador recuperado: ${draftKey}`);
          return JSON.parse(jsonData) as T;
        }
        return null;
      } catch (error) {
        console.error('[DRAFT] Error cargando borrador:', error);
        return null;
      }
    },

    /**
     * Eliminar borrador guardado
     */
    async clearDraft(): Promise<void> {
      try {
        await AsyncStorage.removeItem(draftKey);
        console.log(`[DRAFT] Borrador eliminado: ${draftKey}`);
      } catch (error) {
        console.error('[DRAFT] Error eliminando borrador:', error);
      }
    },

    /**
     * Verificar si existe un borrador
     */
    async hasDraft(): Promise<boolean> {
      try {
        const jsonData = await AsyncStorage.getItem(draftKey);
        return jsonData !== null;
      } catch (error) {
        return false;
      }
    },
  };
}
