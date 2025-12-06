import React, { useState } from 'react';
import {
    View,
    Text,
    TextInput,
    StyleSheet,
    TouchableOpacity,
    ScrollView,
    Modal,
} from 'react-native';
import { Picker } from '@react-native-picker/picker';
import { COLORS } from '../constants/colors';
import {
    TIPOS_VEHICULO,
    MARCAS_VEHICULO,
    ESTADOS_PILOTO,
    NIVELES_DANO,
} from '../constants/situacionTypes';

export interface Vehiculo {
    id: string;
    tipo: string;
    marca: string;
    color: string;
    placa: string;
    estadoPiloto: string;
    nivelDano?: string;
    cargado?: boolean;
    tipoCarga?: string;
}

interface Props {
    vehiculos: Vehiculo[];
    maxVehiculos?: number;
    onAdd: (vehiculo: Vehiculo) => void;
    onEdit: (id: string, vehiculo: Vehiculo) => void;
    onRemove: (id: string) => void;
}

export default function VehiculoManager({ vehiculos, maxVehiculos, onAdd, onEdit, onRemove }: Props) {
    const [modalVisible, setModalVisible] = useState(false);
    const [editingId, setEditingId] = useState<string | null>(null);

    const [tipo, setTipo] = useState('');
    const [marca, setMarca] = useState('');
    const [color, setColor] = useState('');
    const [placa, setPlaca] = useState('');
    const [estadoPiloto, setEstadoPiloto] = useState('Ileso');
    const [nivelDano, setNivelDano] = useState('Leve');
    const [cargado, setCargado] = useState(false);
    const [tipoCarga, setTipoCarga] = useState('');

    const resetForm = () => {
        setTipo('');
        setMarca('');
        setColor('');
        setPlaca('');
        setEstadoPiloto('Ileso');
        setNivelDano('Leve');
        setCargado(false);
        setTipoCarga('');
        setEditingId(null);
    };

    const handleSave = () => {
        if (!tipo || !color) {
            alert('Tipo y color son obligatorios');
            return;
        }

        const vehiculo: Vehiculo = {
            id: editingId || Date.now().toString(),
            tipo,
            marca,
            color,
            placa,
            estadoPiloto,
            nivelDano,
            cargado,
            tipoCarga: cargado ? tipoCarga : undefined,
        };

        if (editingId) {
            onEdit(editingId, vehiculo);
        } else {
            onAdd(vehiculo);
        }

        resetForm();
        setModalVisible(false);
    };

    const handleEdit = (vehiculo: Vehiculo) => {
        setEditingId(vehiculo.id);
        setTipo(vehiculo.tipo);
        setMarca(vehiculo.marca);
        setColor(vehiculo.color);
        setPlaca(vehiculo.placa);
        setEstadoPiloto(vehiculo.estadoPiloto);
        setNivelDano(vehiculo.nivelDano || 'Leve');
        setCargado(vehiculo.cargado || false);
        setTipoCarga(vehiculo.tipoCarga || '');
        setModalVisible(true);
    };

    const puedeAgregarMas = !maxVehiculos || vehiculos.length < maxVehiculos;
    const tituloVehiculos = maxVehiculos
        ? `Veh\u00edculos (${vehiculos.length}/${maxVehiculos})`
        : `Veh\u00edculos Involucrados (${vehiculos.length})`;

    return (
        <View style={styles.container}>
            <View style={styles.header}>
                <Text style={styles.title}>{tituloVehiculos}</Text>
                <TouchableOpacity
                    style={[styles.addButton, !puedeAgregarMas && styles.addButtonDisabled]}
                    onPress={() => {
                        if (!puedeAgregarMas) {
                            alert(`Solo se permite ${maxVehiculos} veh\u00edculo${maxVehiculos === 1 ? '' : 's'} para este tipo de situaci\u00f3n`);
                            return;
                        }
                        resetForm();
                        setModalVisible(true);
                    }}
                    disabled={!puedeAgregarMas}
                >
                    <Text style={[styles.addButtonText, !puedeAgregarMas && styles.addButtonTextDisabled]}>+ Agregar</Text>
                </TouchableOpacity>
            </View>

            {vehiculos.map((vehiculo, index) => (
                <View key={vehiculo.id} style={styles.vehiculoCard}>
                    <View style={styles.vehiculoHeader}>
                        <Text style={styles.vehiculoNumero}>Vehículo {index + 1}</Text>
                        <View style={styles.vehiculoActions}>
                            <TouchableOpacity
                                onPress={() => handleEdit(vehiculo)}
                                style={styles.editButton}
                            >
                                <Text style={styles.editButtonText}>✏️</Text>
                            </TouchableOpacity>
                            <TouchableOpacity
                                onPress={() => onRemove(vehiculo.id)}
                                style={styles.removeButton}
                            >
                                <Text style={styles.removeButtonText}>🗑️</Text>
                            </TouchableOpacity>
                        </View>
                    </View>
                    <Text style={styles.vehiculoInfo}>
                        {vehiculo.tipo} {vehiculo.marca} {vehiculo.color}
                    </Text>
                    <Text style={styles.vehiculoInfo}>Placa: {vehiculo.placa || 'N/A'}</Text>
                    <Text style={styles.vehiculoInfo}>Piloto: {vehiculo.estadoPiloto}</Text>
                </View>
            ))}

            <Modal
                visible={modalVisible}
                animationType="slide"
                transparent={true}
                onRequestClose={() => {
                    resetForm();
                    setModalVisible(false);
                }}
            >
                <View style={styles.modalOverlay}>
                    <View style={styles.modalContent}>
                        <ScrollView>
                            <Text style={styles.modalTitle}>
                                {editingId ? 'Editar Vehículo' : 'Agregar Vehículo'}
                            </Text>

                            <Text style={styles.label}>Tipo de Vehículo *</Text>
                            <Picker
                                selectedValue={tipo}
                                onValueChange={setTipo}
                                style={styles.picker}
                            >
                                <Picker.Item label="Seleccionar..." value="" />
                                {TIPOS_VEHICULO.map((t) => (
                                    <Picker.Item key={t} label={t} value={t} />
                                ))}
                            </Picker>

                            <Text style={styles.label}>Marca</Text>
                            <Picker
                                selectedValue={marca}
                                onValueChange={setMarca}
                                style={styles.picker}
                            >
                                <Picker.Item label="Seleccionar..." value="" />
                                {MARCAS_VEHICULO.map((m) => (
                                    <Picker.Item key={m} label={m} value={m} />
                                ))}
                            </Picker>

                            <Text style={styles.label}>Color *</Text>
                            <TextInput
                                style={styles.input}
                                value={color}
                                onChangeText={setColor}
                                placeholder="Ej: Rojo, Azul, Blanco"
                            />

                            <Text style={styles.label}>Placa</Text>
                            <TextInput
                                style={styles.input}
                                value={placa}
                                onChangeText={setPlaca}
                                placeholder="Ej: P-123ABC"
                                autoCapitalize="characters"
                            />

                            <Text style={styles.label}>Estado del Piloto *</Text>
                            <Picker
                                selectedValue={estadoPiloto}
                                onValueChange={setEstadoPiloto}
                                style={styles.picker}
                            >
                                {ESTADOS_PILOTO.map((e) => (
                                    <Picker.Item key={e} label={e} value={e} />
                                ))}
                            </Picker>

                            <Text style={styles.label}>Nivel de Daño</Text>
                            <Picker
                                selectedValue={nivelDano}
                                onValueChange={setNivelDano}
                                style={styles.picker}
                            >
                                {NIVELES_DANO.map((n) => (
                                    <Picker.Item key={n} label={n} value={n} />
                                ))}
                            </Picker>

                            <View style={styles.checkboxRow}>
                                <TouchableOpacity
                                    style={styles.checkbox}
                                    onPress={() => setCargado(!cargado)}
                                >
                                    <View style={[styles.checkboxBox, cargado && styles.checkboxBoxChecked]}>
                                        {cargado && <Text style={styles.checkboxCheck}>✓</Text>}
                                    </View>
                                    <Text style={styles.checkboxLabel}>Vehículo cargado</Text>
                                </TouchableOpacity>
                            </View>

                            {cargado && (
                                <>
                                    <Text style={styles.label}>Tipo de Carga</Text>
                                    <TextInput
                                        style={styles.input}
                                        value={tipoCarga}
                                        onChangeText={setTipoCarga}
                                        placeholder="Ej: Arena, Cemento, Madera"
                                    />
                                </>
                            )}

                            <View style={styles.modalButtons}>
                                <TouchableOpacity
                                    style={[styles.modalButton, styles.cancelButton]}
                                    onPress={() => {
                                        resetForm();
                                        setModalVisible(false);
                                    }}
                                >
                                    <Text style={styles.cancelButtonText}>Cancelar</Text>
                                </TouchableOpacity>
                                <TouchableOpacity
                                    style={[styles.modalButton, styles.saveButton]}
                                    onPress={handleSave}
                                >
                                    <Text style={styles.saveButtonText}>Guardar</Text>
                                </TouchableOpacity>
                            </View>
                        </ScrollView>
                    </View>
                </View>
            </Modal>
        </View>
    );
}

const styles = StyleSheet.create({
    container: {
        marginVertical: 16,
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 12,
    },
    title: {
        fontSize: 16,
        fontWeight: '600',
        color: COLORS.text.primary,
    },
    addButton: {
        backgroundColor: COLORS.primary,
        paddingVertical: 6,
        paddingHorizontal: 12,
        borderRadius: 6,
    },
    addButtonText: {
        color: COLORS.white,
        fontSize: 14,
        fontWeight: '600',
    },
    addButtonDisabled: {
        backgroundColor: COLORS.border,
        opacity: 0.5,
    },
    addButtonTextDisabled: {
        color: COLORS.text.disabled,
    },
    vehiculoCard: {
        backgroundColor: COLORS.white,
        padding: 12,
        borderRadius: 8,
        marginBottom: 8,
        borderWidth: 1,
        borderColor: COLORS.border,
    },
    vehiculoHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 8,
    },
    vehiculoNumero: {
        fontSize: 14,
        fontWeight: '600',
        color: COLORS.primary,
    },
    vehiculoActions: {
        flexDirection: 'row',
        gap: 8,
    },
    editButton: {
        padding: 4,
    },
    editButtonText: {
        fontSize: 16,
    },
    removeButton: {
        padding: 4,
    },
    removeButtonText: {
        fontSize: 16,
    },
    vehiculoInfo: {
        fontSize: 13,
        color: COLORS.text.secondary,
        marginBottom: 2,
    },
    modalOverlay: {
        flex: 1,
        backgroundColor: 'rgba(0, 0, 0, 0.5)',
        justifyContent: 'center',
        padding: 20,
    },
    modalContent: {
        backgroundColor: COLORS.white,
        borderRadius: 12,
        padding: 20,
        maxHeight: '90%',
    },
    modalTitle: {
        fontSize: 20,
        fontWeight: '600',
        color: COLORS.text.primary,
        marginBottom: 20,
    },
    label: {
        fontSize: 14,
        fontWeight: '500',
        color: COLORS.text.primary,
        marginBottom: 6,
        marginTop: 12,
    },
    input: {
        borderWidth: 1,
        borderColor: COLORS.border,
        borderRadius: 8,
        padding: 12,
        fontSize: 14,
        backgroundColor: COLORS.white,
    },
    picker: {
        borderWidth: 1,
        borderColor: COLORS.border,
        borderRadius: 8,
    },
    checkboxRow: {
        marginVertical: 12,
    },
    checkbox: {
        flexDirection: 'row',
        alignItems: 'center',
    },
    checkboxBox: {
        width: 24,
        height: 24,
        borderWidth: 2,
        borderColor: COLORS.border,
        borderRadius: 4,
        marginRight: 8,
        justifyContent: 'center',
        alignItems: 'center',
    },
    checkboxBoxChecked: {
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
    modalButtons: {
        flexDirection: 'row',
        gap: 12,
        marginTop: 24,
    },
    modalButton: {
        flex: 1,
        paddingVertical: 12,
        borderRadius: 8,
        alignItems: 'center',
    },
    cancelButton: {
        backgroundColor: COLORS.background,
        borderWidth: 1,
        borderColor: COLORS.border,
    },
    cancelButtonText: {
        color: COLORS.text.primary,
        fontSize: 14,
        fontWeight: '600',
    },
    saveButton: {
        backgroundColor: COLORS.primary,
    },
    saveButtonText: {
        color: COLORS.white,
        fontSize: 14,
        fontWeight: '600',
    },
});
