import React, { useEffect, useState } from 'react';
import { View, Text, StyleSheet, TouchableOpacity, ScrollView, ActivityIndicator } from 'react-native';
import { COLORS } from '../constants/colors';
import { geografiaAPI } from '../services/api';

interface Ruta {
  id: number;
  codigo: string;
  nombre: string;
  tipo_ruta?: string;
}

interface Props {
  value?: number;
  onChange: (rutaId: number) => void;
  label?: string;
  required?: boolean;
}

export default function RutaSelector({ value, onChange, label = 'Ruta', required = false }: Props) {
  const [rutas, setRutas] = useState<Ruta[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    loadRutas();
  }, []);

  const loadRutas = async () => {
    try {
      setLoading(true);
      console.log('[RutaSelector] Cargando rutas...');
      const data = await geografiaAPI.getRutas();
      console.log('[RutaSelector] Rutas cargadas:', data.length);
      setRutas(data);
    } catch (error: any) {
      console.error('[RutaSelector] Error al cargar rutas:', error);
      console.error('[RutaSelector] Error response:', error.response?.data);
      console.error('[RutaSelector] Error status:', error.response?.status);

      // Show user-friendly error
      if (error.response?.status === 401) {
        console.error('[RutaSelector] Error 401 - Token inválido o expirado');
      }
    } finally {
      setLoading(false);
    }
  };

  if (loading) {
    return (
      <View style={styles.container}>
        <Text style={styles.label}>{label}</Text>
        <View style={styles.loadingContainer}>
          <ActivityIndicator color={COLORS.primary} />
          <Text style={styles.loadingText}>Cargando rutas...</Text>
        </View>
      </View>
    );
  }

  return (
    <View style={styles.container}>
      <Text style={styles.label}>
        {label}
        {required && <Text style={styles.required}> *</Text>}
      </Text>

      <ScrollView
        horizontal
        showsHorizontalScrollIndicator={false}
        contentContainerStyle={styles.scrollContent}
      >
        {rutas.map((ruta) => {
          const isSelected = value === ruta.id;

          return (
            <TouchableOpacity
              key={ruta.id}
              style={[
                styles.option,
                isSelected && styles.optionSelected,
              ]}
              onPress={() => onChange(ruta.id)}
            >
              <Text
                style={[
                  styles.optionCodigo,
                  isSelected && styles.optionCodigoSelected,
                ]}
              >
                {ruta.codigo}
              </Text>
              <Text
                style={[
                  styles.optionNombre,
                  isSelected && styles.optionNombreSelected,
                ]}
                numberOfLines={1}
              >
                {ruta.nombre}
              </Text>
            </TouchableOpacity>
          );
        })}
      </ScrollView>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    marginBottom: 16,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.text.primary,
    marginBottom: 8,
  },
  required: {
    color: COLORS.danger,
  },
  loadingContainer: {
    flexDirection: 'row',
    alignItems: 'center',
    padding: 16,
    backgroundColor: COLORS.background,
    borderRadius: 8,
  },
  loadingText: {
    marginLeft: 8,
    fontSize: 14,
    color: COLORS.text.secondary,
  },
  scrollContent: {
    gap: 8,
    paddingHorizontal: 2,
  },
  option: {
    paddingVertical: 12,
    paddingHorizontal: 16,
    backgroundColor: COLORS.white,
    borderWidth: 2,
    borderColor: COLORS.border,
    borderRadius: 8,
    minWidth: 120,
  },
  optionSelected: {
    backgroundColor: COLORS.primary,
    borderColor: COLORS.primary,
  },
  optionCodigo: {
    fontSize: 16,
    fontWeight: '700',
    color: COLORS.text.primary,
    marginBottom: 2,
  },
  optionCodigoSelected: {
    color: COLORS.white,
  },
  optionNombre: {
    fontSize: 11,
    color: COLORS.text.secondary,
  },
  optionNombreSelected: {
    color: COLORS.white,
    opacity: 0.9,
  },
});
