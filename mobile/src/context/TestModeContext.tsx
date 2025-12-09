/**
 * Contexto Global para Modo de Pruebas
 *
 * Permite activar/desactivar funciones de prueba y almacena
 * configuraciones específicas para testing y demos
 */

import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import AsyncStorage from '@react-native-async-storage/async-storage';
import api from '../services/api';

interface TestModeContextType {
  // Estado
  testModeEnabled: boolean;
  enableTestMode: () => Promise<void>;
  disableTestMode: () => Promise<void>;
  toggleTestMode: () => Promise<void>;

  // Herramientas de reseteo
  resetSalida: () => Promise<void>;
  resetIngresos: () => Promise<void>;
  resetSituaciones: () => Promise<void>;
  resetAll: () => Promise<void>;
}

const TestModeContext = createContext<TestModeContextType | undefined>(undefined);

const TEST_MODE_KEY = '@provial_test_mode';

export function TestModeProvider({ children }: { children: ReactNode }) {
  const [testModeEnabled, setTestModeEnabled] = useState(false);

  // Cargar estado al iniciar
  useEffect(() => {
    loadTestModeState();
  }, []);

  const loadTestModeState = async () => {
    try {
      const mode = await AsyncStorage.getItem(TEST_MODE_KEY);
      if (mode === 'true') {
        setTestModeEnabled(true);
      }
    } catch (error) {
      console.error('[TEST MODE] Error loading state:', error);
    }
  };

  const enableTestMode = async () => {
    try {
      await AsyncStorage.setItem(TEST_MODE_KEY, 'true');
      setTestModeEnabled(true);
      console.log('🧪 [TEST MODE] Activado');
    } catch (error) {
      console.error('[TEST MODE] Error enabling:', error);
    }
  };

  const disableTestMode = async () => {
    try {
      await AsyncStorage.setItem(TEST_MODE_KEY, 'false');
      setTestModeEnabled(false);
      console.log('✅ [TEST MODE] Desactivado');
    } catch (error) {
      console.error('[TEST MODE] Error disabling:', error);
    }
  };

  const toggleTestMode = async () => {
    if (testModeEnabled) {
      await disableTestMode();
    } else {
      await enableTestMode();
    }
  };

  // Funciones de reseteo (eliminan datos REALES del backend)
  const resetSalida = async () => {
    try {
      console.log('🔄 [TEST MODE] Reseteando salida actual...');
      console.log('[TEST MODE] Llamando a POST /test-mode/reset-salida');

      // Finalizar salida en el backend
      const response = await api.post('/test-mode/reset-salida');
      console.log('[TEST MODE] Respuesta del backend:', response.data);

      // Limpiar estado local
      await AsyncStorage.multiRemove([
        '@provial_salida_activa',
        '@provial_estado_brigada'
      ]);

      console.log('✅ [TEST MODE] Salida finalizada en backend y limpiada localmente');
    } catch (error: any) {
      console.error('[TEST MODE] Error resetting salida:', error);
      console.error('[TEST MODE] Error details:', {
        message: error.message,
        code: error.code,
        response: error.response?.data,
        status: error.response?.status,
      });
      throw error;
    }
  };

  const resetIngresos = async () => {
    try {
      console.log('🔄 [TEST MODE] Reseteando ingresos...');

      // Eliminar del backend
      await api.post('/test-mode/reset-ingresos');

      // Limpiar estado local
      await AsyncStorage.removeItem('@provial_ingreso_activo');

      console.log('✅ [TEST MODE] Ingresos eliminados del backend y local');
    } catch (error) {
      console.error('[TEST MODE] Error resetting ingresos:', error);
      throw error;
    }
  };

  const resetSituaciones = async () => {
    try {
      console.log('🔄 [TEST MODE] Reseteando situaciones...');

      // Eliminar del backend
      await api.post('/test-mode/reset-situaciones');

      // Limpiar estado local
      await AsyncStorage.removeItem('@provial_situaciones');

      console.log('✅ [TEST MODE] Situaciones eliminadas del backend y local');
    } catch (error) {
      console.error('[TEST MODE] Error resetting situaciones:', error);
      throw error;
    }
  };

  const resetAll = async () => {
    try {
      console.log('🔄 [TEST MODE] Reseteando TODO...');

      // Eliminar todo del backend en una sola llamada
      await api.post('/test-mode/reset-all');

      // Limpiar todo el estado local
      await AsyncStorage.multiRemove([
        '@provial_salida_activa',
        '@provial_estado_brigada',
        '@provial_ingreso_activo',
        '@provial_situaciones'
      ]);

      console.log('✅ [TEST MODE] Todo eliminado del backend y local');
    } catch (error) {
      console.error('[TEST MODE] Error resetting all:', error);
      throw error;
    }
  };

  const value: TestModeContextType = {
    testModeEnabled,
    enableTestMode,
    disableTestMode,
    toggleTestMode,
    resetSalida,
    resetIngresos,
    resetSituaciones,
    resetAll,
  };

  return (
    <TestModeContext.Provider value={value}>
      {children}
    </TestModeContext.Provider>
  );
}

export function useTestMode() {
  const context = useContext(TestModeContext);
  if (context === undefined) {
    throw new Error('useTestMode must be used within a TestModeProvider');
  }
  return context;
}
