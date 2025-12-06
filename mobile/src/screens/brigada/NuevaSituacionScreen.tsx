import React, { useState } from 'react';
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
import { useNavigation } from '@react-navigation/native';
import { useAuthStore } from '../../store/authStore';
import { useSituacionesStore } from '../../store/situacionesStore';
import { COLORS } from '../../constants/colors';
import {
  TipoSituacion,
  SITUACIONES_CONFIG,
  SENTIDOS,
} from '../../constants/situacionTypes';
import CombustibleSelector from '../../components/CombustibleSelector';
import RutaSelector from '../../components/RutaSelector';

export default function NuevaSituacionScreen() {
  const navigation = useNavigation();
  const { salidaActiva } = useAuthStore();
  const { createSituacion, isLoading } = useSituacionesStore();

  // Estado del formulario
  const [tipoSeleccionado, setTipoSeleccionado] = useState<TipoSituacion | null>(null);
  const [km, setKm] = useState('');
  const [sentido, setSentido] = useState('');
  const [combustibleFraccion, setCombustibleFraccion] = useState<string | null>(null);
  const [combustibleDecimal, setCombustibleDecimal] = useState<number>(0);
  const [kilometraje, setKilometraje] = useState('');
  const [descripcion, setDescripcion] = useState('');
  const [observaciones, setObservaciones] = useState('');

  // Coordenadas GPS (manual para demo)
  const [latitud, setLatitud] = useState('14.6349'); // Guatemala City por defecto
  const [longitud, setLongitud] = useState('-90.5069');

  // Ruta (se puede cambiar solo en SALIDA_SEDE o CAMBIO_RUTA)
  const [rutaSeleccionada, setRutaSeleccionada] = useState<number | null>(null);

  // Handler para el selector de combustible
  const handleCombustibleChange = (fraccion: string, decimal: number) => {
    setCombustibleFraccion(fraccion);
    setCombustibleDecimal(decimal);
  };

  const handleCrearSituacion = async () => {
    if (!tipoSeleccionado) {
      Alert.alert('Error', 'Debes seleccionar un tipo de situación');
      return;
    }

    if (!salidaActiva) {
      Alert.alert('Error', 'No tienes una salida activa. Debes iniciar salida primero.');
      return;
    }

    const config = SITUACIONES_CONFIG[tipoSeleccionado];

    // Validaciones según el tipo
    if (tipoSeleccionado === 'SALIDA_SEDE' && !rutaSeleccionada) {
      Alert.alert('Error', 'Debes seleccionar una ruta para salir de sede');
      return;
    }

    if (config.requiereCombustible && !combustibleFraccion) {
      Alert.alert('Error', 'El nivel de combustible es requerido');
      return;
    }

    if (config.requiereKilometraje && !kilometraje) {
      Alert.alert('Error', 'El kilometraje de la unidad es requerido');
      return;
    }

    if (config.requiereRuta && !km) {
      Alert.alert('Error', 'El kilómetro de ubicación es requerido');
      return;
    }

    // Determinar qué ruta usar
    let rutaFinal = rutaSeleccionada; // Para SALIDA_SEDE o CAMBIO_RUTA

    // Si requiere ruta y no es SALIDA_SEDE/CAMBIO_RUTA, validar que existe ruta en salida activa
    if (config.requiereRuta && !['SALIDA_SEDE', 'CAMBIO_RUTA'].includes(tipoSeleccionado)) {
      if (!salidaActiva.ruta_codigo) {
        Alert.alert(
          'Error',
          'No tienes una ruta asignada en tu salida. Realiza un "Cambio de Ruta" desde el menú principal primero.'
        );
        return;
      }
      // Para situaciones que requieren ruta, usar la ruta de la salida
      // Nota: salidaActiva solo tiene ruta_codigo, no ruta_id
      // El backend deberá resolver el ruta_id basado en el código o usar el de la salida
    }

    try {
      const data = {
        tipo_situacion: tipoSeleccionado,
        unidad_id: salidaActiva.unidad_id,
        salida_unidad_id: salidaActiva.salida_id,
        ruta_id: rutaFinal || undefined,
        km: km ? parseFloat(km) : undefined,
        sentido: sentido || undefined,
        latitud: latitud ? parseFloat(latitud) : undefined,
        longitud: longitud ? parseFloat(longitud) : undefined,
        combustible: combustibleDecimal || undefined,
        combustible_fraccion: combustibleFraccion || undefined,
        kilometraje_unidad: kilometraje ? parseInt(kilometraje, 10) : undefined,
        descripcion: descripcion || undefined,
        observaciones: observaciones || undefined,
        ubicacion_manual: true, // Modo demo con coordenadas manuales
      };

      await createSituacion(data);

      Alert.alert('Éxito', 'Situación creada correctamente', [
        {
          text: 'OK',
          onPress: () => navigation.goBack(),
        },
      ]);
    } catch (error: any) {
      Alert.alert('Error', error.message || 'No se pudo crear la situación');
    }
  };

  const renderTipoSelector = () => {
    // Filtrar los tipos que ya tienen su propia pantalla en el home
    const tipos = (Object.keys(SITUACIONES_CONFIG) as TipoSituacion[]).filter(
      (t) => !['SALIDA_SEDE', 'CAMBIO_RUTA', 'ASISTENCIA_VEHICULAR', 'INCIDENTE'].includes(t)
    );

    return (
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Tipo de Situación</Text>
        <View style={styles.tiposContainer}>
          {tipos.map((tipo) => {
            const config = SITUACIONES_CONFIG[tipo];
            const isSelected = tipoSeleccionado === tipo;

            return (
              <TouchableOpacity
                key={tipo}
                style={[
                  styles.tipoButton,
                  isSelected && {
                    backgroundColor: config.color,
                    borderColor: config.color,
                  },
                ]}
                onPress={() => setTipoSeleccionado(tipo)}
              >
                <Text
                  style={[
                    styles.tipoButtonText,
                    isSelected && styles.tipoButtonTextSelected,
                  ]}
                >
                  {config.label}
                </Text>
              </TouchableOpacity>
            );
          })}
        </View>
      </View>
    );
  };

  const renderUbicacionFields = () => {
    if (!tipoSeleccionado) return null;

    const config = SITUACIONES_CONFIG[tipoSeleccionado];
    const puedeSeleccionarRuta = ['SALIDA_SEDE', 'CAMBIO_RUTA'].includes(tipoSeleccionado);

    return (
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Ubicación</Text>

        {/* Selector de ruta para SALIDA_SEDE y CAMBIO_RUTA */}
        {puedeSeleccionarRuta && (
          <RutaSelector
            value={rutaSeleccionada || undefined}
            onChange={(rutaId) => setRutaSeleccionada(rutaId)}
            label="Seleccionar Ruta"
            required={tipoSeleccionado === 'SALIDA_SEDE'}
          />
        )}

        {/* Mostrar ruta asignada si no puede cambiarla */}
        {!puedeSeleccionarRuta && asignacion?.ruta_asignada_codigo && (
          <View style={styles.infoBox}>
            <Text style={styles.infoLabel}>Ruta Asignada:</Text>
            <Text style={styles.infoValue}>{asignacion.ruta_asignada_codigo}</Text>
          </View>
        )}

        <Text style={styles.label}>Kilómetro{config.requiereRuta && ' *'}</Text>
        <TextInput
          style={styles.input}
          value={km}
          onChangeText={setKm}
          placeholder="Ej: 125.5"
          keyboardType="decimal-pad"
          placeholderTextColor={COLORS.text.disabled}
        />

        <Text style={styles.label}>Sentido</Text>
        <View style={styles.sentidosContainer}>
          {SENTIDOS.map((s) => (
            <TouchableOpacity
              key={s.value}
              style={[
                styles.sentidoButton,
                sentido === s.value && styles.sentidoButtonSelected,
              ]}
              onPress={() => setSentido(s.value)}
            >
              <Text
                style={[
                  styles.sentidoButtonText,
                  sentido === s.value && styles.sentidoButtonTextSelected,
                ]}
              >
                {s.label}
              </Text>
            </TouchableOpacity>
          ))}
        </View>

        <Text style={styles.label}>Coordenadas GPS (Demo)</Text>
        <View style={styles.coordsContainer}>
          <View style={styles.coordField}>
            <Text style={styles.coordLabel}>Latitud:</Text>
            <TextInput
              style={styles.coordInput}
              value={latitud}
              onChangeText={setLatitud}
              placeholder="14.6349"
              keyboardType="decimal-pad"
              placeholderTextColor={COLORS.text.disabled}
            />
          </View>
          <View style={styles.coordField}>
            <Text style={styles.coordLabel}>Longitud:</Text>
            <TextInput
              style={styles.coordInput}
              value={longitud}
              onChangeText={setLongitud}
              placeholder="-90.5069"
              keyboardType="decimal-pad"
              placeholderTextColor={COLORS.text.disabled}
            />
          </View>
        </View>
      </View>
    );
  };

  const renderCamposAdicionales = () => {
    if (!tipoSeleccionado) return null;

    const config = SITUACIONES_CONFIG[tipoSeleccionado];

    return (
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Información de la Unidad</Text>

        {/* Combustible siempre disponible */}
        <CombustibleSelector
          value={combustibleFraccion || undefined}
          onChange={handleCombustibleChange}
          label={config.requiereCombustible ? 'Nivel de Combustible *' : 'Nivel de Combustible (Opcional)'}
          required={config.requiereCombustible}
        />

        {config.requiereKilometraje && (
          <>
            <Text style={styles.label}>Kilometraje de Unidad *</Text>
            <TextInput
              style={styles.input}
              value={kilometraje}
              onChangeText={setKilometraje}
              placeholder="Ej: 145000"
              keyboardType="number-pad"
              placeholderTextColor={COLORS.text.disabled}
            />
          </>
        )}

        {!config.requiereCombustible && (
          <Text style={styles.helperText}>
            💡 Tip: Reportar el combustible ayuda a analizar el rendimiento de la unidad
          </Text>
        )}
      </View>
    );
  };

  const renderDescripcionFields = () => {
    return (
      <View style={styles.section}>
        <Text style={styles.sectionTitle}>Detalles</Text>

        <Text style={styles.label}>Descripción</Text>
        <TextInput
          style={[styles.input, styles.textArea]}
          value={descripcion}
          onChangeText={setDescripcion}
          placeholder="Descripción breve de la situación"
          multiline
          numberOfLines={3}
          placeholderTextColor={COLORS.text.disabled}
        />

        <Text style={styles.label}>Observaciones</Text>
        <TextInput
          style={[styles.input, styles.textArea]}
          value={observaciones}
          onChangeText={setObservaciones}
          placeholder="Observaciones adicionales"
          multiline
          numberOfLines={3}
          placeholderTextColor={COLORS.text.disabled}
        />
      </View>
    );
  };

  return (
    <View style={styles.container}>
      <ScrollView style={styles.scrollView} contentContainerStyle={styles.scrollContent}>
        {/* Información de asignación */}
        {asignacion && (
          <View style={styles.headerCard}>
            <Text style={styles.headerTitle}>Unidad: {asignacion.unidad_codigo}</Text>
            {asignacion.ruta_asignada_codigo && (
              <Text style={styles.headerSubtitle}>
                Ruta: {asignacion.ruta_asignada_codigo}
              </Text>
            )}
          </View>
        )}

        {/* Tipo de situación */}
        {renderTipoSelector()}

        {/* Campos según el tipo seleccionado */}
        {tipoSeleccionado && (
          <>
            {renderUbicacionFields()}
            {renderCamposAdicionales()}
            {renderDescripcionFields()}
          </>
        )}
      </ScrollView>

      {/* Botón de crear */}
      <View style={styles.footer}>
        <TouchableOpacity
          style={[styles.createButton, (!tipoSeleccionado || isLoading) && styles.buttonDisabled]}
          onPress={handleCrearSituacion}
          disabled={!tipoSeleccionado || isLoading}
        >
          {isLoading ? (
            <ActivityIndicator color="#fff" />
          ) : (
            <Text style={styles.createButtonText}>Crear Situación</Text>
          )}
        </TouchableOpacity>
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    backgroundColor: COLORS.background,
  },
  scrollView: {
    flex: 1,
  },
  scrollContent: {
    padding: 16,
    paddingBottom: 100,
  },
  headerCard: {
    backgroundColor: COLORS.primary,
    padding: 16,
    borderRadius: 12,
    marginBottom: 20,
  },
  headerTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: COLORS.white,
  },
  headerSubtitle: {
    fontSize: 14,
    color: COLORS.white,
    opacity: 0.9,
    marginTop: 4,
  },
  section: {
    backgroundColor: COLORS.white,
    padding: 16,
    borderRadius: 12,
    marginBottom: 16,
    shadowColor: '#000',
    shadowOffset: { width: 0, height: 2 },
    shadowOpacity: 0.1,
    shadowRadius: 4,
    elevation: 3,
  },
  sectionTitle: {
    fontSize: 18,
    fontWeight: '600',
    color: COLORS.text.primary,
    marginBottom: 12,
  },
  tiposContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  tipoButton: {
    paddingVertical: 10,
    paddingHorizontal: 16,
    borderRadius: 20,
    backgroundColor: COLORS.white,
    borderWidth: 2,
    borderColor: COLORS.border,
    marginBottom: 8,
  },
  tipoButtonText: {
    fontSize: 14,
    fontWeight: '500',
    color: COLORS.text.primary,
  },
  tipoButtonTextSelected: {
    color: COLORS.white,
    fontWeight: '600',
  },
  label: {
    fontSize: 14,
    fontWeight: '500',
    color: COLORS.text.primary,
    marginBottom: 8,
    marginTop: 12,
  },
  input: {
    backgroundColor: COLORS.background,
    borderWidth: 1,
    borderColor: COLORS.border,
    borderRadius: 8,
    padding: 12,
    fontSize: 16,
    color: COLORS.text.primary,
  },
  textArea: {
    height: 80,
    textAlignVertical: 'top',
  },
  infoBox: {
    backgroundColor: COLORS.info + '20',
    padding: 12,
    borderRadius: 8,
    marginBottom: 12,
    flexDirection: 'row',
    justifyContent: 'space-between',
  },
  infoLabel: {
    fontSize: 14,
    fontWeight: '500',
    color: COLORS.text.secondary,
  },
  infoValue: {
    fontSize: 14,
    fontWeight: '600',
    color: COLORS.primary,
  },
  sentidosContainer: {
    flexDirection: 'row',
    flexWrap: 'wrap',
    gap: 8,
  },
  sentidoButton: {
    paddingVertical: 8,
    paddingHorizontal: 12,
    borderRadius: 16,
    backgroundColor: COLORS.background,
    borderWidth: 1,
    borderColor: COLORS.border,
  },
  sentidoButtonSelected: {
    backgroundColor: COLORS.primary,
    borderColor: COLORS.primary,
  },
  sentidoButtonText: {
    fontSize: 13,
    color: COLORS.text.primary,
  },
  sentidoButtonTextSelected: {
    color: COLORS.white,
    fontWeight: '600',
  },
  helperText: {
    fontSize: 14,
    color: COLORS.text.secondary,
    fontStyle: 'italic',
  },
  footer: {
    position: 'absolute',
    bottom: 0,
    left: 0,
    right: 0,
    backgroundColor: COLORS.white,
    padding: 16,
    borderTopWidth: 1,
    borderTopColor: COLORS.border,
  },
  createButton: {
    backgroundColor: COLORS.primary,
    padding: 16,
    borderRadius: 12,
    alignItems: 'center',
  },
  buttonDisabled: {
    opacity: 0.5,
  },
  createButtonText: {
    color: COLORS.white,
    fontSize: 16,
    fontWeight: '600',
  },
  coordsContainer: {
    flexDirection: 'row',
    gap: 12,
    marginTop: 8,
  },
  coordField: {
    flex: 1,
  },
  coordLabel: {
    fontSize: 12,
    fontWeight: '500',
    color: COLORS.text.secondary,
    marginBottom: 6,
  },
  coordInput: {
    backgroundColor: COLORS.background,
    borderWidth: 1,
    borderColor: COLORS.border,
    borderRadius: 8,
    padding: 10,
    fontSize: 14,
    color: COLORS.text.primary,
  },
});
