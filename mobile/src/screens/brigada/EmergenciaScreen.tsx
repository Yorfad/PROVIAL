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
    TIPOS_EMERGENCIA,
    SENTIDOS,
} from '../../constants/situacionTypes';
import { useAuthStore } from '../../store/authStore';
import AutoridadSocorroManager, { DetalleAutoridad, DetallesSocorro } from '../../components/AutoridadSocorroManager';
import ObstruccionManager from '../../components/ObstruccionManager';

// New Imports
import { useForm, Controller } from 'react-hook-form';
import { Provider as PaperProvider, SegmentedButtons, TextInput as PaperInput, Button, Switch } from 'react-native-paper';

export default function EmergenciaScreen() {
    const navigation = useNavigation();
    const { salidaActiva } = useAuthStore();

    // Form Setup
    const { control, handleSubmit, setValue, watch, reset, getValues } = useForm({
        defaultValues: {
            tipoEmergencia: '',
            rutaId: null, // Se auto-asignará desde salida activa
            kmInicio: '',
            kmFin: '',
            esRango: false,
            sentido: '',
            autoridadesSeleccionadas: [],
            detallesAutoridades: {},
            socorroSeleccionado: [],
            detallesSocorro: {},
            obstruye: '',
            observaciones: '',
            jurisdiccion: '', // New field
        }
    });

    // Auto-asignar ruta desde salida activa
    useEffect(() => {
        // Note: rutaId se obtiene dinámicamente desde salidaActiva, no se necesita asignar en el form
        // La ruta se mostrará solo como información de solo lectura
    }, [salidaActiva]);

    // Watchers
    const esRango = watch('esRango');

    // UI State
    const [activeTab, setActiveTab] = useState('general');
    const [guardando, setGuardando] = useState(false);
    const [coordenadas, setCoordenadas] = useState<{ latitud: number; longitud: number } | null>(null);
    const [obteniendoUbicacion, setObteniendoUbicacion] = useState(false);

    // Draft Save - EXCLUIR coordenadas (siempre obtener GPS fresco)
    const formData = watch();
    const { coordenadas: _, ...draftData } = formData || {};

    const { loadDraft, clearDraft } = useDraftSave(
        'draft_emergencia_v2',
        draftData,
        { enabled: !guardando }
    );

    useEffect(() => {
        // Auto-restaurar borrador sin diálogo de confirmación
        const loadPreviousDraft = async () => {
            const draft = await loadDraft();
            if (draft) {
                console.log('[DRAFT] Auto-restaurando borrador de emergencia');
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
        if (!data.tipoEmergencia || !data.kmInicio) {
            Alert.alert('Error', 'Complete los campos obligatorios (Tipo, Km)');
            return;
        }
        if (data.esRango && !data.kmFin) {
            Alert.alert('Error', 'Debes ingresar el kilómetro final del rango');
            return;
        }
        if (!coordenadas) {
            Alert.alert('Error', 'Se requieren coordenadas GPS');
            return;
        }

        try {
            setGuardando(true);
            const emergenciaData = {
                ...data,
                latitud: coordenadas.latitud,
                longitud: coordenadas.longitud,
                unidad_id: salidaActiva.unidad_id,
                salida_unidad_id: salidaActiva.salida_id,
                tipo_situacion: 'OTROS',
                tipo_emergencia: data.tipoEmergencia,
                ruta_id: salidaActiva.ruta_codigo, // Usar ruta de la salida activa
                km: parseFloat(data.kmInicio),
                km_fin: data.esRango ? parseFloat(data.kmFin) : null,
            };

            console.log('Enviando emergencia:', emergenciaData);
            // TODO: Call API
            // await api.post('/emergencias', emergenciaData);

            await clearDraft();
            Alert.alert('Éxito', 'Emergencia registrada', [{ text: 'OK', onPress: () => navigation.goBack() }]);
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
                                name="tipoEmergencia"
                                render={({ field: { onChange, value } }) => (
                                    <View style={styles.pickerContainer}>
                                        <Text>Tipo de Emergencia *</Text>
                                        <Picker selectedValue={value} onValueChange={onChange}>
                                            <Picker.Item label="Seleccionar..." value="" />
                                            {TIPOS_EMERGENCIA.map(t => <Picker.Item key={t} label={t} value={t} />)}
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

                            <View style={styles.checkboxRow}>
                                <Controller
                                    control={control}
                                    name="esRango"
                                    render={({ field: { onChange, value } }) => (
                                        <TouchableOpacity
                                            style={styles.checkboxItem}
                                            onPress={() => onChange(!value)}
                                        >
                                            <View style={[styles.checkbox, value && styles.checkboxChecked]}>
                                                {value && <Text style={styles.checkboxCheck}>✓</Text>}
                                            </View>
                                            <Text style={styles.checkboxLabel}>Área afectada (rango de kilómetros)</Text>
                                        </TouchableOpacity>
                                    )}
                                />
                            </View>

                            <View style={styles.row}>
                                <Controller
                                    control={control}
                                    name="kmInicio"
                                    render={({ field: { onChange, value } }) => (
                                        <PaperInput
                                            label={esRango ? "Km Inicial *" : "Kilómetro *"}
                                            value={value}
                                            onChangeText={onChange}
                                            keyboardType="numeric"
                                            style={[styles.input, esRango ? styles.half : { width: '100%' }]}
                                        />
                                    )}
                                />
                                {esRango && (
                                    <Controller
                                        control={control}
                                        name="kmFin"
                                        render={({ field: { onChange, value } }) => (
                                            <PaperInput
                                                label="Km Final *"
                                                value={value}
                                                onChangeText={onChange}
                                                keyboardType="numeric"
                                                style={[styles.input, styles.half]}
                                            />
                                        )}
                                    />
                                )}
                            </View>

                            <Controller
                                control={control}
                                name="sentido"
                                render={({ field: { onChange, value } }) => (
                                    <View style={styles.pickerContainer}>
                                        <Text>Sentido</Text>
                                        <Picker selectedValue={value} onValueChange={onChange}>
                                            <Picker.Item label="Seleccionar..." value="" />
                                            {SENTIDOS.map(s => <Picker.Item key={s.value} label={s.label} value={s.value} />)}
                                        </Picker>
                                    </View>
                                )}
                            />

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

                    {activeTab === 'recursos' && (
                        <View style={styles.section}>
                            <Text style={styles.sectionTitle}>Autoridades y Socorro</Text>
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
                            <Text style={styles.sectionTitle}>Observaciones</Text>
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
                            Guardar Emergencia
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
    checkboxRow: { marginBottom: 10 },
    checkboxItem: { flexDirection: 'row', alignItems: 'center', marginBottom: 8 },
    checkbox: { width: 24, height: 24, borderWidth: 2, borderColor: COLORS.border, borderRadius: 4, marginRight: 8, justifyContent: 'center', alignItems: 'center' },
    checkboxChecked: { backgroundColor: COLORS.primary, borderColor: COLORS.primary },
    checkboxCheck: { color: COLORS.white, fontSize: 16, fontWeight: 'bold' },
    checkboxLabel: { fontSize: 14, color: COLORS.text.primary, flex: 1 },
});
