import React, { useState } from 'react';
import {
    View,
    Text,
    TextInput,
    StyleSheet,
    ScrollView,
    TouchableOpacity,
    Alert,
    ActivityIndicator,
} from 'react-native';
import { useNavigation } from '@react-navigation/native';
import { COLORS } from '../../constants/colors';
import { useAuthStore } from '../../store/authStore';
import RutaSelector from '../../components/RutaSelector';
import FuelSelector from '../../components/FuelSelector';
import { useSituacionesStore } from '../../store/situacionesStore';

export default function SalidaSedeScreen() {
    const navigation = useNavigation();
    const { asignacion, salidaActiva } = useAuthStore();
    const { createSituacion } = useSituacionesStore();

    const [rutaId, setRutaId] = useState<number | undefined>(asignacion?.ruta_asignada_id);
    const [kmInicial, setKmInicial] = useState('0');
    const [combustibleFraccion, setCombustibleFraccion] = useState<string | null>(null);
    const [combustibleDecimal, setCombustibleDecimal] = useState<number>(0);
    const [observaciones, setObservaciones] = useState('');
    const [guardando, setGuardando] = useState(false);

    const handleCombustibleChange = (fraccion: string, decimal: number) => {
        setCombustibleFraccion(fraccion);
        setCombustibleDecimal(decimal);
    };

    const handleGuardar = async () => {
        if (!rutaId) {
            Alert.alert('Error', 'Debes seleccionar la ruta de patrullaje');
            return;
        }

        if (!kmInicial) {
            Alert.alert('Error', 'Debes ingresar el kilómetro inicial');
            return;
        }

        if (!combustibleFraccion) {
            Alert.alert('Error', 'Debes indicar el nivel de combustible');
            return;
        }

        const salidaData = {
            tipo_situacion: 'SALIDA_SEDE' as const,
            ruta_id: rutaId,
            km: parseFloat(kmInicial),
            unidad_id: asignacion?.unidad_id,
            salida_unidad_id: salidaActiva?.salida_id,
            descripcion: `Salida de sede - Inicio de patrullaje`,
            observaciones,
            combustible: combustibleDecimal,
            combustible_fraccion: combustibleFraccion,
        };

        try {
            setGuardando(true);
            console.log('Salida de sede a guardar:', salidaData);

            await createSituacion(salidaData);

            Alert.alert('Éxito', 'Salida de sede registrada correctamente', [
                {
                    text: 'OK',
                    onPress: () => navigation.navigate('BrigadaHome' as never),
                },
            ]);
        } catch (error: any) {
            console.error('Error al guardar salida de sede:', error);
            Alert.alert('Error', error.message || 'No se pudo registrar la salida de sede');
        } finally {
            setGuardando(false);
        }
    };

    return (
        <ScrollView style={styles.container}>
            <View style={styles.content}>
                <View style={styles.header}>
                    <Text style={styles.title}>Salida de Sede</Text>
                    <Text style={styles.subtitle}>
                        Registra el inicio de tu patrullaje
                    </Text>
                </View>

                <View style={styles.infoCard}>
                    <Text style={styles.infoLabel}>Unidad:</Text>
                    <Text style={styles.infoValue}>{asignacion?.unidad_codigo}</Text>
                </View>

                {/* Ruta */}
                <View style={styles.section}>
                    <RutaSelector
                        value={rutaId}
                        onChange={(id) => setRutaId(id)}
                        label="Ruta de Patrullaje *"
                        required
                    />
                </View>

                {/* KM Inicial */}
                <View style={styles.section}>
                    <Text style={styles.label}>Kilómetro Inicial *</Text>
                    <TextInput
                        style={styles.input}
                        value={kmInicial}
                        onChangeText={setKmInicial}
                        placeholder="Ej: 0 (desde la sede)"
                        keyboardType="decimal-pad"
                    />
                    <Text style={styles.hint}>
                        Generalmente es 0 al salir de la sede
                    </Text>
                </View>

                {/* Combustible */}
                <View style={styles.section}>
                    <FuelSelector
                        value={combustibleFraccion}
                        onChange={handleCombustibleChange}
                        label="Nivel de Combustible"
                        required
                    />
                </View>

                {/* Observaciones */}
                <View style={styles.section}>
                    <Text style={styles.label}>Observaciones</Text>
                    <TextInput
                        style={[styles.input, styles.textArea]}
                        value={observaciones}
                        onChangeText={setObservaciones}
                        placeholder="Observaciones opcionales sobre el inicio del patrullaje..."
                        multiline
                        numberOfLines={4}
                    />
                </View>

                {/* Botón Guardar */}
                <TouchableOpacity
                    style={[styles.saveButton, guardando && styles.saveButtonDisabled]}
                    onPress={handleGuardar}
                    disabled={guardando}
                >
                    {guardando ? (
                        <ActivityIndicator color={COLORS.white} />
                    ) : (
                        <Text style={styles.saveButtonText}>Iniciar Patrullaje</Text>
                    )}
                </TouchableOpacity>
            </View>
        </ScrollView>
    );
}

const styles = StyleSheet.create({
    container: {
        flex: 1,
        backgroundColor: COLORS.background,
    },
    content: {
        padding: 16,
    },
    header: {
        marginBottom: 24,
    },
    title: {
        fontSize: 28,
        fontWeight: '700',
        color: COLORS.text.primary,
        marginBottom: 8,
    },
    subtitle: {
        fontSize: 16,
        color: COLORS.text.secondary,
    },
    infoCard: {
        backgroundColor: COLORS.primary + '15',
        padding: 16,
        borderRadius: 12,
        borderLeftWidth: 4,
        borderLeftColor: COLORS.primary,
        marginBottom: 24,
        flexDirection: 'row',
        alignItems: 'center',
    },
    infoLabel: {
        fontSize: 16,
        fontWeight: '600',
        color: COLORS.text.primary,
        marginRight: 8,
    },
    infoValue: {
        fontSize: 20,
        fontWeight: '700',
        color: COLORS.primary,
    },
    section: {
        marginBottom: 24,
    },
    label: {
        fontSize: 16,
        fontWeight: '600',
        color: COLORS.text.primary,
        marginBottom: 8,
    },
    input: {
        borderWidth: 1,
        borderColor: COLORS.border,
        borderRadius: 12,
        padding: 16,
        fontSize: 16,
        backgroundColor: COLORS.white,
        color: COLORS.text.primary,
    },
    textArea: {
        minHeight: 100,
        textAlignVertical: 'top',
    },
    hint: {
        fontSize: 14,
        color: COLORS.text.secondary,
        marginTop: 6,
        fontStyle: 'italic',
    },
    saveButton: {
        backgroundColor: COLORS.primary,
        padding: 18,
        borderRadius: 12,
        alignItems: 'center',
        marginTop: 24,
        marginBottom: 40,
    },
    saveButtonDisabled: {
        opacity: 0.6,
    },
    saveButtonText: {
        color: COLORS.white,
        fontSize: 18,
        fontWeight: '700',
    },
});
