import React, { useEffect, useState } from 'react';
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  TextInput,
  Alert,
  ActivityIndicator,
} from 'react-native';
import { useAuthStore } from '../../store/authStore';
import { COLORS } from '../../constants/colors';
import { useNavigation } from '@react-navigation/native';
import axios from 'axios';
import { API_URL } from '../../constants/config';

import FuelSelector from '../../components/FuelSelector';

const TIPOS_INGRESO = [
  { value: 'COMBUSTIBLE', label: 'Combustible', icon: '⛽', color: '#f59e0b' },
  { value: 'COMISION', label: 'Comisión', icon: '📋', color: '#3b82f6' },
  { value: 'APOYO', label: 'Apoyo', icon: '🤝', color: '#8b5cf6' },
  { value: 'ALMUERZO', label: 'Almuerzo', icon: '🍽️', color: '#10b981' },
  { value: 'MANTENIMIENTO', label: 'Mantenimiento', icon: '🔧', color: '#ef4444' },
  { value: 'FINALIZAR_JORNADA', label: 'Finalizar Jornada', icon: '🏁', color: '#ef4444' },
];

export default function IngresoSedeScreen() {
  const navigation = useNavigation();
  const { salidaActiva, ingresoActivo, miSede, refreshEstadoBrigada } = useAuthStore();

  const [tipoIngreso, setTipoIngreso] = useState('');
  const [kmIngreso, setKmIngreso] = useState('');
  const [combustibleFraccion, setCombustibleFraccion] = useState<string | null>(null);
  const [combustibleDecimal, setCombustibleDecimal] = useState<number>(0);
  const [observaciones, setObservaciones] = useState('');
  const [loading, setLoading] = useState(false);

  const handleCombustibleChange = (fraccion: string, decimal: number) => {
    setCombustibleFraccion(fraccion);
    setCombustibleDecimal(decimal);
  };

  useEffect(() => {
    // Verificar si ya tiene ingreso activo
    if (ingresoActivo) {
      Alert.alert(
        'Ingreso Activo',
        'Ya estás ingresado en sede. Debes registrar salida de sede antes de ingresar nuevamente.',
        [
          { text: 'OK', onPress: () => navigation.goBack() }
        ]
      );
    }
  }, [ingresoActivo]);

  const handleRegistrarIngreso = async () => {
    // Validar campos
    if (!tipoIngreso) {
      Alert.alert('Error', 'Debes seleccionar el tipo de ingreso');
      return;
    }

    if (!miSede?.mi_sede_id) {
      Alert.alert('Error', 'No se ha identificado tu sede asignada. Contacta a soporte.');
      return;
    }

    const data: any = {
      tipo_ingreso: tipoIngreso,
      sede_id: miSede.mi_sede_id,
      es_ingreso_final: false,
    };

    // Validar campos opcionales
    if (kmIngreso.trim()) {
      const kmNum = parseFloat(kmIngreso);
      if (isNaN(kmNum) || kmNum < 0) {
        Alert.alert('Error', 'El kilometraje debe ser un número válido');
        return;
      }
      data.km_ingreso = kmNum;
    }

    if (combustibleFraccion) {
      data.combustible_ingreso = combustibleDecimal;
      data.combustible_fraccion = combustibleFraccion;
    }

    if (observaciones.trim()) {
      data.observaciones = observaciones.trim();
    }

    try {
      setLoading(true);

      const response = await axios.post(`${API_URL}/ingresos/registrar`, data);

      console.log('[INGRESO SEDE] Respuesta:', response.data);

      // Actualizar estado
      await refreshEstadoBrigada();

      const tipoLabel = TIPOS_INGRESO.find(t => t.value === tipoIngreso)?.label || tipoIngreso;

      Alert.alert(
        'Ingreso Registrado',
        `Has ingresado a sede por ${tipoLabel}. ${tipoIngreso === 'FINALIZAR_JORNADA' ? 'Ahora puedes proceder a finalizar la jornada.' : 'Cuando termines, registra la salida de sede para continuar patrullando.'}`,
        [
          {
            text: 'OK',
            onPress: () => navigation.goBack()
          }
        ]
      );
    } catch (error: any) {
      console.error('[INGRESO SEDE] Error:', error);
      const mensaje = error.response?.data?.error || error.message || 'No se pudo registrar el ingreso';
      Alert.alert('Error', mensaje);
    } finally {
      setLoading(false);
    }
  };

  if (!salidaActiva) {
    return (
      <View style={styles.container}>
        <View style={styles.errorCard}>
          <Text style={styles.errorIcon}>⚠️</Text>
          <Text style={styles.errorTitle}>Sin Salida Activa</Text>
          <Text style={styles.errorText}>
            Debes iniciar una salida antes de poder ingresar a sede.
          </Text>
          <TouchableOpacity
            style={styles.backButton}
            onPress={() => navigation.goBack()}
          >
            <Text style={styles.backButtonText}>Volver</Text>
          </TouchableOpacity>
        </View>
      </View>
    );
  }

  return (
    <ScrollView style={styles.container}>
      {/* Header */}
      <View style={styles.header}>
        <Text style={styles.headerTitle}>Ingreso a Sede</Text>
        <Text style={styles.headerSubtitle}>
          Registra tu ingreso temporal a sede
        </Text>
      </View>

      {/* Card de Sede */}
      {miSede && (
        <View style={styles.card}>
          <Text style={styles.cardTitle}>Tu Sede</Text>
          <View style={styles.sedeInfo}>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Sede:</Text>
              <Text style={styles.infoValue}>{miSede.mi_sede_nombre}</Text>
            </View>
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Código:</Text>
              <Text style={styles.infoValue}>{miSede.mi_sede_codigo}</Text>
            </View>
          </View>
        </View>
      )}

      {/* Selección de Tipo de Ingreso */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>
          Tipo de Ingreso <Text style={styles.required}>*</Text>
        </Text>
        <View style={styles.tiposGrid}>
          {TIPOS_INGRESO.map((tipo) => (
            <TouchableOpacity
              key={tipo.value}
              style={[
                styles.tipoButton,
                tipoIngreso === tipo.value && styles.tipoButtonSelected,
                { borderColor: tipo.color }
              ]}
              onPress={() => setTipoIngreso(tipo.value)}
              disabled={loading}
            >
              <Text style={styles.tipoIcon}>{tipo.icon}</Text>
              <Text style={[
                styles.tipoLabel,
                tipoIngreso === tipo.value && { color: tipo.color, fontWeight: '600' }
              ]}>
                {tipo.label}
              </Text>
            </TouchableOpacity>
          ))}
        </View>
      </View>

      {/* Formulario de Datos */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Datos del Ingreso (Opcionales)</Text>

        <View style={styles.formGroup}>
          <Text style={styles.label}>Kilometraje</Text>
          <TextInput
            style={styles.input}
            value={kmIngreso}
            onChangeText={setKmIngreso}
            placeholder="Ej: 12345.6"
            keyboardType="decimal-pad"
            editable={!loading}
          />
        </View>

        <View style={styles.formGroup}>
          <FuelSelector
            value={combustibleFraccion}
            onChange={handleCombustibleChange}
            label="Nivel de Combustible"
          />
        </View>

        <View style={styles.formGroup}>
          <Text style={styles.label}>Observaciones</Text>
          <TextInput
            style={[styles.input, styles.textArea]}
            value={observaciones}
            onChangeText={setObservaciones}
            placeholder="Motivo específico del ingreso..."
            multiline
            numberOfLines={3}
            editable={!loading}
          />
        </View>
      </View>

      {/* Instrucciones */}
      <View style={styles.instructionsCard}>
        <Text style={styles.instructionsTitle}>💡 Recuerda</Text>
        <Text style={styles.instructionsText}>
          • Este ingreso es temporal, no finaliza tu jornada{'\n'}
          • No podrás reportar situaciones mientras estés en sede{'\n'}
          • Al terminar, registra la salida de sede{'\n'}
          • Puedes ingresar varias veces durante el día
        </Text>
      </View>

      {/* Botones */}
      <View style={styles.buttonsContainer}>
        <TouchableOpacity
          style={[styles.button, styles.cancelButton]}
          onPress={() => navigation.goBack()}
          disabled={loading}
        >
          <Text style={styles.cancelButtonText}>Cancelar</Text>
        </TouchableOpacity>

        <TouchableOpacity
          style={[styles.button, styles.confirmButton]}
          onPress={handleRegistrarIngreso}
          disabled={loading || !tipoIngreso}
        >
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.confirmButtonText}>Registrar Ingreso</Text>
          )}
        </TouchableOpacity>
      </View>

      <View style={{ height: 40 }} />
    </ScrollView>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  header: {
    backgroundColor: COLORS.primary,
    padding: 20,
    paddingTop: 16,
  },
  headerTitle: {
    fontSize: 24,
    fontWeight: 'bold',
    color: COLORS.white,
    marginBottom: 4,
  },
  headerSubtitle: {
    fontSize: 14,
    color: COLORS.white,
    opacity: 0.9,
  },
  card: {
    backgroundColor: COLORS.white,
    margin: 16,
    marginBottom: 8,
    padding: 16,
    borderRadius: 12,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  cardTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: COLORS.text.primary,
    marginBottom: 16,
  },
  sedeInfo: {
    backgroundColor: COLORS.info + '10',
    padding: 12,
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: COLORS.info,
  },
  infoRow: {
    flexDirection: 'row',
    justifyContent: 'space-between',
    marginBottom: 8,
  },
  infoLabel: {
    fontSize: 14,
    color: COLORS.text.secondary,
    fontWeight: '500',
  },
  infoValue: {
    fontSize: 14,
    color: COLORS.text.primary,
    fontWeight: '600',
  },
  required: {
    color: COLORS.danger,
  },
  tiposGrid: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 10,
  },
  tipoButton: {
    width: '48%',
    backgroundColor: COLORS.white,
    borderWidth: 2,
    borderColor: COLORS.border,
    borderRadius: 12,
    padding: 16,
    alignItems: 'center',
    minHeight: 100,
    justifyContent: 'center',
  },
  tipoButtonSelected: {
    backgroundColor: COLORS.background,
    borderWidth: 3,
  },
  tipoIcon: {
    fontSize: 32,
    marginBottom: 8,
  },
  tipoLabel: {
    fontSize: 14,
    color: COLORS.text.primary,
    textAlign: 'center',
  },
  formGroup: {
    marginBottom: 20,
  },
  label: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.text.primary,
    marginBottom: 8,
  },
  input: {
    borderWidth: 1,
    borderColor: COLORS.border,
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    backgroundColor: COLORS.white,
  },
  textArea: {
    height: 80,
    textAlignVertical: 'top',
  },
  instructionsCard: {
    backgroundColor: COLORS.info + '20',
    margin: 16,
    marginBottom: 8,
    padding: 16,
    borderRadius: 12,
    borderLeftWidth: 4,
    borderLeftColor: COLORS.info,
  },
  instructionsTitle: {
    fontSize: 16,
    fontWeight: '600',
    color: COLORS.text.primary,
    marginBottom: 8,
  },
  instructionsText: {
    fontSize: 14,
    color: COLORS.text.primary,
    lineHeight: 22,
  },
  buttonsContainer: {
    flexDirection: 'row',
    gap: 12,
    paddingHorizontal: 16,
    marginTop: 8,
  },
  button: {
    flex: 1,
    paddingVertical: 14,
    borderRadius: 8,
    alignItems: 'center',
  },
  cancelButton: {
    backgroundColor: COLORS.white,
    borderWidth: 2,
    borderColor: COLORS.border,
  },
  confirmButton: {
    backgroundColor: COLORS.primary,
  },
  cancelButtonText: {
    color: COLORS.text.primary,
    fontSize: 16,
    fontWeight: '600',
  },
  confirmButtonText: {
    color: COLORS.white,
    fontSize: 16,
    fontWeight: '600',
  },
  errorCard: {
    backgroundColor: COLORS.white,
    margin: 20,
    padding: 24,
    borderRadius: 12,
    alignItems: 'center',
  },
  errorIcon: {
    fontSize: 48,
    marginBottom: 16,
  },
  errorTitle: {
    fontSize: 20,
    fontWeight: '600',
    color: COLORS.text.primary,
    marginBottom: 8,
  },
  errorText: {
    fontSize: 14,
    color: COLORS.text.secondary,
    textAlign: 'center',
    lineHeight: 20,
    marginBottom: 20,
  },
  backButton: {
    backgroundColor: COLORS.primary,
    paddingVertical: 12,
    paddingHorizontal: 24,
    borderRadius: 8,
  },
  backButtonText: {
    color: COLORS.white,
    fontSize: 16,
    fontWeight: '600',
  },
});
