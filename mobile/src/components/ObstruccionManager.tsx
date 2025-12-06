import React, { useState } from 'react';
import {
    View,
    Text,
    TextInput,
    StyleSheet,
    TouchableOpacity,
} from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { COLORS } from '../constants/colors';

interface Props {
    value: string;
    onChange: (descripcion: string) => void;
}

export default function ObstruccionManager({ value, onChange }: Props) {
    const [obstruyeVia, setObstruyeVia] = useState(!!value);
    const [tipoObstruccion, setTipoObstruccion] = useState<'fuera' | 'parcial' | 'total'>('parcial');
    const [carriles, setCarriles] = useState('');
    const [porcentaje, setPorcentaje] = useState('50');
    const [descripcionManual, setDescripcionManual] = useState(value);

    const generarDescripcion = () => {
        if (!obstruyeVia) {
            onChange('');
            setDescripcionManual('');
            return;
        }

        let desc = '';

        if (tipoObstruccion === 'fuera') {
            desc = 'Vehículo fuera de la vía';
        } else if (tipoObstruccion === 'total') {
            desc = 'Obstrucción total de la vía';
        } else {
            // Obstrucción parcial
            if (carriles) {
                desc = `${carriles} obstruido en un ${porcentaje}%`;
            } else {
                desc = `Obstrucción parcial del ${porcentaje}%`;
            }
        }

        onChange(desc);
        setDescripcionManual(desc);
    };

    const handleObstruyeChange = (nuevoValor: boolean) => {
        setObstruyeVia(nuevoValor);
        if (!nuevoValor) {
            onChange('');
            setDescripcionManual('');
        }
    };

    return (
        <View style={styles.container}>
            <Text style={styles.sectionTitle}>Obstrucción de Vía</Text>

            <TouchableOpacity
                style={styles.checkboxItem}
                onPress={() => handleObstruyeChange(!obstruyeVia)}
            >
                <View style={[styles.checkbox, obstruyeVia && styles.checkboxChecked]}>
                    {obstruyeVia && <Text style={styles.checkboxCheck}>✓</Text>}
                </View>
                <Text style={styles.checkboxLabel}>¿Obstruye la vía?</Text>
            </TouchableOpacity>

            {obstruyeVia && (
                <View style={styles.detallesContainer}>
                    <Text style={styles.label}>Tipo de Obstrucción</Text>
                    <Picker
                        selectedValue={tipoObstruccion}
                        onValueChange={(val) => setTipoObstruccion(val)}
                        style={styles.picker}
                    >
                        <Picker.Item label="Vehículo fuera de la vía" value="fuera" />
                        <Picker.Item label="Obstrucción parcial" value="parcial" />
                        <Picker.Item label="Obstrucción total" value="total" />
                    </Picker>

                    {tipoObstruccion === 'parcial' && (
                        <>
                            <Text style={styles.label}>Carril(es) afectado(s)</Text>
                            <TextInput
                                style={styles.input}
                                value={carriles}
                                onChangeText={setCarriles}
                                placeholder="Ej: Carril derecho, Carriles izquierdo y central"
                            />

                            <Text style={styles.label}>Porcentaje de obstrucción (%)</Text>
                            <Picker
                                selectedValue={porcentaje}
                                onValueChange={setPorcentaje}
                                style={styles.picker}
                            >
                                <Picker.Item label="25%" value="25" />
                                <Picker.Item label="50%" value="50" />
                                <Picker.Item label="75%" value="75" />
                                <Picker.Item label="100%" value="100" />
                            </Picker>
                        </>
                    )}

                    <TouchableOpacity
                        style={styles.generarButton}
                        onPress={generarDescripcion}
                    >
                        <Text style={styles.generarButtonText}>Generar Descripción</Text>
                    </TouchableOpacity>

                    <Text style={styles.label}>Descripción generada (puede editarse)</Text>
                    <TextInput
                        style={[styles.input, styles.textArea]}
                        value={descripcionManual}
                        onChangeText={(text) => {
                            setDescripcionManual(text);
                            onChange(text);
                        }}
                        placeholder="Descripción de la obstrucción..."
                        multiline
                        numberOfLines={3}
                    />
                </View>
            )}
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        marginVertical: 12,
    },
    sectionTitle: {
        fontSize: 18,
        fontWeight: '600',
        color: COLORS.text.primary,
        marginBottom: 12,
    },
    checkboxItem: {
        flexDirection: 'row',
        alignItems: 'center',
        marginBottom: 12,
    },
    checkbox: {
        width: 24,
        height: 24,
        borderWidth: 2,
        borderColor: COLORS.border,
        borderRadius: 4,
        marginRight: 8,
        justifyContent: 'center',
        alignItems: 'center',
    },
    checkboxChecked: {
        backgroundColor: COLORS.primary,
        borderColor: COLORS.primary,
    },
    checkboxCheck: {
        color: COLORS.white,
        fontSize: 16,
        fontWeight: 'bold',
    },
    checkboxLabel: {
        fontSize: 14,
        color: COLORS.text.primary,
    },
    detallesContainer: {
        backgroundColor: COLORS.background,
        padding: 12,
        borderRadius: 8,
        marginTop: 8,
    },
    label: {
        fontSize: 14,
        fontWeight: '500',
        color: COLORS.text.primary,
        marginBottom: 6,
        marginTop: 8,
    },
    input: {
        borderWidth: 1,
        borderColor: COLORS.border,
        borderRadius: 8,
        padding: 12,
        fontSize: 14,
        backgroundColor: COLORS.white,
    },
    textArea: {
        minHeight: 80,
        textAlignVertical: 'top',
    },
    picker: {
        borderWidth: 1,
        borderColor: COLORS.border,
        borderRadius: 8,
        backgroundColor: COLORS.white,
    },
    generarButton: {
        backgroundColor: COLORS.success,
        paddingVertical: 10,
        paddingHorizontal: 16,
        borderRadius: 8,
        alignItems: 'center',
        marginTop: 12,
    },
    generarButtonText: {
        color: COLORS.white,
        fontSize: 14,
        fontWeight: '600',
    },
});
