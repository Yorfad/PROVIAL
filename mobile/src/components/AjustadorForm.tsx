import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Controller, Control } from 'react-hook-form';
import { TextInput, Button } from 'react-native-paper';

interface AjustadorFormProps {
    control: Control<any>;
    index: number;
    onRemove: () => void;
}

export const AjustadorForm: React.FC<AjustadorFormProps> = ({ control, index, onRemove }) => {
    return (
        <View style={styles.container}>
            <View style={styles.header}>
                <Text style={styles.title}>Ajustador {index + 1}</Text>
                <Button onPress={onRemove} textColor="red">Eliminar</Button>
            </View>

            <Controller
                control={control}
                name={`ajustadores.${index}.empresa`}
                render={({ field: { onChange, value } }) => (
                    <TextInput label="Aseguradora" value={value} onChangeText={onChange} style={styles.input} />
                )}
            />
            <Controller
                control={control}
                name={`ajustadores.${index}.nombre`}
                render={({ field: { onChange, value } }) => (
                    <TextInput label="Nombre Ajustador" value={value} onChangeText={onChange} style={styles.input} />
                )}
            />

            <Text style={styles.subtitle}>Vehículo del Ajustador</Text>
            <Controller
                control={control}
                name={`ajustadores.${index}.vehiculo_placa`}
                render={({ field: { onChange, value } }) => (
                    <TextInput label="Placa" value={value} onChangeText={onChange} style={styles.input} />
                )}
            />
            <Controller
                control={control}
                name={`ajustadores.${index}.vehiculo_marca`}
                render={({ field: { onChange, value } }) => (
                    <TextInput label="Marca" value={value} onChangeText={onChange} style={styles.input} />
                )}
            />
        </View>
    );
};

const styles = StyleSheet.create({
    container: {
        padding: 10,
        borderWidth: 1,
        borderColor: '#ddd',
        borderRadius: 8,
        marginBottom: 10,
        backgroundColor: '#fff',
    },
    header: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 10,
    },
    title: {
        fontSize: 18,
        fontWeight: 'bold',
    },
    subtitle: {
        fontSize: 16,
        fontWeight: 'bold',
        marginTop: 5,
        marginBottom: 5,
        color: '#666',
    },
    input: {
        marginBottom: 10,
        backgroundColor: '#fff',
    },
});
