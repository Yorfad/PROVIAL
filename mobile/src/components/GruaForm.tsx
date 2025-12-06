import React from 'react';
import { View, Text, StyleSheet } from 'react-native';
import { Controller, Control } from 'react-hook-form';
import { TextInput, Button, Switch } from 'react-native-paper';

interface GruaFormProps {
    control: Control<any>;
    index: number;
    onRemove: () => void;
}

export const GruaForm: React.FC<GruaFormProps> = ({ control, index, onRemove }) => {
    return (
        <View style={styles.container}>
            <View style={styles.header}>
                <Text style={styles.title}>Grúa {index + 1}</Text>
                <Button onPress={onRemove} textColor="red">Eliminar</Button>
            </View>

            <Controller
                control={control}
                name={`gruas.${index}.empresa`}
                render={({ field: { onChange, value } }) => (
                    <TextInput label="Empresa" value={value} onChangeText={onChange} style={styles.input} />
                )}
            />
            <Controller
                control={control}
                name={`gruas.${index}.placa`}
                render={({ field: { onChange, value } }) => (
                    <TextInput label="Placa Grúa" value={value} onChangeText={onChange} style={styles.input} />
                )}
            />
            <Controller
                control={control}
                name={`gruas.${index}.tipo`}
                render={({ field: { onChange, value } }) => (
                    <TextInput label="Tipo (Plataforma, etc.)" value={value} onChangeText={onChange} style={styles.input} />
                )}
            />
            <Controller
                control={control}
                name={`gruas.${index}.piloto`}
                render={({ field: { onChange, value } }) => (
                    <TextInput label="Nombre Piloto" value={value} onChangeText={onChange} style={styles.input} />
                )}
            />

            <View style={styles.row}>
                <Text>¿Realizó traslado?</Text>
                <Controller
                    control={control}
                    name={`gruas.${index}.traslado`}
                    render={({ field: { onChange, value } }) => (
                        <Switch value={value} onValueChange={onChange} />
                    )}
                />
            </View>
            <Controller
                control={control}
                name={`gruas.${index}.traslado`}
                render={({ field: { value } }) => (
                    value ? (
                        <Controller
                            control={control}
                            name={`gruas.${index}.traslado_a`}
                            render={({ field: { onChange, value } }) => (
                                <TextInput label="Lugar de traslado" value={value} onChangeText={onChange} style={styles.input} />
                            )}
                        />
                    ) : <View />
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
    input: {
        marginBottom: 10,
        backgroundColor: '#fff',
    },
    row: {
        flexDirection: 'row',
        justifyContent: 'space-between',
        alignItems: 'center',
        marginBottom: 10,
    },
});
