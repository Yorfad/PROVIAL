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
import { TIPOS_VEHICULO, MARCAS_VEHICULO } from '../constants/situacionTypes';

export interface Grua {
    id: string;
    tipo: string;
    placa: string;
    empresa?: string;
    asignado_a_vehiculo_idx?: number;
}

interface Props {
    gruas: Grua[];
    vehiculos: Array<{ id: string; tipo: string; placa: string }>;
    onAdd: (grua: Grua) => void;
    onEdit: (id: string, grua: Grua) => void;
    onRemove: (id: string) => void;
}

export default function GruaManager({ gruas, vehiculos, onAdd, onEdit, onRemove }: Props) {
    const [modalVisible, setModalVisible] = useState(false);
    const [editingId, setEditingId] = useState<string | null>(null);

    const [tipo, setTipo] = useState('');
    const [placa, setPlaca] = useState('');
    const [empresa, setEmpresa] = useState('');
    const [asignadoAIdx, setAsignadoAIdx] = useState<number>(-1);

    const resetForm = () => {
        setTipo('Grúa');
        setPlaca('');
        setEmpresa('');
        setAsignadoAIdx(-1);
        setEditingId(null);
    };

    const handleSave = () => {
        if (!tipo || !placa) {
            alert('Tipo y placa son obligatorios');
            return;
        }

        const grua: Grua = {
            id: editingId || Date.now().toString(),
            tipo,
            placa,
            empresa,
            asignado_a_vehiculo_idx: asignadoAIdx >= 0 ? asignadoAIdx : undefined,
        };

        if (editingId) {
            onEdit(editingId, grua);
        } else {
            onAdd(grua);
        }

        resetForm();
        setModalVisible(false);
    };

    const handleEdit = (grua: Grua) => {
        setEditingId(grua.id);
        setTipo(grua.tipo);
        setPlaca(grua.placa);
        setEmpresa(grua.empresa || '');
        setAsignadoAIdx(grua.asignado_a_vehiculo_idx ?? -1);
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
                <Text style={styles.title}>Grúas Involucradas ({gruas.length})</Text>
                <TouchableOpacity
                    style={styles.addButton}
                    onPress={() => {
                        resetForm();
                        setModalVisible(true);
                    }}
                >
                    <Text style={styles.addButtonText}>+ Agregar Grúa</Text>
                </TouchableOpacity>
            </View>

            {gruas.map((grua, index) => (
                <View key={grua.id} style={styles.gruaCard}>
                    <View style={styles.gruaHeader}>
                        <Text style={styles.gruaNumero}>Grúa {index + 1}</Text>
                        <View style={styles.gruaActions}>
                            <TouchableOpacity
                                onPress={() => handleEdit(grua)}
                                style={styles.editButton}
                            >
                                <Text style={styles.editButtonText}>✏️</Text>
                            </TouchableOpacity>
                            <TouchableOpacity
                                onPress={() => onRemove(grua.id)}
                                style={styles.removeButton}
                            >
                                <Text style={styles.removeButtonText}>🗑️</Text>
                            </TouchableOpacity>
                        </View>
                    </View>
                    <Text style={styles.gruaInfo}>{grua.tipo} - {grua.placa}</Text>
                    {grua.empresa && <Text style={styles.gruaInfo}>Empresa: {grua.empresa}</Text>}
                    <Text style={styles.gruaInfo}>Asignado a: {getVehiculoAsignado(grua.asignado_a_vehiculo_idx)}</Text>
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
                                {editingId ? 'Editar Grúa' : 'Agregar Grúa'}
                            </Text>

                            <Text style={styles.label}>Tipo *</Text>
                            <Picker
                                selectedValue={tipo}
                                onValueChange={setTipo}
                                style={styles.picker}
                            >
                                <Picker.Item label="Grúa" value="Grúa" />
                                <Picker.Item label="Grúa Liviana" value="Grúa Liviana" />
                                <Picker.Item label="Grúa Pesada" value="Grúa Pesada" />
                                <Picker.Item label="Plataforma" value="Plataforma" />
                            </Picker>

                            <Text style={styles.label}>Placa *</Text>
                            <TextInput
                                style={styles.input}
                                value={placa}
                                onChangeText={setPlaca}
                                placeholder="Ej: P-123ABC"
                                autoCapitalize="characters"
                            />

                            <Text style={styles.label}>Empresa</Text>
                            <TextInput
                                style={styles.input}
                                value={empresa}
                                onChangeText={setEmpresa}
                                placeholder="Nombre de la empresa"
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
    gruaCard: {
        backgroundColor: COLORS.white,
        padding: 12,
        borderRadius: 8,
        marginBottom: 8,
        borderWidth: 1,
        borderColor: COLORS.border,
    },
    gruaHeader: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 8,
    },
    gruaNumero: {
        fontSize: 14,
        fontWeight: '600',
        color: COLORS.primary,
    },
    gruaActions: {
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
    gruaInfo: {
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
