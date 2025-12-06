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

export interface Ajustador {
    id: string;
    nombre: string;
    empresa: string;
    telefono?: string;
    asignado_a_vehiculo_idx?: number;
}

interface Props {
    ajustadores: Ajustador[];
    vehiculos: Array<{ id: string; tipo: string; placa: string }>;
    onAdd: (ajustador: Ajustador) => void;
    onEdit: (id: string, ajustador: Ajustador) => void;
    onRemove: (id: string) => void;
}

export default function AjustadorManager({ ajustadores, vehiculos, onAdd, onEdit, onRemove }: Props) {
    const [modalVisible, setModalVisible] = useState(false);
    const [editingId, setEditingId] = useState<string | null>(null);

    const [nombre, setNombre] = useState('');
    const [empresa, setEmpresa] = useState('');
    const [telefono, setTelefono] = useState('');
    const [asignadoAIdx, setAsignadoAIdx] = useState<number>(-1);

    const resetForm = () => {
        setNombre('');
        setEmpresa('');
        setTelefono('');
        setAsignadoAIdx(-1);
        setEditingId(null);
    };

    const handleSave = () => {
        if (!nombre || !empresa) {
            alert('Nombre y empresa son obligatorios');
            return;
        }

        const ajustador: Ajustador = {
            id: editingId || Date.now().toString(),
            nombre,
            empresa,
            telefono,
            asignado_a_vehiculo_idx: asignadoAIdx >= 0 ? asignadoAIdx : undefined,
        };

        if (editingId) {
            onEdit(editingId, ajustador);
        } else {
            onAdd(ajustador);
        }

        resetForm();
        setModalVisible(false);
    };

    const handleEdit = (ajustador: Ajustador) => {
        setEditingId(ajustador.id);
        setNombre(ajustador.nombre);
        setEmpresa(ajustador.empresa);
        setTelefono(ajustador.telefono || '');
        setAsignadoAIdx(ajustador.asignado_a_vehiculo_idx ?? -1);
        setModalVisible(true);
    };

    const getVehiculoAsignado = (idx?: number) => {
        if (idx === undefined || idx < 0 || idx >= vehiculos.length) return 'Sin asignar';
        const vehiculo = vehiculos[idx];
        return `${vehiculo.tipo} ${vehiculo.placa}`;
    };

    return (
        <View style={styles.container}>
            <View style={styles.header}>
                <Text style={styles.title}>Ajustadores Involucrados ({ajustadores.length})</Text>
                <TouchableOpacity
                    style={styles.addButton}
                    onPress={() => {
                        resetForm();
                        setModalVisible(true);
                    }}
                >
                    <Text style={styles.addButtonText}>+ Agregar Ajustador</Text>
                </TouchableOpacity>
            </View>

            {ajustadores.map((ajustador, index) => (
                <View key={ajustador.id} style={styles.ajustadorCard}>
                    <View style={styles.ajustadorHeader}>
                        <Text style={styles.ajustadorNumero}>Ajustador {index + 1}</Text>
                        <View style={styles.ajustadorActions}>
                            <TouchableOpacity
                                onPress={() => handleEdit(ajustador)}
                                style={styles.editButton}
                            >
                                <Text style={styles.editButtonText}>✏️</Text>
                            </TouchableOpacity>
                            <TouchableOpacity
                                onPress={() => onRemove(ajustador.id)}
                                style={styles.removeButton}
                            >
                                <Text style={styles.removeButtonText}>🗑️</Text>
                            </TouchableOpacity>
                        </View>
                    </View>
                    <Text style={styles.ajustadorInfo}>{ajustador.nombre}</Text>
                    <Text style={styles.ajustadorInfo}>Empresa: {ajustador.empresa}</Text>
                    {ajustador.telefono && <Text style={styles.ajustadorInfo}>Tel: {ajustador.telefono}</Text>}
                    <Text style={styles.ajustadorInfo}>Asignado a: {getVehiculoAsignado(ajustador.asignado_a_vehiculo_idx)}</Text>
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
                                {editingId ? 'Editar Ajustador' : 'Agregar Ajustador'}
                            </Text>

                            <Text style={styles.label}>Nombre del Ajustador *</Text>
                            <TextInput
                                style={styles.input}
                                value={nombre}
                                onChangeText={setNombre}
                                placeholder="Nombre completo"
                            />

                            <Text style={styles.label}>Empresa Aseguradora *</Text>
                            <TextInput
                                style={styles.input}
                                value={empresa}
                                onChangeText={setEmpresa}
                                placeholder="Ej: Seguros G&T, El Roble, etc."
                            />

                            <Text style={styles.label}>Teléfono</Text>
                            <TextInput
                                style={styles.input}
                                value={telefono}
                                onChangeText={setTelefono}
                                placeholder="Ej: 1234-5678"
                                keyboardType="phone-pad"
                            />

                            <Text style={styles.label}>Asignado a vehículo</Text>
                            <Picker
                                selectedValue={asignadoAIdx}
                                onValueChange={setAsignadoAIdx}
                                style={styles.picker}
                            >
                                <Picker.Item label="Sin asignar" value={-1} />
                                {vehiculos.map((vehiculo, idx) => (
                                    <Picker.Item
                                        key={vehiculo.id}
                                        label={`Vehículo ${idx + 1}: ${vehiculo.tipo} ${vehiculo.placa}`}
                                        value={idx}
                                    />
                                ))}
                            </Picker>

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
    ajustadorCard: {
        backgroundColor: COLORS.white,
        padding: 12,
        borderRadius: 8,
        marginBottom: 8,
        borderWidth: 1,
        borderColor: COLORS.border,
    },
    ajustadorHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 8,
    },
    ajustadorNumero: {
        fontSize: 14,
        fontWeight: '600',
        color: COLORS.primary,
    },
    ajustadorActions: {
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
    ajustadorInfo: {
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
        maxHeight: '80%',
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
