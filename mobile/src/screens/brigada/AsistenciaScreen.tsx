import React, { useState, useEffect } from 'react';
import * as Location from 'expo-location';
import { useDraftSave } from '../../hooks/useDraftSave';
import {
    View,
    Text,
    StyleSheet,
    ScrollView,
    TouchableOpacity,
    Alert,
    ActivityIndicator,
} from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { useNavigation } from '@react-navigation/native';
import { COLORS } from '../../constants/colors';
import {
    TIPOS_ASISTENCIA,
    SENTIDOS,
} from '../../constants/situacionTypes';
import { useAuthStore } from '../../store/authStore';
import AutoridadSocorroManager, { DetalleAutoridad, DetallesSocorro } from '../../components/AutoridadSocorroManager';
import ObstruccionManager from '../../components/ObstruccionManager';

// New Imports
import { useForm, useFieldArray, Controller } from 'react-hook-form';
import { Provider as PaperProvider, SegmentedButtons, TextInput as PaperInput, Button, Switch } from 'react-native-paper';
import { VehiculoForm } from '../../components/VehiculoForm';
import { GruaForm } from '../../components/GruaForm';
import { AjustadorForm } from '../../components/AjustadorForm';

export default function AsistenciaScreen() {
    const navigation = useNavigation();
    const { salidaActiva } = useAuthStore();

    // Form Setup
    const { control, handleSubmit, setValue, watch, reset, getValues } = useForm({
        defaultValues: {
            tipoAsistencia: '',
            rutaId: null, // Se auto-asignará desde salida activa
            km: '',
            sentido: '',
            vehiculos: [],
            gruas: [],
            ajustadores: [],
            autoridadesSeleccionadas: [],
            detallesAutoridades: {},
            socorroSeleccionado: [],
            detallesSocorro: {},
            servicioProporcionado: '',
            obstruye: '',
            observaciones: '',
            jurisdiccion: '', // New field
            direccion_detallada: '', // New field
        }
    });

    // Auto-asignar ruta desde salida activa
    useEffect(() => {
        // Note: rutaId se obtiene dinámicamente desde salidaActiva, no se necesita asignar en el form
        // La ruta se mostrará solo como información de solo lectura
    }, [salidaActiva]);

    const { fields: vehiculoFields, append: appendVehiculo, remove: removeVehiculo } = useFieldArray({
        control,
        name: "vehiculos"
    });

    const { fields: gruaFields, append: appendGrua, remove: removeGrua } = useFieldArray({
        control,
        name: "gruas"
    });

    const { fields: ajustadorFields, append: appendAjustador, remove: removeAjustador } = useFieldArray({
        control,
        name: "ajustadores"
    });

    // Watchers for summary
    const vehiculos = watch('vehiculos');

    // UI State
    const [activeTab, setActiveTab] = useState('general');
    const [guardando, setGuardando] = useState(false);
    const [coordenadas, setCoordenadas] = useState<{ latitud: number; longitud: number } | null>(null);
    const [obteniendoUbicacion, setObteniendoUbicacion] = useState(false);

    // Draft Save - EXCLUIR coordenadas (siempre obtener GPS fresco)
    const formData = watch();
    const { coordenadas: _, ...draftData } = formData || {};

    const { loadDraft, clearDraft } = useDraftSave(
        'draft_asistencia_v2',
        draftData,
        { enabled: !guardando }
    );

    useEffect(() => {
        // Auto-restaurar borrador sin diálogo de confirmación
        const loadPreviousDraft = async () => {
            const draft = await loadDraft();
            if (draft) {
                console.log('[DRAFT] Auto-restaurando borrador de asistencia');
                reset(draft);
            }
        };
        loadPreviousDraft();
        // Siempre obtener GPS fresco (no del borrador)
        obtenerUbicacion();
    }, []);

    const obtenerUbicacion = async () => {
        try {
            setObteniendoUbicacion(true);
            const { status } = await Location.requestForegroundPermissionsAsync();
            if (status !== 'granted') {
                Alert.alert('Permisos requeridos', 'Se necesita acceso a la ubicación.');
                return;
            }
            const location = await Location.getCurrentPositionAsync({ accuracy: Location.Accuracy.High });
            setCoordenadas({
                latitud: location.coords.latitude,
                longitud: location.coords.longitude,
            });
        } catch (error) {
            console.error('Error ubicación:', error);
        } finally {
            setObteniendoUbicacion(false);
        }
    };

    const onSubmit = async (data: any) => {
        // Validar que haya salida activa y ruta
        if (!salidaActiva) {
            Alert.alert('Error', 'No hay salida activa. Debes iniciar una salida primero.');
            return;
        }
        if (!salidaActiva.ruta_codigo) {
            Alert.alert('Error', 'No tienes ruta asignada. Ve a "Cambio de Ruta" para asignar una ruta primero.');
            return;
        }
        if (!data.tipoAsistencia || !data.km) {
            Alert.alert('Error', 'Complete los campos obligatorios (Tipo, Km)');
            return;
        }
        if (vehiculoFields.length === 0) {
            Alert.alert('Error', 'Debe agregar al menos un vehículo');
            return;
        }
        if (!coordenadas) {
            Alert.alert('Error', 'Se requieren coordenadas GPS');
            return;
        }

        try {
            setGuardando(true);
            const asistenciaData = {
                ...data,
                latitud: coordenadas.latitud,
                longitud: coordenadas.longitud,
                unidad_id: salidaActiva.unidad_id,
                salida_unidad_id: salidaActiva.salida_id,
                tipo_situacion: 'ASISTENCIA_VEHICULAR',
                tipo_asistencia: data.tipoAsistencia,
                ruta_id: salidaActiva.ruta_codigo, // Usar ruta de la salida activa
                km: parseFloat(data.km),
            };

            console.log('Enviando asistencia:', asistenciaData);
            // TODO: Call API
            // await api.post('/asistencias', asistenciaData);

            await clearDraft();
            Alert.alert('Éxito', 'Asistencia registrada', [{ text: 'OK', onPress: () => navigation.goBack() }]);
        } catch (error: any) {
            Alert.alert('Error', error.message || 'No se pudo guardar');
        } finally {
            setGuardando(false);
        }
    };

    return (
        <PaperProvider>
            <View style={styles.container}>
                <View style={styles.tabContainer}>
                    <SegmentedButtons
                        value={activeTab}
                        onValueChange={setActiveTab}
                        buttons={[
                            { value: 'general', label: 'General' },
                            { value: 'vehiculos', label: 'Vehículos' },
                            { value: 'recursos', label: 'Recursos' },
                            { value: 'otros', label: 'Otros' },
                        ]}
                    />
                </View>

                <ScrollView style={styles.content}>
                    {activeTab === 'general' && (
                        <View style={styles.section}>
                            <Text style={styles.sectionTitle}>Ubicación y Tipo</Text>

                            {/* GPS Indicator */}
                            <View style={[styles.gpsIndicator, coordenadas ? styles.gpsOk : styles.gpsError]}>
                                <Text style={styles.gpsText}>
                                    {obteniendoUbicacion ? '📍 Obteniendo...' : coordenadas ? `GPS: ${coordenadas.latitud.toFixed(5)}, ${coordenadas.longitud.toFixed(5)}` : '⚠️ Sin GPS'}
                                </Text>
                                {!coordenadas && !obteniendoUbicacion && (
                                    <Button mode="contained-tonal" onPress={obtenerUbicacion} compact>Reintentar</Button>
                                )}
                            </View>

                            <Controller
                                control={control}
                                name="tipoAsistencia"
                                render={({ field: { onChange, value } }) => (
                                    <View style={styles.pickerContainer}>
                                        <Text>Tipo de Asistencia *</Text>
                                        <Picker selectedValue={value} onValueChange={onChange}>
                                            <Picker.Item label="Seleccionar..." value="" />
                                            {TIPOS_ASISTENCIA.map(t => <Picker.Item key={t} label={t} value={t} />)}
                                        </Picker>
                                    </View>
                                )}
                            />

                            {/* Ruta de la salida activa */}
                            <View style={styles.infoBox}>
                                <Text style={styles.infoLabel}>Ruta Actual</Text>
                                <Text style={styles.infoValue}>
                                    {salidaActiva?.ruta_codigo || 'Sin ruta asignada'}
                                </Text>
                                <Text style={styles.infoHelper}>
                                    Para cambiar de ruta, usa la función "Cambio de Ruta" desde el menú principal.
                                </Text>
                            </View>

                            <View style={styles.row}>
                                <Controller
                                    control={control}
                                    name="km"
                                    render={({ field: { onChange, value } }) => (
                                        <PaperInput label="Kilómetro *" value={value} onChangeText={onChange} keyboardType="numeric" style={[styles.input, styles.half]} />
                                    )}
                                />
                                <Controller
                                    control={control}
                                    name="sentido"
                                    render={({ field: { onChange, value } }) => (
                                        <View style={[styles.pickerContainer, styles.half]}>
                                            <Text>Sentido</Text>
                                            <Picker selectedValue={value} onValueChange={onChange}>
                                                <Picker.Item label="Seleccionar..." value="" />
                                                {SENTIDOS.map(s => <Picker.Item key={s.value} label={s.label} value={s.value} />)}
                                            </Picker>
                                        </View>
                                    )}
                                />
                            </View>

                            <Controller
                                control={control}
                                name="jurisdiccion"
                                render={({ field: { onChange, value } }) => (
                                    <PaperInput label="Jurisdicción (Muni/Depto)" value={value} onChangeText={onChange} style={styles.input} />
                                )}
                            />

                            <Text style={[styles.sectionTitle, { marginTop: 20 }]}>Obstrucción de Vía</Text>
                            <ObstruccionManager
                                value={watch('obstruye')}
                                onChange={(val) => setValue('obstruye', val)}
                            />
                        </View>
                    )}

                    {activeTab === 'vehiculos' && (
                        <View style={styles.section}>
                            <Text style={styles.sectionTitle}>Vehículos Involucrados ({vehiculoFields.length})</Text>
                            {vehiculoFields.map((field, index) => (
                                <VehiculoForm
                                    key={field.id}
                                    control={control}
                                    index={index}
                                    onRemove={() => removeVehiculo(index)}
                                />
                            ))}
                            <Button mode="contained" onPress={() => appendVehiculo({})} icon="plus" style={styles.addButton}>
                                Agregar Vehículo
                            </Button>
                        </View>
                    )}

                    {activeTab === 'recursos' && (
                        <View style={styles.section}>
                            <Text style={styles.sectionTitle}>Grúas ({gruaFields.length})</Text>
                            {gruaFields.map((field, index) => (
                                <GruaForm key={field.id} control={control} index={index} onRemove={() => removeGrua(index)} />
                            ))}
                            <Button mode="outlined" onPress={() => appendGrua({})} icon="tow-truck" style={styles.addButton}>
                                Agregar Grúa
                            </Button>

                            <Text style={[styles.sectionTitle, { marginTop: 20 }]}>Ajustadores ({ajustadorFields.length})</Text>
                            {ajustadorFields.map((field, index) => (
                                <AjustadorForm key={field.id} control={control} index={index} onRemove={() => removeAjustador(index)} />
                            ))}
                            <Button mode="outlined" onPress={() => appendAjustador({})} icon="account-tie" style={styles.addButton}>
                                Agregar Ajustador
                            </Button>

                            <Text style={[styles.sectionTitle, { marginTop: 20 }]}>Autoridades y Socorro</Text>
                            <AutoridadSocorroManager
                                tipo="autoridad"
                                seleccionados={watch('autoridadesSeleccionadas')}
                                detalles={watch('detallesAutoridades')}
                                onSelectionChange={(val) => setValue('autoridadesSeleccionadas', val)}
                                onDetallesChange={(val) => setValue('detallesAutoridades', val)}
                            />
                            <AutoridadSocorroManager
                                tipo="socorro"
                                seleccionados={watch('socorroSeleccionado')}
                                detalles={watch('detallesSocorro')}
                                onSelectionChange={(val) => setValue('socorroSeleccionado', val)}
                                onDetallesChange={(val) => setValue('detallesSocorro', val)}
                            />
                        </View>
                    )}

                    {activeTab === 'otros' && (
                        <View style={styles.section}>
                            <Text style={styles.sectionTitle}>Servicio Proporcionado</Text>
                            <Controller
                                control={control}
                                name="servicioProporcionado"
                                render={({ field: { onChange, value } }) => (
                                    <PaperInput label="Servicio Proporcionado" value={value} onChangeText={onChange} multiline numberOfLines={3} style={styles.textArea} />
                                )}
                            />

                            <Text style={[styles.sectionTitle, { marginTop: 20 }]}>Observaciones</Text>
                            <Controller
                                control={control}
                                name="observaciones"
                                render={({ field: { onChange, value } }) => (
                                    <PaperInput label="Observaciones" value={value} onChangeText={onChange} multiline numberOfLines={4} style={styles.textArea} />
                                )}
                            />
                        </View>
                    )}

                    <View style={styles.buttonContainer}>
                        <Button mode="outlined" onPress={() => navigation.goBack()} style={styles.button}>Cancelar</Button>
                        <Button mode="contained" onPress={handleSubmit(onSubmit)} loading={guardando} disabled={guardando} style={styles.button}>
                            Guardar Asistencia
                        </Button>
                    </View>
                </ScrollView>
            </View>
        </PaperProvider>
    );
}

const styles = StyleSheet.create({
    container: { flex: 1, backgroundColor: COLORS.background },
    tabContainer: { padding: 10, backgroundColor: '#fff' },
    content: { padding: 16 },
    section: { marginBottom: 24 },
    sectionTitle: { fontSize: 18, fontWeight: 'bold', marginBottom: 12, color: COLORS.text.primary },
    input: { marginBottom: 10, backgroundColor: '#fff' },
    pickerContainer: { borderWidth: 1, borderColor: '#ddd', borderRadius: 5, marginBottom: 10, padding: 5, backgroundColor: '#fff' },
    row: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center', marginBottom: 10 },
    half: { width: '48%' },
    addButton: { marginTop: 10 },
    textArea: { backgroundColor: '#fff' },
    buttonContainer: { flexDirection: 'row', gap: 10, marginBottom: 40, marginTop: 20 },
    button: { flex: 1 },
    gpsIndicator: { padding: 10, borderRadius: 5, marginBottom: 10, flexDirection: 'row', justifyContent: 'space-between', alignItems: 'center' },
    gpsOk: { backgroundColor: '#e8f5e9', borderWidth: 1, borderColor: '#4caf50' },
    gpsError: { backgroundColor: '#ffebee', borderWidth: 1, borderColor: '#ef5350' },
    gpsText: { fontSize: 12 },
    infoBox: { padding: 12, backgroundColor: '#f5f5f5', borderRadius: 8, borderLeftWidth: 4, borderLeftColor: COLORS.primary, marginBottom: 10 },
    infoLabel: { fontSize: 12, fontWeight: '600', color: '#666', marginBottom: 4 },
    infoValue: { fontSize: 16, fontWeight: 'bold', color: COLORS.text.primary, marginBottom: 4 },
    infoHelper: { fontSize: 11, color: '#999', fontStyle: 'italic' },
});
