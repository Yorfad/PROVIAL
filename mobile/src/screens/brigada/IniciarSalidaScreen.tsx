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

export default function IniciarSalidaScreen() {
  const navigation = useNavigation();
  const { asignacion, salidaActiva, refreshEstadoBrigada } = useAuthStore();

  const [kmSalida, setKmSalida] = useState('');
  const [combustibleSalida, setCombustibleSalida] = useState('');
  const [observaciones, setObservaciones] = useState('');
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    // Verificar si ya tiene salida activa
    if (salidaActiva) {
      Alert.alert(
        'Salida Activa',
        'Ya tienes una salida activa. Debes finalizar el día antes de iniciar una nueva salida.',
        [
          { text: 'OK', onPress: () => navigation.goBack() }
        ]
      );
    }
  }, [salidaActiva]);

  const handleIniciarSalida = async () => {
    // Validar campos
    if (!kmSalida.trim()) {
      Alert.alert('Error', 'Debes ingresar el kilometraje de salida');
      return;
    }

    if (!combustibleSalida.trim()) {
      Alert.alert('Error', 'Debes ingresar el nivel de combustible');
      return;
    }

    const kmNum = parseFloat(kmSalida);
    const combustibleNum = parseFloat(combustibleSalida);

    if (isNaN(kmNum) || kmNum < 0) {
      Alert.alert('Error', 'El kilometraje debe ser un número válido');
      return;
    }

    if (isNaN(combustibleNum) || combustibleNum < 0 || combustibleNum > 100) {
      Alert.alert('Error', 'El combustible debe estar entre 0 y 100');
      return;
    }

    try {
      setLoading(true);

      const response = await axios.post(`${API_URL}/salidas/iniciar`, {
        km_salida: kmNum,
        combustible_salida: combustibleNum,
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

  if (!asignacion) {
    return (
      <View style={styles.container}>
        <View style={styles.errorCard}>
          <Text style={styles.errorIcon}>⚠️</Text>
          <Text style={styles.errorTitle}>Sin Asignación</Text>
          <Text style={styles.errorText}>
            No tienes una unidad asignada. Contacta a tu encargado de sede para que te asigne una unidad.
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
        <View style={styles.unidadInfo}>
          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Unidad:</Text>
            <Text style={styles.infoValue}>{asignacion.unidad_codigo}</Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Tipo:</Text>
            <Text style={styles.infoValue}>{asignacion.tipo_unidad}</Text>
          </View>
          <View style={styles.infoRow}>
            <Text style={styles.infoLabel}>Tu Rol:</Text>
            <Text style={styles.infoValue}>{asignacion.rol_tripulacion}</Text>
          </View>
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
          <Text style={styles.label}>
            Nivel de Combustible (%) <Text style={styles.required}>*</Text>
          </Text>
          <TextInput
            style={styles.input}
            value={combustibleSalida}
            onChangeText={setCombustibleSalida}
            placeholder="Ej: 75"
            keyboardType="decimal-pad"
            editable={!loading}
          />
          <Text style={styles.hint}>Porcentaje de combustible (0-100)</Text>
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
});
