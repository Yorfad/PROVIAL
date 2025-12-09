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
import { turnosAPI } from '../../services/api';

export default function IniciarSalidaScreen() {
  const navigation = useNavigation();
  const { asignacion, salidaActiva, refreshEstadoBrigada } = useAuthStore();

  const [kmSalida, setKmSalida] = useState('');
  const [combustibleFraccion, setCombustibleFraccion] = useState<string | null>(null);
  const [combustibleDecimal, setCombustibleDecimal] = useState<number>(0);
  const [observaciones, setObservaciones] = useState('');
  const [loading, setLoading] = useState(false);

  // Asignacion de turno (sistema nuevo)
  const [asignacionTurno, setAsignacionTurno] = useState<any>(null);
  const [loadingAsignacion, setLoadingAsignacion] = useState(true);

  const handleCombustibleChange = (fraccion: string, decimal: number) => {
    setCombustibleFraccion(fraccion);
    setCombustibleDecimal(decimal);
  };

  // Cargar asignacion de turno al montar
  useEffect(() => {
    const loadAsignacionTurno = async () => {
      try {
        setLoadingAsignacion(true);
        const data = await turnosAPI.getMiAsignacionHoy();
        setAsignacionTurno(data);
      } catch (error) {
        console.log('[INICIAR SALIDA] No hay asignacion de turno');
        setAsignacionTurno(null);
      } finally {
        setLoadingAsignacion(false);
      }
    };
    loadAsignacionTurno();
  }, []);

  useEffect(() => {
    // Verificar si ya tiene salida activa
    if (salidaActiva) {
      Alert.alert(
        'Salida Activa',
        'Ya tienes una salida activa. Debes finalizar el dia antes de iniciar una nueva salida.',
        [
          { text: 'OK', onPress: () => navigation.goBack() }
        ]
      );
    }
  }, [salidaActiva]);

  // La asignacion efectiva es la de turno o la permanente
  const asignacionEfectiva = asignacionTurno || asignacion;

  const handleIniciarSalida = async () => {
    // Validar campos
    if (!kmSalida.trim()) {
      Alert.alert('Error', 'Debes ingresar el kilometraje de salida');
      return;
    }

    if (!combustibleFraccion) {
      Alert.alert('Error', 'Debes seleccionar el nivel de combustible');
      return;
    }

    const kmNum = parseFloat(kmSalida);

    if (isNaN(kmNum) || kmNum < 0) {
      Alert.alert('Error', 'El kilometraje debe ser un número válido');
      return;
    }

    try {
      setLoading(true);

      const response = await axios.post(`${API_URL}/salidas/iniciar`, {
        km_salida: kmNum,
        combustible_salida: combustibleDecimal,
        combustible_fraccion: combustibleFraccion,
        observaciones: observaciones.trim() || undefined,
      });

      console.log('[INICIAR SALIDA] Respuesta:', response.data);

      // Actualizar estado
      await refreshEstadoBrigada();

      Alert.alert(
        '¡Salida Iniciada!',
        response.data.message || 'Tu jornada laboral ha comenzado. Ya puedes reportar situaciones.',
        [
          {
            text: 'OK',
            onPress: () => navigation.goBack()
          }
        ]
      );
    } catch (error: any) {
      console.error('[INICIAR SALIDA] Error:', error);
      const mensaje = error.response?.data?.error || error.message || 'No se pudo iniciar la salida';
      Alert.alert('Error', mensaje);
    } finally {
      setLoading(false);
    }
  };

  // Mostrar loading mientras carga asignacion de turno
  if (loadingAsignacion) {
    return (
      <View style={[styles.container, { justifyContent: 'center', alignItems: 'center' }]}>
        <ActivityIndicator size="large" color={COLORS.primary} />
        <Text style={{ marginTop: 16, color: COLORS.text.secondary }}>
          Verificando asignacion...
        </Text>
      </View>
    );
  }

  // Mostrar error si no hay ninguna asignacion (ni turno ni permanente)
  if (!asignacionEfectiva) {
    return (
      <View style={styles.container}>
        <View style={styles.errorCard}>
          <Text style={styles.errorIcon}>⚠️</Text>
          <Text style={styles.errorTitle}>Sin Asignacion</Text>
          <Text style={styles.errorText}>
            No tienes una unidad asignada para hoy. Contacta a Operaciones para que te asignen.
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
        <Text style={styles.headerTitle}>Iniciar Salida</Text>
        <Text style={styles.headerSubtitle}>
          Registra el inicio de tu jornada laboral
        </Text>
      </View>

      {/* Card de Unidad Asignada */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Tu Unidad Asignada</Text>
        {/* Indicador si es asignacion de turno */}
        {asignacionTurno && (
          <View style={[styles.tipoBadge, { backgroundColor: asignacionTurno.dias_para_salida === 0 ? COLORS.success : COLORS.info }]}>
            <Text style={styles.tipoBadgeText}>
              {asignacionTurno.dias_para_salida === 0 ? 'TURNO DE HOY' : asignacionTurno.dias_para_salida === 1 ? 'TURNO DE MANANA' : `EN ${asignacionTurno.dias_para_salida} DIAS`}
            </Text>
          </View>
        )}
        <View style={styles.unidadInfo}>
          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Unidad:</Text>
            <Text style={styles.infoValue}>
              {asignacionEfectiva.unidad_codigo || asignacionEfectiva.codigo}
            </Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Tipo:</Text>
            <Text style={styles.infoValue}>
              {asignacionEfectiva.tipo_unidad || 'N/A'}
            </Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Tu Rol:</Text>
            <Text style={styles.infoValue}>
              {asignacionEfectiva.mi_rol || asignacionEfectiva.rol_tripulacion || 'N/A'}
            </Text>
          </View>
          {asignacionTurno?.ruta_codigo && (
            <View style={styles.infoRow}>
              <Text style={styles.infoLabel}>Ruta:</Text>
              <Text style={styles.infoValue}>{asignacionTurno.ruta_codigo}</Text>
            </View>
          )}
        </View>
      </View>

      {/* Formulario */}
      <View style={styles.card}>
        <Text style={styles.cardTitle}>Datos de Salida</Text>

        <View style={styles.formGroup}>
          <Text style={styles.label}>
            Kilometraje de Salida <Text style={styles.required}>*</Text>
          </Text>
          <TextInput
            style={styles.input}
            value={kmSalida}
            onChangeText={setKmSalida}
            placeholder="Ej: 12345.6"
            keyboardType="decimal-pad"
            editable={!loading}
          />
          <Text style={styles.hint}>Kilometraje actual del odómetro</Text>
        </View>

        <View style={styles.formGroup}>
          <FuelSelector
            value={combustibleFraccion}
            onChange={handleCombustibleChange}
            label="Nivel de Combustible"
            required
          />
        </View>

        <View style={styles.formGroup}>
          <Text style={styles.label}>Observaciones (Opcional)</Text>
          <TextInput
            style={[styles.input, styles.textArea]}
            value={observaciones}
            onChangeText={setObservaciones}
            placeholder="Cualquier observación sobre el estado de la unidad..."
            multiline
            numberOfLines={3}
            editable={!loading}
          />
        </View>
      </View>

      {/* Instrucciones */}
      <View style={styles.instructionsCard}>
        <Text style={styles.instructionsTitle}>📋 Importante</Text>
        <Text style={styles.instructionsText}>
          • Verifica el kilometraje y combustible antes de iniciar{'\n'}
          • Una vez iniciada la salida, podrás reportar situaciones{'\n'}
          • Puedes ingresar a sedes durante tu jornada{'\n'}
          • Al finalizar el día, debes registrar el ingreso final
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
          onPress={handleIniciarSalida}
          disabled={loading}
        >
          {loading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.confirmButtonText}>Iniciar Salida</Text>
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
  unidadInfo: {
    backgroundColor: COLORS.primary + '10',
    padding: 12,
    borderRadius: 8,
    borderLeftWidth: 4,
    borderLeftColor: COLORS.primary,
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
  formGroup: {
    marginBottom: 20,
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
  hint: {
    fontSize: 12,
    color: COLORS.text.secondary,
    marginTop: 4,
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
    backgroundColor: COLORS.success,
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
  tipoBadge: {
    paddingVertical: 6,
    paddingHorizontal: 12,
    borderRadius: 16,
    alignSelf: 'flex-start',
    marginBottom: 12,
  },
  tipoBadgeText: {
    color: COLORS.white,
    fontSize: 12,
    fontWeight: '600',
  },
});
